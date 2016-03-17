//
//  EventStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class EventStore: NSObject {

    static let sharedStore = EventStore()
    
    var allEvents:[Event] = [Event]()
    
    private override init() {
        super.init()
        
        let eventsArchive = NSKeyedUnarchiver.unarchiveObjectWithFile(self.eventArchivePath()) as? [Event]
        allEvents = eventsArchive ?? allEvents
    }
    
    func eventArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (documentFolder as NSString).stringByAppendingPathComponent("Events.archive")
    }
    
    func getEventsList() {
        SessionStore.sharedStore.getEventList(self)
    }
    
    func importEventsList(json:[String: AnyObject]) {
        
    }
}

extension EventStore: SessionStoreDelegate {
    func sessionStore(progress: Double, forDownloadTask task: NSURLSessionDownloadTask) {
        // notify caller
    }
    
    func sessionStoreCompleted(DownloadTask task: NSURLSessionDownloadTask, toURL location: NSURL, withDictionary result: [String : AnyObject]?) {
        print(result!)
    }
}