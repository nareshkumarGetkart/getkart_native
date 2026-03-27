//
//  BoardFilterView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/03/26.
//

import SwiftUI

struct BoardFilterView: View {

    @State private var fromDate: Date = Date()
    @State private var toDate: Date = Date()
    @State private var selectedRange: String = "This Week"
    @State private var selectedCategory: String = "Board"
    @State private var selectedStatus: String = "Active"
    
    var formattedFromDate: String {
        dateFormatter.string(from: fromDate)
    }

    var formattedToDate: String {
        dateFormatter.string(from: toDate)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }

    var body: some View {
        VStack(spacing: 16) {

            // Drag Indicator
//            Capsule()
//                .fill(Color.gray.opacity(0.4))
//                .frame(width: 40, height: 5)
//                .padding(.top, 8)

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 20) {
                        
                    Spacer()
                    Text("Filter by:")
                        .font(.inter(.semiBold, size: 16))

                    // MARK: Date Range
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Date Range")
                            .font(.inter(.medium, size: 14))

                        HStack(spacing: 12) {
                            DateFieldView(title: "From", date: $fromDate)
                            DateFieldView(title: "To", date: $toDate)
                        }
                        .onChange(of: fromDate) { newValue in
                            if newValue >= toDate {
                                toDate = newValue
                            }
                        }

                        HStack(spacing: 12) {
                            BoardFilterChip(title: "Today", isSelected: selectedRange == "Today") {
                                selectedRange = "Today"
                            }
                            BoardFilterChip(title: "This Week", isSelected: selectedRange == "This Week") {
                                selectedRange = "This Week"
                            }
                            BoardFilterChip(title: "This Month", isSelected: selectedRange == "This Month") {
                                selectedRange = "This Month"
                            }
                        }
                    }

                    // MARK: Category
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Select Ad Category")                        .font(.inter(.medium, size: 14))


                        CategoryScrollView(items: ["Board", "Ideas", "Image Ad", "Video Ad"], selected: $selectedCategory)
                    }

                    // MARK: Status
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Status")
                            .font(.inter(.medium, size: 14))
                        CategoryScrollView(items: ["Active", "Rejected", "Inreview", "Draft"], selected: $selectedStatus)
                    }

                    Divider()

                    // MARK: Buttons
                    HStack(spacing: 16) {

                        Button(action: {
                            resetAll()
                        }) {
                            Text("Reset All")
                                .frame(maxWidth: .infinity)
                                .frame(height:50)
                                //.padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                                .font(.inter(.semiBold, size: 14))

                        }

                        Button(action: {
                            // Apply action
                        }) {
                            Text("Apply Filters(4)")
                                .frame(maxWidth: .infinity)
                                .frame(height:50)
                                //.padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.inter(.semiBold, size: 14))

                        }
                    }
                }
                .padding(9)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }

    func resetAll() {
        selectedRange = ""
        selectedCategory = ""
        selectedStatus = ""
    }
}

#Preview {
    BoardFilterView()
}


struct CategoryScrollView: View {
    
    let items: [String]
    @Binding var selected: String
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 10) {
                
                ForEach(items, id: \.self) { item in
                    
                    Button {
                        selected = item
                    } label: {
                        Text(item)
                            .font(.inter(.semiBold, size: 13))
                            .frame(minWidth: 89) //  fixed minimum width
                            .frame(height:50)
                           // .padding(.vertical, 10)
                            .background(
                                selected == item
                                ? Color.orange
                                : Color.gray.opacity(0.15)
                            )
                            .foregroundColor(
                                selected == item ? .white : .gray
                            )
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}
struct DateFieldView: View {

    var title: String
    @Binding var date: Date

    @State private var showPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Button {
                showPicker = true
            } label: {
                HStack {
                    Text(formatDate(date))
                        .foregroundColor(Color(.label))
                        .font(.inter(.regular, size: 13))

                    Spacer()

                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(height:50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .sheet(isPresented: $showPicker) {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("Done") {
                    showPicker = false
                }.foregroundColor(Color(.systemOrange))
                .padding()
            }
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}

struct BoardFilterChip: View {

    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
               // .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .font(.inter(.semiBold, size: 13))
                .frame(height:50)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(12)
        }
    }
}


