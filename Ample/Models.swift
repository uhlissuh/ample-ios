//
//  Models.swift
//  Ample
//
//  Created by Alissa sobo on 6/27/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import Foundation
import CoreLocation

struct User {
    var name: String
    var accountKitId: String
}

struct Review {
    var id: Int
    var workerOrBizId: Int
    var workerOrBizName: String
    var content: String
    var timestamp: TimeInterval
    var fatSlider: Int
    var skillSlider: Int
    var reviewer: User
}

struct Location {
    var city: String
    var country: String?
    var address2: String?
    var address3: String?
    var state: String
    var address1: String?
    var zipCode: String?
}

struct Category {
    var title: String?
    var alias: String?
}

struct Business {
    var id: Int?
    var name: String
    var coordinates: (latitude: Double, longitude: Double)
    var phone: String?
    var yelpId: String
    var city: String
    var state: String
    var address1: String?
    var address2: String?
    var score: Int?
    var imageUrl: String?
    var categoryTitles: [String]
}


