/**
* The types of imagery provided by Bing Maps.
*
* @namespace
* @alias BingMapsStyle
*
* @see BingMapsImageryProvider
*/

public enum BingMapsStyle: String {
    /**
    * Aerial imagery.
    *
    * @type {String}
    * @constant
    */
    case Aerial = "Aerial",
    
    /**
    * Aerial imagery with a road overlay.
    *
    * @type {String}
    * @constant
    */
    AerialWithLabels = "AerialWithLabels",
    
    /**
    * Roads without additional imagery.
    *
    * @type {String}
    * @constant
    */
    Road = "Road",
    
    /**
    * Ordnance Survey imagery
    *
    * @type {String}
    * @constant
    */
    OrdnanceSurvey = "OrdnanceSurvey",
    
    /**
    * Collins Bart imagery.
    *
    * @type {String}
    * @constant
    */
    CollinsBart = "CollinsBart"
}
