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
        return "AqJZu2hZlN7PoYUQRF4YoTwknbXwuK5vVK9f7STen3t9sHrdOlIA49rpI-swOOLt"
    }
}
