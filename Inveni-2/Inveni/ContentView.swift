import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var userCoordinate: CLLocationCoordinate2D?
    @State private var modalOffset: CGSize = .zero
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    private let minModalOffset: CGFloat = UIScreen.main.bounds.height * 0.125
    private let maxModalOffset: CGFloat = UIScreen.main.bounds.height * 0.90
    @State private var isShowingModal = true
    @StateObject var shared = Shared()
    
    var body: some View {
        VStack {
            MapView(userCoordinate: $userCoordinate, events: shared.events)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    requestUserLocationAuthorization()
                }
                .frame(maxWidth: .infinity)
                .background(Color.black)
                
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black.opacity(0.5))
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingModal, content: {
            SwiftUIView(userCoordinate: $userCoordinate).environmentObject(shared)
                .interactiveDismissDisabled(true)
                .presentationDetents([.fraction(0.25), .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
        })
    }

    private func requestUserLocationAuthorization() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
}
struct MapView: UIViewRepresentable {
    @Binding var userCoordinate: CLLocationCoordinate2D?
    var events: [Event]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let userCoordinate = userCoordinate {
            uiView.setCenter(userCoordinate, animated: true)
        }

        uiView.removeAnnotations(uiView.annotations)
        for event in events {
            let annotation = MKPointAnnotation()
            annotation.coordinate = event.coordinates
            annotation.title = event.title
            uiView.addAnnotation(annotation)
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
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "EventPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = CustomPinView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
}

class CustomPinView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let eventAnnotation = newValue as? MKPointAnnotation else { return }
            image = UIImage(named: "PinEvento")?.resize(targetSize: CGSize(width: 30, height: 30))
           
        }
    }
}


extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
struct C: View {
    @State var nomi = ["Pippo", "Topolino", "Pluto", "Minnie"]
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(searched, id: \.self) { nome in
                    Text(nome)
                }
                .onDelete { indexSet in
                    self.nomi.remove(atOffsets: indexSet)
                }
            }
        }
        .frame(maxWidth: .infinity) 
        .navigationTitle("Mia lista")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var searched: [String] {
        if searchText.isEmpty {
            return nomi
        }
        return nomi.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



