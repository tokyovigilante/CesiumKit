class BingMapsAPI {
    
    class func getKey(key: String?) -> String {
        if key != nil {
            return key!
        }
        print("This application is using Cesium's default Bing Maps key.  Please create a new key for the application as soon as possible and prior to deployment by visiting https://www.bingmapsportal.com, and provide your key to Cesium by setting the BingMapsImageryProvider.Options.Key property before constructing the CesiumWidget or any other object that uses the Bing Maps API.")
        return "Aj1ony_-Typ-KjG9SJWiKSHY23U1KmK7yAmZa9lDmuF2osXWkcZ22VPsqmCt0TCt"
    }
}
