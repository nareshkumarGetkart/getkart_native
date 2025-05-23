//
//  Chat+Audio.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 30/09/24.
//

import Foundation
import AVFoundation
import UIKit

extension ChatVC:Mp3RecorderDelegate{
   
    //MARK: Mp3RecorderDelegate
    func failRecord() {
        self.btnImgMicBlink.alpha = 1.0
        btnAudioRecordStarted.setTitle("Too short", for: .normal)
        btnAudioRecordStarted.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [self] in
            btnAudioRecordStarted.isEnabled = true
        })
    }
    
    func beginConvert() {
        
    }
    
    func endConvert(with voiceData: Data!) {
        self.btnImgMicBlink.alpha = 1.0
        self.uploadMp3Audio(voiceData: voiceData)
    }
        
    @objc func countVoiceTime(){
        
        playTime += 1
        let seconds =  playTime % 60
        let minutes =  (playTime / 60) % 60
        self.btnAudioRecordStarted.setTitle(String(format: " %02d:%02d < Slide to cancel", minutes,seconds), for: .normal)

        if (playTime>=180) {
            self.endRecordVoice()
        }
    }
    
    @objc func endRecordVoice(){
      
        if ((playTimer) != nil) {
            MP3?.stopRecord()
            playTimer?.invalidate()
            playTimer = nil
        }
        if(playTime > 1)
        {
            self.btnAudioRecordStarted.setTitle("Recorded..." , for: .normal)
        }
        self.perform(#selector(ClearRecordComponents), with: self, afterDelay: 1.0)
    }
    
    
    @objc func cancelRecordVoice(){
       
        if ((playTimer) != nil) {
            MP3?.cancelRecord()
            playTimer?.invalidate()
            playTimer = nil
        }
        self.btnAudioRecordStarted.setTitle("Cancelled" , for: .normal)
        self.perform(#selector(ClearRecordComponents), with: self, afterDelay: 1.0)
    }
        
    @objc func ClearRecordComponents(){
        bgViewAudioRecord.isHidden = true
    }
   
    func beginRecordVoice(){
        if  checkMicPermission() == false{
            AlertView.sharedManager.presentAlertWith(title: "", msg: "Please enable microphone to send audio message from settings.", buttonTitles: ["Cancel","Ok"], onController: self) { title, index in
                if index == 1{
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)

                }
            }
            
            return
        }
        
//        if checkBlockUnblock() == true{
//            return
//        }
        btnAudioRecordStarted.isHidden = false
        btnMic.isHidden = false
        MP3?.startRecord()
        playTime = 0
        playTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countVoiceTime), userInfo: nil, repeats: true)
        playTimer?.fire()
    }
   
    func BlinkAnimation(){
        btnImgMicBlink.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [.autoreverse, .repeat],
            animations: {
                self.btnImgMicBlink.alpha = 1.0
            }) { finished in

            }
    }
    
    @IBAction func voiceRecord(_ sender : UIButton){
        
        if isItemDeleted{
            AlertView.sharedManager.showToast(message: "Item is not available")
            return
        }
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
        
        if  checkMicPermission() == false{
          
            AlertView.sharedManager.presentAlertWith(title: "Alert!", msg: "Please enable microphone to send audio message from settings.", buttonTitles: ["Cancel","Ok"], onController: self) { title, index in
                if index == 1{
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)

                }
            }
            

            return
        }
        
//        if checkBlockUnblock() == true{
//            return
//        }
        MP3  = Mp3Recorder(delegate: self)
        self.bgViewAudioRecord.isHidden = false

        AudioServicesPlaySystemSound(0)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        self.btnAudioRecordStarted.isHidden = !self.btnAudioRecordStarted.isHidden
        self.btnAudioRecordStarted.setTitle(" 00:00 < Slide to cancel", for: .normal)
        isbeginVoiceRecord = !isbeginVoiceRecord
        let _ = self.textView.resignFirstResponder()
        self.btnAudioRecordStarted.isHighlighted = false
        BlinkAnimation()
        self.beginRecordVoice()
    }
    
    
    func checkMicPermission() -> Bool {
        
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            permissionCheck = true
        case AVAudioSession.RecordPermission.denied:
            permissionCheck = false
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }
        return permissionCheck
    }
    
    
    func removeFiles(fileUrl:URL?){
        do {
            if let url = fileUrl {
                if FileManager.default.fileExists(atPath: (url.path)) {
                    try FileManager.default.removeItem(at: url)
                    print(" Image DEleted")
                }
            }
        } catch let err as NSError {
            print("Not able to remove\(err)")
        }
    }
    //MARK: Api upload
    
    func uploadMp3Audio(voiceData: Data){
        
        Themes.sharedInstance.showActivityViewTop(uiView: self.view,position: .bottom)
        let assetName:String = "\(Int(Date().timeIntervalSince1970)).mp3"
        
        var fileURL:URL?
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            fileURL = documentsDirectory.appendingPathComponent(assetName)
            
            do {
                try voiceData.write(to: fileURL!)
                
                let params =  Dictionary<String, Any>() //["type":3]
                                
                URLhandler.sharedinstance.uploadMedia(fileName: assetName, fileKey: "audio", param:  params as [String : AnyObject], file: fileURL!, url:  Constant.shared.upload_chat_files, mimeType: "audio/mpeg") { [weak self] responseObject, error in
                                      

                  //  self?.removeFiles(fileUrl: fileURL)
                    
                    if(error != nil)
                    {
                        DispatchQueue.main.async {
                            if let velfView = self?.view{
                                Themes.sharedInstance.removeActivityView(uiView: velfView)
                            }
                        }
                        //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                        print(error ?? "defaultValue")
                    }else{
                        
                        let result = responseObject! as NSDictionary
                        let code = result["code"] as? Int ?? 0
                        let message = result["message"] as? String ?? ""
                        
                        if code == 200{
                            
                            if let data = result["data"] as? Dictionary<String,Any>{
                                
                                if let fileStr = data["file"] as? String{
                                    
                                   // self.sendMessageList(msg: fileStr, msgType: "file")
                                }
                                
                                if let audio = data["audio"] as? String{
                                    self?.sendMessageList(msg: audio, msgType: "audio")
                                    self?.removeFiles(fileUrl: fileURL)
                                }
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            
                            if let velfView = self?.view{
                                Themes.sharedInstance.removeActivityView(uiView: velfView)
                            }
                        })
                    }
                    
                    
                }
                
            } catch (let error) {
                print("error saving file to documents:", error.localizedDescription)
            }
        } catch (let error) {
            print("error saving file to documents:", error.localizedDescription)
        }
        
    }
}
