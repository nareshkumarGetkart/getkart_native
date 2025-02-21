//
//  MobileCodeVC.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 20/08/24.
//

import UIKit

public enum DisplayLanguageType{
    case chinese
    case english
    case spanish
}

class MobileCodeVC: UIViewController, UITextFieldDelegate {
        
    @IBOutlet weak var txtFdSearch:UITextField!
    @IBOutlet weak var btnCross:UIButton!
    @IBOutlet weak var countryTableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    fileprivate var regex = ""
    fileprivate var searchCountrys : [[String:Any]]!
    public var selectedCountryCallBack : ((_ countryDic: [String:Any])->(Void))!
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        
        txtFdSearch.delegate = self
        searchCountrys = CountryCodeJson
        self.countryTableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.bgView.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
        })
        
    }
    
    //MARK: UIButton Action  Methods
    @IBAction func closeButtonActionMethod(_ sender : UIButton){
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)

    }
    //MARK: UITextfield Delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = (textField.text ?? "") as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        if resultString.count == 0 {
            searchCountrys = CountryCodeJson
            countryTableView.reloadData()
            return true
        }
        
        self.getRegexString(searchString: resultString.lowercased())
        var results :[[String:Any]] = []
        for countryDic in CountryCodeJson {
            let zh = countryDic["zh"] as! String
            let en = countryDic["en"] as! String
            let es = countryDic["es"] as! String
            let code = "\(countryDic["code"] as! NSNumber)"
            let locale = countryDic["locale"] as! String
            if self.checkSearchStringCharHas(compareString: zh.lowercased())||self.checkSearchStringCharHas(compareString: en.lowercased().replacingOccurrences(of: " ", with: ""))||self.checkSearchStringCharHas(compareString: es.lowercased().replacingOccurrences(of: " ", with: ""))||self.checkSearchStringCharHas(compareString: code)||self.checkSearchStringCharHas(compareString: locale.lowercased().replacingOccurrences(of: " ", with: "")){
                results.append(countryDic)
            }
        }
        searchCountrys = results
        countryTableView.reloadData()
        
        return true
    }
    
    func getRegexString(searchString: String){
        var str :String = ""
        let count = searchString.count
        for index in 0..<count {
            let i = searchString.index(searchString.startIndex, offsetBy: index, limitedBy: searchString.endIndex)
            if str.count == 0{
                str = "(^|[a-z0-9\\u4e00-\\u9fa5])+[\(searchString[i!])]"
            }else{
                str = "\(str)+[a-z0-9\\u4e00-\\u9fa5]*[\(searchString[i!])]"
            }
            print(searchString[i!])
        }
        regex = "\(str)+[a-z0-9\\u4e00-\\u9fa5]*$"
    }
    func checkSearchStringCharHas(compareString: String) -> Bool{
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: compareString)
        return isValid
    }
    
}


extension MobileCodeVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
   
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCountrys.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "CountryTableViewCell"
        
        var countryCell:CountryTableViewCell! = tableView.dequeueReusableCell(withIdentifier: indentifier) as? CountryTableViewCell
        
        if countryCell == nil {
            
            countryCell=CountryTableViewCell(style: .default, reuseIdentifier: indentifier)
        }
        countryCell.selectionStyle = .none
        countryCell.countryNameLabel.text = (searchCountrys[indexPath.row]["en"] as! String)
    
        countryCell.countryNameLabel.font = UIFont(name: "Inter-Medium", size: 16.5)
        countryCell.countryNameLabel.textColor = UIColor.black
        
        let path = Bundle(for: type(of: self)).resourcePath! + "/CountryPicker.bundle"
        let CABundle = Bundle(path: path)!
        countryCell.countryImageView.image = UIImage(named: "\(searchCountrys[indexPath.row]["locale"] as! String)", in:  CABundle, compatibleWith: nil)
        
        countryCell.phoneCodeLabel.text = "+\(searchCountrys[indexPath.row]["code"] as! NSNumber)"
        countryCell.phoneCodeLabel.font = UIFont(name: "Inter-Medium", size: 16.5)
        countryCell.phoneCodeLabel.textColor = UIColor.black
        
        return countryCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dic = searchCountrys[indexPath.row]
        dic["countryImage"] = UIImage(named:"CountryPicker.bundle/\(searchCountrys[indexPath.row]["locale"] as! String)")
        self.selectedCountryCallBack(dic)
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}

