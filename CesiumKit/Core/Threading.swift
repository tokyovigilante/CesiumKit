//
//  Threading.swift
//  SwiftThreading
//
//  Created by Joshua Smith on 7/5/14.
//  Copyright (c) 2014 iJoshSmith. All rights reserved.
//

//
// This code has been tested against Xcode 6 Beta 5.
//

import Foundation

public enum AsyncResult<R> {
    
    /*
    Describes a normal outcome: the computation was carried through to its completion and
    yielded a result.
    */
    case Success(@autoclosure() -> R)
    
    /*
    Describes an error condition: the computation failed.
    */
    case Failure(String)
    
    public init(_ value: R) {
        self = .Success(value)
    }
    
    public init(_ string: String) {
        self = .Failure(string)
    }
    
    public var failed: Bool {
        switch self {
        case .Failure(let string):
            return true
            
        default:
            return false
        }
    }
    
    public var value: R? {
        switch self {
        case .Success(let value):
            return value()
            
        default:
            return nil
        }
    }
    
    public var error: String? {
        switch self {
        case .Failure(let string):
            return string
            
        default:
            return nil
        }
    }
    
    public static func perform<R> (
        backgroundClosure: () -> AsyncResult<R>,
        asyncClosures: (success: (result: R) -> (), failure: (error: String) -> ()))
    {
        dispatch_async(queue) {
            let result = backgroundClosure()
            
            if result.failed {
                dispatch_async(dispatch_get_main_queue(), { asyncClosures.failure(error: result.error!) })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { asyncClosures.success(result: result.value!) })
            }
        }
    }
}

//infix operator ~> {}

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
*/
/*func ~> (
    backgroundClosure: () -> (),
    mainClosure:       () -> ())
{
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), mainClosure)
    }
}*/

/**
Executes the lefthand closure on a background thread and,
upon completion, the success or failure closures on the main thread.
Passes the background closure's output to the main closures.
*/
/*func ~> <R> (
    backgroundClosure: () -> AsyncResult<R>,
    asyncClosures: (success: (result: R) -> (), failure: (error: String) -> ()))
{
    dispatch_async(queue) {
        let result = backgroundClosure()
        
        if result.failed {
            dispatch_async(dispatch_get_main_queue(), { asyncClosures.failure(error: result.error!) })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), { asyncClosures.success(result: result.value!) })
        }
    }
}*/

/** Serial dispatch queue used by the ~> operator. */
private let queue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_CONCURRENT)
