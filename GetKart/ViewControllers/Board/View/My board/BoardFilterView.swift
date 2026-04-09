//
//  BoardFilterView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/03/26.
//

import SwiftUI


final class FilterBoard{
    
    static let shared = FilterBoard()
    private init(){ }
    
    var fromDate = ""
    var toDate = ""
    var selectedRange = ""
    var selectedCategory:Int?
    var selectedStatus = ""
    
    
    func removeSavedFilter(){
        FilterBoard.shared.fromDate = ""
        FilterBoard.shared.toDate = ""
        FilterBoard.shared.selectedRange = ""
        FilterBoard.shared.selectedCategory = nil
        FilterBoard.shared.selectedStatus = ""
    }
}


struct BoardFilterView: View {

    @Environment(\.presentationMode) var presentationMode
    
    @State private var fromDate: Date? = nil
    @State private var toDate: Date? = nil
    
    @State private var selectedRange: String = ""
    @State private var selectedCategory: String = ""
    @State private var selectedStatus: String = ""
    
    var onFilterApplied:()->Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
    
    var formattedFromDate: String {
        fromDate != nil ? dateFormatter.string(from: fromDate!) : ""
    }

    var formattedToDate: String {
        toDate != nil ? dateFormatter.string(from: toDate!) : ""
    }
    
    var isDateSelected: Bool {
        fromDate != nil || toDate != nil
    }
    
    var isValidDateRange: Bool {
        fromDate != nil && toDate != nil
    }

    var isPartialDateSelected: Bool {
        (fromDate != nil && toDate == nil) ||
        (fromDate == nil && toDate != nil)
    }

    
    var body: some View {
        VStack(spacing: 16) {

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 20) {
                        
                    Text("Filter by:")
                        .font(.inter(.semiBold, size: 16)).padding(.top)

                    // MARK: Date Range
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Date Range")
                            .font(.inter(.medium, size: 14))

                        HStack(spacing: 12) {
                            
                            DateFieldView(
                                title: "From",
                                date: $fromDate,
                                isHighlighted: isDateSelected
                            )
                            
                            DateFieldView(
                                title: "To",
                                date: $toDate,
                                isHighlighted: isDateSelected
                            )
                        }
                        
                        //  Clear quick filter when date selected
                        .onChange(of: fromDate) { newFrom in
                            guard let newFrom else { return }
                            
                            // Clear quick filter
                            selectedRange = ""
                            
                            // Fix: From should not be greater than To
                            if let to = toDate, newFrom > to {
                                toDate = newFrom
                            }
                        }

                        .onChange(of: toDate) { newTo in
                            guard let newTo else { return }
                            
                            // Clear quick filter
                            selectedRange = ""
                            
                            // Fix: To should not be less than From
                            if let from = fromDate, newTo < from {
                                fromDate = newTo
                            }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {

                                chip("Today")
                                chip("Last 7 days")
                                chip("Last 14 days")
                                chip("Last 30 days")
                                chip("Last 3 Months")
                            }
                        }
                    }

                    // MARK: Category
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Ad Category")
                            .font(.inter(.medium, size: 14))

                        CategoryScrollView(
                            items: ["Board", "Ideas", "Image Ad", "Video Ad"],
                            selected: $selectedCategory
                        )
                    }

                    // MARK: Status
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Status")
                            .font(.inter(.medium, size: 14))

                        CategoryScrollView(
                            items: ["Active", "Rejected", "Inreview", "Sponsored"],
                            selected: $selectedStatus
                        )
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
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                                .font(.inter(.semiBold, size: 14))
                        }
                        
                        Button(action: {
//                            if isPartialDateSelected {
//                                AlertView.sharedManager.showToast(message: "Please select both From and To date")
//                                return
//                            }
                           
                            updateApplyFilterStatus()
                            onFilterApplied()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            
                            let filterCount =
                            (selectedRange.isEmpty ? 0 : 1) +
                            (selectedStatus.isEmpty ? 0 : 1) +
                            (selectedCategory.isEmpty ? 0 : 1) +
                             (isValidDateRange ? 1 : 0)
                             
                            let title = filterCount > 0
                            ? "Apply Filters(\(filterCount))"
                            : "Apply Filters"
                            
                            Text(title)
                                .frame(maxWidth: .infinity)
                                .frame(height:50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.inter(.semiBold, size: 14))
                        }.disabled(isPartialDateSelected)
                        .opacity(isPartialDateSelected ? 0.5 : 1)
                    }
                }
                .padding(8)
            }
            .onAppear {
                getAppliedFilterStatus()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .padding(.horizontal,2)
    }
}

#Preview {
    BoardFilterView(onFilterApplied: {})
}

extension BoardFilterView {
    
    func chip(_ title: String) -> some View {
        BoardFilterChip(
            title: title,
            isSelected: selectedRange == title
        ) {
            selectedRange = title
            
            //  Clear dates when chip selected
            fromDate = nil
            toDate = nil
        }
    }
}

extension BoardFilterView {
    
    func resetAll() {
        selectedRange = ""
        selectedCategory = ""
        selectedStatus = ""
        fromDate = nil
        toDate = nil
    }
    
    func updateApplyFilterStatus(){
        
        // Category
        switch selectedCategory {
        case "Board": FilterBoard.shared.selectedCategory = 0
        case "Ideas": FilterBoard.shared.selectedCategory = 3
        case "Image Ad": FilterBoard.shared.selectedCategory = 1
        case "Video Ad": FilterBoard.shared.selectedCategory = 2
        default: FilterBoard.shared.selectedCategory = nil
        }
        
        // Status
        switch selectedStatus {
        case "Active": FilterBoard.shared.selectedStatus = "approved"
        case "Rejected": FilterBoard.shared.selectedStatus = "rejected"
        case "Inreview": FilterBoard.shared.selectedStatus = "review"
        case "Sponsored": FilterBoard.shared.selectedStatus = "featured"
        default: FilterBoard.shared.selectedStatus = ""
        }
        
        // Range
        switch selectedRange {
        case "Today": FilterBoard.shared.selectedRange = "today"
        case "Last 7 days": FilterBoard.shared.selectedRange = "within-1-week"
        case "Last 14 days": FilterBoard.shared.selectedRange = "within-2-week"
        case "Last 30 days": FilterBoard.shared.selectedRange = "within-1-month"
        case "Last 3 Months": FilterBoard.shared.selectedRange = "within-3-month"
        default: FilterBoard.shared.selectedRange = ""
        }
        
        // 👉 SAVE DATES
//        FilterBoard.shared.fromDate = formattedFromDate
//        FilterBoard.shared.toDate = formattedToDate
        
        // ✅ Date Handling
        if isValidDateRange {
            FilterBoard.shared.fromDate = formattedFromDate
            FilterBoard.shared.toDate = formattedToDate
            
            // ❗ When custom date is used → remove quick filter
            FilterBoard.shared.selectedRange = ""
            
        } else {
            // ❌ Incomplete date → ignore both
            FilterBoard.shared.fromDate = ""
            FilterBoard.shared.toDate = ""
        }
    }
    
    func getAppliedFilterStatus(){
        //Catgeory
        if FilterBoard.shared.selectedCategory == 0{
            selectedCategory = "Board"
            
        }else if FilterBoard.shared.selectedCategory == 3{
            
            selectedCategory = "Ideas"
            
        }else if FilterBoard.shared.selectedCategory == 1{
            selectedCategory = "Image Ad"
            
        }else if  FilterBoard.shared.selectedCategory == 2{
            
            selectedCategory = "Video Ad"
        }
        
        //Status
        // value : 'draft', 'review', 'approved', 'rejected', 'sold out','featured'
        
        if  FilterBoard.shared.selectedStatus == "approved"{
            selectedStatus = "Active"
            
            
        }else if FilterBoard.shared.selectedStatus == "rejected" {
            
            selectedStatus = "Rejected"
            
            
        }else if FilterBoard.shared.selectedStatus == "review"{
            
            selectedStatus = "Inreview"
            
            
        }else if FilterBoard.shared.selectedStatus == "featured"{
            
            selectedStatus = "Sponsored"
            
        }
        
        //Date Range
        //posted_since :  today , within-1-week,within-2-week,within-1-month,within-3-month
        
        if FilterBoard.shared.selectedRange == "today"{
            
            selectedRange = "Today"
            
        }else if FilterBoard.shared.selectedRange == "within-1-week" {
            
            selectedRange = "Last 7 days"
            
        }else if FilterBoard.shared.selectedRange == "within-2-week" {
            
            selectedRange = "Last 14 days"
            
        }else if FilterBoard.shared.selectedRange == "within-1-month"{
            selectedRange = "Last 30 days"
        }else if FilterBoard.shared.selectedRange == "within-3-month"{
            selectedRange = "Last 3 Months"
        }
        
        if !FilterBoard.shared.fromDate.isEmpty {
            fromDate = convertToDate(FilterBoard.shared.fromDate)
        }
        
        if !FilterBoard.shared.toDate.isEmpty {
            toDate = convertToDate(FilterBoard.shared.toDate)
        }
    }
    
    func convertToDate(_ string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
}
struct CategoryScrollView: View {
    
    let items: [String]
    @Binding var selected: String
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 7) {
                
                ForEach(items, id: \.self) { item in
                    
                    Button {
                        selected = item
                    } label: {
                        Text(item)
                            .font(.inter(.semiBold, size: 13))
                            .frame(minWidth: 89) //  fixed minimum width
                            .frame(height:48)
                            .foregroundColor(
                                selected == item ? .white : .gray
                            )
                   
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(selected == item ? Color.orange : Color.gray.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(selected == item ? Color.orange : Color.gray.opacity(0.25), lineWidth: 0.8)
                            )
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

struct DateFieldView: View {

    var title: String
    @Binding var date: Date?
    var isHighlighted: Bool
    
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
                    Text(date != nil ? formatDate(date!) : "Select Date")
                        .foregroundColor(.primary)
                        .font(.inter(.regular, size: 13))

                    Spacer()

                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(height:50)
                .background(Color.gray.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHighlighted ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(12)
            }
        }
       /* .sheet(isPresented: $showPicker) {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { date ?? Date() },
                        set: { date = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("Done") {
                    showPicker = false
                }
                .foregroundColor(.orange)
                .padding()
            }
        }*/
        
        .sheet(isPresented: $showPicker) {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { date ?? Calendar.current.startOfDay(for: Date()) },
                        set: {
                            date = Calendar.current.startOfDay(for: $0)
                            showPicker = false
                        }
                    ),
                    in: ...Date(),   //  restrict future dates
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("Done") {
                    if date == nil {
                        date = Calendar.current.startOfDay(for: Date())
                    }
                    showPicker = false
                }
                .foregroundColor(.orange)
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
                .frame(maxWidth: .infinity)
                .font(.inter(.semiBold, size: 13))
                .frame(minWidth: 95) //  fixed minimum width
                .frame(height:48)
                .foregroundColor(isSelected ? .white : .gray)
                
        }.background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? Color.orange : Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? Color.orange : Color.gray.opacity(0.25), lineWidth: 0.8)
        )
        .clipped()
    }
}


