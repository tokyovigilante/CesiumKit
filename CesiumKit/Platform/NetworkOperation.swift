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
        let config = `default`
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
    
    fileprivate var _privateReady: Bool = false
    override var isReady: Bool {
    get {
            return _privateReady
        }
        set (newAnswer) {
            if newAnswer == _privateReady {
                return
            }
            willChangeValue(forKey: "isReady")
            _privateReady = newAnswer
            didChangeValue(forKey: "isReady")
        }
    }
    
    fileprivate var _privateExecuting: Bool = false
    override var isExecuting: Bool {
        get {
            return _privateExecuting
        }
        set (newAnswer) {
            if newAnswer == _privateExecuting {
                return
            }
            willChangeValue(forKey: "isExecuting")
            _privateExecuting = newAnswer
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    fileprivate var _privateFinished: Bool = false
    override var isFinished: Bool {
        get {
            return _privateFinished
        }
        set (newAnswer) {
            if newAnswer == _privateFinished {
                return
            }
            willChangeValue(forKey: "isFinished")
            _privateFinished = newAnswer
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isAsynchronous: Bool { return true }
    
    var data: Data {
        if let data = _incomingData {
           return (NSData(data: data as Data) as Data)
        }
        return Data()
    }
    
    fileprivate var _incomingData: Data? = nil
    
    var error: NSError?
    
    fileprivate let headers: [String: String]?
    
    fileprivate let parameters: [String: String]?
    
    fileprivate let url: String
    
    init(url: String, headers: [String: String]? = nil, parameters: [String: String]? = nil) {
        self.url = url
        self.headers = headers
        self.parameters = parameters
        super.init()
        isReady = true
    }
    
    func enqueue () {
        QueueManager.sharedInstance.networkQueue.addOperation(self)
    }
    
    override func start () {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        let session = URLSession.resourceSharedSession
        
        let completeURL: URL
        if let parameters = parameters {
            guard var urlComponents = URLComponents(string: self.url) else {
                isFinished = true
                //setError
                return
            }
            urlComponents.percentEncodedQuery = encodeParameters(parameters)
            completeURL = urlComponents.url ?? URL(string: self.url)!
        } else {
            completeURL = URL(string: self.url)!
        }
        
        var request = URLRequest(url: completeURL)

        _ = headers?.map { request.setValue($1, forHTTPHeaderField: $0) }
        
        let dataTask = session.dataTask(with: request)
        dataTask.networkOperation = self
        
        dataTask.resume()
    }
    
    fileprivate func encodeParameters (_ parameters: [String: String]) -> String {
        return (parameters.map { "\($0)=\($1)" }).joined(separator: "&")
    }
}

extension URLSessionTask {
    
    fileprivate struct AssociatedKeys {
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

class ResourceSessionDelegate: NSObject, URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let request = dataTask.originalRequest else {
            return
        }
        guard let operation = dataTask.networkOperation else {
            return
        }
        if operation.isCancelled {
            completionHandler(.cancel)
            operation.isFinished = true
            return
        }
        //Check the response code and react appropriately
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 404:
                logPrint(.error, "404 not found: \(request.url!)")
                operation.isFinished = true
                dataTask.cancel()
            default:
                completionHandler(.allow)
            }
        }
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        logPrint(.warning, "session invalid")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let operation = dataTask.networkOperation else {
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
                operation._incomingData = Data()
            } else {
                operation._incomingData = Data(capacity: capacity)
            }
        }
        logPrint(.debug, "Received \(data.count) bytes from " + (dataTask.originalRequest?.url?.absoluteString ?? "unknown"))
        //As the data may be discontiguous, you should use [NSData enumerateByteRangesUsingBlock:] to access it.
        data.enumerateBytes { (buffer, byteIndex, stop) in
            operation._incomingData?.append(buffer.baseAddress!, count: buffer.count)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let operation = task.networkOperation else {
            return
        }
        task.networkOperation = nil
        operation.error = error as NSError?
        operation.isFinished = true
    }

}
