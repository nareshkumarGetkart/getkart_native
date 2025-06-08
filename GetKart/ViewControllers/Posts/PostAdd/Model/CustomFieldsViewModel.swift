//
//  CustomFieldsViewModel.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import Foundation
class CustomFieldsViewModel{
    
    var dataArray:[CustomField]?
    weak var delegate:RefreshScreen?
    var page = 1
    var isDataLoading = true
    
    init(){
    }
    
    
    func getCustomFieldsListApi(category_ids:String){
        let url = Constant.shared.getCustomfields + "?category_ids=\(category_ids)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) {[weak self] (obj:CustomFieldsParse) in
            
            if obj.data != nil {
                self?.dataArray = obj.data
                self?.delegate?.refreshScreen()
            }
        }
    }
    
    
    func appendInitialFilterFieldAndGetCustomFieldds(category_ids:String){
        self.dataArray = [CustomField]()
        
        for ind in 0..<4 {
            
            let obj = CustomField(id: ind, name: "", type: .none, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
            
            self.dataArray?.append(obj)
        }
        
        
        let url = Constant.shared.getCustomfields + "?category_ids=\(category_ids)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) {[weak self] (obj:CustomFieldsParse) in
            
            if obj.data != nil {
                
                for objCustomField in obj.data ?? []{
                    
                    if objCustomField.type == .radio || objCustomField.type  ==  .checkbox || objCustomField.type  == .dropdown{
                        self?.dataArray?.append(objCustomField)
                    }
                }
            }
        }
    }
}

// MARK: - CustomFieldsParse
struct CustomFieldsParse: Codable {
    var error: Bool?
    var message: String?
    var data: [CustomField]?
    var code: Int?
}

// MARK: - Datum
/*struct CustomFields: Codable {
    var id: Int?
    var name, type: String?
    var image: String?
    var datumRequired: Int?
    var values: [String]?
    var minLength, maxLength: Int?
    var status: Int?
    
    var arrIsSelected:Array<Bool> = Array()
    //value inserted by user
    var selectedValue:String?

    enum CodingKeys: String, CodingKey {
        case id, name, type, image
        case datumRequired = "required"
        case values
        case minLength = "min_length"
        case maxLength = "max_length"
        case status
    }
}*/

