//
//  NetworkOperation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

class NetworkOperation: NSOperation, NSURLSessionTaskDelegate {
    
    private var _privateFinished: Bool = false
    override var isFinished: Bool {
        get {
            return _privateFinished
        }
        set (newAnswer) {
            willChangeValueForKey("isFinished")
            _privateFinished = newAnswer
            didChangeValueForKey("isFinished")
        }
    }
    
    let incomingData = NSMutableData()
    
    var sessionTask: NSURLSessionTask?
    
    var localURLSession: NSURLSession {
        return NSURLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
    }
    
    var localConfig: NSURLSessionConfiguration {
        return NSURLSessionConfiguration.defaultSessionConfiguration()
    }
    
    let url: NSURL
    
    init(url: NSURL) {
        self.url = url
        self.init()
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        
        sessionTask = localURLSession.dataTaskWithRequest(request)
        sessionTask!.resume()
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        //Check the response code and react appropriately
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        incomingData.appendData(data)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        if NSThread.isMainThread() { log("Main Thread!") }
        if error != nil {
            log("Failed to receive response: \(error)")
            finished = true
            return
        }
        processData()
        finished = true
    }
    
}