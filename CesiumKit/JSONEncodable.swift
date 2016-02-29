//
//  JSONEncodable.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 29/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

protocol JSONEncodable {
    
    init (json: JSONObject) throws
    
    func toJSON () -> JSONObject
}