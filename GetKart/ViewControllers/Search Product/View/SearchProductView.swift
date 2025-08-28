//
//  SearchProductView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//


import SwiftUI




struct SearchProductView: View {
 
    var navigation:UINavigationController?
 //   @State var navigateToFilterScreen = false
    @State var strCategoryTitle = ""
    @StateObject private var viewModel = ProductSearchViewModel()
    @FocusState private var isFocused: Bool
    var onSelectSuggestion: (Search) -> Void
    var isToCloseToHomeScreen = false
    @State private var recentSearches  = [String]()
    @State private var wrapHeight: CGFloat = 0
    
    var body: some View {
       
        VStack {

            HStack {
          
                VStack{
                    
                    HStack{
                        
                        Button(action: {
                            if isToCloseToHomeScreen{
                                for controller in self.navigation?.viewControllers ?? []{
                                    if controller.isKind(of: HomeVC.self){
                                        self.navigation?.popToViewController(controller, animated: true)
                                    }
                                }
                            }else{
                                navigation?.popViewController(animated: true)
                            }
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
                                        viewModel.istoSearch = false
                                        isFocused = false
                                        saveSearchTerm(viewModel.searchText)

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
            
                .onAppear{
                    loadRecentSearches()
                }

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
                       /*
                        
                        if  viewModel.searchText.count == 0  {
                            if recentSearches.count > 0{

                                VStack{
                                    Divider().padding(5)
                                    HStack{
                                        Text("Recent Searches").font(.manrope(.semiBold, size: 15.0))
                                        Spacer()
                                        Button {
                                            
                                            removeAllRecentSearches()
                                            recentSearches.removeAll()
                                        } label: {
                                            Text("Clear").font(.manrope(.semiBold, size: 15.0))
                                        }
                                        
                                    }.padding([.leading,.trailing])
                                 
                                    
                                    FlowLayout(data: recentSearches) { item in
                                        HStack(spacing: 6) {
                                            Image(systemName: "clock")
                                                .font(.caption)
                                            Text(item)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                    }
                                  
                                  /*  LazyVGrid(columns: adaptiveColumns, spacing: 10) {

                                        ForEach(Array(recentSearches.enumerated()), id: \.element) { index, str in
                                            HStack{
                                                Spacer()
                                                Image("search").resizable()
                                                    .frame(width: 15, height: 15)
                                                    .padding(.leading, 10)
                                                Text(str).font(.manrope(.medium, size: 15.0)).padding(.trailing, 10)
                                                Spacer()
                                            }.frame(height:30).frame(minWidth:70)
                                                .overlay {
                                                RoundedRectangle(cornerRadius: 15.0).stroke(Color(.gray), lineWidth: 1.0)
                                            }.cornerRadius(15.0)
                                            
                                                .onTapGesture {
                                                    viewModel.searchText = str
                                                }
                                            
                                        }
                                        
                                        
                                    }
                                    */
                                    Divider().padding(5)
                                    HStack{
                                        Text("Popular Categories").font(.manrope(.semiBold, size: 15.0))
                                        Spacer()
                                    }.padding([.leading,.trailing])

                                } .background(Color(.systemBackground))
                            }
                            
                        }
                        */
                        
                       ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        
                            SearchSuggestionCell(title: item.keyword ?? "",categoryTitle:item.categoryName ?? "")
                                .onTapGesture {
                                    if  viewModel.searchText.count > 0{
                                        saveSearchTerm(viewModel.searchText)
                                    }
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
        let locality = Local.shared.getUserLocality()

        var locStr = locality
        
        if locality.count > 0{
            locStr += ",\(city) \(state) \(country)"

        }else{
            locStr = "\(city) \(state) \(country)"
        }
        

        if city.count == 0 && state.count == 0{
            locStr = "All India"
        }else  if city.count == 0 && state.count > 0{
            locStr = "All \(state)"

        }
            
        return locStr
    }
    
    
    func saveSearchTerm(_ term: String) {
        var searches = UserDefaults.standard.stringArray(forKey: "recentSearchesKey") ?? []

        // Remove duplicates and add the new term at the beginning
        searches.removeAll(where: { $0 == term })
        searches.insert(term, at: 0)

        // Limit the number of recent searches
        let maxRecents = 5 // Or any desired limit
        if searches.count > maxRecents {
            searches = Array(searches.prefix(maxRecents))
        }

        UserDefaults.standard.set(searches, forKey: "recentSearchesKey")
        UserDefaults.standard.synchronize()
    }
    
    func loadRecentSearches(){
        recentSearches =
 UserDefaults.standard.stringArray(forKey: "recentSearchesKey") ?? []
    }
    
    func removeAllRecentSearches(){
        UserDefaults.standard.set([], forKey: "recentSearchesKey")
        UserDefaults.standard.synchronize()

    }

}


#Preview {
    SearchProductView(navigation: nil, strCategoryTitle: "", onSelectSuggestion: {_ in }, isToCloseToHomeScreen:false)
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



struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data,
         spacing: CGFloat = 10,
         alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
           
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return    ZStack(alignment: .topLeading) {

            ForEach(Array(data), id: \.self) { item in
                self.content(item)
                    .padding(.all, 5)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        width -= d.width + spacing
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        return result
                    })
            }
        }
    }
}
