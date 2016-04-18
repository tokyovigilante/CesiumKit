//
//  String+HMAC.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

extension String {
    var md5: String {
        return HMAC.hash(self, algo: .MD5)
    }
    
    var sha1: String {
        return HMAC.hash(self, algo: .SHA1)
    }
    
    var sha224: String {
        return HMAC.hash(self, algo: .SHA224)
    }
    
    var sha256: String {
        return HMAC.hash(self, algo: .SHA256)
    }
    
    var sha384: String {
        return HMAC.hash(self, algo: .SHA384)
    }
    
    var sha512: String {
        return HMAC.hash(self, algo: .SHA512)
    }
}