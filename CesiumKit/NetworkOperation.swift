//
//  NetworkOperation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

class NetworkOperation: /*NSOperation*/NSObject, NSURLSessionDataDelegate {
    
    private var _privateFinished: Bool = false
    /*override*/ var finished: Bool {
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
    
    var localURLSession: NSURLSession!/* {
        return NSURLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
    }*/
    
    var localConfig: NSURLSessionConfiguration {
        var configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.testtoast.cesiumkit")
        /*configuration.HTTPAdditionalHeaders = ["Accept": "application/json",
            //"Accept-Language": "en",
            //"Authorization": authString,
            //"User-Agent": userAgentString
        ]*/
        return configuration
    }
    
    let url: NSURL
    
    init(url: NSURL) {
        self.url = url
        super.init()
        localURLSession = NSURLSession(configuration: localConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    /*override*/func start() {
        /*if cancelled {
            finished = true
            return
        }*/
        let request = NSMutableURLRequest(URL: NSURL(string: "http://google.com")!)//self.url)
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        sessionTask = localURLSession.dataTaskWithRequest(request)
        
        sessionTask?.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print(challenge.proposedCredential?.debugDescription)
        print(challenge.sender.debugDescription)
        completionHandler(.UseCredential, challenge.proposedCredential)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print(challenge.proposedCredential?.debugDescription)
        print(challenge.debugDescription)
        completionHandler(.UseCredential, challenge.proposedCredential)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("invalid")
    }
    
    func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        /*if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }*/
        //Check the response code and react appropriately
        completionHandler(.Allow)
    }
    
    func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        /*if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }*/
        //As the data may be discontiguous, you should use [NSData enumerateByteRangesUsingBlock:] to access it.
        incomingData.appendData(data)
    }
    
    func urlSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        /*if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }*/
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
        print("done")
    }
    
    deinit {
        print("butts")
    }
    
}