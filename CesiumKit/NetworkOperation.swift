//
//  NetworkOperation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

private let networkDelegateQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    return queue
}()

extension NSURLSessionConfiguration {
    /// Just like defaultSessionConfiguration, returns a
    /// newly created session configuration object, customised
    /// from the default to your requirements.
    class func resourceSessionConfiguration() -> NSURLSessionConfiguration {
        let config = defaultSessionConfiguration()
        // Eg we think 60s is too long a timeout time.
        config.timeoutIntervalForRequest = 20
        config.HTTPShouldUsePipelining = true
        config.HTTPMaximumConnectionsPerHost = 4
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
                configuration: NSURLSessionConfiguration.resourceSessionConfiguration(), delegate: ResourceSessionDelegate(), delegateQueue: networkDelegateQueue)
        }
        return Instance.session
    }
}

private let ResponseDelegateKey = "responseDelegateObject"

class NetworkOperation: NSOperation {
    
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
    
    var data: NSData {
        if let data = _incomingData {
           return NSData(data: data)
        }
        return NSData()
    }
    
    private var _incomingData: NSMutableData? = nil
    
    var error: NSError?
    
    private let headers: [String: String]?
    
    private let parameters: [String: String]?
    
    private let url: String
    
    init(url: String, headers: [String: String]? = nil, parameters: [String: String]? = nil) {
        self.url = url
        self.headers = headers
        self.parameters = parameters
        super.init()
    }
    
    func enqueue () {
        QueueManager.sharedInstance.networkQueue.addOperation(self)
    }
    
    override func start () {
        if cancelled {
            finished = true
            return
        }
        let session = NSURLSession.resourceSharedSession
        
        let completeURL: NSURL
        if let parameters = parameters {
            guard let urlComponents = NSURLComponents(string: self.url) else {
                finished = true
                //setError
                return
            }
            urlComponents.percentEncodedQuery = encodeParameters(parameters)
            completeURL = urlComponents.URL ?? NSURL(string: self.url)!
        } else {
            completeURL = NSURL(string: self.url)!
        }
        
        let request = NSMutableURLRequest(URL: completeURL)
        
        _ = headers?.map { request.setValue($1, forHTTPHeaderField: $0) }
        
        let dataTask = session.dataTaskWithRequest(request)
        dataTask.networkOperation = self
        //NSURLProtocol.setProperty(self, forKey: ResponseDelegateKey, inRequest: request)
        
        dataTask.resume()
    }
    
    private func encodeParameters (parameters: [String: String]) -> String {
        return (parameters.map { "\($0)=\($1)" }).joinWithSeparator("&")
    }
}

extension NSURLSessionTask {
    
    private struct AssociatedKeys {
        static var networkOperation = "networkOperationKey"
    }
    
    var networkOperation: NetworkOperation? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.networkOperation) as? NetworkOperation
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.networkOperation, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

class ResourceSessionDelegate: NSObject, NSURLSessionDataDelegate {
    
    /*func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        guard let request = dataTask.originalRequest else {
            return
        }
        guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        if operation.cancelled {
            completionHandler(.Cancel)
            operation.finished = true
            return
        }
        //Check the response code and react appropriately
        completionHandler(.Allow)
    }*/
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.PerformDefaultHandling, nil)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("invalid")
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        guard let operation = dataTask.networkOperation else {
        //guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        if operation.cancelled {
            operation.finished = true
            dataTask.cancel()
            return
        }
        
        if operation._incomingData == nil {
            var capacity = -1

            if let response = dataTask.response {
                capacity = Int(response.expectedContentLength)
            }
            if capacity == -1 {
                operation._incomingData = NSMutableData()
            } else {
                operation._incomingData = NSMutableData(capacity: capacity)
            }
        }
        //As the data may be discontiguous, you should use [NSData enumerateByteRangesUsingBlock:] to access it.
        data.enumerateByteRangesUsingBlock { pointer, range, stop in
            operation._incomingData!.appendBytes(pointer, length: range.length)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {

        guard let operation = task.networkOperation else {
        //guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        task.networkOperation = nil
        operation.error = error
        operation.finished = true
    }
}
