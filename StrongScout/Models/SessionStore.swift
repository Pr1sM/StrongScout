//
//  SessionStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

@objc
protocol SessionStoreDelegate {
    func sessionStoreCompleted(DownloadTask task:NSURLSessionDownloadTask, toURL location:NSURL, withDictionary result:[String:AnyObject]?)
    func sessionStore(progress:Double, forDownloadTask task:NSURLSessionDownloadTask)
}

class SessionStore: NSObject {
    static let sharedStore:SessionStore = SessionStore()
    
    private weak var delegate:SessionStoreDelegate?
    
    private var sessionConfig:NSURLSessionConfiguration!
    
    private override init() {
        super.init()
        
        sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        sessionConfig.HTTPAdditionalHeaders = ["Accept":"application/json",
            "Authorization":"Basic bmNrczNUMDUyNToxODlCOEMzNi04MDJELTQ4RjYtQUFBMS1COTFDOEZGMjYwNjg="]
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        sessionConfig.timeoutIntervalForRequest = 30.0
    }
    
    func convertJSONToDictionary(data:NSData?) -> [String:AnyObject]? {
        if let d = data {
            return try? NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [String: AnyObject]
        }
        
        return nil
    }
    
    func getEventList(delegate:SessionStoreDelegate?) {
        self.delegate = delegate
        let url = NSURL(string: "https://frc-api.firstinspires.org/v2.0/2016/events?exludeDistrict=false")!
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: url)
        let task = session.downloadTaskWithRequest(request)
        
        task.resume()
    }
}

extension SessionStore: NSURLSessionDelegate {
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        if let error = error {
            print("\(session) did become invalid with error: \(error)")
        }
    }
}

extension SessionStore: NSURLSessionTaskDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("\(session), \(task) did complete with error \(error)")
    }
}

extension SessionStore: NSURLSessionDownloadDelegate {
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        if let d = delegate {
            d.sessionStore(progress, forDownloadTask: downloadTask)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let d = delegate {
            let data = NSData(contentsOfURL: location)
            let dictionary = convertJSONToDictionary(data)
            d.sessionStoreCompleted(DownloadTask: downloadTask, toURL: location, withDictionary:dictionary)
        }
    }
}
