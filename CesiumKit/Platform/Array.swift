//
//  Array.swift
//  Cent
//
//  Created by Ankur Patel on 6/28/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

import Foundation

public func deleteDuplicates<S:ExtensibleCollectionType where S.Generator.Element: Equatable>(seq:S)-> S {
    let s = reduce(seq, S()){
        ac, x in contains(ac,x) ? ac : ac + [x]
    }
    return s
}

extension Array {
    func size () -> Int {
        return self.count * sizeofValue(self[0])
    }
}



