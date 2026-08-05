//
//  CountryListView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/07/26.
//

import SwiftUI

struct CountryListView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var countries: [Countries] = []
    @State private var selectedCountryId: Int?

    /// Callback to return the selected country
    var onCountrySelected: ((Countries) -> Void)?

    var body: some View {

        VStack(spacing: 0) {

            Text("Country/Region")
                .font(.headline)
                .padding()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(countries, id: \.id) { country in
                        CountryCellView(
                            obj: country,
                            isSelected: selectedCountryId == country.id
                        ) {
                            selectedCountryId = country.id
                            onCountrySelected?(country)
                            dismiss()        // Dismiss after selection
                        }

                        Divider()
                    }
                }
            }
        }
        .onAppear {
            getCountries()
        }
    }

    // MARK: API

    func getCountries() {
        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: true,
            url: Constant.shared.get_countries
        ) { (obj: CountriesModal) in
            self.countries = obj.data ?? []
        }
    }
}
