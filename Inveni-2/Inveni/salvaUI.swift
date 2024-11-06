import Foundation
import MapKit

struct Event: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var description: String
    var location: String
    var coordinates: CLLocationCoordinate2D
    
    init(title: String, date: Date, description: String, location: String, coordinates: CLLocationCoordinate2D) {
        self.title = title
        self.date = date
        self.description = description
        self.location = location
        self.coordinates = coordinates
    }
}

class Shared: ObservableObject {
    @Published var events: [Event] = []
    @Published var userCoordinate: CLLocationCoordinate2D?
    
    func addEvent(_ event: Event) {
        events.append(event)
        userCoordinate = event.coordinates
    }
    
    func eventNamesAndPins() -> [(String, String)] {
        return events.map { ($0.title, "PinEvento") }
    }
    
    
    func eventAnnotations() -> [MKPointAnnotation] {
        return events.map { event in
            let annotation = MKPointAnnotation()
            annotation.coordinate = event.coordinates
            annotation.title = event.title
            return annotation
        }
    }
}






