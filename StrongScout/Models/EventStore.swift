//
//  EventStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

enum EventFilterType {
    case None, Type, Country
}

class EventStore: NSObject {

    static let sharedStore = EventStore()
    
    var allEvents:[Event] = [Event]()
    var eventsByType:[[Event]] = [[Event]]()
    var selectedEvent:Event? {
        didSet {
            if selectedEvent == nil {
                NSUserDefaults.standardUserDefaults().setNilValueForKey("StrongScout.selectedEvent")
            } else {
                let data = NSKeyedArchiver.archivedDataWithRootObject(selectedEvent!)
                NSUserDefaults.standardUserDefaults().setValue(data, forKey: "StrongScout.selectedEvent")
            }
        }
    }
    
    var requestProgressUpdate:((Double) -> ())? = nil
    var requestCompletion:((NSError?) -> ())? = nil
    var requestCanceled:(() -> ())? = nil
    
    
    private override init() {
        super.init()
        
        let eventsArchive = NSKeyedUnarchiver.unarchiveObjectWithFile(self.eventArchivePath()) as? [Event]
        allEvents = eventsArchive ?? allEvents
        let data = NSUserDefaults.standardUserDefaults().valueForKey("StrongScout.selectedEvent") as? NSData
        if data != nil {
            self.selectedEvent = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? Event
        }
        
        createEventByType()
    }
    
    func saveEventList() -> Bool {
        let path = eventArchivePath()
        return NSKeyedArchiver.archiveRootObject(allEvents, toFile: path)
    }
    
    func eventArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (documentFolder as NSString).stringByAppendingPathComponent("Events.archive")
    }
    
    func getEventsList(inProgress:((Double) -> ())?, completion:((NSError?) -> ())?) {
        requestProgressUpdate = inProgress
        requestCompletion = completion
        SessionStore.sharedStore.runRequest(.EventList, withDelegate: self)
    }
    
    func cancelRequest(handler:(() -> ())?) {
        requestCanceled = handler
        SessionStore.sharedStore.cancelRequest()
    }
    
    func importEventsList(data:NSData?) {
        guard let d = data else { return }
        
        let json = JSON(data: d)
        if json["eventCount"].intValue == 0 {
            print("Error in receiving events: \(json[0].error)")
            return
        }
        print("Receieved \(json["eventCount"].intValue) events")
        allEvents.removeAll()
        for (_,subJson):(String,JSON) in json["Events"] {
            let event = Event(json: subJson)
            allEvents.append(event)
        }
        createEventByType()
        saveEventList()
    }
    
    func filterEventsBy(type:EventFilterType, compareValue:AnyObject) -> [Event] {
        let cVal = compareValue as! String
        let filteredEvents = allEvents.filter({event in event.type == cVal})
        print("There are only \(filteredEvents.count) in the filtered Array")
        return filteredEvents
    }
    
    func createEventByType() {
        if allEvents.count < 0 {
            return
        }
        
        var regionals = [Event]()
        var districtEvent = [Event]()
        var districtChampionship = [Event]()
        var championshipSubdivision = [Event]()
        var championshipDivision = [Event]()
        var championship = [Event]()
        var offseason = [Event]()
        
        for event in allEvents {
            if event.type == "Regional" {
                regionals.append(event)
            } else if event.type == "DistrictEvent" {
                districtEvent.append(event)
            } else if event.type == "DistrictChampionship" {
                districtChampionship.append(event)
            } else if event.type == "ChampionshipSubdivision" {
                championshipSubdivision.append(event)
            } else if event.type == "ChampionshipDivision" {
                championshipDivision.append(event)
            } else if event.type == "Championship" {
                championship.append(event)
            } else if event.type == "OffSeason" {
                offseason.append(event)
            }
        }
        
        regionals.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        districtEvent.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        districtChampionship.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        championshipSubdivision.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        championshipDivision.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        championship.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        offseason.sortInPlace({$0.dateStart!.compare($1.dateStart!) == .OrderedAscending})
        
        self.eventsByType = [regionals,
                             districtEvent,
                             districtChampionship,
                             championshipSubdivision,
                             championshipDivision,
                             championship,
                             offseason]
        
        print("\(eventsByType.count)")
    }
    
    func eventHeaderForSection(section:Int) -> String {
        return section == 0 ? "Regional"                 :
               section == 1 ? "District Event"           :
               section == 2 ? "District Championship"    :
               section == 3 ? "Championship Subdivision" :
               section == 4 ? "Championship Division"    :
               section == 5 ? "Championship"             :
               section == 6 ? "OffSeason"                : ""
    }
}

extension EventStore: SessionStoreDelegate {
    func sessionStore(progress: Double, forRequest request: RequestType) {
        if request == .EventList {
            requestProgressUpdate?(progress)
        }
    }
    
    func sessionStoreCompleted(request: RequestType, withData data: NSData?, andError error: NSError?) {
        if request == .EventList {
            requestCompletion?(error)
            if let d = data {
                importEventsList(d)
            }
        }
        requestCanceled = nil
        requestCompletion = nil
        requestProgressUpdate = nil
    }
    
    func sessionStoreCanceled(request: RequestType) {
        if request == .EventList {
            requestCanceled?()
        }
        requestCanceled = nil
        requestCompletion = nil
        requestProgressUpdate = nil
    }
}