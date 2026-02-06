//
//  PopularItemsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import SwiftUI
import Kingfisher


struct ProductCard: View {

    @Binding var objItem:ItemModel
    
    var onItemLikeDislike: (ItemModel) -> Void

    var body: some View {
        
        ZStack{
            VStack(alignment: .leading) {
                
                ZStack(alignment: .topTrailing) {
                    
                    KFImage(URL(string: objItem.image ?? ""))
                        .placeholder {
                            Image("getkartplaceholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: widthScreen / 2.0 - 15, height: widthScreen / 2.0 - 15)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                        .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: widthScreen,
                                                                    height: widthScreen))
                        )
                        .fade(duration: 0.25)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: widthScreen / 2.0 - 15, height: widthScreen / 2.0 - 15)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    
                    
                    HStack{
                        
                        if (objItem.isFeature ?? false) == true{
                            Text("Featured").frame(width:75,height:20)
                                .background(.orange)
                                .cornerRadius(5)
                                .foregroundColor(Color(UIColor.white))
                                .padding(.horizontal).padding(.top)
                                .font(.manrope(.regular, size: 13))
                            
                        }
                        
                        Spacer()
                    }
                    
                }.padding(.bottom)
                
                
                VStack(alignment: .leading,spacing: 4){
                    Text("\(Local.shared.currencySymbol) \((objItem.price ?? 0.0).formatNumber())").multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
                        .font(Font.manrope(.bold, size: 15))
                    
                    Text(objItem.name ?? "").foregroundColor(Color(UIColor.label))
                        .multilineTextAlignment(.leading).lineLimit(1)
                        .font(Font.manrope(.semiBold, size: 14))
                    
                    
                    let matchedCatId = matchedCategoryId(from: objItem.allCategoryIDS ?? "") ?? 0
                     
                     if matchedCatId > 0{
                         Text(callSpecificValueBasedOnCategory(catId:matchedCatId, list: objItem.customFields ?? []))
                         .foregroundColor(Color(UIColor.label))
                            .multilineTextAlignment(.leading).lineLimit(1)
                            .font(Font.manrope(.regular, size: 12)).frame(height:12)
                    }
                        
                    HStack(spacing: 2){
                        Image("location-outline").resizable()
                            .renderingMode(.template).frame(width: 15,height:15)
                            .foregroundColor(Color(UIColor.label))
                        Text(objItem.address ?? "").foregroundColor(Color(UIColor.label))
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .font(Font.manrope(.regular, size: 12))
                            .foregroundColor(.gray)
                        Spacer(minLength: 0)
                    }.padding(.horizontal,0)
                    if (matchedCatId == 0){
                        Spacer(minLength: 12)
                    }
                    
                }.padding([.trailing,.leading,.bottom],10).frame(maxWidth: widthScreen/2.0 - 20,alignment:.leading)
                
                
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
            .contentShape(Rectangle())
            
            HStack{
                //
                if (objItem.user?.isVerified ?? 0) == 1{
                    Button {
                        AppDelegate.sharedInstance.presentVerifiedInfoView()
                    } label: {
                        Image( "verifiedIcon").resizable().aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .padding(3)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                    }
                    .frame(width: 40,height: 40)
                    .padding([.leading], 15)
                    .allowsHitTesting(true)
                    
                }
                Spacer()
                Button {
                    if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                        var obj = objItem
                        obj.isLiked = !(obj.isLiked ?? false)
                        objItem = obj
                        addToFavourite(itemId: objItem.id ?? 0)
                        onItemLikeDislike(objItem)
                    }
                } label: {
                    let islike = ((objItem.isLiked ?? false) == true)
                    Image( islike ? "like_fill" : "like")
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                    
                }
                .frame(width: 50,height: 50)
                .padding([.trailing], 15)
                .allowsHitTesting(true)
                
            }.padding(.top,widthScreen / 2.0 - 108)
            
        }
    }
    
    
    
    func addToFavourite(itemId:Int){
        
        let params = ["item_id":"\(itemId)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                
            }
        }
    }

}



//MARK: New api

func callSpecificValueBasedOnCategory(catId:Int,list: [CustomField?]) -> String{
    
    switch catId {
    case 229,226,242,237:
        do{
            //val propertyCategoryIds = listOf(229, 226,242,237)
           return getBedBathText(list)
        }
    
    default:
        return getYearKmText(list)
        
    }
    

    
}

func matchedCategoryId(from categoryIds: String) -> Int? {
    let checkIds: Set<Int> = [500, 130, 501, 229, 26, 226, 242, 237]

    let categoryIdArray = categoryIds
        .split(separator: ",")
        .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

    // Return first matching category id
    for id in categoryIdArray {
        if checkIds.contains(id) {
            return id
        }
    }

    return nil
}


func getBedBathText(_ list: [CustomField?]) -> String {
    var bedrooms = ""
    var bathrooms = ""

    for item in list {
        guard let item else { continue }

        let name = item.name?
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let value = item.value?.first as? String ?? ""

        if name.contains("bedroom") ||
            name.contains("bedrooms") ||
            name.contains("bed") ||
            name.contains("bhk") {

            bedrooms = value.trimmingCharacters(in: .whitespaces)

        } else if name.contains("bathroom") ||
                    name.contains("bath") ||
                    name.contains("toilet") {

            bathrooms = value.trimmingCharacters(in: .whitespaces)
        }
    }

    if !bedrooms.isEmpty && !bathrooms.isEmpty {
        return "\(bedrooms) BHK - \(bathrooms) Bathroom"
    }

    if !bedrooms.isEmpty {
        return "\(bedrooms) BHK"
    }

    if !bathrooms.isEmpty {
        return "\(bathrooms) Bathroom"
    }
    
    

    return ""
}

func getYearKmText(_ list: [CustomField?]) -> String {
    var year = ""
    var km = ""
    var ram = ""
    var storage = ""

    for item in list {
        guard let item = item else { continue }

        let name = item.name?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let value = item.value?.first??.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        switch true {

        // 🚗 Car fields
        case name.contains("year"), name.contains("model"):
            year = value

        case name.contains("km"),
             name.contains("kilometer"),
             name.contains("kms"),
             name.contains("driven"):
            km = value

        // 📱 Mobile fields
        case name.contains("memory"), name.contains("ram"):
            ram = value

        case name.contains("storage"):
            storage = value

        default:
            break
        }
    }

    // 📱 Mobile text first (same priority as Kotlin)
    if !ram.isEmpty || !storage.isEmpty {
        if !ram.isEmpty && !storage.isEmpty {
            return "\(ram) RAM - \(storage) Storage"
        } else if !ram.isEmpty {
            return "\(ram) RAM"
        } else if !storage.isEmpty {
            return "\(storage) Storage"
        }
        return ""
    }

    // 🚗 Car text
    if !year.isEmpty && !km.isEmpty {
        return "\(year) - \(formatKm(km)) KM"
    } else if !year.isEmpty {
        return year
    } else if !km.isEmpty {
        return "\(formatKm(km)) KM"
    } else {
        return ""
    }
}

func formatKm(_ km: String) -> String {
    let cleaned = km.replacingOccurrences(of: ",", with: "")
    if let number = Double(cleaned) {
        return NumberFormatter.localizedString(
            from: NSNumber(value: number),
            number: .decimal
        )
    }
    return km
}
