//
//  LocationViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/05/25.
//

import Foundation
import SwiftUI
import MapKit




class ConfirmLocationViewModel: ObservableObject {
    
    @Published var selectedCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var locationInfo = ""
    @Published var circle = MKCircle(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 1000)
    
    
    func updateLocation(latitude: String, longitude: String, city: String, state: String, country: String,locality:String) {
        guard let lat = Double(latitude), let lng = Double(longitude) else { return }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
            self.selectedCoordinate = coord
            self.mapRegion.center = coord
            self.circle = MKCircle(center: coord, radius: 0.0)
            if locality.count > 0{
                self.locationInfo = "\(locality), \(city)\((city.count > 0) ? ", " : "") \(state)"//, \(country)"
            }else{
                self.locationInfo = "\(city)\((city.count > 0) ? ", " : "") \(state)"//, \(country)"
            }
        })
   
    }
}



import SwiftUI
import MapKit

struct TapMapView1: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var mapRegion: MKCoordinateRegion
    @Binding var locationInfo: String
    @Binding var range: Double
    @Binding var circle: MKCircle
     var delegate:LocationSelectedDelegate?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update region if changed
        if uiView.region.center.latitude != mapRegion.center.latitude ||
            uiView.region.center.longitude != mapRegion.center.longitude {
            uiView.setRegion(mapRegion, animated: true)
        }

        // Remove existing annotations
        uiView.removeAnnotations(uiView.annotations)

        // Add new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)

        // Update overlays
        uiView.removeOverlays(uiView.overlays)
        let newCircle = MKCircle(center: coordinate, radius: range)
        uiView.addOverlay(newCircle)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TapMapView1

        init(_ parent: TapMapView1) {
            self.parent = parent
        }

        @objc func mapTapped(_ sender: UITapGestureRecognizer) {
            guard let mapView = sender.view as? MKMapView else { return }
            let point = sender.location(in: mapView)
            let newCoordinate = mapView.convert(point, toCoordinateFrom: mapView)

            // Update bindings
            parent.coordinate = newCoordinate
            parent.mapRegion.center = newCoordinate
            parent.circle = MKCircle(center: newCoordinate, radius: parent.range)

            // Optional: Update location info (reverse geocoding)
            parent.updateStateCity1(for: newCoordinate)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(overlay: circleOverlay)
                renderer.strokeColor = UIColor.red
                renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

extension TapMapView1 {
    func updateStateCity1(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            DispatchQueue.main.async {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                var locality = placemark.subLocality ?? ""
                            
                

                self.locationInfo = [city, state, country].filter { !$0.isEmpty }.joined(separator: ", ")
                self.delegate?.savePostLocation(latitude:"\(coordinate.latitude)", longitude: "\(coordinate.longitude)", city: city, state: state, country: country, locality: locality)
                
            }
        }
    }
}
