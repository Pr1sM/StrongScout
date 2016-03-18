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
    
    var requestProgressUpdate:Optional<(Double) -> ()> = nil
    var requestCompletion:Optional<(Bool) -> ()> = nil
    
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
        
        schedule = NSKeyedUnarchiver.unarchiveObjectWithFile(scheduleArchivePath()) as? [ScheduleItem] ?? schedule
    }
    
    func scheduleArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (documentFolder as NSString).stringByAppendingPathComponent("Schedule.archive")
    }
    
    func getScheduleList(inProgress:Optional<(Double) -> ()>, completion:Optional<(Bool) -> ()>) {
        guard currentSchedule != nil else { return }
        requestProgressUpdate = inProgress
        requestCompletion = completion
        SessionStore.sharedStore.runRequest(.ScheduleList, withDelegate: self)
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
        print("Imported \(schedule.count) Schedule Items")
    }
}

extension ScheduleStore: SessionStoreDelegate {
    func sessionStore(progress: Double, forDownloadTask task: NSURLSessionDownloadTask) {
        requestProgressUpdate?(progress)
    }
    
    func sessionStoreCompleted(request: RequestType, withData data: NSData?) {
        requestCompletion?(true)
        if request == .ScheduleList {
            importSchedule(data)
        }
    }
}
