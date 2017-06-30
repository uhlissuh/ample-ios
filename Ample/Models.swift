//
//  Models.swift
//  Ample
//
//  Created by Alissa sobo on 6/27/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import Foundation

struct Servicer {
    var name: String
    var specialty: String
    var id: Int
}

struct Review {
    var id: Int
    var user_id: Int
    var servicer_id: Int
    var content: String
}
