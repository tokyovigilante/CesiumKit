//
//  NDHpple.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation
import UIKit


class NDHpple {
    
    let data: String
    let isXML: Bool
    
    init(data: String, isXML: Bool) {
        
        self.data = data
        self.isXML = isXML
    }
    
    convenience init(XMLData: String) {
        
        self.init(data: XMLData, isXML: true)
    }
    
    convenience init(HTMLData: String) {
        
        self.init(data: HTMLData, isXML: false)
    }
    
    func searchWithXPathQuery(xPathOrCSS: String) -> Array<NDHppleElement>? {
        
        let nodes = isXML ? PerformXMLXPathQuery(data, xPathOrCSS) : PerformHTMLXPathQuery(data, xPathOrCSS)
        return nodes?.map{ NDHppleElement(node: $0) }
    }
    
    func peekAtSearchWithXPathQuery(xPathOrCSS: String) -> NDHppleElement? {
        
        return searchWithXPathQuery(xPathOrCSS)?[0]
    }
}