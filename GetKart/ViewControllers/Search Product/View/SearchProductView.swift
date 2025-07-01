//
//  SearchProductView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//


import SwiftUI




struct SearchProductView: View {
 
    var navigation:UINavigationController?
    @State var navigateToFilterScreen = false
    @State var strCategoryTitle = ""
    @StateObject private var viewModel = ProductSearchViewModel()
    @FocusState private var isFocused: Bool
    var onSelectSuggestion: (Search) -> Void

    var body: some View {
       
        VStack {

            HStack {
          
                VStack{
                    
                    HStack{
                        
                        Button(action: {
                            navigation?.popViewController(animated: true)
                        }) {
                            Image("Cross")
                                .renderingMode(.template)
                                .foregroundColor(Color(.label))
                                .padding(5)
                        }.padding(.leading,8)
                        
                        
                        HStack {
                            Image("search")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 10)
                            
                            TextField("Search any item...", text: $viewModel.searchText)
                                .focused($isFocused) // bind focus to this field
                                .tint(Color.orange)
                                .frame(height: 45)
                                .submitLabel(.search)
                                .background(Color(.systemBackground))
                                .padding(.trailing, 10)
                                .onSubmit {
                                    if  viewModel.searchText.count > 0{
                                        onSelectSuggestion(Search(categoryID: 0, categoryName: "", categoryImage: "", keyword:  viewModel.searchText))
                                        self.navigation?.popViewController(animated: false)
                                }
                                }
                        }
                        .background(Color(.systemBackground))
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(((viewModel.searchText.count > 0) ? Color(.orange) : Color(.separator)), lineWidth: 1)
                        ).clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    HStack{
                        HStack{
                            Image("location_icon_orange")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 10)

                            Text(getLocation())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .frame(height: 45)
                                .padding(.trailing, 10)
                        }.background(Color(.systemBackground))
                            .frame(height: 45)
                            .frame(maxWidth: .infinity) // Makes HStack full-width

                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separator), lineWidth: 1)
                            ).clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        
                    }.padding(.leading,47)
                
                }.padding(.horizontal, 10).padding(.bottom)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                    }

              
            }.background(Color(.systemBackground))
            

            if viewModel.items.count == 0  && !viewModel.isDataLoading{
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Spacer()
                        Image("no_data_found_illustrator")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 150, height: 150)
                            .padding()
                        Text("No Data Found")
                            .foregroundColor(.orange)
                            .font(Font.manrope(.medium, size: 20.0))
                            .padding(.top)
                            .padding(.horizontal)
                        Text("We're sorry what you were looking for. Please try another way")
                            .font(Font.manrope(.regular, size: 16.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        
                        
                        ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        
                            SearchSuggestionCell(title: item.keyword ?? "",categoryTitle:item.categoryName ?? "")
                                .onTapGesture {
                                    onSelectSuggestion(item)
                                    self.navigation?.popViewController(animated: false)
                            }
                        
                           
                        }
                    }
                    .padding(.horizontal, 10)

                    if viewModel.isDataLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        UIApplication.shared.endEditing()
                    }
                )

            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)

    }

    
    func getLocation()->String{
        let city = Local.shared.getUserCity()
        let country = Local.shared.getUserCountry()
        let state = Local.shared.getUserState()
        
        var locStr = "\(city) \(state) \(country)"

        if city.count == 0 && state.count == 0{
            locStr = "All India"
        }else  if city.count == 0 && state.count > 0{
            locStr = "All \(state)"

        }
            
        return locStr
    }
}


#Preview {
    SearchProductView(navigation: nil, strCategoryTitle: "", onSelectSuggestion: {_ in })
}




struct SearchSuggestionCell:View {
    let title:String
    let categoryTitle:String
    
    var body: some View {
        VStack{
            HStack{
                
                Image("search").renderingMode(.template).foregroundColor(Color(.label)).padding(.leading,10)
                VStack(alignment: .leading){
                    if title.count > 0{
                        Text(title)
                            .font(Font.manrope(.bold, size: 16)).padding([.leading,.trailing],5)
                    }
                    if categoryTitle.count == 0{
                        Text("In all categories") .font(Font.manrope(.regular, size: 15)).padding([.leading,.trailing],8)
                    }else{
                        Text("\(categoryTitle)") .font(Font.manrope(.regular, size: 15)).padding([.leading,.trailing],8)
                    }
                }
                Spacer()
                
            }.padding(.top,10)
            Divider().background(Color(.separator))
        }.background(Color(.systemBackground))
    }
}
