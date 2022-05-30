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
    let realmService = RealmService()
    
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var markers: [GMSMarker]?
    let zoom: Float = 16
    
    var recordUpdatingLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocationManager()
        self.configureMap()
    }
    
    // -MARK: Private
    
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
        self.locationManager?.delegate = self
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.startMonitoringSignificantLocationChanges()
        self.locationManager?.requestAlwaysAuthorization()
    }
    
    func addMarkerByPosition(_ position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.icon = GMSMarker.markerImage(with: .orange)
        marker.map = self.mapView
        self.markers?.append(marker)
    }
    
    func showTrackError() {
        let alert = UIAlertController(title: "Ошибка", message: "В данный момент происходит слежение. Сначала необходимо остановить слежение, нажав на ОК", preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "ОК", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.clearPathAndStopUpdatingLocation()
            self.loadLastTrack()
        }
        let cancel = UIAlertAction(title: "Отмена", style: .default)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    func clearPathAndStopUpdatingLocation() {
        self.routePath?.removeAllCoordinates()
        self.locationManager?.startMonitoringSignificantLocationChanges()
        self.locationManager?.stopUpdatingLocation()
        self.recordUpdatingLocation = false
    }
    
    func loadLastTrack() {
        if let coornidates = self.realmService.read(object: CoordinateModel.self) as? [CoordinateModel] {
            self.route?.map = nil
            self.route = GMSPolyline()
            self.routePath = GMSMutablePath()
            
            for coornidate in coornidates {
                self.routePath?.add(CLLocationCoordinate2DMake(coornidate.latitude, coornidate.longitude))
            }
            
            self.route?.path = self.routePath
            self.route?.map = self.mapView
            
            let bounds = GMSCoordinateBounds(path: self.routePath!)
            let update = GMSCameraUpdate.fit(bounds)
            self.mapView.animate(with: update)
        }
    }
    
    // -MARK: Action
    
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
    
    @IBAction func startNewTrack(_ sender: Any) {
        self.route?.map = nil
        self.route = GMSPolyline()
        self.routePath = GMSMutablePath()
        self.route?.map = self.mapView
        self.locationManager?.startUpdatingLocation()
        self.recordUpdatingLocation = true
    }
    
    @IBAction func stopTrack(_ sender: Any) {
        guard let path = self.routePath else { return }
        
        var items: [CLLocationCoordinate2D] = []
        for i in 0..<path.count() {
            let coordinate = path.coordinate(at: i)
            items.append(coordinate)
        }
        
        let coordinats = items.map { CoordinateModel(data: $0) }
        
        self.realmService.delete(object: CoordinateModel.self)
        self.realmService.add(models: coordinats)
        
        self.clearPathAndStopUpdatingLocation()
    }
    
    @IBAction func showLastTrack(_ sender: Any) {
        if self.recordUpdatingLocation {
            self.showTrackError()
        } else {
            self.loadLastTrack()
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
                
        self.routePath?.add(location.coordinate)
        self.route?.path = self.routePath
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: self.zoom)
        self.mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
