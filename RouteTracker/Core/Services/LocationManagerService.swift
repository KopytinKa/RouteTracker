//
//  LocationManagerService.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 05.06.2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxRelay

final class LocationManagerService: NSObject {
    // MARK: Properties
    static let instance = LocationManagerService()
    
    let locationManager = CLLocationManager()
    let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    // MARK: Private
    private func configureLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
}

extension LocationManagerService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.accept(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
