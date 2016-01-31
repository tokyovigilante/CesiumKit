//
//  Simon1994PlanetaryPositions.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 18/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation


/**
 * Contains functions for finding the Cartesian coordinates of the sun and the moon in the
 * Earth-centered inertial frame.
 *
 * @namespace
 * @alias Simon1994PlanetaryPositions
 */
class Simon1994PlanetaryPositions {
    
    static let sharedInstance = Simon1994PlanetaryPositions()
    
     /* STK Comments ------------------------------------------------------
     This function uses constants designed to be consistent with
     the SPICE Toolkit from JPL version N0051 (unitim.c)
     M0 = 6.239996
     M0Dot = 1.99096871e-7 rad/s = 0.01720197 rad/d
     EARTH_ECC = 1.671e-2
     TDB_AMPL = 1.657e-3 secs
     --------------------------------------------------------------------
     
     Values taken as specified in STK Comments except: 0.01720197 rad/day = 1.99096871e-7 rad/sec
     Here we use the more precise value taken from the SPICE value 1.99096871e-7 rad/sec converted to rad/day
     All other constants are consistent with the SPICE implementation of the TDB conversion
     except where we treat the independent time parameter to be in TT instead of TDB.
     This is an approximation made to facilitate performance due to the higher prevalance of
     the TT2TDB conversion over TDB2TT in order to avoid having to iterate when converting to TDB for the JPL ephemeris.
     Days are used instead of seconds to provide a slight improvement in numerical precision.
     
     For more information see:
     http://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB
     ftp://ssd.jpl.nasa.gov/pub/eph/planets/ioms/ExplSupplChap8.pdf
     */
    private let epoch: JulianDate
    private let GravitationalParameterOfEarth: Double
    private let GravitationalParameterOfSun: Double
    private let MetersPerKilometer: Double
    private let RadiansPerDegree: Double
    private let RadiansPerArcSecond: Double
    private let MetersPerAstronomicalUnit: Double
    
    private let semiMajorAxis0: Double
    private let meanLongitude0: Double
    private let meanLongitude1: Double
    private let p1u: Double
    private let p2u: Double
    private let p3u: Double
    private let p4u: Double
    private let p5u: Double
    private let p6u: Double
    private let p7u: Double
    private let p8u: Double
    private let Ca1: Double
    private let Ca2: Double
    private let Ca3: Double
    private let Ca4: Double
    private let Ca5: Double
    private let Ca6: Double
    private let Ca7: Double
    private let Ca8: Double
    private let Sa1: Double
    private let Sa2: Double
    private let Sa3: Double
    private let Sa4: Double
    private let Sa5: Double
    private let Sa6: Double
    private let Sa7: Double
    private let Sa8: Double
    private let q1u: Double
    private let q2u: Double
    private let q3u: Double
    private let q4u: Double
    private let q5u: Double
    private let q6u: Double
    private let q7u: Double
    private let q8u: Double
    private let Cl1: Double
    private let Cl2: Double
    private let Cl3: Double
    private let Cl4: Double
    private let Cl5: Double
    private let Cl6: Double
    private let Cl7: Double
    private let Cl8: Double
    private let Sl1: Double
    private let Sl2: Double
    private let Sl3: Double
    private let Sl4: Double
    private let Sl5: Double
    private let Sl6: Double
    private let Sl7: Double
    private let Sl8: Double
    
    private let TdtMinusTai: Double
    private let J2000d: Double
    
    private let maxIterationCount = 50
    private let keplerEqConvergence = Math.Epsilon8
    
    private let _moonEarthMassRatio: Double
    private let _factor: Double
    
    init () {
        // configure static variables
        
        epoch = JulianDate(julianDayNumber: 2451545, secondsOfDay: 0, timeStandard: .TAI) //Actually TDB (not TAI)
        
        GravitationalParameterOfEarth = 3.98600435e14
        GravitationalParameterOfSun = GravitationalParameterOfEarth * (1.0 + 0.012300034) * 328900.56
        MetersPerKilometer = 1000.0
        RadiansPerDegree = Math.RadiansPerDegree
        RadiansPerArcSecond = Math.RadiansPerArcSecond
        MetersPerAstronomicalUnit = 1.49597870e+11 // IAU 1976 value
        
        TdtMinusTai = 32.184
        J2000d = 2451545.0
        
        // From section 5.8
        semiMajorAxis0 = 1.0000010178 * MetersPerAstronomicalUnit
        meanLongitude0 = 100.46645683 * RadiansPerDegree
        meanLongitude1 = 1295977422.83429 * RadiansPerArcSecond
        
        // From table 6
        p1u = 16002.0
        p2u = 21863.0
        p3u = 32004.0
        p4u = 10931.0
        p5u = 14529.0
        p6u = 16368.0
        p7u = 15318.0
        p8u = 32794.0
        
        Ca1 = 64 * 1e-7 * MetersPerAstronomicalUnit
        Ca2 = -152 * 1e-7 * MetersPerAstronomicalUnit
        Ca3 = 62 * 1e-7 * MetersPerAstronomicalUnit
        Ca4 = -8 * 1e-7 * MetersPerAstronomicalUnit
        Ca5 = 32 * 1e-7 * MetersPerAstronomicalUnit
        Ca6 = -41 * 1e-7 * MetersPerAstronomicalUnit
        Ca7 = 19 * 1e-7 * MetersPerAstronomicalUnit
        Ca8 = -11 * 1e-7 * MetersPerAstronomicalUnit
        
        Sa1 = -150 * 1e-7 * MetersPerAstronomicalUnit
        Sa2 = -46 * 1e-7 * MetersPerAstronomicalUnit
        Sa3 = 68 * 1e-7 * MetersPerAstronomicalUnit
        Sa4 = 54 * 1e-7 * MetersPerAstronomicalUnit
        Sa5 = 14 * 1e-7 * MetersPerAstronomicalUnit
        Sa6 = 24 * 1e-7 * MetersPerAstronomicalUnit
        Sa7 = -28 * 1e-7 * MetersPerAstronomicalUnit
        Sa8 = 22 * 1e-7 * MetersPerAstronomicalUnit
        
        q1u = 10.0
        q2u = 16002.0
        q3u = 21863.0
        q4u = 10931.0
        q5u = 1473.0
        q6u = 32004.0
        q7u = 4387.0
        q8u = 73.0
        
        Cl1 = -325 * 1e-7
        Cl2 = -322 * 1e-7
        Cl3 = -79 * 1e-7
        Cl4 = 232 * 1e-7
        Cl5 = -52 * 1e-7
        Cl6 = 97 * 1e-7
        Cl7 = 55 * 1e-7
        Cl8 = -41 * 1e-7
        
        Sl1 = -105 * 1e-7
        Sl2 = -137 * 1e-7
        Sl3 = 258 * 1e-7
        Sl4 = 35 * 1e-7
        Sl5 = -116 * 1e-7
        Sl6 = -88 * 1e-7
        Sl7 = -112 * 1e-7
        Sl8 = -80 * 1e-7
        
        _moonEarthMassRatio = 0.012300034 // From 1992 mu value in Table 2
        _factor = _moonEarthMassRatio / (_moonEarthMassRatio + 1.0) * -1
    }
    
    func computeTdbMinusTtSpice(daysSinceJ2000InTerrestrialTime: Double) -> Double {
        let g = 6.239996 + (0.0172019696544) * daysSinceJ2000InTerrestrialTime
        return 1.657e-3 * sin(g + 1.671e-2 * sin(g))
    }
    
    private func taiToTdb(date: JulianDate) -> JulianDate {
        //Converts TAI to TT
        var result = date.addSeconds(TdtMinusTai)
        
        //Converts TT to TDB
        let days = result.totalDays() - J2000d
        result = result.addSeconds(computeTdbMinusTtSpice(days))
        
        return result
    }

    private func elementsToCartesian(semimajorAxis semimajorAxis: Double, eccentricity: Double, inclination: Double, longitudeOfPerigee: Double, longitudeOfNode: Double, meanLongitude: Double, gravitationalParameter: Double) -> Cartesian3 {
        
        var inclination = inclination
        var longitudeOfNode = longitudeOfNode
        
        if inclination < 0.0 {
            inclination = -inclination
            longitudeOfNode += M_PI
        }
        
        assert(inclination >= 0.0 && inclination <= M_PI, "The inclination is out of range. Inclination must be greater than or equal to zero and less than or equal to Pi radians.")
        
        let radiusOfPeriapsis = semimajorAxis * (1.0 - eccentricity)
        let argumentOfPeriapsis = longitudeOfPerigee - longitudeOfNode
        let rightAscensionOfAscendingNode = longitudeOfNode
        let trueAnomaly = meanAnomalyToTrueAnomaly(meanLongitude - longitudeOfPerigee, eccentricity: eccentricity)
        let type = OrbitType.fromEccentricity(eccentricity, tolerance: 0.0)
        assert(type != .Hyperbolic || abs(Math.negativePiToPi(trueAnomaly)) < acos(-1.0 / eccentricity), "The true anomaly of the hyperbolic orbit lies outside of the bounds of the hyperbola.")
        
        let perifocalToEquatorial = perifocalToCartesianMatrix(argumentOfPeriapsis, inclination: inclination, rightAscension: rightAscensionOfAscendingNode)
        let semilatus = radiusOfPeriapsis * (1.0 + eccentricity)
        let costheta = cos(trueAnomaly)
        let sintheta = sin(trueAnomaly)
        
        let denom = (1.0 + eccentricity * costheta)
        assert(denom > Math.Epsilon10, "elements cannot be converted to cartesian")
        
        let radius = semilatus / denom
        return perifocalToEquatorial.multiplyByVector(Cartesian3(x: radius * costheta, y: radius * sintheta, z: 0.0))
    }
    
    // Calculates the true anomaly given the mean anomaly and the eccentricity.
    private func meanAnomalyToTrueAnomaly(meanAnomaly: Double, eccentricity: Double) -> Double {
        assert(eccentricity >= 0.0 && eccentricity < 1.0, "eccentricity out of range")
        
        let eccentricAnomaly = meanAnomalyToEccentricAnomaly(meanAnomaly, eccentricity: eccentricity)
        return eccentricAnomalyToTrueAnomaly(eccentricAnomaly, eccentricity: eccentricity)
    }
    
    // Calculates the eccentric anomaly given the mean anomaly and the eccentricity.
    private func meanAnomalyToEccentricAnomaly(meanAnomaly: Double, eccentricity: Double) -> Double {
        assert(eccentricity >= 0.0 && eccentricity < 1.0, "eccentricity out of range")
        
        let revs = floor(meanAnomaly / Math.TwoPi)
        var meanAnomaly = meanAnomaly
        
        // Find angle in current revolution
        meanAnomaly -= revs * Math.TwoPi
        
        // calculate starting value for iteration sequence
        var iterationValue = meanAnomaly + (eccentricity * sin(meanAnomaly)) /
            (1.0 - sin(meanAnomaly + eccentricity) + sin(meanAnomaly))
        
        // Perform Newton-Raphson iteration on Kepler's equation
        var eccentricAnomaly = Double.infinity
        
        var count = 0
        while count < maxIterationCount && abs(eccentricAnomaly - iterationValue) > keplerEqConvergence {
            eccentricAnomaly = iterationValue
            let NRfunction = eccentricAnomaly - eccentricity * sin(eccentricAnomaly) - meanAnomaly
            let dNRfunction = 1 - eccentricity * cos(eccentricAnomaly)
            iterationValue = eccentricAnomaly - NRfunction / dNRfunction
            count += 1
        }
        
        // STK Components uses a numerical method to find the eccentric anomaly in the case that Kepler's
        // equation does not converge. We don't expect that to ever be necessary for the reasonable orbits used here.
        assert(count < maxIterationCount, "Kepler equation did not converge")
        
        return iterationValue + revs * Math.TwoPi
    }
    
    // Calculates the true anomaly given the eccentric anomaly and the eccentricity.
    private func eccentricAnomalyToTrueAnomaly(eccentricAnomaly: Double, eccentricity: Double) -> Double {
        assert(eccentricity >= 0.0 && eccentricity < 1.0, "eccentricity out of range")
        
        // Calculate the number of previous revolutions
        let revs = floor(eccentricAnomaly / Math.TwoPi)
        
        var eccentricAnomaly = eccentricAnomaly
        
        // Find angle in current revolution
        eccentricAnomaly -= revs * Math.TwoPi
        
        // Calculate true anomaly from eccentric anomaly
        let trueAnomalyX = cos(eccentricAnomaly) - eccentricity
        let trueAnomalyY = sin(eccentricAnomaly) * sqrt(1 - eccentricity * eccentricity)
        
        var trueAnomaly = atan2(trueAnomalyY, trueAnomalyX)
        
        // Ensure the correct quadrant
        trueAnomaly = Math.zeroToTwoPi(trueAnomaly)
        if eccentricAnomaly < 0 {
            trueAnomaly -= Math.TwoPi
        }
        
        // Add on previous revolutions
        trueAnomaly += revs * Math.TwoPi
        
        return trueAnomaly
    }

    /** Calculates the transformation matrix to convert from the perifocal (PQW) coordinate
     system to inertial cartesian coordinates.
    */
    private func perifocalToCartesianMatrix(argumentOfPeriapsis: Double, inclination: Double, rightAscension: Double) -> Matrix3 {
        assert(inclination >= 0.0 && inclination < 1.0, "eccentricity out of range")
        
        let cosap = cos(argumentOfPeriapsis)
        let sinap = sin(argumentOfPeriapsis)
        
        let cosi = cos(inclination)
        let sini = sin(inclination)
        
        let cosraan = cos(rightAscension)
        let sinraan = sin(rightAscension)
        
        return Matrix3(
            cosraan * cosap - sinraan * sinap * cosi,
            -cosraan * sinap - sinraan * cosap * cosi,
            sinraan * sini,
            
            sinraan * cosap + cosraan * sinap * cosi,
            -sinraan * sinap + cosraan * cosap * cosi,
            -cosraan * sini,
            
            sinap * sini,
            cosap * sini,
            cosi)
    }
    
    /**
     * Gets a point describing the motion of the Earth-Moon barycenter according to the equations
     * described in section 6.
     */
    func computeSimonEarthMoonBarycenter(date: JulianDate) -> Cartesian3 {
        // t is thousands of years from J2000 TDB
        let tdbDate = taiToTdb(date)
        let x = Double(tdbDate.dayNumber - epoch.dayNumber) + ((tdbDate.secondsOfDay - epoch.secondsOfDay) / TimeConstants.SecondsPerDay)
        let t = x / (TimeConstants.DaysPerJulianCentury * 10.0)
        
        let u = 0.35953620 * t
        let cs1 = Ca1 * cos(p1u * u) + Sa1 * sin(p1u * u)
        let cs2 = Ca2 * cos(p2u * u) + Sa2 * sin(p2u * u)
        let cs3 = Ca3 * cos(p3u * u) + Sa3 * sin(p3u * u)
        let cs4 = Ca4 * cos(p4u * u) + Sa4 * sin(p4u * u)
        let cs5 = Ca5 * cos(p5u * u) + Sa5 * sin(p5u * u)
        let cs6 = Ca6 * cos(p6u * u) + Sa6 * sin(p6u * u)
        let cs7 = Ca7 * cos(p7u * u) + Sa7 * sin(p7u * u)
        let cs8 = Ca8 * cos(p8u * u) + Sa8 * sin(p8u * u)
        
        let semimajorAxis = semiMajorAxis0 + cs1 + cs2 + cs3 + cs4 + cs5 + cs6 + cs7 + cs8
        
        let clsl1 = Cl1 * cos(q1u * u) + Sl1 * sin(q1u * u)
        let clsl2 = Cl2 * cos(q2u * u) + Sl2 * sin(q2u * u)
        let clsl3 = Cl3 * cos(q3u * u) + Sl3 * sin(q3u * u)
        let clsl4 = Cl4 * cos(q4u * u) + Sl4 * sin(q4u * u)
        let clsl5 = Cl5 * cos(q5u * u) + Sl5 * sin(q5u * u)
        let clsl6 = Cl6 * cos(q6u * u) + Sl6 * sin(q6u * u)
        let clsl7 = Cl7 * cos(q7u * u) + Sl7 * sin(q7u * u)
        let clsl8 = Cl8 * cos(q8u * u) + Sl8 * sin(q8u * u)
        let meanLongitude = meanLongitude0 + meanLongitude1 * t + clsl1 + clsl2 + clsl3 + clsl4 + clsl5 + clsl6 + clsl7 + clsl8
        
        
        // All constants in this part are from section 5.8
        let eccentricity = 0.0167086342 - 0.0004203654 * t
        let longitudeOfPerigee = 102.93734808 * RadiansPerDegree + 11612.35290 * RadiansPerArcSecond * t
        let inclination = 469.97289 * RadiansPerArcSecond * t
        let longitudeOfNode = 174.87317577 * RadiansPerDegree - 8679.27034 * RadiansPerArcSecond * t
        
        return elementsToCartesian(
            semimajorAxis: semimajorAxis,
            eccentricity: eccentricity,
            inclination: inclination,
            longitudeOfPerigee: longitudeOfPerigee,
            longitudeOfNode: longitudeOfNode,
            meanLongitude: meanLongitude,
            gravitationalParameter: GravitationalParameterOfSun
        )
    }
    
    /**
     * Gets a point describing the position of the moon according to the equations described in section 4.
     */
    func computeSimonMoon(date: JulianDate) -> Cartesian3 {
        let tdbDate = taiToTdb(date)
        let x = Double(tdbDate.dayNumber - epoch.dayNumber) + ((tdbDate.secondsOfDay - epoch.secondsOfDay) / TimeConstants.SecondsPerDay)
        let t: Double = x / TimeConstants.DaysPerJulianCentury
        let t2: Double = t * t
        let t3: Double = t2 * t
        let t4: Double = t3 * t
        
        // Terms from section 3.4 (b.1)
        var semimajorAxis: Double = 383397.7725 + 0.0040 * t
        var eccentricity: Double = 0.055545526 - 0.000000016 * t
        
        let inclinationConstant: Double = 5.15668983 * RadiansPerDegree
        var inclinationSecPart: Double = -0.00008 * t + 0.02966 * t2 -
            0.000042 * t3 - 0.00000013 * t4
        let longitudeOfPerigeeConstant: Double = 83.35324312 * RadiansPerDegree
        var longitudeOfPerigeeSecPart: Double = 14643420.2669 * t - 38.2702 * t2 -
            0.045047 * t3 + 0.00021301 * t4
        let longitudeOfNodeConstant: Double = 125.04455501 * RadiansPerDegree
        var longitudeOfNodeSecPart: Double = -6967919.3631 * t + 6.3602 * t2 +
            0.007625 * t3 - 0.00003586 * t4
        let meanLongitudeConstant: Double = 218.31664563 * RadiansPerDegree
        var meanLongitudeSecPart: Double = 1732559343.48470 * t - 6.3910 * t2 +
            0.006588 * t3 - 0.00003169 * t4
        
        // Delaunay arguments from section 3.5 b
        let D: Double = 297.85019547 * RadiansPerDegree + RadiansPerArcSecond *
            (1602961601.2090 * t - 6.3706 * t2 + 0.006593 * t3 - 0.00003169 * t4)
        let F: Double = 93.27209062 * RadiansPerDegree + RadiansPerArcSecond *
            (1739527262.8478 * t - 12.7512 * t2 - 0.001037 * t3 + 0.00000417 * t4)
        let l: Double = 134.96340251 * RadiansPerDegree + RadiansPerArcSecond *
            (1717915923.2178 * t + 31.8792 * t2 + 0.051635 * t3 - 0.00024470 * t4)
        let lprime: Double = 357.52910918 * RadiansPerDegree + RadiansPerArcSecond *
            (129596581.0481 * t - 0.5532 * t2 + 0.000136 * t3 - 0.00001149 * t4)
        let psi: Double = 310.17137918 * RadiansPerDegree - RadiansPerArcSecond *
            (6967051.4360 * t + 6.2068 * t2 + 0.007618 * t3 - 0.00003219 * t4)
        
        // Add terms from Table 4
        let twoD: Double = 2.0 * D
        let fourD: Double = 4.0 * D
        let sixD: Double = 6.0 * D
        let twol: Double = 2.0 * l
        let threel: Double = 3.0 * l
        let fourl: Double = 4.0 * l
        let twoF: Double = 2.0 * F
        semimajorAxis += 3400.4 * cos(twoD)
        semimajorAxis -= 635.6 * cos(twoD - l)
        semimajorAxis -= 235.6 * cos(l)
        semimajorAxis += 218.1 * cos(twoD - lprime)
        semimajorAxis += 181.0 * cos(twoD + l)
        
        eccentricity += 0.014216 * cos(twoD - l) + 0.008551 * cos(twoD - twol)
        eccentricity -= 0.001383 * cos(l) + 0.001356 * cos(twoD + l)
        eccentricity -= 0.001147 * cos(fourD - threel) - 0.000914 * cos(fourD - twol)
        eccentricity += 0.000869 * cos(twoD - lprime - l) - 0.000627 * cos(twoD)
        eccentricity -= 0.000394 * cos(fourD - fourl) + 0.000282 * cos(twoD - lprime - twol)
        eccentricity -= 0.000279 * cos(D - l) - 0.000236 * cos(twol)
        eccentricity += 0.000231 * cos(fourD) + 0.000229 * cos(sixD - fourl)
        eccentricity -= 0.000201 * cos(twol - twoF)
        
        inclinationSecPart += 486.26 * cos(twoD - twoF) - 40.13 * cos(twoD)
        inclinationSecPart += 37.51 * cos(twoF) + 25.73 * cos(twol - twoF)
        inclinationSecPart += 19.97 * cos(twoD - lprime - twoF)
        
        longitudeOfPerigeeSecPart += -55609 * sin(twoD - l) - 34711 * sin(twoD - twol)
        longitudeOfPerigeeSecPart -= 9792 * sin(l) + 9385 * sin(fourD - threel)
        longitudeOfPerigeeSecPart += 7505 * sin(fourD - twol) + 5318 * sin(twoD + l)
        longitudeOfPerigeeSecPart += 3484 * sin(fourD - fourl) - 3417 * sin(twoD - lprime - l)
        longitudeOfPerigeeSecPart -= 2530 * sin(sixD - fourl) - 2376 * sin(twoD)
        longitudeOfPerigeeSecPart -= 2075 * sin(twoD - threel) - 1883 * sin(twol)
        longitudeOfPerigeeSecPart -= 1736 * sin(sixD - 5.0 * l) + 1626 * sin(lprime)
        longitudeOfPerigeeSecPart -= 1370 * sin(sixD - threel)
        
        longitudeOfNodeSecPart += -5392 * sin(twoD - twoF)
        longitudeOfNodeSecPart -= 540 * sin(lprime) - 441 * sin(twoD)
        longitudeOfNodeSecPart += 423 * sin(twoF) - 288 * sin(twol - twoF)
        
        meanLongitudeSecPart += -3332.9 * sin(twoD) + 1197.4 * sin(twoD - l)
        meanLongitudeSecPart -= 662.5 * sin(lprime) + 396.3 * sin(l)
        meanLongitudeSecPart -= 218.0 * sin(twoD - lprime)
 
        // Add terms from Table 5
        let twoPsi: Double = 2.0 * psi
        let threePsi: Double = 3.0 * psi
        
        inclinationSecPart += 46.997 * cos(psi) * t
        inclinationSecPart -= 0.614 * cos(twoD - twoF + psi) * t
        inclinationSecPart += 0.614 * cos(twoD - twoF - psi) * t
        inclinationSecPart -= 0.0297 * cos(twoPsi) * t2
        inclinationSecPart -= 0.0335 * cos(psi) * t2
        inclinationSecPart += 0.0012 * cos(twoD - twoF + twoPsi) * t2
        inclinationSecPart -= 0.00016 * cos(psi) * t3
        inclinationSecPart += 0.00004 * cos(threePsi) * t3
        inclinationSecPart += 0.00004 * cos(twoPsi) * t3
        
        let perigeeAndMean: Double = 2.116 * sin(psi) * t
            // - 0.111 * sin(twoD - twoF - psi) * t 
            // - 0.0015 * sin(psi) * t2
        longitudeOfPerigeeSecPart += perigeeAndMean
        meanLongitudeSecPart += perigeeAndMean
        
        longitudeOfNodeSecPart += -520.77 * sin(psi) * t
        longitudeOfNodeSecPart += 13.66 * sin(twoD - twoF + psi) * t
        longitudeOfNodeSecPart += 1.12 * sin(twoD - psi) * t
        longitudeOfNodeSecPart -= 1.06 * sin(twoF - psi) * t
        longitudeOfNodeSecPart += 0.660 * sin(twoPsi) * t2 + 0.371 * sin(psi) * t2
        longitudeOfNodeSecPart -= 0.035 * sin(twoD - twoF + twoPsi) * t2
        longitudeOfNodeSecPart -= 0.015 * sin(twoD - twoF + psi) * t2
        longitudeOfNodeSecPart += 0.0014 * sin(psi) * t3 - 0.0011 * sin(threePsi) * t3
        longitudeOfNodeSecPart -= 0.0009 * sin(twoPsi) * t3
        
        // Add constants and convert units
        semimajorAxis *= MetersPerKilometer
        let inclination: Double = inclinationConstant + inclinationSecPart * RadiansPerArcSecond
        let longitudeOfPerigee: Double = longitudeOfPerigeeConstant + longitudeOfPerigeeSecPart * RadiansPerArcSecond
        let meanLongitude: Double = meanLongitudeConstant + meanLongitudeSecPart * RadiansPerArcSecond
        let longitudeOfNode: Double = longitudeOfNodeConstant + longitudeOfNodeSecPart * RadiansPerArcSecond
        
        return elementsToCartesian(
            semimajorAxis: semimajorAxis,
            eccentricity: eccentricity,
            inclination: inclination,
            longitudeOfPerigee: longitudeOfPerigee,
            longitudeOfNode: longitudeOfNode,
            meanLongitude: meanLongitude,
            gravitationalParameter: GravitationalParameterOfEarth
        )
    }
    
    /**
     * Gets a point describing the motion of the Earth.  This point uses the Moon point and
     * the 1992 mu value (ratio between Moon and Earth masses) in Table 2 of the paper in order
     * to determine the position of the Earth relative to the Earth-Moon barycenter.
     */
    func computeSimonEarth (date: JulianDate) -> Cartesian3 {
        let result = computeSimonMoon(date)
        return result.multiplyByScalar(_factor)
    }
 
    // Values for the <code>axesTransformation</code> needed for the rotation were found using the STK Components
    // GreographicTransformer on the position of the sun center of mass point and the earth J2000 frame.
    private let _axesTransformation = Matrix3(
        1.0000000000000002, 5.619723173785822e-16, 4.690511510146299e-19,
        -5.154129427414611e-16, 0.9174820620691819, -0.39777715593191376,
        -2.23970096136568e-16, 0.39777715593191376, 0.9174820620691819
    )
    
    /**
     * Computes the position of the Sun in the Earth-centered inertial frame
     *
     * @param {JulianDate} [julianDate] The time at which to compute the Sun's position, if not provided the current system time is used.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} Calculated sun position
     */
    func computeSunPositionInEarthInertialFrame (date: JulianDate = JulianDate.now()) -> Cartesian3 {
        
        //first forward transformation
        var translation = computeSimonEarthMoonBarycenter(date)
        var result = translation.negate()
        
        //second forward transformation
        translation = computeSimonEarth(date)
        
        result = result.subtract(translation)
        return _axesTransformation.multiplyByVector(result)
    }
    
    /**
     * Computes the position of the Moon in the Earth-centered inertial frame
     *
     * @param {JulianDate} [julianDate] The time at which to compute the Sun's position, if not provided the current system time is used.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} Calculated moon position
     */
    func computeMoonPositionInEarthInertialFrame (date: JulianDate = JulianDate.now()) -> Cartesian3 {
        return _axesTransformation.multiplyByVector(computeSimonMoon(date))
    }
    
}
