//
//  Models.swift
//  Ample
//
//  Created by Alissa sobo on 6/27/17.
//  Copyright © 2017 Alissa sobo. All rights reserved.
//

import Foundation
import CoreLocation

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
    var alias: String?
    var title: String?
}



struct Business {
    var rating: Int?
    var price: String?
    var phone: String
    var id: String?
    var isClosed: Bool?
    var categories: [Category]
    var name: String
    var coordinates: (latitude: Double, longitude: Double)
    var imageUrl: String?
    var location: Location?
}
