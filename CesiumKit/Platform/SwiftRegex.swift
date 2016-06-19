//
//  SwiftRegex.swift
//  SwiftRegex
//
//  Created by John Holdsworth on 26/06/2014.
//  Copyright (c) 2014 John Holdsworth.
//
//  $Id: //depot/SwiftRegex/SwiftRegex.swift#37 $
//
//  This code is in the public domain from:
//  https://github.com/johnno1962/SwiftRegex
//

import Foundation

var swiftRegexCache = Dictionary<String,RegularExpression>()

public class SwiftRegex: NSObject, Boolean {
    
    var target: NSString
    var regex: RegularExpression
    
    init(target:NSString, pattern:String, options: RegularExpression.Options = RegularExpression.Options(rawValue: 0)) {
        self.target = target
        if let regex = swiftRegexCache[pattern] {
            self.regex = regex
        } else {
            do {
                let regex = try RegularExpression(pattern: pattern, options:options)
                swiftRegexCache[pattern] = regex
                self.regex = regex
            } catch let error as NSError {
                SwiftRegex.failure("Error in pattern: \(pattern) - \(error)")
                self.regex = RegularExpression()
            }
        }
        super.init()
    }
    
    class func failure(_ message: String) {
        logPrint(level: .error, "SwiftRegex: "+message)
        //assert(false,"SwiftRegex: failed")
    }
    
    final var targetRange: NSRange {
        return NSRange(location: 0,length: target.length)
    }
    
    final func substring(_ range: NSRange) -> String {
        if ( range.location != NSNotFound ) {
            return target.substring(with: range)
        } else {
            return ""
        }
    }
    
    public func doesMatch(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> Bool {
        return range(options).location != NSNotFound
    }
    
    public func range(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> NSRange {
        return regex.rangeOfFirstMatch(in: target as String, options: [], range: targetRange)
    }
    
    public func match(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> String! {
        return substring(range(options)) as String
    }
    
    public func groups(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> [String]! {
        return groupsForMatch( regex.firstMatch(in: target as String, options: options, range: targetRange) )
    }
    
    func groupsForMatch(_ match: TextCheckingResult!) -> [String]! {
        if match != nil {
            var groups = [String]()
            for groupno in 0...regex.numberOfCaptureGroups {
                if let group = substring(match.range(at: groupno)) as String! {
                    groups += [group]
                } else {
                    groups += ["_"] // avoids bridging problems
                }
            }
            return groups
        } else {
            return nil
        }
    }
    
    public subscript(groupno: Int) -> String! {
        get {
            return groups()[groupno]
        }
        set(newValue) {
            if let mutableTarget = target as? NSMutableString {
                for match in Array(matchResults().reversed()) {
                    let replacement = regex.replacementString( for: match as! TextCheckingResult,
                        in: target as String, offset: 0, template: newValue )
                    mutableTarget.replaceCharacters(in: match.range(at: groupno), with: replacement)
                }
            } else {
                SwiftRegex.failure("Group modify on non-mutable")
            }
        }
    }
    
    func matchResults(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> [AnyObject] {
        return regex.matches(in: target as String, options: options, range: targetRange)
    }
    
    public func ranges(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> [NSRange] {
        return matchResults(options).map { $0.range }
    }
    
    public func matches(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> [String] {
        return matchResults(options).map { self.substring($0.range) }
    }
    
    public func allGroups(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> [[String]] {
        return matchResults(options).map { self.groupsForMatch($0 as! TextCheckingResult) }
    }
    
    public func dictionary(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) -> Dictionary<String,String> {
        var out = Dictionary<String,String>()
        for match in matchResults(options) {
            out[substring(match.range(at: 1)) as String] =
                substring(match.range(at: 2)) as String
        }
        return out
    }
    
    func substituteMatches(_ options: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions(), substitution: (TextCheckingResult, UnsafeMutablePointer<ObjCBool>) -> String) -> String {
            var out = "" //NSMutableString()
            var pos = 0
        
            regex.enumerateMatches(in: target as String, options: options, range: targetRange ) {
                (match: TextCheckingResult?, flags: RegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
                
                let matchRange = match!.range
                out += self.substring(NSRange(location:pos, length:matchRange.location-pos))
                out += (substitution(match!, stop))
                pos = matchRange.location + matchRange.length
            }
            
            out += substring(NSRange(location:pos, length:targetRange.length-pos))
            
            return out
    }
    
    public var boolValue: Bool {
        return doesMatch()
    }
}

extension NSString {
    public subscript(pattern: String, options: RegularExpression.Options) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: options)
    }
}

extension NSString {
    public subscript(pattern: String) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern)
    }
}

extension String {
    public subscript(pattern: String, options: RegularExpression.Options) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: options)
    }
}

extension String {
    public subscript(pattern: String) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern)
    }
}

public func RegexMutable(_ string: NSString) -> NSMutableString {
    return NSMutableString(string:string as String)
}

