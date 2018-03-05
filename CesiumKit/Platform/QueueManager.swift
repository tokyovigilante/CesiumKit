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

    let processorQueue: DispatchQueue

    let networkQueue: OperationQueue

    let upsampleQueue: DispatchQueue

    let resourceLoadQueue: DispatchQueue

    let fontAtlasQueue: DispatchQueue

    init () {
        processorQueue = DispatchQueue(label: "com.testtoast.CesiumKit.processorQueue")
        upsampleQueue = DispatchQueue(label: "com.testtoast.CesiumKit.upsampleQueue")
        resourceLoadQueue = DispatchQueue(label: "com.testtoast.CesiumKit.textureLoadQueue")
        fontAtlasQueue = DispatchQueue(label: "com.testtoast.CesiumKit.fontAtlasQueue")

        networkQueue = OperationQueue()
        networkQueue.qualityOfService = .utility
        networkQueue.isSuspended = false
        networkQueue.maxConcurrentOperationCount = _maxConcurrentNetworkRequests
    }


}
