//
//  QueueManager.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

private let _maxConcurrentNetworkRequests = 12

class QueueManager {
    
    static let sharedInstance = QueueManager()
    
    let processorQueue: dispatch_queue_t
    
    let networkQueue: NSOperationQueue
    
    let upsampleQueue: dispatch_queue_t
    
    init () {
        processorQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        upsampleQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        //processorQueue = NSOperationQueue()
        //processorQueue.qualityOfService = .Utility
        
        networkQueue = NSOperationQueue()
        networkQueue.qualityOfService = .Utility
        networkQueue.suspended = false
        networkQueue.maxConcurrentOperationCount = _maxConcurrentNetworkRequests
    }
    

}