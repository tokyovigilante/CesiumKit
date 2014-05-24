//
//  CSPassState.h
//  CesiumKit
//
//  Created by Ryan Walklin on 6/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSContext, CSFrameBuffer;

/**
 * The state for a particular rendering pass.  This is used to supplement the state
 * in a command being executed.
 *
 * @alias PassState
 * @constructor
 *
 * @see DrawCommand
 * @see ClearCommand
 */

@interface CSPassState : NSObject

-(id)initWithContext:(CSContext *)context;

/**
 * The context used to execute commands for this pass.
 *
 * @type {Context}
 */
@property (weak) CSContext *context;

/**
 * The framebuffer to render to.  This framebuffer is used unless a {@link DrawCommand}
 * or {@link ClearCommand} explicitly define a framebuffer, which is used for off-screen
 * rendering.
 *
 * @type {Framebuffer}
 * @default undefined
 */
@property (weak) CSFrameBuffer *frameBuffer;

/**
 * When defined, this overrides the blending property of a {@link DrawCommand}'s render state.
 * This is used to, for example, to allow the renderer to turn off blending during the picking pass.
 * <p>
 * When this is <code>undefined</code>, the {@link DrawCommand}'s property is used.
 * </p>
 *
 * @type {Boolean}
 * @default undefined
 */
#warning handle undefined
@property BOOL blendingEnabled;

@property id scissorTest;

@end
