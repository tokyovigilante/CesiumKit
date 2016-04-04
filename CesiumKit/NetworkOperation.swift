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
    override var finished: Bool {
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
        super.init()
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        
        sessionTask = localURLSession.dataTask(with: request)
        sessionTask!.resume()
    }

    func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        //Check the response code and react appropriately
        completionHandler(.allow)
    }
    
    func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        incomingData.append(data)
    }
    
    func urlSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        if NSThread.isMainThread() { print("Main Thread!") }
        if error != nil {
            print("Failed to receive response: \(error)")
            finished = true
            return
        }
        processData()
        finished = true
    }
    
    func processData() {
        
    }
    
}