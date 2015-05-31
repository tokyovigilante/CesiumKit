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

var swiftRegexCache = Dictionary<String,NSRegularExpression>()

public class SwiftRegex: NSObject, BooleanType {
    
    var target: NSString
    var regex: NSRegularExpression
    
    init(target:NSString, pattern:String, options:NSRegularExpressionOptions = nil) {
        self.target = target
        if let regex = swiftRegexCache[pattern] {
            self.regex = regex
        } else {
            var error: NSError?
            if let regex = NSRegularExpression(pattern: pattern, options:options, error:&error) {
                swiftRegexCache[pattern] = regex
                self.regex = regex
            }
            else {
                SwiftRegex.failure("Error in pattern: \(pattern) - \(error)")
                self.regex = NSRegularExpression()
            }
        }
        super.init()
    }
    
    class func failure(message: String) {
        println("SwiftRegex: "+message)
        //assert(false,"SwiftRegex: failed")
    }
    
    final var targetRange: NSRange {
        return NSRange(location: 0,length: target.length)
    }
    
    final func substring(range: NSRange) -> String {
        if ( range.location != NSNotFound ) {
            return target.substringWithRange(range)
        } else {
            return ""
        }
    }
    
    public func doesMatch(options: NSMatchingOptions = nil) -> Bool {
        return range(options: options).location != NSNotFound
    }
    
    public func range(options: NSMatchingOptions = nil) -> NSRange {
        return regex.rangeOfFirstMatchInString(target as! String, options: nil, range: targetRange)
    }
    
    public func match(options: NSMatchingOptions = nil) -> String! {
        return substring(range(options: options)) as String
    }
    
    public func groups(options: NSMatchingOptions = nil) -> [String]! {
        return groupsForMatch( regex.firstMatchInString(target as! String, options: options, range: targetRange) )
    }
    
    func groupsForMatch(match: NSTextCheckingResult!) -> [String]! {
        if match != nil {
            var groups = [String]()
            for groupno in 0...regex.numberOfCaptureGroups {
                if let group = substring(match.rangeAtIndex(groupno)) as String! {
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
                for match in matchResults().reverse() {
                    let replacement = regex.replacementStringForResult( match as! NSTextCheckingResult,
                        inString: target as! String, offset: 0, template: newValue )
                    mutableTarget.replaceCharactersInRange(match.rangeAtIndex(groupno), withString: replacement)
                }
            } else {
                SwiftRegex.failure("Group modify on non-mutable")
            }
        }
    }
    
    func matchResults(options: NSMatchingOptions = nil) -> [AnyObject] {
        let result = regex.matchesInString(target as! String, options: options, range: targetRange)
        return regex.matchesInString(target as! String, options: options, range: targetRange)
    }
    
    public func ranges(options: NSMatchingOptions = nil) -> [NSRange] {
        return matchResults(options: options).map { $0.range }
    }
    
    public func matches(options: NSMatchingOptions = nil) -> [String] {
        return matchResults(options: options).map { self.substring($0.range) }
    }
    
    public func allGroups(options: NSMatchingOptions = nil) -> [[String]] {
        return matchResults(options: options).map { self.groupsForMatch($0 as! NSTextCheckingResult) }
    }
    
    public func dictionary(options: NSMatchingOptions = nil) -> Dictionary<String,String> {
        var out = Dictionary<String,String>()
        for match in matchResults(options: options) {
            out[substring(match.rangeAtIndex(1)) as String] =
                substring(match.rangeAtIndex(2)) as String
        }
        return out
    }
    
    func substituteMatches(options: NSMatchingOptions = nil, substitution: (NSTextCheckingResult, UnsafeMutablePointer<ObjCBool>) -> String) -> String {
            var out = "" //NSMutableString()
            var pos = 0
            
            regex.enumerateMatchesInString(target as! String, options: options, range: targetRange ) {
                (match: NSTextCheckingResult!, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
                
                let matchRange = match.range
                out += self.substring(NSRange(location:pos, length:matchRange.location-pos))
                out += (substitution(match, stop))
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
    public subscript(pattern: String, options: NSRegularExpressionOptions) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: options)
    }
}

extension NSString {
    public subscript(pattern: String) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern)
    }
}

extension String {
    public subscript(pattern: String, options: NSRegularExpressionOptions) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern, options: options)
    }
}

extension String {
    public subscript(pattern: String) -> SwiftRegex {
        return SwiftRegex(target: self, pattern: pattern)
    }
}

public func RegexMutable(string: NSString) -> NSMutableString {
    return NSMutableString(string:string as! String)
}

