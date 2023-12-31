//
//  MapView.swift
//  G2_findevents
//
//  Created by Created by Zahra Shahin - Golnaz Chehrazi on 2023-06-25 on 2023-06-26.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    
    @State var evntList:[Event] = []

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Set the region of the map to center around the specified coordinates
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
        
        // Optionally, add an annotation to mark the specified location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
    }
}
