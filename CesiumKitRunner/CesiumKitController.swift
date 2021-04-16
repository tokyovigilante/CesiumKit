//
//  CesiumKitController.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import MetalKit
import CesiumKit

class CesiumKitController: NSObject, MTKViewDelegate {
    
    fileprivate let _globe: CesiumGlobe!
    
    fileprivate let _view: MTKView
    
    //private let _viewportOverlay: ViewportQuad
    
    fileprivate let _fontName = "HelveticaNeue"
    fileprivate let _fontSize: Float = 36
    
    init (view: MTKView) {
        
        _view = view
        _view.device = MTLCreateSystemDefaultDevice()
        _view.colorPixelFormat = PixelFormat.bgra8Unorm.toMetal()
        _view.depthStencilPixelFormat = PixelFormat.depth32FloatStencil8.toMetal()
        _view.framebufferOnly = false
        _view.preferredFramesPerSecond = 60
        _view.autoResizeDrawable = true
        
        let options = CesiumOptions(
            //clock: Clock(multiplier: 600),
            clock: Clock(clockStep: .systemClock, isUTC: false),
            imageryProvider: nil,
            terrain: false,
            lighting: true,
            skyBox: true,
            fog: true,
            scene3DOnly: true
        )

        _globe = CesiumGlobe(view: _view, options: options)
        _globe.scene.imageryLayers.addImageryProvider(BingMapsImageryProvider(key: Constants.BING_MAPS_KEY))
        //_globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
        
        _globe.scene.camera.constrainedAxis = Cartesian3.unitZ
        
        //Flat ocean view
        /*_globe.scene.camera.setView(
            orientation: .headingPitchRoll(heading: 0.0, pitch: 0.0, roll: 0.0),
            destination: .cartesian(Cartesian3.fromDegrees(longitude: 0.0, latitude: 0.0, height: 100))
        )*/
        
        // Everest
        _globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 86.95278, latitude: 28.288056, height: 10000), offset: HeadingPitchRange(heading: 180.0, pitch: 0, range: 5000))
        
        // Murrumbeena
        //_globe.scene.camera.setView(position: Cartesian3.fromDegrees(longitude: 145.075, latitude: -37.892, height: 1000), heading: 0, pitch: 0, roll: 0)
        
        //Wellington,
        /*_globe.scene.camera.setView(
            orientation: .headingPitchRoll(heading: 0.0, pitch: 0.0, roll: 0.0),
            destination: .cartesian(Cartesian3.fromDegrees(longitude: 174.784356, latitude: -41.438928, height: 1000))
        )*/
        //_globe.scene.camera.viewRectangle(Rectangle(fromDegreesWest: 150, south: -90, east: 110, north: 20))
        
        /*let viewportFabric = ColorFabricDescription(color: Color(fromRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.8))
        _viewportOverlay = ViewportQuad(
            rectangle: BoundingRectangle(x: 20, y: 20, width: 400, height: 400),
            material: Material(fromType: ColorMaterialType(fabric: viewportFabric))
        )
        _globe.scene.primitives.add(_viewportOverlay)*/
        
        /*let labels = LabelCollection(scene: _globe.scene)
        labels.add(
            position: Cartesian3(x: 4.0, y: 5.0, z: 6.0),
            text: "A label"
        )
        _globe.scene.primitives.add(labels)*/
        /*
        let window = _globe.scene.addOffscreenQuad(width: 400, height: 400)
        
        let blue = Color(fromRed: 40/255, green: 144/255, blue: 252/255, alpha: 1.0)
        let viewportFabric = ColorFabricDescription(color: Color(fromRed: 40/255, green: 144/255, blue: 252/255, alpha: 1.0))
        let material = Material(fromType: ColorMaterialType(fabric: viewportFabric))

        window.addRectangle(Cartesian4(x: 50, y: 50, width: 50, height: 50), material: material)
        
        window.addString("Test", fontName: "HelveticaNeue", color: blue, pointSize: 20, rectangle: Cartesian4(x: 110, y: 50, width: 600, height: 50))*/
        
        super.init()
    }
    
    func startRendering () {
        _view.isPaused = false
    }
    
    func stopRendering () {
        _view.isPaused = true
    }
    
    func draw(in view: MTKView) {
        _globe.scene.camera.moveForward(5.0)
        #if os(iOS)
            view.contentScaleFactor = 2.0
            let scaleFactor = view.contentScaleFactor
        #elseif os(OSX)
            view.layer!.contentsScale = 2.0
            let scaleFactor = view.layer!.contentsScale
        #endif
            let viewBoundsSize = view.bounds.size
            let renderWidth = viewBoundsSize.width * scaleFactor
            let renderHeight = viewBoundsSize.height * scaleFactor
            let renderSize = CGSize(width: renderWidth, height: renderHeight)
        #if os(OSX)
            //view.autoResizeDrawable = false
            //view.drawableSize = renderSize
        #endif
        
        _globe.render(renderSize)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //_viewportOverlay.rectangle = BoundingRectangle(x: 20, y: 20, width: 200, height: 200)
        /*let scale = self.v!.backingScaleFactor
         let layerSize = view.bounds.size
         
         _metalView.metalLayer.contentsScale = scale
         _metalView.metalLayer.frame = CGRectMake(0, 0, layerSize.width, layerSize.height)
         _metalView.metalLayer.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)*/
    }
    
    func handleMouseDown (_ button: MouseButton, position: Cartesian2, modifier: KeyboardEventModifier?) {
        _globe.eventHandler.handleMouseDown(button, position: position, modifier: modifier)
    }
    
    func handleMouseMove (_ button: MouseButton, position: Cartesian2, modifier: KeyboardEventModifier?) {
        _globe.eventHandler.handleMouseMove(button, position: position, modifier: modifier)
    }
    
    func handleMouseUp (_ button: MouseButton, position: Cartesian2, modifier: KeyboardEventModifier?) {
        _globe.eventHandler.handleMouseMove(button, position: position, modifier: modifier)
    }
    
    func handleWheel (_ deltaX: Double, deltaY: Double) {
        _globe.eventHandler.handleWheel(deltaX, deltaY: deltaY)
    }


}
