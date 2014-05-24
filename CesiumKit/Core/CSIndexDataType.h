//
//  CSIndexDataType.h
//  CesiumKit
//
//  Created by Ryan Walklin on 18/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

typedef enum IndexDatatype {
    /**
     * 0x1401.  8-bit unsigned byte corresponding to <code>UNSIGNED_BYTE</code> and the type
     * of an element in <code>Uint8Array</code>.
     *
     * @type {Number}
     * @constant
     */
    UNSIGNED_BYTE = 0x1401,
    
    /**
     * 0x1403.  16-bit unsigned short corresponding to <code>UNSIGNED_SHORT</code> and the type
     * of an element in <code>Uint16Array</code>.
     *
     * @type {Number}
     * @constant
     */
    UNSIGNED_SHORT = 0x1403,
    
    /**
     * 0x1405.  32-bit unsigned int corresponding to <code>UNSIGNED_INT</code> and the type
     * of an element in <code>Uint32Array</code>.
     *
     * @type {Number}
     * @constant
     */
    UNSIGNED_INT = 0x1405
} IndexDatatype;

