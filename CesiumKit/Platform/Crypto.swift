//
//  Crypto.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CommonCrypto

public struct HMAC {
    
    static func hash(inp: String, algo: HMACAlgo) -> String {
        if let stringData = inp.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            return hexStringFromBuffer(digest(stringData, algo: algo))
        }
        return ""
    }
    
    private static func digest(input : NSData, algo: HMACAlgo) -> [UInt8] {
        let digestLength = algo.digestLength()
        var hash = [UInt8](count: digestLength, repeatedValue: 0)
        switch algo {
        case .MD5:
            CC_MD5(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA1:
            CC_SHA1(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA224:
            CC_SHA224(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA256:
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA384:
            CC_SHA384(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA512:
            CC_SHA512(input.bytes, UInt32(input.length), &hash)
            break
        }
        return hash
    }
    
    private static func hexStringFromBuffer(input: [UInt8]) -> String {
        return input.reduce("") { $0 + String(format:"%02x", $1) }
    }
}

enum HMACAlgo {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}