//
//  CategoryModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import Foundation



struct CategoryModel{
    
    var id:Int?
    var sequence:Int?
    var image:String?
    var parent_category_id:String?
    var description:String?
    var created_at:String?
    var updated_at:String?
    var slug:String?
    var translated_name:String?
    var status:Int?
    var subcategories_count:Int?
    var all_items_count:Int?
}


struct SubCategoriesModel{
    
    var id:Int?
    var sequence:Int?
    var image:String?
    var parent_category_id:Int?
    var description:String?
    var status:Int?
    var created_at:String?
    var updated_at:String?
    var slug:String?
    var translated_name:String?
    var approved_items_count:Int?
    var subcategories_count:Int?
//    var subcategories:Array?
//    var translations:Array?

}

       
