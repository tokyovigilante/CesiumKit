//
//  SIMDType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import simd

protocol SIMDType {}

extension Float: SIMDType {}
extension float2: SIMDType {}
extension float3: SIMDType {}
extension float4: SIMDType {}
extension float2x2: SIMDType {}
extension float3x3: SIMDType {}
extension float4x4: SIMDType {}
extension matrix_float4x4: SIMDType {}
extension Texture: SIMDType {}
