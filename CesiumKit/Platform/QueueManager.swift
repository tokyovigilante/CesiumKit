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
    
    let resourceLoadQueue: dispatch_queue_t
    
    let fontAtlasQueue: dispatch_queue_t
    
    init () {
        processorQueue = dispatch_queue_create("com.testtoast.CesiumKit.processorQueue", DISPATCH_QUEUE_SERIAL)
        upsampleQueue = dispatch_queue_create("com.testtoast.CesiumKit.upsampleQueue", DISPATCH_QUEUE_SERIAL)
        resourceLoadQueue = dispatch_queue_create("com.testtoast.CesiumKit.textureLoadQueue", DISPATCH_QUEUE_SERIAL)
        fontAtlasQueue = dispatch_queue_create("com.testtoast.CesiumKit.fontAtlasQueue", DISPATCH_QUEUE_SERIAL)

        networkQueue = NSOperationQueue()
        networkQueue.qualityOfService = .Utility
        networkQueue.suspended = false
        networkQueue.maxConcurrentOperationCount = _maxConcurrentNetworkRequests
    }
    

}