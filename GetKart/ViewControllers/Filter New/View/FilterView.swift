//
//  FilterView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/06/25.
//

import SwiftUI

struct FilterView: View {
    
    var navigation:UINavigationController?
    var categoryId:String?
    var categImg:String?
    var categoryName:String?
    @StateObject var fieldVM = FIlterViewModel()

    var filterDict:Dictionary<String,Any>? = nil
    var fieldArray:[CustomField]? = nil
    var onApplyFilter: ([String: Any],[CustomField]) -> Void
    var selectedIndex = -1
    @State var searchText = ""
    
    @State var showClearAlert:Bool = false
    
    var body: some View {

        HStack{
            Text("FILTER").padding(.top)
            Spacer()
            Button {
                navigation?.dismiss(animated: true)
            } label: {
                Image("close-small").renderingMode(.template)
                    .foregroundColor(Color(.label))
                    .padding(5).padding(.top)
            }

        }.padding([.leading,.trailing])
            .onAppear{
                if  fieldVM.fieldsArray.count == 0{
                    
                    if (fieldArray?.count ?? 0) > 0{
                        fieldVM.fieldsArray = fieldArray ?? []
                        fieldVM.dictCustomFields = filterDict ?? [:]
                        fieldVM.selectedIndex = selectedIndex
                    }else{

                        fieldVM.getCustomFieldsListApi(category_ids: self.categoryId ?? "")
                    }
                   
                }
            }
        Divider().background(Color.gray)
        HStack{
            VStack{
                ScrollView{
                ForEach(fieldVM.fieldsArray.indices, id: \.self) { index in
                    let item = fieldVM.fieldsArray[index]
                    
                    HStack {
                        // Left vertical colored bar
                        Rectangle()
                            .fill(index == fieldVM.selectedIndex ? Color.orange : Color.clear)
                            .frame(width: 3).cornerRadius(8.0)
                        
                        
                        Text(item.name ?? "")
                            .font(Font.manrope(.medium, size: 16))
                            .foregroundColor(index == fieldVM.selectedIndex ? .orange : Color(.label))
                            .background(Color.clear)
                            .contentShape(Rectangle()) // makes full area tappable
                        Spacer()
                    }.frame(minHeight:35)//.padding([.leading,.trailing])
                        .background(Color.clear)
                    
                    
                        .onTapGesture {
                            fieldVM.selectedIndex = index
                        }
                }
                
                Spacer()
                
                }//.padding(0)
                
            }.frame(width: 140)
             //.padding()
            Divider().background(Color.gray)
            
            VStack{
                if fieldVM.selectedIndex < fieldVM.fieldsArray.count && fieldVM.selectedIndex >= 0 {
                    if (fieldVM.fieldsArray[fieldVM.selectedIndex].values?.count ?? 0) > 12{
                        HStack{
                            
                            TextField("Search \(fieldVM.fieldsArray[fieldVM.selectedIndex].name ?? "")...", text: $searchText).tint(.orange)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                //.padding(.horizontal)
                                .onChange(of: searchText) { newValue in
                                    
                                }
                        }
                    }
                }
                ScrollView{
                    if fieldVM.selectedIndex >= 0,fieldVM.fieldsArray.count > fieldVM.selectedIndex {
                        let item = fieldVM.fieldsArray[fieldVM.selectedIndex]
                        
                        HStack{
                            if item.type == .sortby{
                                Text("\((item.name ?? "").uppercased())")
                                    .font(Font.manrope(.medium, size: 16.0))
                            }else{
                                Text("FILTER BY \((item.name ?? "").uppercased())")
                                    .font(Font.manrope(.medium, size: 16.0))
                            }
                            Spacer()
                        }
                       
                        if fieldVM.selectedIndex > 0{
                            
                            HStack{
                                
                                Text("Choose from options below").font(Font.manrope(.regular, size: 11.0))
                                Spacer()
                            }.padding(.bottom,10)
                        }
                    
                        if item.type == .category{
                    
                            CategoryViewFilter(title: categoryName ?? "", icomImgUrl: categImg ?? "")
                            
                        }else if item.type == .checkbox{
                            //Checkbox View
                            if let unwrappedVal = item.values {
                              
                                let unwrappedValues = returnSearchedText(mainArray: item.values)
                               // unwrappedValues = returnSearchedText(mainArray: item.values)
                                
                                ForEach(Array(unwrappedValues.enumerated()), id: \.offset) { index, value in
                                    
                                    CheckBoxSelectionView(
                                               title: value ?? "",
                                               isSelected: fieldVM.fieldsArray[fieldVM.selectedIndex].value?.contains(value) == true
                                           )
                                    
                                    .onTapGesture {
                                        // handle tap on index
                                        
                                        guard let value = value else { return }
                                        var objCustomField = fieldVM.fieldsArray[fieldVM.selectedIndex]
                                        
                                        if objCustomField.value?.contains(value) == true {
                                            objCustomField.value?.removeAll { $0 == value }
                                            let joinedStr = objCustomField.value?.compactMap{$0}.joined(separator: ",")
                                            fieldVM.dictCustomFields["\(objCustomField.id ?? 0)"] = joinedStr

                                        } else {
                                            if objCustomField.value == nil {
                                                objCustomField.value = []
                                            }
                                            objCustomField.value?.append(value)
                                            let joinedStr = objCustomField.value?.compactMap{$0}.joined(separator: ",")
                                            fieldVM.dictCustomFields["\(objCustomField.id ?? 0)"] = joinedStr
                                        }
                                        // Replace the whole struct to trigger  update
                                        fieldVM.fieldsArray[fieldVM.selectedIndex] = objCustomField
                                    }
                                }
                            } else {
                                Text("No data available")
                            }
                            
                            
                            
                        }else   if item.type == .radio{
                            
                            if let unwrappedValues = item.values {
                                ForEach(Array(unwrappedValues.enumerated()), id: \.offset) { index, value in
                                    
                                    RadioSelectionView(title: value ?? "", isSelected: fieldVM.fieldsArray[fieldVM.selectedIndex].value?.contains(value) == true)
                                    
                                        .onTapGesture {
                                            // handle tap on index
                                            
                                            guard let value = value else { return }
                                            
                                            var objCustomField = fieldVM.fieldsArray[fieldVM.selectedIndex]
                                            objCustomField.value?.removeAll()
                                            fieldVM.dictCustomFields["\(objCustomField.id ?? 0)"] = ""

                                            if objCustomField.value == nil {
                                                objCustomField.value = []
                                            }
                                            objCustomField.value?.append(value)
                                            fieldVM.dictCustomFields["\(objCustomField.id ?? 0)"] = value

                                            // Replace the whole struct to trigger  update
                                            fieldVM.fieldsArray[fieldVM.selectedIndex] = objCustomField
                                        }
                                }
                            } else {
                                Text("No data available")
                            }
                        }else if item.type == .sortby{
                            if let unwrappedValues = item.values {
                                
                                ForEach(Array(unwrappedValues.enumerated()), id: \.offset) { index, value in
                                    
                                    SortSelectionView(title: value ?? "", isSelected: fieldVM.fieldsArray[fieldVM.selectedIndex].value?.contains(value) == true)
                                        .onTapGesture {
                                            
                                            guard let value = value else { return }
                                            
                                            var objCustomField = fieldVM.fieldsArray[fieldVM.selectedIndex]
                                            objCustomField.value?.removeAll()
                                            
                                            if objCustomField.value == nil {
                                                objCustomField.value = []
                                            }
                                            objCustomField.value?.append(value)
                                            
                                             let str = value.lowercased()
                                                .replacingOccurrences(of: " ", with: "-")
                                            fieldVM.dictCustomFields["sort_by"] = str
                                            // Replace the whole struct to trigger  update
                                            fieldVM.fieldsArray[fieldVM.selectedIndex] = objCustomField
                                        }
                                }
                            }
                        }else if item.type == .range{
                            
                            if let unwrappedValues = item.ranges {
                                buildRangeList(for: unwrappedValues)
                            }

                            rangeSliderView

                            
                           
                        }
                        
                    }
                    
                    Spacer()
                }//.padding(0)
            }.padding([.leading,.trailing],8)
                        
        }.padding([.top,.bottom],0)
        
        Divider()
        HStack{
            
            Button {
                
              /*  fieldVM.selectedIndex = 0
                fieldVM.dictCustomFields.removeAll()
                for (index,_) in fieldVM.fieldsArray.enumerated(){
                    var objCustomField = self.fieldVM.fieldsArray[index]
                    if objCustomField.value?.count ?? 0 > 0 {
                    }
                    // objCustomField.value?[0] = ""
                    objCustomField.value?.removeAll()
                    
                    // dictCustomFields["\(objCustomField.id ?? 0)"] = ""
                    objCustomField.selectedMaxValue = nil // objCustomField.maxPrice
                    objCustomField.selectedMinValue = nil //objCustomField.minPrice
                    fieldVM.fieldsArray[index] = objCustomField
                    */
                showClearAlert = true
                 
            } label: {
                Text("Clear Filters")
                    .frame(width: 120)
                    .foregroundColor(Color(Themes.sharedInstance.themeColor))

            }
            
            
            
            Button {
                      
                for (index,obj) in fieldVM.fieldsArray.enumerated(){

                    if obj.type == .range{
                        if let min = obj.selectedMinValue, let max = obj.selectedMaxValue{
                            fieldVM.dictCustomFields["\(obj.id ?? 0)"] = "\(Int(min)),\(Int(max))"
                        }else if let min = obj.selectedMinValue{
                            fieldVM.fieldsArray[index].selectedMaxValue = obj.maxPrice ?? 0
                            fieldVM.dictCustomFields["\(obj.id ?? 0)"] = "\(Int(min)),\(Int(obj.maxPrice ?? 0))"

                        }else if let max = obj.selectedMaxValue{
                            fieldVM.fieldsArray[index].selectedMinValue = obj.minPrice ?? 0
                            fieldVM.dictCustomFields["\(obj.id ?? 0)"] = "\(Int(obj.minPrice ?? 0)),\(Int(max))"
                        }
                    }
                    
                }
                self.navigation?.dismiss(animated: true, completion: {
                    onApplyFilter(fieldVM.dictCustomFields, fieldVM.fieldsArray)

                })
    
                
            } label: {
                Text("Apply")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(Themes.sharedInstance.themeColor))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }.padding(.leading,30).padding(.trailing,10)

        }.ignoresSafeArea()
        
        
            .alert("Want to clear all filter changes?", isPresented: $showClearAlert) {
                Button("Cancel", role: .none) {
                            // Cancel action
                        }.foregroundColor(.blue)
                
                Button("Clear", role: .none) {
                            // Clear action
                            print("Filters cleared")
                            clearFilterAlert()
                        }.foregroundColor(.blue)
                
               
                    } message: {
                        Text("You modified some filters. This action will clear all the filter selections.")
                    }
        

    }
    
    
   
    func isRangeSelected(_ value: PriceRange) -> Bool {
        let selectedField = fieldVM.fieldsArray[fieldVM.selectedIndex]
        let isMinEqual =  selectedField.selectedMinValue == value.min
        let isMaxEqual = selectedField.selectedMaxValue == value.max
        let bothEqual = isMinEqual && isMaxEqual
        
        return bothEqual
               
    }
    
    @ViewBuilder
    func buildRangeList(for ranges: [PriceRange]) -> some View {
        ForEach(Array(ranges.enumerated()), id: \.offset) { index, value in
            let isSelected = isRangeSelected(value)

            RangePriceView(isSelected: isSelected, obj: value)
                .onTapGesture {
                    var objCustomField = fieldVM.fieldsArray[fieldVM.selectedIndex]
                    objCustomField.selectedMinValue = value.min
                    objCustomField.selectedMaxValue = value.max
                    fieldVM.fieldsArray[fieldVM.selectedIndex] = objCustomField
                }
        }
    }

    
    var rangeSliderView: some View {
        let selectedItem = fieldVM.fieldsArray[fieldVM.selectedIndex]
        let maxVal: Double = selectedItem.maxPrice ?? 0
        let minVal: Double = selectedItem.minPrice ?? 0

        let modelBinding = Binding<CustomField>(
            get: { fieldVM.fieldsArray[fieldVM.selectedIndex] },
            set: { fieldVM.fieldsArray[fieldVM.selectedIndex] = $0 }
        )

        let lowerBinding = Binding<Double>(
            get: { selectedItem.selectedMinValue ?? minVal },
            set: { fieldVM.fieldsArray[fieldVM.selectedIndex].selectedMinValue = $0 }
        )

        let upperBinding = Binding<Double>(
            get: { selectedItem.selectedMaxValue ?? maxVal },
            set: { fieldVM.fieldsArray[fieldVM.selectedIndex].selectedMaxValue = $0 }
        )

        return RangeViewFilter(
            model: modelBinding,
            lowerValue: lowerBinding,
            upperValue: upperBinding,
            maxValue: maxVal,
            lowerRangeValue: minVal,
            upperRangeValue: maxVal
        )
    }
    
    
    func returnSearchedText(mainArray: [String?]?) -> [String?] {
        guard let values = mainArray else { return [] }
        return searchText.isEmpty ? values : values.filter {
            ($0?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    
    func clearFilterAlert(){
        
        fieldVM.selectedIndex = 0
        fieldVM.dictCustomFields.removeAll()
        for (index,_) in fieldVM.fieldsArray.enumerated(){
            var objCustomField = self.fieldVM.fieldsArray[index]
            if objCustomField.value?.count ?? 0 > 0 {
            }
            // objCustomField.value?[0] = ""
            objCustomField.value?.removeAll()
            
            // dictCustomFields["\(objCustomField.id ?? 0)"] = ""
            objCustomField.selectedMaxValue = nil // objCustomField.maxPrice
            objCustomField.selectedMinValue = nil //objCustomField.minPrice
            fieldVM.fieldsArray[index] = objCustomField
        }
    }

}

#Preview {
    FilterView(filterDict: [:], fieldArray: [], onApplyFilter: {dict,arr in})
}


extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
struct CategoryViewFilter:View {
    var title:String = ""
    var icomImgUrl:String = ""

    var body: some View {
        
        HStack{
            
            AsyncImage(url: URL(string: icomImgUrl)) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50,height: 50)
                    .cornerRadius(10)
                    .clipped()
                    .padding(.leading,5)
            } placeholder: {
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 50,height: 50).cornerRadius(10)
                
            }
            Text(title).font(Font.manrope(.regular, size: 15.0))
            Spacer()
        }.overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5)
        )
    }
}


struct RadioSelectionView:View {
    var title:String = ""
    var isSelected: Bool
    var body: some View {
        
        HStack{
            (isSelected ? Image("radio_sel") : Image("radio_un"))
            Text(title)
            Spacer()
        }
    }
}


struct CheckBoxSelectionView: View {
    var title: String
    var isSelected: Bool
    var body: some View {
        HStack {
            (isSelected ? Image("checkbox_sel") : Image("checkbox_un"))
            Text(title).font(Font.manrope(.regular, size: 14.0))
             .foregroundColor(Color(UIColor.label))
            Spacer()
        }
    }
}


struct RangePriceView:View {
    var isSelected:Bool
    var obj:PriceRange
    
    var body: some View {
        
        HStack{
            Text(obj.label ?? "").font(Font.manrope(.regular, size: 12)).padding(.leading)
            Spacer()
            if (obj.count ?? 0) > 0{
                Text("\(obj.count ?? 0)+ items").font(Font.manrope(.regular, size: 12)).padding(.trailing)
            }

        }.frame(height: 35)
        .background(
            RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.orange.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5).shadow(radius: 10.0)
        )
        .contentShape(Rectangle())
    }
}


struct SortSelectionView:View {
    
    var title:String
    var isSelected : Bool
    
    var body: some View {
        
        HStack{
            Text(title).font(Font.manrope(.regular, size: 12)).padding(.leading)
            Spacer()

        }.frame(height: 35).overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5).shadow(radius: 10.0)
        )//.padding(.top,2.5)
        .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.orange.opacity(0.1) : Color.clear)
                )
        .contentShape(Rectangle())
    }
    
}

struct RangeViewFilter:View {
    
    @Binding var model: CustomField
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    
    var maxValue: Double
    var istoHideTextField: Bool = true
    
    @State private var minVal: String = ""
    @State private var maxVal: String = ""
    
    
    var lowerRangeValue: Double
    var upperRangeValue: Double
    
    
    var body: some View {
        
        VStack{
            
            if istoHideTextField == false {
                HStack{
                    TextField("Min", text: $minVal).frame(height: 40).padding(.horizontal, 10).keyboardType(.numberPad).tint(.orange)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.0)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    Spacer(minLength: 15)
                    TextField("Max", text: $maxVal).frame(height: 40).padding(.horizontal, 10).keyboardType(.numberPad).tint(.orange)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.0)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                }
            }
            
            Image("Graph").frame(height: 130).aspectRatio(contentMode: .fit)
            
            RangeSlider(lowerValue: $lowerValue, upperValue: $upperValue, minValue: lowerRangeValue, maxValue: upperRangeValue).padding([.leading,.trailing],10)
            
            // Min/Max value display
            HStack {
                Text("\(AttributedString(String(format: "%.0f", lowerValue)))")
                Spacer()
                
//                if upperValue == maxValue{
//                    Text("\(AttributedString(String(format: "%.0f+", upperValue)))")
//
//                }else{
                    Text("\(AttributedString(String(format: "%.0f", upperValue)))")

               // }
            }.padding([.leading,.trailing],8)
                .font(.caption)
       

        }
    }
}





struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double

    var minValue: Double
    var maxValue: Double
    let minimumGap: Double = 1

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let thumbSize: CGFloat = 20
            let range = maxValue - minValue
            
            // Convert values to positions
            let lowerRatio = (lowerValue - minValue) / range
            let upperRatio = (upperValue - minValue) / range

            let lowerX = CGFloat(lowerRatio) * width
            let upperX = CGFloat(upperRatio) * width

            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)

                // Selected Range
                Capsule()
                    .fill(Color.orange)
                    .frame(width: upperX - lowerX, height: 4)
                    .offset(x: lowerX)

                // Lower Thumb
                Circle()
                    .fill(Color.orange)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: lowerX - thumbSize / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let dragX = gesture.location.x
                                let rawValue = (Double(dragX / width) * range) + minValue
                                let clamped = max(minValue, min(rawValue, upperValue - minimumGap))
                                lowerValue = clamped
                            }
                    )

                // Upper Thumb
                Circle()
                    .fill(Color.orange)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: upperX - thumbSize / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let dragX = gesture.location.x
                                let rawValue = (Double(dragX / width) * range) + minValue
                                let clamped = min(maxValue, max(rawValue, lowerValue + minimumGap))
                                upperValue = clamped
                            }
                    )
            }
        }
        .frame(height: 34)
    }
}
