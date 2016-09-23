/**
* Object for setting and retrieving the default BingMaps API key.
*
* @namespace
* @alias BingMapsApi
*/
    
class BingMapsAPI {
    
    class func getKey(_ key: String?) -> String {
        if key != nil {
            return key!
        }
        logPrint(.warning, "This application is using CesiumKit's default Bing Maps key.  Please create a new key for the application as soon as possible and prior to deployment by visiting https://www.bingmapsportal.com, and provide your key to CesiumKit by setting the BingMapsImageryProvider.Key property before constructing the CesiumWidget or any other object that uses the Bing Maps API.")
        return "An03y3XzVHs8DaE4RK-FtSnGwZy-kzs_h-f6ZpF7EOztyEil-CZTR4zga3YLaHq7"
    }
}
