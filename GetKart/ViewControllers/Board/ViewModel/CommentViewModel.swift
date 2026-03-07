//
//  CommentViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 26/02/26.
//

import Foundation


class CommentViewModel:ObservableObject{
    
    @Published var commentsArray = [CommentModel]()
    var isDataLoading = false
    var page = 1
    
    
    func getComment(itemId:Int){
        let params = ["item_id":itemId,"page":page] as [String : Any]
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.get_comments, param: params,httpMethod: .post) { (obj:CommentParse) in
            
            if obj.code == 200{
                self.commentsArray.append(contentsOf: obj.data?.data ?? [])
                self.page = self.page + 1
            }
        }
     
    }
    
    
    func getReplies(itemId:Int,commentId:Int){
        let params = ["comment_id":commentId,"page":1] as [String : Any]
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.get_replies, param: params,httpMethod: .post) { (obj:CommentParse) in
            
            if obj.code == 200{
                
                let index  = self.commentsArray.firstIndex { $0.id == commentId }
                if let arrIndex = index {
                   if (self.commentsArray[arrIndex].replyArray?.count ?? 0) > 0 {
                        self.commentsArray[arrIndex].replyArray?.append(contentsOf: obj.data?.data ?? [])
                    }else{
                        self.commentsArray[arrIndex].replyArray =  obj.data?.data ?? []
                    }
                }
               // self.page = self.page + 1
            }
        }
     
    }
    
    func addComment(msg:String,itemId:Int){
        
        let params = ["item_id":itemId,"comment":msg] as [String : Any]
      
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.add_comment, param: params,httpMethod: .post) { (obj:CommentSingleParse) in
            
            if obj.code == 200{
                if let respObj = obj.data{
                    self.commentsArray.insert( respObj, at: 0)
                    
                }
                self.page = self.page + 1
            }
        }
    }
    
    
    func replyComment(msg:String,comment_id:Int){
        
        let params = ["comment_id":comment_id,"comment":msg] as [String : Any]
//        URLhandler.sharedinstance.makeCall(url: Constant.shared.add_reply, param: params) { response, error in
//            
//        }
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.add_reply, param: params,httpMethod: .post) { (obj:CommentSingleParse) in
            
            if obj.code == 200{
                let index  = self.commentsArray.firstIndex { $0.id == comment_id }
                if let arrIndex = index {
                    if let respObj = obj.data{
                       
                        if (self.commentsArray[arrIndex].replyArray?.count ?? 0) > 0 {
                             self.commentsArray[arrIndex].replyArray?.insert(respObj, at: 0)
                         }else{
                             self.commentsArray[arrIndex].replyArray =  [respObj]
                         }
                    }
                  
                }
            }
        }
    }
    
    
    func likeComment(comment_id:Int){
        
        let params = ["comment_id":comment_id] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.like_comment, param: params) { response, error in
            
        }
    }
    
    
    func unlikeComment(comment_id:Int){
        
        let params = ["comment_id":comment_id] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.unlike_comment, param: params) { response, error in
            
        }
    }
    
    func deleteComment(comment_id:Int){
        
        let params = ["comment_id":comment_id] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.delete_comment, param: params) { response, error in
            if error == nil{
                 if  let result = response{
                     let index  = self.commentsArray.firstIndex { $0.id == comment_id }
                     if let arrIndex = index {
                         self.commentsArray.remove(at: arrIndex)
                     }
                 }
             }
        }
    }
    
    func editComment(commentId:Int,comment:String){
        
        let params = ["comment_id":commentId,"comment":comment] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.edit_comment, param: params) { response, error in
            
            
            if error == nil{
                if  let result = response{
                    let index  = self.commentsArray.firstIndex { $0.id == commentId }
                    if let arrIndex = index {
                        
                        self.commentsArray[arrIndex].comment = comment
                        
                    }
                }
            }
            
        
        }
    }
    
    func editReply(commentId:Int,comment:String,parentId:Int){
        
        let params = ["comment_id":commentId,"comment":comment] as [String : Any]
        //URLhandler.sharedinstance.makeCall(url: Constant.shared.edit_reply, param: params) { response, error in
            URLhandler.sharedinstance.makeCall(url: Constant.shared.edit_comment, param: params) { response, error in

            if error == nil{
                 if  let result = response{
                     let index  = self.commentsArray.firstIndex { $0.id == parentId }
                     if let arrIndex = index {
                         let commentArray = self.commentsArray[arrIndex].replyArray
                         let replyindex  = commentArray?.firstIndex { $0.id == commentId }

                         if let removeIndex = replyindex{
                        
                             self.commentsArray[arrIndex].replyArray?[removeIndex].comment = comment
                         }
                     }
                 }
             }

        }
    }

    func deleteReply(comment_id:Int,parentId:Int){
        
        let params = ["comment_id":comment_id] as [String : Any]
     //   URLhandler.sharedinstance.makeCall(url: Constant.shared.delete_reply, param: params) { response, error in
        
    URLhandler.sharedinstance.makeCall(url: Constant.shared.delete_comment, param: params) { response, error in

            if error == nil{
                 if  let result = response{
                     let index  = self.commentsArray.firstIndex { $0.id == parentId }
                     if let arrIndex = index {
                         let commentArray = self.commentsArray[arrIndex].replyArray
                         let replyindex  = commentArray?.firstIndex { $0.id == comment_id }

                         if let removeIndex = replyindex{
                             self.commentsArray[arrIndex].repliesCount = (self.commentsArray[arrIndex].repliesCount ?? 0) - 1
                             self.commentsArray[arrIndex].replyArray?.remove(at: removeIndex)
                         }
                     }
                 }
             }

        }
    }
}

