//
//  CreateAdSecondView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/08/25.
//

import SwiftUI
/*
struct CreateAdSecondView: View {
    
    var navigationController:UINavigationController?
    @StateObject var objViewModel:PostAdsViewModel = PostAdsViewModel()
    var filterDict:Dictionary<String,Any>? = nil

    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Post Detail").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            .onAppear{
                objViewModel.getCustomFieldsListApi(category_ids: "104,130")
            }
        
        ScrollView{
            
            VStack(spacing:20){
                
                ForEach(objViewModel.dataArray ?? []) { obj in
                    
                    if obj.type == .textbox || obj.type == .number {
                        
                        TextFieldView(title: obj.name ?? "", icon:obj.image ?? "")
                        
                    }else if obj.type == .dropdown{
                        let nonNilValues = obj.values?.compactMap { $0 } ?? []
                        if !nonNilValues.isEmpty {
                            DropDownView(title: obj.name ?? "", options: nonNilValues, icon:obj.image ?? "")
                        }
                        
                    }else if obj.type == .radio{
                         VStack{
                            HStack{
                                AsyncImage(url: URL(string: obj.image ?? "")) { img in
                                    img.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40,height: 40)
                                        .cornerRadius(10)
                                        .clipped()
                                        .padding(.leading,5)
                                } placeholder: {
                                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit)
                                        .frame(width: 50,height: 50).cornerRadius(10)
                                    
                                }
                                Text(obj.name ?? "")
                                Spacer()
                            }.padding([.leading,.trailing])
                        if let unwrappedValues = obj.values {
//                           
//                                ForEach(Array(unwrappedValues.enumerated()), id: \.offset) { index, value in
//                                    
//                                   RadioSelectionView(title: value ?? "", isSelected: obj.value?.contains(value) == true).padding()
//                                    
//                                }
                            }
                            
                        }
                        
                    }else if obj.type == .checkbox{
                        //Checkbox View
                       // if let unwrappedValues = obj.values {
                          
                            
                         /*   let nonNilValues = obj.values?.compactMap { $0 } ?? []
                            let nonNilValue = obj.value?.compactMap { $0 } ?? []

                            if !nonNilValues.isEmpty {
                                CheckBoxListView(title: obj.name ?? "", icon: obj.image ?? "", options: nonNilValues,selOptions:nonNilValue)
                            }
                        */
                            
                           // ForEach(Array(unwrappedValues.enumerated()), id: \.offset) { index, value in
                                
//                                CheckBoxSelectionView(
//                                           title: value ?? "",
//                                           isSelected: obj.value?.contains(value) == true
//                                       )
                                
                           // }
                       // }
                    }
                }
                
                Spacer()
            }
        }.background(Color(.systemGray6))
        
        Button {
            
        } label: {
            Text("Next").foregroundColor(.white).font(.manrope(.medium, size: 16))
        }.frame(maxWidth: .infinity,maxHeight:50)
            .background(Color.orange)
            .cornerRadius(8.0)
            .clipped()
            .padding()

                
    }
}

#Preview {
    CreateAdSecondView()
}




struct CheckBoxListView:View {
    var title: String
    let icon: String
    let options: [String]
    var selOptions: [String]

    
    var body: some View {
        VStack {
            HStack{
                AsyncImage(url: URL(string: icon)) { img in
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.leading,5)
                } placeholder: {
                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40).cornerRadius(10)
                    Spacer()
                    
                }
                Text(title).font(Font.manrope(.regular, size: 14.0))
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            
          /*  LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 1) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, value in
                    
                    HStack {
                       let isSelected =  (selOptions.contains(value) == true) ? true : false
                        (isSelected ? Image("checkbox_sel") : Image("checkbox_un"))
                        Text(title).font(Font.manrope(.regular, size: 14.0))
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                    }
                }
            }*/
         
        }.padding([.leading,.trailing])
    }
}


struct RadioListView:View {
    var title: String
    let icon: String
    let options: [String]
    var selOptions: [String]

    
    var body: some View {
        VStack {
            HStack{
                AsyncImage(url: URL(string: icon)) { img in
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.leading,5)
                } placeholder: {
                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40).cornerRadius(10)
                    Spacer()
                    
                }
                Text(title).font(Font.manrope(.regular, size: 14.0))
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            
           /* LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 1) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, value in
                    
                    HStack {
                       let isSelected =  (selOptions.contains(value) == true) ? true : false
                        (isSelected ? Image("checkbox_sel") : Image("checkbox_un"))
                        Text(title).font(Font.manrope(.regular, size: 14.0))
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                    }
                }
            }*/
         
        }.padding([.leading,.trailing])
    }
}


struct TextFieldView: View {
    var title: String
    let icon: String

    @State var textVal: String = ""
    
    var body: some View {
        VStack {
            HStack{
                AsyncImage(url: URL(string: icon)) { img in
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.leading,5)
                } placeholder: {
                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40).cornerRadius(10)
                    Spacer()
                    
                }
                Text(title).font(Font.manrope(.regular, size: 14.0))
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            
            TextField(title, text: $textVal).padding(.horizontal).cornerRadius(10.0)
                .frame(height:50)
                .overlay {
                RoundedRectangle(cornerRadius: 10.0)
                        .stroke(Color.gray,lineWidth: 1.0)
            }
        }.padding([.leading,.trailing])
    }
}



struct DropDownView: View {
    let title: String
    let options: [String]
    let icon: String

    @State private var isExpanded = false
    @State private var selectedOption: String = "Select Option"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack{
                AsyncImage(url: URL(string: icon)) { img in
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.leading,5)
                } placeholder: {
                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 40,height: 40).cornerRadius(10)
                    Spacer()
                    
                }
                Text(title).font(Font.manrope(.regular, size: 14.0))
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            
            dropDownButton
            
            if isExpanded {
                dropDownOptions
            }
        }
        .padding([.leading,.trailing])
    }
    
    private var dropDownButton: some View {
        Button(action: {
            withAnimation {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text(selectedOption)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .frame(height:50).padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(Color.gray, lineWidth: 1.0)
            ).cornerRadius(10.0)
        }
    }
    
    private var dropDownOptions: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 0) {
                ForEach(options, id: \.self) { option in
                    dropDownOption(option)
                }
            }
        }.frame(height:400)
        .background(
            RoundedRectangle(cornerRadius: 10.0)
                .stroke(Color.gray.opacity(1.0))
        )
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private func dropDownOption(_ option: String) -> some View {
        Button(action: {
            selectedOption = option
            withAnimation {
                isExpanded = false
            }
        }) {
            Text(option)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .foregroundColor(.primary)
        .overlay(Divider(), alignment: .bottom)
        
    }
}


*/
