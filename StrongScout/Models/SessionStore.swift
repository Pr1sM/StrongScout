//
//  SessionStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

enum RequestType: Int {
    case None = 0, EventList, ScheduleList
    
    var url : String {
        switch(self) {
        case .EventList:
            return "https://frc-api.firstinspires.org/v2.0/2016/events?exludeDistrict=false"
        case .ScheduleList:
            return "https://frc-api.firstinspires.org/v2.0/2016/schedule/\(ScheduleStore.sharedStore.currentSchedule!)?tournamentLevel=qual"
        default:
            return ""
        }
    }
}

protocol SessionStoreDelegate: class {
    func sessionStoreCompleted(request:RequestType, withData data:NSData?, andError error:NSError?)
    func sessionStoreCanceled(request:RequestType)
    func sessionStore(progress:Double, forRequest request:RequestType)
}

class SessionStore: NSObject {
    static let sharedStore:SessionStore = SessionStore()
    
    private weak var delegate:SessionStoreDelegate?
    
    private var sessionConfig:NSURLSessionConfiguration!
    private var currentRequest:RequestType = .None
    private var currentTask:NSURLSessionDownloadTask? = nil
    
    private override init() {
        super.init()
        
        sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        sessionConfig.HTTPAdditionalHeaders = ["Accept":"application/json", "Authorization":"Basic UHJpc006MTFEQTAwRDAtNUQ4Ri00RUUxLTg2OTItNDI4MEI4RENBQjFB"]
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        sessionConfig.timeoutIntervalForRequest = 30.0
    }
    
//    func getEventList(delegate:SessionStoreDelegate?) {
//        self.delegate = delegate
//        let url = NSURL(string: "https://frc-api.firstinspires.org/v2.0/2016/events?exludeDistrict=false")!
//        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
//        let request = NSMutableURLRequest(URL: url)
//        let task = session.downloadTaskWithRequest(request)
//        
//        task.resume()
//    }
    
    func runRequest(type:RequestType, withDelegate delegate:SessionStoreDelegate?) {
        guard currentTask == nil else { return }
        self.delegate = delegate
        self.currentRequest = type
        let url = NSURL(string: self.currentRequest.url)!
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: url)
        currentTask = session.downloadTaskWithRequest(request)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(5000 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
//            self.currentTask!.resume()
//        })
        currentTask!.resume()
    }
    
    func cancelRequest() {
        guard currentTask != nil else { return }
        currentTask!.cancel()
    }
    
    private func sessionCompleteCleanup(data:NSData?, error:NSError?) {
        if let d = delegate {
            d.sessionStoreCompleted(self.currentRequest, withData: data, andError: error)
        }
        delegate = nil
        self.currentRequest = .None
        self.currentTask = nil
    }
}

extension SessionStore: NSURLSessionDelegate {
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        if let error = error {
            print("\(session) did become invalid with error: \(error)")
        }
        if let d = delegate {
            d.sessionStoreCanceled(self.currentRequest)
        }
        delegate = nil
        self.currentRequest = .None
        self.currentTask = nil
    }
}

extension SessionStore: NSURLSessionTaskDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("\(session), \(task) did complete with error \(error)")
        if error == nil {
            self.sessionCompleteCleanup(nil, error: nil)
        } else if error!.userInfo[NSLocalizedDescriptionKey] as! String == "cancelled" {
            if let d = delegate {
                d.sessionStoreCanceled(self.currentRequest)
            }
            delegate = nil
            self.currentRequest = .None
            self.currentTask = nil
        } else {
            self.sessionCompleteCleanup(nil, error: error)
        }
    }
}

extension SessionStore: NSURLSessionDownloadDelegate {
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        if let d = delegate {
            d.sessionStore(progress, forRequest: self.currentRequest)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let data = NSData(contentsOfURL: location)
        self.sessionCompleteCleanup(data, error: nil)
    }
}
