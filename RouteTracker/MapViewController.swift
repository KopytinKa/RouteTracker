//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 09.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager: CLLocationManager?
    let geocoder = CLGeocoder()
    
    var markers: [GMSMarker]?
    let zoom: Float = 16
    
    var recordUpdatingLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocationManager()
        self.configureMap()
    }
    
    func configureMap() {
        self.locationManager?.requestLocation()

        if let coordinate = self.locationManager?.location?.coordinate {
            let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: self.zoom)
            self.mapView.camera = camera
            self.addMarkerByPosition(coordinate)
        }
    }
    
    func configureLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.delegate = self
    }
    
    func addMarkerByPosition(_ position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.icon = GMSMarker.markerImage(with: .orange)
        marker.map = self.mapView
        self.markers?.append(marker)
    }
    
    func addPathByPosition(_ position: CLLocationCoordinate2D) {
        guard let lastPosition = self.markers?.last?.position else { return }
        
        let path = GMSMutablePath()
        path.add(lastPosition)
        path.add(position)

        let line = GMSPolyline(path: path)
        line.map = self.mapView
    }
    
    @IBAction func updateLocation(_ sender: Any) {
        if self.recordUpdatingLocation {
            self.locationManager?.stopUpdatingLocation()
        } else {
            self.locationManager?.startUpdatingLocation()
        }
        self.recordUpdatingLocation.toggle()
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        self.configureMap()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocoder.reverseGeocodeLocation(location) { places, error in
            print(places?.first)
        }
        
        self.addMarkerByPosition(location.coordinate)
        self.addPathByPosition(location.coordinate)
        
        self.mapView.animate(toLocation: location.coordinate)
        self.mapView.animate(toZoom: self.zoom)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
