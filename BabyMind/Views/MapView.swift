//
//  MapView.swift
//
//  Harita görünümü (Google Maps benzeri)
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var institutions: [HealthInstitution]
    @Binding var userLocation: CLLocation?
    let onInstitutionTap: (HealthInstitution) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // Harita stilini ayarla
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        
        // Clustering'i etkinleştir (iOS 11+)
        if #available(iOS 11.0, *) {
            mapView.register(
                MKMarkerAnnotationView.self,
                forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
            )
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Eski annotation'ları temizle
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        
        // Kurumları annotation olarak ekle
        for institution in institutions {
            if let location = institution.location {
                let annotation = InstitutionAnnotation(institution: institution)
                annotation.coordinate = location.coordinate
                annotation.title = institution.name
                annotation.subtitle = institution.type.rawValue
                mapView.addAnnotation(annotation)
            }
        }
        
        // Kullanıcı konumunu merkeze al
        if let userLocation = userLocation {
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
            mapView.setRegion(region, animated: true)
        } else if let firstInstitution = institutions.first(where: { $0.location != nil }),
                  let location = firstInstitution.location {
            // Kullanıcı konumu yoksa ilk kurumu merkeze al
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Kullanıcı konumu için varsayılan görünümü kullan
            if annotation is MKUserLocation {
                return nil
            }
            
            guard let institutionAnnotation = annotation as? InstitutionAnnotation else {
                return nil
            }
            
            let identifier = "InstitutionAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            // Clustering özelliklerini ayarla
            annotationView?.canShowCallout = true
            annotationView?.clusteringIdentifier = "HealthInstitution"
            annotationView?.displayPriority = .required
            
            // Buton ekle
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
            
            // Tip'e göre renk
            let color = institutionAnnotation.institution.type.color
            annotationView?.markerTintColor = UIColor(
                red: CGFloat(color.red),
                green: CGFloat(color.green),
                blue: CGFloat(color.blue),
                alpha: 1.0
            )
            annotationView?.glyphImage = UIImage(systemName: institutionAnnotation.institution.type.icon)
            annotationView?.glyphTintColor = .white
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let institutionAnnotation = view.annotation as? InstitutionAnnotation else { return }
            parent.onInstitutionTap(institutionAnnotation.institution)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let institutionAnnotation = view.annotation as? InstitutionAnnotation else { return }
            // Annotation seçildiğinde bilgi göster
        }
    }
}

// Custom Annotation Class
class InstitutionAnnotation: NSObject, MKAnnotation {
    let institution: HealthInstitution
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(institution: HealthInstitution) {
        self.institution = institution
        if let location = institution.location {
            self.coordinate = location.coordinate
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        self.title = institution.name
        self.subtitle = institution.type.rawValue
    }
}


