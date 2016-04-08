//
//  NetworkOperation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false


extension NSURLSessionConfiguration {
    /// Just like defaultSessionConfiguration, returns a
    /// newly created session configuration object, customised
    /// from the default to your requirements.
    class func resourceSessionConfiguration() -> NSURLSessionConfiguration {
        let config = defaultSessionConfiguration()
        // Eg we think 60s is too long a timeout time.
        //config.timeoutIntervalForRequest = 20
        // Some headers that are common to all reqeuests.
        // Eg my backend needs to be explicitly asked for JSON.
        //config.HTTPAdditionalHeaders = ["MyResponseType": "JSON"]
        // Eg we want to use pipelining.
        //config.HTTPShouldUsePipelining = true
    /*configuration.HTTPAdditionalHeaders = ["Accept": "application/json",*/

        return config
    }
}

extension NSURLSession {
    /// Just like sharedSession, returns a shared singleton
    /// session object.
    class var resourceSharedSession: NSURLSession {
        // The session is stored in a nested struct because
        // you can't do a 'static let' singleton in a
        // class extension.
        struct Instance {
            // The singleton URL session, configured
            // to use our custom config and delegate.
            static let session = NSURLSession(
                configuration: NSURLSessionConfiguration.resourceSessionConfiguration(), delegate: ResourceSessionDelegate(), delegateQueue: nil)
        }
        return Instance.session
    }
}

// delegate for receiving data

let ResponseDelegateKey = "ResponseDelegateKey"

class NetworkOperation: NSObject /*: NSOperation*/{
    
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
    
    private let completionBlock: (NSData, NSError?) -> ()
    
    private let headers: [String: String]?
    
    private let parameters: [String: String]?
    
    private let url: String
    
    init(url: String, headers: [String: String]? = nil, parameters: [String: String]? = nil, completionBlock: ((NSData, NSError?) -> ())) {
        self.url = url
        self.headers = headers
        self.parameters = parameters
        self.completionBlock = completionBlock
    }
    
    func start () {
        /*if cancelled {
         finished = true
         return
         }*/
        let session = NSURLSession.resourceSharedSession
        
        let completeURL: NSURL
        if let parameters = parameters {
            guard let urlComponents = NSURLComponents(string: self.url) else {
                /*if cancelled {
                 finished = true
                 setError
                 return
                 }*/
                return
            }
            urlComponents.percentEncodedQuery = encodeParameters(parameters)
            completeURL = urlComponents.URL ?? NSURL(string: self.url)!
        } else {
            completeURL = NSURL(string: self.url)!
        }
        
        let request = NSMutableURLRequest(URL: completeURL)
        
        NSURLProtocol.setProperty(self, forKey: "ResponseDelegateKey", inRequest: request)
        
        _ = headers?.map { request.setValue($1, forHTTPHeaderField: $0) }
        
        let dataTask = session.dataTaskWithRequest(request)
        dataTask.resume()
    }
    
    func executeCompletionBlock (error: NSError?) {
        completionBlock(incomingData, error)
    }
    
    private func encodeParameters (parameters: [String: String]) -> String {
        return (parameters.map { "\($0)=\($1)" }).joinWithSeparator("&")
    }
    
}

class ResourceSessionDelegate: NSObject, NSURLSessionDataDelegate {
    
    func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        /*if cancelled {
         finished = true
         sessionTask?.cancel()
         return
         }*/
        //Check the response code and react appropriately
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.PerformDefaultHandling, nil)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("invalid")
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let request = dataTask.originalRequest else {
            return
        }
        guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        /*if cancelled {
         finished = true
         sessionTask?.cancel()
         return
         }*/
        //As the data may be discontiguous, you should use [NSData enumerateByteRangesUsingBlock:] to access it.
        operation.incomingData.appendData(data)
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let request = task.originalRequest else {
            return
        }
        guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        operation.executeCompletionBlock(error)
    }
}
