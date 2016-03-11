CesiumKit
=========

iOS/OS X port of the [Cesium](http://cesiumjs.org) WebGL virtual globe project.

Status
------
OS X and iOS Metal renderers are largely complete, with support for FXAA, terrain, lighting, water effects and text rendering.
The only currently-implemented image providers are the Bing Maps provider (with Web Mercator reprojection) and the TileCoordinate provider for debugging, however these can be layered.
Current efforts are focused on implementing camera controls and touch-based inputs.
I'm eventually hoping for near complete globe support with CZML interoperability with cesium.js.
Community contributions and feedback are welcome.

![](https://github.com/tokyovigilante/CesiumKit/blob/master/CurrentStatus.jpg)

Testing
-------
Requires Swift 2.0/Xcode 7.2 beta and an iOS 9 device with a minimum A7 processor, or OS X 10.11 with a compatible GPU.

Run the getDependencies.sh script to pull down PMJSON, glsl-optimizer and Alamofire from Github. Then build and run either the iOS or OS X test runner target.
At the moment the only external API are global object creation and render calls and minimal camera control. I'm hoping to keep things simple for implementation, but am looking into touch-based controls as a high priority now.

Licence
-------

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

Credits
-------

CesiumKit is based on the [Cesium WebGL Virtual Globe and Map Engine](http://cesiumjs.org) by AGI.
GLSL->Metal shader real-time translation performed by the [glsl-optimizer library](https://github.com/aras-p/glsl-optimizer) by Brian Paul, Aras Pranckevičius and Unity Technologies.
JSON parsing performed using the [PMJSON library](https://github.com/postmates/PMJSON) by Postmates.
Networking support from [Alamofire](https://github.com/Alamofire/Alamofire).

Feedback
--------
[ryan@testtoast.com](mailto:ryan@testtoast.com)

![](https://github.com/tokyovigilante/CesiumKit/blob/master/Everest.jpg)
