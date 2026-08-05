import SwiftUI
import GooglePlaces

struct PlaceSearchView: View {
    var onPlaceSelected: (SelectedPlace) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var query = ""
    @State private var results: [GMSAutocompletePrediction] = []
    private let searchHelper = PlacesSearch()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#FF9900"))
                    }
                    
                    Spacer()
                    
                    Text("Location")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#FF9900"))
                }.frame(height:44)
                .padding()
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search city, area or locality", text: $query)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .tint(.orange)
                }
                .padding(10).frame(height:50)
               // .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Divider()
                
                // Results list
                List(results, id: \.placeID) { prediction in
                    Button {
                        searchHelper.fetchPlaceDetails(placeID: prediction.placeID) { place in
                               if let place = place {
                                   let selected = SelectedPlace(
                                       name: place.name ?? "",
                                       city: place.city,
                                       state: place.state,
                                       country: place.country,
                                       locality: place.locality,
                                       latitude: place.coordinate.latitude,
                                       longitude: place.coordinate.longitude, formattedAddress: place.formattedAddress
                                   )
                                   onPlaceSelected(selected)
                                   dismiss()
                               }
                           }
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text(prediction.attributedFullText.string)
                                .foregroundColor(Color(.label))
                                .font(.system(size: 16))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(Color(.label))
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
        }
        .onChange(of: query) { newValue in
            guard !newValue.isEmpty else {
                results = []
                return
            }
            searchHelper.searchPlaces(query: newValue) { predictions in
                self.results = predictions
            }
        }
    }
}

class PlacesSearch {
    private let placesClient = GMSPlacesClient.shared()
    
    func searchPlaces(query: String, completion: @escaping ([GMSAutocompletePrediction]) -> Void) {
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        filter.countries = ["IN"]
        //filter.type = .address

        placesClient.findAutocompletePredictions(fromQuery: query,
                                                 filter: filter,
                                                 sessionToken: GMSAutocompleteSessionToken()) { (results, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion([])
                return
            }
            completion(results ?? [])
        }
    }
    
    func fetchPlaceDetails(placeID: String, completion: @escaping (GMSPlace?) -> Void) {
        let fields: GMSPlaceField = [.name, .formattedAddress, .coordinate, .addressComponents]
        
        placesClient.fetchPlace(fromPlaceID: placeID,
                                placeFields: fields,
                                sessionToken: nil) { (place, error) in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(place)
        }
    }
   
}


extension GMSPlace {
    var city: String? {
        return addressComponents?.first(where: { $0.types.contains("locality") })?.name
    }
    
    var state: String? {
        return addressComponents?.first(where: { $0.types.contains("administrative_area_level_1") })?.name
    }
    
    var country: String? {
        return addressComponents?.first(where: { $0.types.contains("country") })?.name
    }
    
    var locality: String? {
        return addressComponents?.first(where: {
            $0.types.contains("sublocality") || $0.types.contains("sublocality_level_1")
        })?.name
    }
}

struct SelectedPlace {
    let name: String
    let city: String?
    let state: String?
    let country: String?
    let locality: String?
    let latitude: Double
    let longitude: Double
    let formattedAddress: String?

}
