//
//  CoordinateModel.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 27.05.2022.
//

import Foundation
import CoreLocation
import RealmSwift

class CoordinateModel: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var latitude: Double = 0.00
    @objc dynamic var longitude: Double = 0.00
    
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience required init(data: CLLocationCoordinate2D) {
        self.init()

        self.latitude = data.latitude
        self.longitude = data.longitude
    }
}
