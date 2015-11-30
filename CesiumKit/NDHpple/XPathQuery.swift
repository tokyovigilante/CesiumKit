//
//  XPathQuery.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

func createNode(currentNode: xmlNodePtr, inout parentDictionary: Dictionary<String, AnyObject>, parentContent: Bool) -> Dictionary<String, AnyObject>? {
    
    var resultForNode = Dictionary<String, AnyObject>(minimumCapacity: 8)
    
    if currentNode.memory.name != nil {
        
        let name = String.fromCString(UnsafePointer<CChar>(currentNode.memory.name))
        resultForNode.updateValue(name!, forKey: NDHppleNodeKey.Name.rawValue)
    }
    
    if currentNode.memory.content != nil {

        let content = String.fromCString(UnsafePointer<CChar>(currentNode.memory.content))
        if resultForNode[NDHppleNodeKey.Name.rawValue] as AnyObject? as? String == "text" {
            
            if parentContent {
                
                parentDictionary.updateValue(content!, forKey: NDHppleNodeKey.Content.rawValue)
                return nil
            }
            
            resultForNode.updateValue(content!, forKey: NDHppleNodeKey.Content.rawValue)
            return resultForNode
        } else {
            
            resultForNode.updateValue(content!, forKey: NDHppleNodeKey.Content.rawValue)
        }
    }
    
    var attribute = currentNode.memory.properties
    if attribute != nil {
        
        var attributeArray = Array<Dictionary<String, AnyObject>>()
        
        while attribute != nil {
        
            var attributeDictionary = Dictionary<String, AnyObject>()
            let attributeName = attribute.memory.name
            if attributeName != nil {
                
                attributeDictionary.updateValue(String.fromCString(UnsafePointer<CChar>(attributeName))!, forKey: NDHppleNodeKey.AttributeName.rawValue)
            }
            
            if attribute.memory.children != nil {
                
                if let childDictionary = createNode(attribute.memory.children, &attributeDictionary, true) {
                    
                    attributeDictionary.updateValue(childDictionary, forKey: NDHppleNodeKey.AttributeContent.rawValue)
                }
            }
            
            if attributeDictionary.count > 0 {
                
                attributeArray.append(attributeDictionary)
            }
            
            attribute = attribute.memory.next
        }
        
        if attributeArray.count > 0 {
            
            resultForNode.updateValue(attributeArray, forKey: NDHppleNodeKey.AttributeArray.rawValue)
        }
    }
    
    var childNode = currentNode.memory.children
    if childNode != nil {
        
        var childContentArray = Array<Dictionary<String, AnyObject>>()
        
        while childNode != nil {
            
            if let childDictionary = createNode(childNode, &resultForNode, false) {
                
                childContentArray.append(childDictionary)
            }
        
            childNode = childNode.memory.next
        }
        
        if childContentArray.count > 0 {
            
            resultForNode.updateValue(childContentArray, forKey: NDHppleNodeKey.Children.rawValue)
        }
    }
    
    let buffer = xmlBufferCreate()
    xmlNodeDump(buffer, currentNode.memory.doc, currentNode, 0, 0)
    resultForNode.updateValue(String.fromCString(UnsafePointer<CChar>(buffer.memory.content))!, forKey: "raw")
    xmlBufferFree(buffer)
    
    return resultForNode
}

func PerformXPathQuery(data: NSString, query: String, isXML: Bool) -> Array<Dictionary<String, AnyObject>>? {
    
    var result: Array<Dictionary<String, AnyObject>>?
    
    let bytes = data.cStringUsingEncoding(NSUTF8StringEncoding)
    let length = CInt(data.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let url = ""
    let encoding = CFStringGetCStringPtr(nil, 0)
    let options: CInt = isXML ? 1 : ((1 << 5) | (1 << 6))
    
    var function = isXML ? xmlReadMemory : htmlReadMemory
    let doc = function(bytes, length, url, encoding, options)

    if doc != nil {
        
        let xPathCtx = xmlXPathNewContext(doc)
        if xPathCtx != nil {

            var queryBytes = query.cStringUsingEncoding(NSUTF8StringEncoding)!
            let ptr = UnsafePointer<CChar>(queryBytes)

            let xPathObj = xmlXPathEvalExpression(UnsafePointer<CUnsignedChar>(ptr), xPathCtx)
            if xPathObj != nil {
                
                let nodes = xPathObj.memory.nodesetval
                if nodes != nil {
                    
                    var resultNodes = Array<Dictionary<String, AnyObject>>()
                    let nodesArray = UnsafeBufferPointer(start: nodes.memory.nodeTab, count: Int(nodes.memory.nodeNr))
                    var dummy = Dictionary<String, AnyObject>()
                    for rawNode in nodesArray {

                        if let node = createNode(rawNode, &dummy, false) {

                            resultNodes.append(node)
                        }
                    }
                    
                    result = resultNodes
                }
                
                xmlXPathFreeObject(xPathObj)
            }
            
            xmlXPathFreeContext(xPathCtx)
        }
        
        xmlFreeDoc(doc)
    }
    
    return result
}

func PerformXMLXPathQuery(data: String, query: String) -> Array<Dictionary<String, AnyObject>>? {

    return PerformXPathQuery(data, query, true)
}

func PerformHTMLXPathQuery(data: String, query: String) -> Array<Dictionary<String, AnyObject>>? {

    return PerformXPathQuery(data, query, false)
}