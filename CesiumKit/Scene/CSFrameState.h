//
//  CSFrameState.h
//  CesiumKit
//
//  Created by Ryan Walklin on 5/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSWebMercatorProjection, CSCamera, CSCullingVolume, CSOccluder;

@interface CSFrameState : NSObject

@property BOOL sceneIs3D;
@property UInt32 frameNumber;
@property NSTimeInterval time;
@property (nonatomic) CSWebMercatorProjection *projection; // 2D only
@property (nonatomic) CSCamera *camera;
@property (nonatomic) CSCullingVolume *cullingVolume;
@property (nonatomic) CSOccluder *occluder;
/**
 * <code>true</code> if the primitive should update for a render pass, <code>false</code> otherwise.
 * @type {Boolean}
 * @default false
 */
@property BOOL renderPass;

/**
 * <code>true</code> if the primitive should update for a picking pass, <code>false</code> otherwise.
 * @type {Boolean}
 * @default false
 */
@property BOOL pickPass;

/**
 * An array of functions to be called at the end of the frame.  This array
 * will be cleared after each frame.
 * <p>
 * This allows queueing up events in <code>update</code> functions and
 * firing them at a time when the subscribers are free to change the
 * scene state, e.g., manipulate the camera, instead of firing events
 * directly in <code>update</code> functions.
 * </p>
 *
 * @type {Array}
 *
 * @example
 * frameState.afterRender.push(function() {
 *   // take some action, raise an event, etc.
 * });
 */
@property NSMutableArray *afterRender;

@end
