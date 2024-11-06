
import SwiftUI
import MapKit
struct DettaglioEventoView: View {
    @EnvironmentObject var shared: Shared
    var event: Event
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        VStack {
            Text(event.title)
                .font(.title)
            Text(event.description)
            Text("Data: \(formattedDate(event.date))")
            Text(event.location)
            Map(
                coordinateRegion: .constant(MKCoordinateRegion(center: event.coordinates, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))),
                showsUserLocation: true,
                userTrackingMode: $userTrackingMode,
                annotationItems: [event]
            ) { event in
                MapPin(coordinate: event.coordinates, tint: .red)
            }
            .frame(height: 400)
            .cornerRadius(60)
            .padding()
            Spacer()
        }
        .padding()
        .navigationTitle("Dettagli Evento")
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
