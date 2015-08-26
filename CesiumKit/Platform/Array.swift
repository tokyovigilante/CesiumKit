//
//  Array.swift
//  Cent
//
//  Created by Ankur Patel on 6/28/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

import Foundation

public func deleteDuplicates<S:RangeReplaceableCollectionType where S.Generator.Element: Equatable>(seq:S)-> S {
    let s = seq.reduce(S()){
        ac, x in ac.contains(x) ? ac : ac + [x]
    }
    return s
}

extension Array {
    func size () -> Int {
        return self.count * sizeofValue(self[0])
    }
}



