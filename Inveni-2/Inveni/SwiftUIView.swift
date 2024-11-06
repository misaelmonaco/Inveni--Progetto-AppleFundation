import SwiftUI
import CoreLocation
import MapKit
struct SwiftUIView: View {
    @State var searchText: String = ""
    @State var isModalPresented = false
    @EnvironmentObject var shared: Shared
    @Binding var userCoordinate: CLLocationCoordinate2D?

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CreaEventoView()) {
                    Text("Crea Evento")
                        .colorMultiply(.orange)
                        .bold()
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(50)
                }
                .padding()

                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 0.5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.clear)
                                .overlay(
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(shared.eventNamesAndPins(), id: \.0) { name, pinImage in
                                                VStack {
                                                    Image(pinImage)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 90, height: 90)
                                                        .clipped()

                                                    Text(name)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                        }
                                        .padding(10)
                                        .frame(height: isModalPresented ? 180 : geometry.size.height)
                                    }
                                )
                        )
                        .padding(10)
                        .frame(height: isModalPresented ? 180 : nil)
                }

                Spacer()

                List {
                    ForEach(shared.events) { event in
                        NavigationLink(destination: DettaglioEventoView(event: event, selectedLocation: $userCoordinate)) {
                            Text(event.title)
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                }
            }
            .onAppear {
                if let lastEvent = shared.events.last {
                    userCoordinate = lastEvent.coordinates
                } else {
                    userCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                }
            }
            }
        }
    }


struct CreaEventoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var newEvent = Event(title: "", date: Date(), description: "", location: "", coordinates: CLLocationCoordinate2D())
    @EnvironmentObject var shared: Shared
    @ObservedObject var locationViewModel = LocationViewModel()
    
    var body: some View {
            NavigationView {
                Form {
                    TextField("Titolo", text: $newEvent.title)
                    DatePicker("Data", selection: $newEvent.date, displayedComponents: .date)
                    TextField("Descrizione", text: $newEvent.description)
                    
                    Button("Salva") {
                        if let currentLocation = locationViewModel.currentLocation {
                            newEvent.coordinates = currentLocation.coordinate
                            newEvent.location = "Your Location Name" // Imposta il nome della posizione reale qui
                        }
                        shared.addEvent(newEvent) // Aggiorna la posizione nell'oggetto Shared
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .navigationTitle("Nuovo Evento")
                .onAppear {
                    locationViewModel.requestAuthorization()
                    locationViewModel.getCurrentLocation()
                }
            }
        }
    
    
    
    
    class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
            @Published var currentLocation: CLLocation?
            private var locationManager = CLLocationManager()

            override init() {
                super.init()
                locationManager.delegate = self
            }

            func requestAuthorization() {
                locationManager.requestWhenInUseAuthorization()
            }

            func getCurrentLocation() {
                locationManager.requestLocation()
            }

            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                guard let location = locations.first else { return }
                currentLocation = location
            }

            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                print("Error getting location: \(error.localizedDescription)")
            }
        }

        struct SwiftUIView_Previews: PreviewProvider {
            static var previews: some View {
                let shared = Shared()
                return SwiftUIView(userCoordinate: .constant(nil)).environmentObject(shared)
            }
        }
    }
