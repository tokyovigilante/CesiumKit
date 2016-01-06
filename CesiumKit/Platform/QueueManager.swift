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
    
    let processorQueue: dispatch_queue_t = dispatch_queue_create("cesiumkit.processorQueue", DISPATCH_QUEUE_SERIAL)
    
    private let _networkQueue: dispatch_queue_t = dispatch_queue_create("cesiumkit.networkQueue", DISPATCH_QUEUE_CONCURRENT)
    
    private let _networkSemaphore: dispatch_semaphore_t = dispatch_semaphore_create(_maxConcurrentNetworkRequests)
        
    func networkQueue(rateLimit rateLimit: Bool = true) -> dispatch_queue_t {
        if rateLimit {
            dispatch_semaphore_wait(_networkSemaphore, DISPATCH_TIME_FOREVER)
            dispatch_semaphore_signal(_networkSemaphore)
        }
        return _networkQueue
    }
}