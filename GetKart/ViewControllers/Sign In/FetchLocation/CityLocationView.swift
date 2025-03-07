
import Foundation
import SwiftUI

struct CityLocationView: View {
    var navigationController: UINavigationController?
    @State var arrCities:Array<CityModal> = []
    @State private var searchText = ""
    var state:StateModal = StateModal()
    @State var pageNo = 1
    @State var totalRecords = 1
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                
                Text("\(self.state.name ?? "")").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
            // MARK: - Search Bar
            HStack {
                TextField("Search State", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .frame(height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                // Icon button on the right (for settings or any other action)
                Button(action: {
                    // Action for icon button
                    
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            
            
            
            
            Divider()
            
            // MARK: - List of Countries
            ScrollView{
                LazyVStack {
                    ForEach(arrCities) { city in
                        CountryRow(strTitle:city.name ?? "").frame(height: 40)
                            .onAppear{
                                if  let index = arrCities.firstIndex(where: { $0.id == city.id }) {
                                    if index == arrCities.count - 1{
                                        if self.totalRecords != arrCities.count {
                                            fetchCityListing()
                                        }
                                    }
                                }
                             
                                
                            }
                            .onTapGesture{
                            }
                        Divider()
                    }
                }
            }
            
            Spacer()
        }.onAppear{
            self.fetchCityListing()
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
    
}
    
  
    
    func fetchCityListing(){
        let url = Constant.shared.get_Cities + "?state_id=\(state.id ?? 0)&page=\(pageNo)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:CityParse) in
            
            pageNo = pageNo + 1
            totalRecords  = obj.data?.total ?? 0
            self.arrCities.append(contentsOf:obj.data?.data ?? [])
            print(self.arrCities)
           
       }
   }
    
}


#Preview {
    StateLocationView()
}
