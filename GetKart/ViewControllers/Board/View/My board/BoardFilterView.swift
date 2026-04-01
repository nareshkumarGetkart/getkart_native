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
}


struct BoardFilterView: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var fromDate: Date = Date()
    @State private var toDate: Date = Date()
    @State private var selectedRange: String = ""
    @State private var selectedCategory: String = ""
    @State private var selectedStatus: String = ""
    
    var onFilterApplied:()->Void
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

                       /* HStack(spacing: 12) {
                            DateFieldView(title: "From", date: $fromDate)
                            DateFieldView(title: "To", date: $toDate)
                        }
                        .onChange(of: fromDate) { newValue in
                            if newValue >= toDate {
                                toDate = newValue
                            }
                        }*/
                       
                            ScrollView(.horizontal, showsIndicators: false) {
                               
                                HStack(spacing: 7) {
                                BoardFilterChip(title: "Today", isSelected: selectedRange == "Today") {
                                    selectedRange = "Today"
                                }
                                BoardFilterChip(title: "This Week", isSelected: selectedRange == "This Week") {
                                    selectedRange = "This Week"
                                }
                                
                                BoardFilterChip(title: "Two Week", isSelected: selectedRange == "Two Week") {
                                    selectedRange = "Two Week"
                                }
                                BoardFilterChip(title: "This Month", isSelected: selectedRange == "This Month") {
                                    selectedRange = "This Month"
                                }
                                
                                BoardFilterChip(title: "Three Month", isSelected: selectedRange == "Three Month") {
                                    selectedRange = "Three Month"
                                }
                            }
                            }.padding(.horizontal,2)
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
                           // updateApplyFilterStatus()
                            
                            
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
                            updateApplyFilterStatus()
                            onFilterApplied()
                            presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            let filterCount = (selectedRange.count > 0 ? 1 : 0) + (selectedStatus.count > 0 ? 1 : 0) + ((selectedCategory.count > 0) ? 1 : 0)
                            let titleBtn = (filterCount > 0) ? "Apply Filters(\(filterCount))" : "Apply Filters"
                            Text(titleBtn)
                                .frame(maxWidth: .infinity)
                                .frame(height:50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.inter(.semiBold, size: 14))
                        }
                    }
                }
                .padding(8)
            }.onAppear{
                getAppliedFilterStatus()
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
    
    
    func updateApplyFilterStatus(){
        //Catgeory
        if selectedCategory == "Board"{
            FilterBoard.shared.selectedCategory = 0
        }else if selectedCategory == "Ideas"{
            FilterBoard.shared.selectedCategory = 3

        }else if selectedCategory == "Image Ad"{
            FilterBoard.shared.selectedCategory = 1
        }else if selectedCategory == "Video Ad"{
            FilterBoard.shared.selectedCategory = 2
        }else{
            FilterBoard.shared.selectedCategory = nil
        }
        
        //Status
       // value : 'draft', 'review', 'approved', 'rejected', 'sold out','featured'
         
        if selectedStatus == "Active"{
            FilterBoard.shared.selectedStatus = "approved"

        }else if selectedStatus == "Rejected"{
            FilterBoard.shared.selectedStatus = "rejected"

        }else if selectedStatus == "Inreview"{
            FilterBoard.shared.selectedStatus = "review"

        }else if selectedStatus == "Draft"{
            FilterBoard.shared.selectedStatus = "draft"
        }else{
            FilterBoard.shared.selectedStatus = ""
        }
        
        //Date Range
        //posted_since :  today , within-1-week,within-2-week,within-1-month,within-3-month
        
        if selectedRange == "Today"{
            FilterBoard.shared.selectedRange = "today"

        }else if selectedRange == "This Week"{
            FilterBoard.shared.selectedRange = "within-1-week"
        }else if selectedRange == "Two Week"{
            FilterBoard.shared.selectedRange = "within-2-week"
        }else if selectedRange == "This Month"{
            FilterBoard.shared.selectedRange = "within-1-month"
        }else if selectedRange == "Three Month"{
            FilterBoard.shared.selectedRange = "within-3-month"
        }else{
            FilterBoard.shared.selectedRange = ""
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
            

        }else if FilterBoard.shared.selectedStatus == "draft"{
            
            selectedStatus = "Draft"
            
        }
        
        //Date Range
        //posted_since :  today , within-1-week,within-2-week,within-1-month,within-3-month
        
        if FilterBoard.shared.selectedRange == "today"{
            
            selectedRange = "Today"

        }else if FilterBoard.shared.selectedRange == "within-1-week" {
            
            selectedRange = "This Week"
            
        }else if FilterBoard.shared.selectedRange == "within-2-week" {
            
            selectedRange = "Two Week"
            
        }else if FilterBoard.shared.selectedRange == "within-1-month"{
            selectedRange = "This Month"
        }else if FilterBoard.shared.selectedRange == "within-3-month"{
            selectedRange = "Three Month"
        }
       
    }
}

#Preview {
    BoardFilterView(onFilterApplied: {})
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
                           // .padding(.vertical, 10)
//                            .background(
//                                selected == item
//                                ? Color.orange
//                                : Color.gray.opacity(0.15)
//                            )
                            .foregroundColor(
                                selected == item ? .white : .gray
                            )
//                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//                            .overlay(
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .stroke( selected == item  ? Color.orange : Color.gray.opacity(0.4), lineWidth: 1)
//                                    )
//                        
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
                .frame(minWidth: 89) //  fixed minimum width
                .frame(height:48)
                //.background(isSelected ? Color.orange : Color.gray.opacity(0.1))
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


