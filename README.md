CesiumKit
=========
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

iOS/Swift port of the [Cesium](http://cesiumjs.org) WebGL virtual globe project.

Status
------
Renderer and core are largely complete. Textured globe support is functional. The only implemented image providers are the Bing Maps provider and the TileCoordinate provider for debugging, however these can be layered.
Current efforts are focused on implementing camera controls, touch-based inputs, and will then be looking at terrain support.
I'm eventually hoping for near complete globe support with CZML interoperability with cesium.js.
Community contributions and feedback are welcome.

![](https://github.com/tokyovigilante/CesiumKit/blob/master/CurrentStatus.jpg)

Testing
-------
Build and run CesiumKitRunner. Performance in the simulator is poor due to the software OpenGL ES renderer. Performance on devices is much better and is in fact CPU-bound, due to a combination of Swift performance and currently unoptimised code. 
I've hardcoded resolution in the simulator to 25% of screen resolution for performance, however performance on device is at or near 60fps at Retina resolutions (iPad Air 2)

At the moment the only external API are global object creation and render calls and minimal camera control. I'm hoping to keep things simple for implementation, but am looking into touch-based controls as a high priority now.

Licence
-------

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

Feedback
--------
[ryan@testtoast.com](mailto:ryan@testtoast.com)


