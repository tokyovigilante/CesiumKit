//
//  Fog.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * Blends the atmosphere to geometry far from the camera for horizon views. Allows for additional
 * performance improvements by rendering less geometry and dispatching less terrain requests.
 *
 * @alias Fog
 * @constructor
 */
class Fog {
    /**
     * <code>true</code> if fog is enabled, <code>false</code> otherwise.
     * @type {Boolean}
     * @default true
     */
    var enabled = true
    
    /**
     * A scalar that determines the density of the fog. Terrain that is in full fog are culled.
     * The density of the fog increases as this number approaches 1.0 and becomes less dense as it approaches zero.
     * The more dense the fog is, the more aggressively the terrain is culled. For example, if the camera is a height of
     * 1000.0m above the ellipsoid, increasing the value to 3.0e-4 will cause many tiles close to the viewer be culled.
     * Decreasing the value will push the fog further from the viewer, but decrease performance as more of the terrain is rendered.
     * @type {Number}
     * @default 2.0e-4
     */
    var density = 3.0e-4
    
    /**
     * A factor used to increase the screen space error of terrain tiles when they are partially in fog. The effect is to reduce
     * the number of terrain tiles requested for rendering. If set to zero, the feature will be disabled. If the value is increased
     * for mountainous regions, less tiles will need to be requested, but the terrain meshes near the horizon may be a noticeably
     * lower resolution. If the value is increased in a relatively flat area, there will be little noticeable change on the horizon.
     * @type {Number}
     * @default 2.0
     */
    var screenSpaceErrorFactor = 4.0
    
    
    // These values were found by sampling the density at certain views and finding at what point culled tiles impacted the view at the horizon.
    private let heightsTable = [359.393, 800.749, 1275.6501, 2151.1192, 3141.7763, 4777.5198, 6281.2493, 12364.307, 15900.765, 49889.0549, 78026.8259, 99260.7344, 120036.3873, 151011.0158, 156091.1953, 203849.3112, 274866.9803, 319916.3149, 493552.0528, 628733.5874]
    private var densityTable = [2.0e-5, 2.0e-4, 1.0e-4, 7.0e-5, 5.0e-5, 4.0e-5, 3.0e-5, 1.9e-5, 1.0e-5, 8.5e-6, 6.2e-6, 5.8e-6, 5.3e-6, 5.2e-6, 5.1e-6, 4.2e-6, 4.0e-6, 3.4e-6, 2.6e-6, 2.2e-6]
    
    private var tableLastIndex = 0
    
    private let tableStartDensity: Double
    
    private let tableEndDensity: Double
    
    init () {
        // Scale densities by 1e6 to bring lowest value to ~1. Prevents divide by zero.
        for i in 0..<densityTable.count {
            densityTable[i] *= 1.0e6
        }
        // Change range to [0, 1].
        tableStartDensity = densityTable[1]
        tableEndDensity = densityTable.last!
        let difference = tableStartDensity - tableEndDensity
        for i in 0..<densityTable.count {
            densityTable[i] = (densityTable[i] - tableEndDensity) / difference
        }
    }
    
    private func findInterval (height: Double) -> Int {

        let length = heightsTable.count
        
        if height < heightsTable[0] {
            tableLastIndex = 0
            return tableLastIndex
        } else if height > heightsTable[length - 1] {
            tableLastIndex = length - 2
            return tableLastIndex
        }
        
        // Take advantage of temporal coherence by checking current, next and previous intervals
        // for containment of time.
        if height >= heightsTable[tableLastIndex] {
            if tableLastIndex + 1 < length && height < heightsTable[tableLastIndex + 1] {
                return tableLastIndex
            } else if tableLastIndex + 2 < length && height < heightsTable[tableLastIndex + 2] {
                tableLastIndex += 1
                return tableLastIndex
            }
        } else if (tableLastIndex - 1 >= 0 && height >= heightsTable[tableLastIndex - 1]) {
            tableLastIndex -= 1
            return tableLastIndex
        }
        
        // The above failed so do a linear search.
        var i = 0
        for j in 0..<(length - 2) {
            i = j
            if height >= heightsTable[i] && height < heightsTable[i + 1] {
                break
            }
        }
        tableLastIndex = i
        return tableLastIndex
    }
    
    func update (inout frameState: FrameState) {
        frameState.fog.enabled = enabled
        if !enabled {
            return
        }
        
        let camera = frameState.camera!
        let positionCartographic = camera.positionCartographic
        
        // Turn off fog in space.
        if positionCartographic.height > 800000.0 || frameState.mode != .Scene3D {
            frameState.fog.enabled = false
            return
        }
        
        let height = positionCartographic.height
        let i = findInterval(height)
        let t = Math.clamp((height - heightsTable[i]) / (heightsTable[i + 1] - heightsTable[i]), min: 0.0, max: 1.0)
        var density = Math.lerp(p: densityTable[i], q: densityTable[i + 1], time: t)
        
        // Again, scale value to be in the range of densityTable (prevents divide by zero) and change to new range.
        let startDensity = self.density * 1.0e6
        let endDensity = (startDensity / tableStartDensity) * tableEndDensity
        density = (density * (startDensity - endDensity)) * 1.0e-6
        
        // Fade fog in as the camera tilts toward the horizon.
        let positionNormal = camera.positionWC.normalize()
        let dot = Math.clamp(camera.directionWC.dot(positionNormal), min: 0.0, max: 1.0)
        density *= 1.0 - dot
        
        frameState.fog.density = density
        frameState.fog.sse = screenSpaceErrorFactor
    }
    
}