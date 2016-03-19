//
//  ScheduleStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/18/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class ScheduleStore: NSObject {
    
    static let sharedStore:ScheduleStore = ScheduleStore()
    
    var requestProgressUpdate:((Double) -> ())? = nil
    var requestCompletion:((NSError?) -> ())? = nil
    var requestCanceled:(() -> ())? = nil
    
    var schedule:[ScheduleItem] = []
    
    var currentSchedule:String? {
        didSet {
            if currentSchedule == nil {
                NSUserDefaults.standardUserDefaults().setNilValueForKey("StrongScout.currentSchedule")
            } else {
                NSUserDefaults.standardUserDefaults().setObject(currentSchedule, forKey: "StrongScout.currentSchedule")
            }
        }
    }

    private override init() {
        super.init()
        
        currentSchedule = NSUserDefaults.standardUserDefaults().objectForKey("StrongScout.currentSchedule") as? String
        
        let path = self.scheduleArchivePath()
        schedule = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [ScheduleItem] ?? schedule
    }
    
    func scheduleArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (documentFolder as NSString).stringByAppendingPathComponent("Schedule.archive")
    }
    
    func saveSchedule() -> Bool {
        let path = self.scheduleArchivePath()
        return NSKeyedArchiver.archiveRootObject(schedule, toFile: path)
    }
    
    func getScheduleList(inProgress:((Double) -> ())?, completion:((NSError?) -> ())?) {
        guard currentSchedule != nil else { return }
        requestProgressUpdate = inProgress
        requestCompletion = completion
        SessionStore.sharedStore.runRequest(.ScheduleList, withDelegate: self)
    }
    
    func cancelRequest(handler:(() -> ())?) {
        requestCanceled = handler
        SessionStore.sharedStore.cancelRequest()
    }
    
    func importSchedule(data:NSData?) {
        guard let d = data else { return }
        
        let json = JSON(data: d)
        schedule.removeAll()
        print("Received \(json["Schedule"].count) Schedule Items")
        for (_,subJSON):(String,JSON) in json["Schedule"] {
            let scheduleItem = ScheduleItem(json: subJSON)
            schedule.append(scheduleItem)
        }
        schedule.sortInPlace({ $0.startTime!.compare($1.startTime!) == .OrderedAscending })
        print("Imported \(schedule.count) Schedule Items")
        self.saveSchedule()
    }
    
    func buildMatchListForGroup(group:Int) {
        guard 1...7 ~= group && group != 4 else { return }
        var stationCode = (group & 4) > 0 ? "Blue" : "Red"
        stationCode += "\(group & 3)"
        var teamList:[MatchQueueData] = [MatchQueueData]()
        for item in schedule {
            let m = item.matchNumber
            for t in item.teams {
                if t.station == stationCode {
                    let data = MatchQueueData(match: m, team: t.teamNumber, alliance: (group & 4) > 0 ? .blue : .red)
                    teamList.append(data)
                }
            }
        }
        MatchStore.sharedStore.createMatchQueueFromMatchData(teamList)
    }
}

extension ScheduleStore: SessionStoreDelegate {
    func sessionStore(progress: Double, forRequest request: RequestType) {
        if request == .ScheduleList {
            requestProgressUpdate?(progress)
        }
    }
    
    func sessionStoreCompleted(request: RequestType, withData data: NSData?, andError error: NSError?) {
        if request == .ScheduleList {
            requestCompletion?(error)
            importSchedule(data)
        }
        requestCompletion = nil
        requestProgressUpdate = nil
        requestCanceled = nil
    }
    
    func sessionStoreCanceled(request: RequestType) {
        if request == .ScheduleList {
            requestCanceled?()
        }
        requestCompletion = nil
        requestProgressUpdate = nil
        requestCanceled = nil
    }
}
