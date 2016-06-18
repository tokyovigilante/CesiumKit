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
    
    static func hash(_ inp: String, algo: HMACAlgo) -> String {
        if let stringData = inp.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            return hexStringFromBuffer(digest(stringData, algo: algo))
        }
        return ""
    }
    
    private static func digest(_ input : Data, algo: HMACAlgo) -> [UInt8] {
        let digestLength = algo.digestLength()
        var hash = [UInt8](repeating: 0, count: digestLength)
        switch algo {
        case .md5:
            CC_MD5(input.bytes, UInt32(input.length), &hash)
            break
        case .sha1:
            CC_SHA1(input.bytes, UInt32(input.length), &hash)
            break
        case .sha224:
            CC_SHA224(input.bytes, UInt32(input.length), &hash)
            break
        case .sha256:
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
            break
        case .sha384:
            CC_SHA384(input.bytes, UInt32(input.length), &hash)
            break
        case .sha512:
            CC_SHA512(input.bytes, UInt32(input.length), &hash)
            break
        }
        return hash
    }
    
    private static func hexStringFromBuffer(_ input: [UInt8]) -> String {
        return input.reduce("") { $0 + String(format:"%02x", $1) }
    }
}

enum HMACAlgo {
    case md5, sha1, sha224, sha256, sha384, sha512
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .md5:
            result = CC_MD5_DIGEST_LENGTH
        case .sha1:
            result = CC_SHA1_DIGEST_LENGTH
        case .sha224:
            result = CC_SHA224_DIGEST_LENGTH
        case .sha256:
            result = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            result = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
