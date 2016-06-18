//
//  NetworkOperation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 3/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

private let networkDelegateQueue: OperationQueue = {
    let queue = OperationQueue()
    return queue
}()

extension URLSessionConfiguration {
    /// Just like defaultSessionConfiguration, returns a
    /// newly created session configuration object, customised
    /// from the default to your requirements.
    class func resourceSessionConfiguration() -> URLSessionConfiguration {
        let config = `default`()
        // Eg we think 60s is too long a timeout time.
        config.timeoutIntervalForRequest = 20
        config.httpMaximumConnectionsPerHost = 2
        return config
    }
}

extension URLSession {
    /// Just like sharedSession, returns a shared singleton
    /// session object.
    class var resourceSharedSession: URLSession {
                
        // The session is stored in a nested struct because
        // you can't do a 'static let' singleton in a
        // class extension.
        struct Instance {
            // The singleton URL session, configured
            // to use our custom config and delegate.
            static let session = URLSession(
                configuration: URLSessionConfiguration.resourceSessionConfiguration(), delegate: ResourceSessionDelegate(), delegateQueue: networkDelegateQueue)
        }
        return Instance.session
    }
}

private let ResponseDelegateKey = "responseDelegateObject"

class NetworkOperation: Operation {
    
    private var _privateFinished: Bool = false
    override var isFinished: Bool {
        get {
            return _privateFinished
        }
        set (newAnswer) {
            willChangeValue(forKey: "isFinished")
            _privateFinished = newAnswer
            didChangeValue(forKey: "isFinished")
        }
    }
    
    var data: Data {
        if let data = _incomingData {
           return (NSData(data: data as Data) as Data)
        }
        return Data()
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
        if isCancelled {
            isFinished = true
            return
        }
        let session = URLSession.resourceSharedSession
        
        let completeURL: URL
        if let parameters = parameters {
            guard let urlComponents = URLComponents(string: self.url) else {
                isFinished = true
                //setError
                return
            }
            urlComponents.percentEncodedQuery = encodeParameters(parameters)
            completeURL = urlComponents.url ?? URL(string: self.url)!
        } else {
            completeURL = URL(string: self.url)!
        }
        
        let request = NSMutableURLRequest(url: completeURL)
        
        _ = headers?.map { request.setValue($1, forHTTPHeaderField: $0) }
        
        let dataTask = session.dataTask(with: request)
        dataTask.networkOperation = self
        //NSURLProtocol.setProperty(self, forKey: ResponseDelegateKey, inRequest: request)
        
        dataTask.resume()
    }
    
    private func encodeParameters (_ parameters: [String: String]) -> String {
        return (parameters.map { "\($0)=\($1)" }).joined(separator: "&")
    }
}

extension URLSessionTask {
    
    private struct AssociatedKeys {
        static var networkOperation = "networkOperationKey"
    }
    
    var networkOperation: NetworkOperation? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.networkOperation) as? NetworkOperation
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.networkOperation, newValue, .objc_ASSOCIATION_ASSIGN)
        }
    }
}

class ResourceSessionDelegate: NSObject, URLSessionDataDelegate {
    
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
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: NSError?) {
        print("invalid")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let operation = dataTask.networkOperation else {
        //guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        if operation.isCancelled {
            operation.isFinished = true
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
        data.enumerateBytes { pointer, range, stop in
            operation._incomingData!.append(pointer, length: range.length)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {

        guard let operation = task.networkOperation else {
        //guard let operation = NSURLProtocol.propertyForKey(ResponseDelegateKey, inRequest: request) as? NetworkOperation else {
            return
        }
        task.networkOperation = nil
        operation.error = error
        operation.isFinished = true
    }
}
