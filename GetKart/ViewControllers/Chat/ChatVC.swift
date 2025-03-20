//
//  ChatVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/03/25.
//

import UIKit
import IQKeyboardManagerSwift
import MobileCoreServices

class ChatVC: UIViewController {
    
    @IBOutlet weak var bgViewAudioRecord: UIView!
    @IBOutlet weak var btnAudioRecordStarted: UIButton!
    @IBOutlet weak var btnImgMicBlink: UIButton!

    var isbeginVoiceRecord = false
    var playTime:Int = 0
    var playTimer:Timer?
    var MP3:Mp3Recorder?
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgViewProfile:UIImageView!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var imgViewProduct:UIImageView!
    @IBOutlet weak var lblProduct:UILabel!
    
    var item_offer_id:Int = 0
    var page = 1
    @IBOutlet weak var btnThreeDots:UIButton!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var inputBarBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var inputBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnMic:UIButton!
    @IBOutlet weak var btnSend:UIButton!
    
   lazy private var imagePicker = UIImagePickerController()

    var chatArray = [MessageModel]()
    
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()
    
    var isDataLoading = true
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        //btnBack.setImageTintColor(color: .black)
        btnBack.setImageColor(color: .black)
        self.topRefreshControl.backgroundColor = .clear
        self.tblView.refreshControl = topRefreshControl
        
        registerTblCell()
        
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.size.height/2.0
        imgViewProfile.clipsToBounds = true
        textView.returnKeyType = .default
        textView.enablesReturnKeyAutomatically = true
        textView.font = UIFont.Manrope.regular(size: 16).font
        textView.isPlaceholderEnabled = true
        textView.placeholder = NSAttributedString(string: "Type your message..", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.Manrope.regular(size: 16).font!])
        textView.maxNumberOfLines = 5
        textView.delegate = self
        addObservers()
        getMessageList()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        IQKeyboardManager.shared.isEnabled = false
        // self.getUserInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        IQKeyboardManager.shared.isEnabled = true
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        if !isDataLoading {
            isDataLoading = true
            page = page + 1
            self.getMessageList()
        }
        refreshControl.endRefreshing()
    }
      
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessageButtonAction(sender : UIButton){
        
        if (textView.text?.count ?? 0) > 0{
            self.sendMessageList(msg: textView.text ?? "", msgType: "text")
            self.textView.text = ""
        }
    }
    
    
    @IBAction func micButtonAction(sender : UIButton){
        
    }
    
    @IBAction func attachmentButtonAction(sender : UIButton){
        
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true)
        
        //        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", "public.data","public.pdf", "public.doc","public.rtf"], in: .import)
        //        documentPicker.allowsMultipleSelection = false
        //        documentPicker.modalPresentationStyle = .fullScreen
        //        //Call Delegate
        //        documentPicker.delegate = self
        //        self.present(documentPicker, animated: true)
    }
    
    @IBAction func threeDotsButtonAction(sender : UIButton){
        self.view.endEditing(true)
        //
        //        if (UIApplication.shared.delegate as! AppDelegate).isInternetConnected == false{
        //            (AppDelegate.sharedInstance.navigationController?.topViewController)?.view.makeToast(message: Constant.shared.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault,image: UIImage(named: "wifi")!)
        //
        //            return
        //        }
        
        let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)
        
        //        let report = UIAlertAction(title: "Report", style: .default) { (action) in
        //            self.reportUser()
        //        }
        
        let block = UIAlertAction(title: "Block", style: .default) { (action) in
            
            //  self.blockUnblock(type: 1)
            //self.blockApi(id: self.recieverId, isToBlock: 1)
            
        }
        
       // let unblock = UIAlertAction(title: "Unblock", style: .default) { (action) in
            // self.blockApi(id: self.recieverId, isToBlock: 0)
            //  self.blockUnblock(type: 0)
            
       // }
        
        
        
        
        //  actionSheetAlertController.addAction(report)
        
        //        if userBlockedByYou == 1 {
        //            actionSheetAlertController.addAction(unblock)
        //
        //        }else{
       // actionSheetAlertController.addAction(block)
        //  }
        
        self.present(actionSheetAlertController, animated: true, completion: nil)
        
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.chatMessages), name: NSNotification.Name(rawValue: SocketEvents.chatMessages.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessage), name: NSNotification.Name(rawValue: SocketEvents.sendMessage.rawValue), object: nil)

        
    }
    //MARK: Other helpful methods
    func registerTblCell(){
        
        tblView.register(UINib(nibName: "SendChatCell", bundle: nil), forCellReuseIdentifier: "SendChatCell")
        tblView.register(UINib(nibName: "RecieveChatCell", bundle: nil), forCellReuseIdentifier: "RecieveChatCell")
        tblView.register(UINib(nibName: "SeperatorDateCell", bundle: nil), forCellReuseIdentifier: "SeperatorDateCell")
        
        tblView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        tblView.register(UINib(nibName: "RecieveChatCell", bundle: nil), forCellReuseIdentifier: "RecieveChatCell")
        
        tblView.register(UINib(nibName: "RecieveImageCell", bundle: nil), forCellReuseIdentifier: "RecieveImageCell")
        
        tblView.register(UINib(nibName: "SenderImageCell", bundle: nil), forCellReuseIdentifier: "SenderImageCell")
        
        tblView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingAudio")
        
        tblView.register(UINib(nibName: "ReciveAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingAudio")
        
        
  
    }
    
    
    func getMessageList(){
        
        let params = ["page":page,"item_offer_id":item_offer_id] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.chatMessages.rawValue, params)
        
    }
    
    
    func sendMessageList(msg:String,msgType:String){
        
        
        if msgType == "file"{
            let params = ["message":"","audio":"","file":msg,"item_offer_id":item_offer_id] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(SocketEvents.sendMessage.rawValue, params)
        }else if msgType == "audio"{
            let params = ["message":"","audio":msg,"file":"","item_offer_id":item_offer_id] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(SocketEvents.sendMessage.rawValue, params)
        }else if msgType == "text"{
            
            let params = ["message":msg,"audio":"","file":"","item_offer_id":item_offer_id] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(SocketEvents.sendMessage.rawValue, params)
        }
    
    }
    
    
    func uploadFIleToServer(img:UIImage,name:String){
        
        
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "file", url: Constant.shared.upload_chat_files, params: [:]) { responseObject, error in
            
//        }
//        URLhandler.sharedinstance.uploadMedia(fileName: name, param: [:], file: file, url: Constant.shared.upload_chat_files, mimeType: "image/*") { responseObject, error in
//            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        if let fileStr = data["file"] as? String{
                            
                            self.sendMessageList(msg: fileStr, msgType: "file")
                        }
                        
                        if let audio = data["audio"] as? String{
                           // self.sendMessageList(msg: audio, msgType: "audio")
                        }
                 
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: Keyboard observers
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var statusBarHeight = 0
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.first(where: \.isKeyWindow)
                statusBarHeight = Int(window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) - 5
            } else {
                statusBarHeight = Int(UIApplication.shared.statusBarFrame.height) - 5
            }
            inputBarBottomSpace.constant = keyboardFrame.height - CGFloat(statusBarHeight) + 10
            //            self.btnMic.isHidden = true
            //            self.btnGift.isHidden = true
            view.setNeedsLayout()
            view.layoutIfNeeded()
            scrollToBottom(animated: false)
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        inputBarBottomSpace.constant = 0
        //        self.btnMic.isHidden = false
        //        self.btnGift.isHidden = false
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    
    func scrollToBottom(animated: Bool) {
        guard chatArray.count > 0 else {
            return
        }
        tblView.scrollToRow(at: IndexPath(row: chatArray.count - 1, section: 0), at: .bottom, animated: animated)
    }
    
    
    @objc func chatMessages(notification: Notification) {
        
        guard let data = notification.userInfo else{
            return
        }
        
        if page == 1{
            self.chatArray.removeAll()
        }
        if let response : MessageParse = try? SocketParser.convert(data: data) {

            
            if (response.data?.data?.count ?? 0) == 0 && self.chatArray.count > 0 {
                //No chat getting
            }else{
                
                if item_offer_id > 0 && (response.data?.data?.count ?? 0) > 0{
                    //Checking if other room messages
                    if let msg = response.data?.data?.first, (msg.itemOfferID ?? 0) > 0 {
                        if (msg.itemOfferID ?? 0) != item_offer_id{
                            return
                        }
                    }
                }
                
                var index = 0
                for msg in self.chatArray{
                    if (msg.messageType ?? "") == "100" {
                        if index < chatArray.count {
                            self.chatArray.remove(at: index)
                            index = index - 1
                        }
                    }
                    index = index + 1
                }
                
                let oldChatArray = self.chatArray
                let oldCount = self.chatArray.count
                self.chatArray.removeAll()
                self.chatArray.append(contentsOf: response.data?.data ?? [])
                self.chatArray.append(contentsOf: oldChatArray)
                
                if chatArray.count > 0 {
                    if page == 1{
                        // self.totalRecords = resp.totalRecords ?? 0
                        self.reorderingMessage(pageNo: page, oldCount: 0)
                    }else{
                        self.reorderingMessage(pageNo: page, oldCount: oldCount)
                    }
                }
            }
            if chatArray.count == 0{
                
                
                chatArray.append(MessageModel(readAt: nil, id: nil, createdAt: Date().getISODateFormat(), file: nil, itemOfferID: nil, message: nil, messageType:"100", updatedAt: nil, senderID: nil, audio: nil))
            }
            
            
            self.tblView.reloadData()
            if self.page >= 2 && (response.data?.data?.count ?? 0) > 0{
                
            }else{
                  self.scrollToBottom(animated: false)
            }
            self.isDataLoading = false
        }
    }
    
    
    @objc func sendMessage(notification: Notification) {
        
        guard let data = notification.userInfo else{
            return
        }
        if let response : SendMessageParse = try? SocketParser.convert(data: data) {
            
            if let obj = response.data {
                self.chatArray.append(obj)
                self.tblView.reloadData()
                self.scrollToBottom(animated: true)
            }
            
        }
    }
    
    
    
    func convertTimestamp(isoDateString:String) -> Int64 {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC time
        
        if let date = isoFormatter.date(from: isoDateString) {
            // print("Converted Date:", date)
            
            let timestamp = Int64(date.timeIntervalSince1970) // Convert to seconds
            
            // print("Timestamp from ISO Date:", timestamp)
            return timestamp
            
            
        } else {
            
            print("Invalid date format")
            return 0
        }
    }
    
    
    func reorderingMessage(pageNo:Int,oldCount:Int){
        
        // DispatchQueue.main.async {
        
        let messageFrame = self.chatArray[0]
        
        var timestamp:Int64 =  convertTimestamp(isoDateString: messageFrame.createdAt ?? "")
        
        var orderingArr = [MessageModel]()
        _ = (self.chatArray).map {
            
            if(orderingArr.count > 0)
            {
                
                if(timestamp > 0)
                {
                    let presenttimestamp:Int64 = convertTimestamp(isoDateString:$0.createdAt ?? "")
                    let Prevdate:Date = ConverttimeStamptodateentity(timestamp: timestamp) as Date
                    let Presentdate:Date = ConverttimeStamptodateentity(timestamp: presenttimestamp) as Date
                    
                    var components:Int! = ReturnNumberofDays(fromdate:Prevdate , todate: Presentdate)
                    if(components == 0)
                    {
                        if(!Calendar.current.isDate(Prevdate, inSameDayAs: Presentdate))
                        {
                            components = 1
                        }
                    }
                    if components != 0 {
                        let obj = MessageModel(readAt: "", id: nil, createdAt: $0.createdAt, file: nil, itemOfferID: nil, message: nil, messageType:"100", updatedAt: nil, senderID: nil, audio: nil)
                        orderingArr.append(obj)
                    }
                    
                    
                    timestamp =  convertTimestamp(isoDateString:$0.createdAt ?? "")
                    
                }
                
            }
            else
            {
                
                let obj = MessageModel(readAt: "", id: nil, createdAt: $0.createdAt, file: nil, itemOfferID: nil, message: nil, messageType:"100", updatedAt: nil, senderID: nil, audio: nil)
                
                //   let obj = ChatDetail(createdAt: $0.createdAt, type: 100)
                orderingArr.append(obj)
                
            }
            orderingArr.append($0)
        }
        
        //  let obj = ChatDetail(createdAt: messageFrame.createdAt, type: 100)
        //   orderingArr.insert(obj, at: 0)
        
        
        self.chatArray.removeAll()
        self.chatArray.append(contentsOf: orderingArr)
        
        UIView.setAnimationsEnabled(false)
        self.tblView.reloadData()
        UIView.setAnimationsEnabled(true)
        
        if pageNo == 1{
            //self.scrollToBottom(animated: false)
        }else{
            
        }
        //}
    }
    
    func ReturnNumberofDays(fromdate:Date,todate:Date)->Int? {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromdate, to: todate)
        if(components.day! == 0)
        {
            
            if(Calendar.current.isDate(fromdate, inSameDayAs: todate))
            {
                return 0
            }
            else
            {
                return 0
            }
            
        }
        return components.day
        
    }
    
    func ConverttimeStamptodateentity(timestamp:Int64)->Date!
    {
        var date:Date!
        if(timestamp > 0)
        {
            date  = Date(timeIntervalSince1970: TimeInterval((timestamp)/1000))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            //dateFormatter.timeZone = NSTimeZone.local //Edit
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        else
        {
            date = nil
        }
        return date
    }
}

extension ChatVC: GrowingTextViewDelegate {
    
    func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
        print("Height Will Change To: \(height)  Diff: \(difference)")

        inputBarHeight.constant =  height + 38
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func growingTextView(_ growingTextView: GrowingTextView, didChangeHeight height: CGFloat, difference: CGFloat) {
        print("Height Did Change!")
    }

    func growingTextViewShouldReturn(_ growingTextView: GrowingTextView) -> Bool {
       /* guard let text = growingTextView.text, !text.isEmpty else {
            return false
        }
        messages.append(text)
        textView.text = nil
        tblView.beginUpdates()
        tblView.insertRows(at: [IndexPath(row: messages.count, section: 0)], with: .none)
        tblView.endUpdates()
        scrollToBottom(animated: true)*/
        return false
    }
    
    func growingTextView(_ growingTextView: GrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
       
//        if text.count > 0{
//            self.sendtypinStatus(status: true)
//
//        }else{
//            //self.sendtypinStatus(status: false)
//        }
        return true
    }
    func growingTextViewDidBeginEditing(_ growingTextView: GrowingTextView) {
       // self.sendtypinStatus(status: true)
    }
   
    func growingTextViewDidEndEditing(_ growingTextView: GrowingTextView) {
      //  self.sendtypinStatus(status: false)
    }
    
}


// MARK: ImagePicker Delegate
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {

   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
    
            
            self.uploadFIleToServer(img: pickedImage, name: "file")
           
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Handle the user canceling the image picker, if needed.
        dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    print(urls)
        
      
    }
   
}



extension ChatVC:UITableViewDelegate,UITableViewDataSource {

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tblView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _ = textView.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return chatArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
         let chatObj = chatArray[indexPath.row]
        
         let date = Date(timeIntervalSince1970: TimeInterval(self.convertTimestamp(isoDateString: chatObj.createdAt ?? "")))
         let dateFormatter = DateFormatter()
        
         dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
         dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
         dateFormatter.timeZone = .current
         dateFormatter.dateFormat = "hh:mm a"

        var cell = ChatterCell()
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()

        if (chatObj.messageType ?? "") == "100"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeperatorDateCell") as! SeperatorDateCell
            cell.bgViewEndToEndEncryptedMsg.isHidden = (indexPath.row == 0) ? false : true
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.lblDate.text = dateFormatter.string(from: date)
            if Date().to_DD_MM_YYY() == dateFormatter.string(from: date){
                cell.lblDate.text = "Today"
            }

            return cell
            
        }else if chatObj.senderID == objLoggedInUser.id{
           
                
            switch (chatObj.messageType ?? ""){
                    
                case "text": do{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "SendChatCell", for: indexPath) as! SendChatCell
                    cell.lblMessage.attributedText = NSAttributedString(string:  chatObj.message ?? "")
                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomLeft,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }
//                    if chatObj.messageStatus == 1{
//                        cell.imgViewSeen.setImageTintColor(color: .gray)
//                        cell.lblSeen.isHidden = true
//                    }else if chatObj.messageStatus == 3{
//                        cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
//                        cell.lblSeen.isHidden = false
//                    }
                    
                    cell.lblTime.text = dateFormatter.string(from: date)
                   
                }
                
            case "file": do{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                
                cell.lblMessage.attributedText = NSAttributedString(string:  chatObj.message ?? "")
                
                DispatchQueue.main.async {
                    cell.bgview.roundCorners(corners: [.bottomLeft,.topLeft,.topRight], radius: 15.0)
                    cell.bgview.updateConstraints()
                }
                /*if chatObj.messageStatus == 1{
                    cell.imgViewSeen.setImageTintColor(color: .gray)
                    cell.lblSeen.isHidden = true
                }else if chatObj.messageStatus == 3{
                    cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
                    cell.lblSeen.isHidden = false
                }*/
                cell.lblTime.text = dateFormatter.string(from: date)
                cell.imgView.kf.indicatorType = .activity
                cell.imgView.kf.setImage(with: URL(string: chatObj.file ?? ""), options: [.cacheOriginalImage])
            }
                
               

            case "audio": do{
                cell = tableView.dequeueReusableCell(withIdentifier: "outgoingAudio", for: indexPath) as! AudioTableViewCell
              //  cell.lblMessage.attributedText = NSAttributedString(string:"")
                cell.playPauseButton.tag = indexPath.row
                cell.playPauseButton.addTarget(self, action: #selector(playPauseTapped(sender:)), for: .touchUpInside)
                /*
                if chatObj.messageStatus == 1{
                    cell.imgViewSeen.setImageTintColor(color: .gray)
                    cell.lblSeen.isHidden = true
                }else if chatObj.messageStatus == 3{
                    cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
                    cell.lblSeen.isHidden = false
                }
                cell.lblTime.text = dateFormatter.string(from: date)
                cell.audioDuration.text =  "\(chatObj.mediaDuration ?? 0)"
                cell.audioSlider.value = Float(chatObj.mediaDuration ?? 0) / 180
                 */
                
                DispatchQueue.main.async {
                    cell.bgview.roundCorners(corners: [.bottomLeft,.topLeft,.topRight], radius: 15.0)
                    cell.bgview.updateConstraints()
                }
                
            }

              /*  case 6: do{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "outgoingAudio", for: indexPath) as! AudioTableViewCell
                  //  cell.lblMessage.attributedText = NSAttributedString(string:"")
                    cell.playPauseButton.tag = indexPath.row
                    cell.playPauseButton.addTarget(self, action: #selector(playPauseTapped(sender:)), for: .touchUpInside)
                    if chatObj.messageStatus == 1{
                        cell.imgViewSeen.setImageTintColor(color: .gray)
                        cell.lblSeen.isHidden = true
                    }else if chatObj.messageStatus == 3{
                        cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
                        cell.lblSeen.isHidden = false
                    }
                    cell.lblTime.text = dateFormatter.string(from: date)
                    cell.audioDuration.text =  "\(chatObj.mediaDuration ?? 0)"
                    cell.audioSlider.value = Float(chatObj.mediaDuration ?? 0) / 180

                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomLeft,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }

                }
                    
                case 7: do{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "SenderGiftCell", for: indexPath) as! SenderGiftCell
                    cell.lblMessage.attributedText = NSAttributedString(string:"")
                    if chatObj.messageStatus == 1{
                        cell.imgViewSeen.setImageTintColor(color: .gray)
                        cell.lblSeen.isHidden = true
                    }else if chatObj.messageStatus == 3{
                        cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
                        cell.lblSeen.isHidden = false
                    }
                    cell.lblTime.text = dateFormatter.string(from: date)
                    cell.imgView.kf.setImage(with: URL(string: chatObj.media ?? ""), options: [.cacheOriginalImage])
                }
                    
                case 8,1: do{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                    
                    cell.lblMessage.attributedText = NSAttributedString(string:  chatObj.message ?? "")
                    
                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomLeft,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }
                    if chatObj.messageStatus == 1{
                        cell.imgViewSeen.setImageTintColor(color: .gray)
                        cell.lblSeen.isHidden = true
                    }else if chatObj.messageStatus == 3{
                        cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
                        cell.lblSeen.isHidden = false
                    }
                    cell.lblTime.text = dateFormatter.string(from: date)
                    cell.imgView.kf.indicatorType = .activity
                    cell.imgView.kf.setImage(with: URL(string: chatObj.media ?? ""), options: [.cacheOriginalImage])
                }
                  */
                default:
                    break
                }
            
            
            }else{
            
                    
                switch (chatObj.messageType ?? ""){
                    
                case "text": do{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RecieveChatCell", for: indexPath) as! RecieveChatCell
                    
                    cell.lblMessage.attributedText = NSAttributedString(string:  chatObj.message ?? "")
                    cell.lblTime.text = dateFormatter.string(from: date)

                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomRight,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }
                  
                }
                    
                case "file": do{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RecieveImageCell", for: indexPath) as! RecieveImageCell
                    
                    cell.lblMessage.attributedText = NSAttributedString(string:  chatObj.message ?? "")
                    
                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomLeft,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }
                    /*if chatObj.messageStatus == 1{
                        cell.imgViewSeen.setImageTintColor(color: .gray)
                        cell.lblSeen.isHidden = true
                    }else if chatObj.messageStatus == 3{
                        cell.imgViewSeen.setImageTintColor(color: UIColor(hexString:"F11A7B"))
                        cell.lblSeen.isHidden = false
                    }*/
                    cell.lblTime.text = dateFormatter.string(from: date)
                    cell.imgView.kf.indicatorType = .activity
                    cell.imgView.kf.setImage(with: URL(string: chatObj.file ?? ""), options: [.cacheOriginalImage])
                }
                 
                case "audio": do{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "incomingAudio", for: indexPath) as! AudioTableViewCell
                    
                    cell.playPauseButton.tag = indexPath.row
                   cell.playPauseButton.addTarget(self, action: #selector(playPauseTapped(sender:)), for: .touchUpInside)
                   /* cell.lblTime.text = dateFormatter.string(from: date)
                    cell.audioDuration.text = "\(chatObj.mediaDuration ?? 0)"
                    cell.audioSlider.value = Float(chatObj.mediaDuration ?? 0) / 180
                   */
                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomRight,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }
                }
                    /*
                case 7: do{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RecieveGiftCell", for: indexPath) as! RecieveGiftCell
                    
                    cell.lblMessage.attributedText = NSAttributedString(string:"")
                    
                    cell.lblTime.text = dateFormatter.string(from: date)
                    cell.imgView.kf.setImage(with: URL(string: chatObj.media ?? ""), options: [.cacheOriginalImage])
                    
                }
                    
                case 8,1: do{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RecieveImageCell", for: indexPath) as! RecieveImageCell
                    
                    cell.lblMessage.attributedText = NSAttributedString(string:  chatObj.message ?? "")
                    
                    DispatchQueue.main.async {
                        cell.bgview.roundCorners(corners: [.bottomRight,.topLeft,.topRight], radius: 15.0)
                        cell.bgview.updateConstraints()
                    }
                    
                    cell.lblTime.text = dateFormatter.string(from: date)
                    cell.imgView.kf.indicatorType = .activity
                    cell.imgView.kf.setImage(with: URL(string: chatObj.media ?? ""), options: [.cacheOriginalImage])
                    
                }
                   */
                default: break
                }
            
            
        }
         /*
        cell.contentView.tag = indexPath.row
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureCellAction(_:)))
        long.delegate = self
        cell.contentView.addGestureRecognizer(long)
        //            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureCellAction(_:)))
        //            pan.delegate = self
        //             cell1.contentView.addGestureRecognizer(pan)
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(Swipeleft(_ : )))
        left.direction = .left
        cell.contentView.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(Swiperight(_ : )))
        right.direction = .right
        cell.contentView.addGestureRecognizer(right)
        */
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        return cell
        
        
    }
    
    @objc func playPauseTapped(sender: UIButton) {
         
          let row:Int = (sender as AnyObject).tag
          guard self.chatArray.count > row else{return}
          let indexpath = NSIndexPath.init(row: row, section: 0)
          
        //  if let cellItem:ChatterCell = tblView.cellForRow(at: indexpath as IndexPath) as? AudioTableViewCell {

        if let audioUrl = URL(string: self.chatArray[indexpath.row].audio ?? ""){
                                  
                  let destVc:AudioPlayerVC = StoryBoard.chat.instantiateViewController(withIdentifier: "AudioPlayerVC") as! AudioPlayerVC
                  destVc.modalPresentationStyle = .overCurrentContext
                  destVc.modalTransitionStyle = .coverVertical
                  destVc.audioUrl = audioUrl
                  self.present(destVc, animated: true, completion: nil)
              }
         // }
      }
      
    /*
    
    @objc func longGestureCellAction(_ recognizer: UILongPressGestureRecognizer){
       
        
        
//        if  self.requestedUser == 0{
//            return
//        }
//        self.center_item.tintColor = CustomColor.sharedInstance.newThemeColor
//        self.left_item.tintColor = CustomColor.sharedInstance.newThemeColor
//        self.right_item.tintColor = CustomColor.sharedInstance.newThemeColor
        
        if let point = recognizer.view?.convert(recognizer.location(in: recognizer.view), to: self.view) {
            
            if(popovershow == false)
            {
                popovershow = true
                
                let index = IndexPath(row: (recognizer.view?.tag)!, section: 0)
                
                let cell = self.tblView.cellForRow(at: index)
                var messageFrame = ChatDetail()
                if(self.chatArray.count > (recognizer.view?.tag)!)
                {
                    messageFrame = self.chatArray[(recognizer.view?.tag)!]
                }
               
                
                if messageFrame.isDeleted == 1{
                    return
                }
//                if messageFrame.message.replyObj == nil {
//                    messageFrame.message.replyObj = ReplyInfo(respDict: [:])
//                }
                let cellConfi = FTCellConfiguration()
                cellConfi.textColor = UIColor.black.withAlphaComponent(0.7)
                cellConfi.textFont = UIFont.systemFont(ofSize: 15.0)
                cellConfi.textAlignment = .left
                cellConfi.menuIconSize = 17.0
                cellConfi.ignoreImageOriginalColor = true
                
                let menuOptionNameArray = self.longGestureDataSource(messageFrame: messageFrame).0
                
                let menuOptionImageNameArray = self.longGestureDataSource(messageFrame: messageFrame).1
                
                let config = FTConfiguration.shared
                config.backgoundTintColor = UIColor(red: 213/255, green: 213/255, blue: 211/255, alpha: 1.0)
                config.borderColor = UIColor.clear
                config.menuWidth = 155
                config.menuSeparatorColor = UIColor.lightGray
                config.menuRowHeight = 44
                config.cornerRadius = 15
                config.globalShadow = true
                
                let rectOfCell = self.tblView.rectForRow(at: index)
                let rectOfCellInSuperview = self.tblView.convert(rectOfCell, to: AppDelegate.sharedInstance.navigationController?.topViewController!.view)
                
                _ = config.selectedView.subviews.map {
                    $0.removeFromSuperview()
                }
                config.selectedView.frame = rectOfCellInSuperview
              //  config.selectedView.addSubview(self.copyView(viewforCopy: (cell?.contentView)!))
                
                FTPopOverMenu.showFromSenderFrame(senderFrame: CGRect(origin: point, size: CGSize.zero), with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, cellConfigurationArray: Array(repeating: cellConfi, count: menuOptionNameArray.count), done: { (selectedIndex) in
                    self.popovershow = false
                    self.view.endEditing(true)
                    let action = menuOptionNameArray[selectedIndex]
                    if(action == "Delete")
                    {
                        
                        let PZUSER = DBManager.fetchUserFromDB(id: Local.shared.getUserId())
                        if (PZUSER?.role ?? 0) < 2 {
                            let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "PremiumPlanVC") as! PremiumPlanVC
                            vc.type = 1
                            vc.planBoughtDelegate = self
                            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
                            
                        }else{
                            let messageFrame = self.chatArray[index.row]
                            
                            
                            let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: "Delete this message?", preferredStyle: .actionSheet)
                            
                            let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            
                            let deleteForMe = UIAlertAction(title: "Delete for me", style: .default) { (action) in
                                
                                self.singleMessageDelete(messageId:self.chatArray[index.row].messageId ?? "", deleteFlag: 0)
                                
                            }
                            
                            let deleteChatBoth = UIAlertAction(title: "Delete for everyone", style: .default) { (action) in
                                
                                self.singleMessageDelete(messageId:self.chatArray[index.row].messageId ?? "", deleteFlag: 1)
                            }
                            
                            if self.checkTimeStampMorethan5Mins(timestamp: Int(messageFrame.createdAt ?? 0)){
                                
                                if messageFrame.sender == Local.shared.getUserId(){
                                    actionSheetAlertController.addAction(deleteChatBoth)
                                    actionSheetAlertController.addAction(deleteForMe)
                                }else{
                                    actionSheetAlertController.addAction(deleteForMe)
                                }
                            }else{
                                actionSheetAlertController.addAction(deleteForMe)
                            }
                            
                            actionSheetAlertController.addAction(cancelActionButton)
                            self.present(actionSheetAlertController, animated: true, completion: nil)
                            
                        }
                    }else if(action == "Reply")
                    {
                        self.ShowReplyView(messageFrame)
                   
                    }else if(action == "Copy")
                    {
                        UIPasteboard.general.string = messageFrame.message ?? ""
                    }
                }) {
                    self.popovershow = false
                }
            }
        }
    }
   
    func checkTimeStampMorethan5Mins(timestamp : Int) -> Bool
    {
        if(timestamp > 0)
        {
            var date = Date(timeIntervalSince1970: TimeInterval("\(timestamp)")!/1000)
            date = date.addingTimeInterval(5.0 * 60.0)
            let currentDate = Date()
            if date >= currentDate  {
                return true
            }
            else
            {
                return false
            }
        }
        return false
    }
    
    
    
    @objc func didClickCellButton(_ sender: UIButton){
        
//        if  self.requestedUser == 0{
//            return
//        }
        
//        var isBeginEditing = false
//        var firstIndexpath = IndexPath()
//
//        guard !isBeginEditing else{
//            let row:Int = (sender as AnyObject).tag
//            guard self.chatArray.count > row else{return}
//            let indexpath = NSIndexPath.init(row: row, section: 0)
//            firstIndexpath = indexpath as IndexPath
//
//            if let cell = tblView.cellForRow(at: firstIndexpath) {
//                if cell.isSelected {
//                    tblView.deselectRow(at: firstIndexpath, animated: false)
//                    tableView(tblView, cellForRowAt: firstIndexpath)
//                }else {
//                    tblView.selectRow(at: firstIndexpath, animated: false, scrollPosition: .none)
//                    tableView(tblView, cellForRowAt: firstIndexpath)
//                }
//            }
//            return
//        }
//
        let row:Int = sender.tag
       
        guard self.chatArray.count > row else{return}
        let messageFrame:ChatDetail = self.chatArray[row]
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        if let cellItem:ChatterCell = self.tblView.cellForRow(at: indexpath as IndexPath) as? ChatterCell {
                        
            var index = 0
            for msgObj in self.chatArray{
                
                if (msgObj.messageId ?? "") == (messageFrame.reply ?? ""){
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        
                        self.tblView.isPagingEnabled = true
                        self.tblView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
                        self.tblView.isPagingEnabled = false
                    }, completion: {_ in
                       
                        if let cell:ChatterCell = self.tblView.cellForRow(at: IndexPath(row: index, section: 0) as IndexPath) as? ChatterCell {
                            cell.bgview.layer.borderColor = UIColor.orange.cgColor
                            cell.bgview.layer.borderWidth = 1.5
                            cell.bgview.clipsToBounds = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            cell.bgview.layer.borderColor = UIColor.clear.cgColor
                            cell.bgview.layer.borderWidth = 0
                            cell.bgview.clipsToBounds = true
                        }
                    }
                    })
                    break
                }
                index = index + 1
            }
        }
    }
    
  @objc func playPauseTapped(sender: UIButton) {
       
        let row:Int = (sender as AnyObject).tag
        guard self.chatArray.count > row else{return}
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
      //  if let cellItem:ChatterCell = tblView.cellForRow(at: indexpath as IndexPath) as? AudioTableViewCell {

            if let audioUrl = URL(string: self.chatArray[indexpath.row].media ?? ""){
                                
                let destVc:AudioPlayerVC = StoryBoard.chat.instantiateViewController(withIdentifier: "AudioPlayerVC") as! AudioPlayerVC
                destVc.modalPresentationStyle = .overCurrentContext
                destVc.modalTransitionStyle = .coverVertical
                destVc.audioUrl = audioUrl
                self.present(destVc, animated: true, completion: nil)
            }
       // }
    }
    
    
    func longGestureDataSource(messageFrame : ChatDetail) -> ([String], [String]){
        
        var menuOptionNameArray : [String] = []
        var menuOptionImageNameArray : [String] = []
                
        menuOptionNameArray = ["Reply","Copy","Delete"]
        menuOptionImageNameArray = [ "menu_reply", "menu_copy", "menu_delete"]
        
        /* 0-Text, 1-Media (Image,video,GIF, Document), 2-Link, 3-Contact, 4-Location, 6-Music, 7-gift */

        if messageFrame.type != 0{
            menuOptionNameArray = ["Reply","Delete"]
            menuOptionImageNameArray = [ "menu_reply", "menu_delete"]
        }
        
        
        if messageFrame.receiver == Local.shared.getUserId(){
            if messageFrame.type == 0{
                menuOptionNameArray = ["Reply","Copy","Delete"]
                menuOptionImageNameArray = [ "menu_reply", "menu_copy", "menu_delete"]
            }else{
                menuOptionNameArray = ["Reply","Delete"]
                menuOptionImageNameArray = [ "menu_reply", "menu_delete"]
            }
            
        }
        
        return (menuOptionNameArray, menuOptionImageNameArray)
    }
    
    @objc func Swipeleft(_ recognizer:UIGestureRecognizer){
        
//        if  self.requestedUser == 0{
//            return
//        }
//
        let cell = self.tblView.cellForRow(at: IndexPath(row: (recognizer.view?.tag)!, section: 0)) as? ChatterCell
        var messageFrame = ChatDetail()
        if(self.chatArray.count > (recognizer.view?.tag)!)
        {
            messageFrame = self.chatArray[(recognizer.view?.tag)!]
        }
        
        if messageFrame.isDeleted == 1{
            return
        }
        
        //  let translation = recognizer.translationInView(self.view)
        
        let translation: CGPoint =  recognizer.location(in: view) //recognizer.translation(in: view)
        //Swipe to Left
        if((messageFrame.sender ?? "") == Local.shared.getUserId())
        {
            recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
            //  recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
            recognizer.location(ofTouch: 0, in: view)
            
            UIView.animate(withDuration: 0.25) {
               // cell?.replyImg.alpha = 1.0
            }
            
            if (recognizer.view?.frame.origin.x ?? 0.0) < -(UIScreen.main.bounds.size.width * 0.9) {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                })
            }
            if recognizer.state == .ended {
                let x = Int(recognizer.view?.frame.origin.x ?? 0)
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                }) { finished in
                    if CGFloat(x) < -50 {
//                        let messageinfoVC = StoryBoard.main.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
//                        messageinfoVC.ChatType = "single"
//                        messageinfoVC.messageinfo = messageFrame
//                        self.pushView(messageinfoVC, animated: true)
                    }
                   // cell?.replyImg.alpha = 0.0
                }
            }
        }
    }
    
    @objc func Swiperight(_ recognizer:UIGestureRecognizer){
        
//        if  self.requestedUser == 0{
//            return
//        }
        let cell = self.tblView.cellForRow(at: IndexPath(row: (recognizer.view?.tag)!, section: 0)) as? ChatterCell
        var messageFrame = ChatDetail()
        if(self.chatArray.count > (recognizer.view?.tag)!)
        {
            messageFrame = self.chatArray[(recognizer.view?.tag)!]
        }
        
        if messageFrame.isDeleted == 1{
            return
        }
        
        let translation: CGPoint = recognizer.location(in: view)  // recognizer.translation(in: view)
        UIView.animate(withDuration: 0.25) {
            //cell?.replyImg.alpha = 1.0
        }
        recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
        // recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        recognizer.location(ofTouch: 0, in: view)
        
        if (recognizer.view?.frame.origin.x ?? 0.0) > UIScreen.main.bounds.size.width * 0.9 {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
            })
        }
        if recognizer.state == .ended {
            let x = Int(recognizer.view?.frame.origin.x ?? 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
            }) { finished in
               // if CGFloat(x) > 85 {
                    if CGFloat(x) > 25 {

                    if(messageFrame.type ?? 0) != 100
                    {
                        let _ = self.textView.becomeFirstResponder()
                        self.ShowReplyView(messageFrame)
                    }
                }
               // cell?.replyImg.alpha = 0.0
            }
        }
    }
    */
}
