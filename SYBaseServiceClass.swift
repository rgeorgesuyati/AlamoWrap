//
//  SYBaseServiceClass.swift
//  AnshinKyuyu
//
//  Created by Sulabh Surendran on 11/8/16.
//  Copyright © 2016 Sulabh Surendran. All rights reserved.
//

import Alamofire
//import Simple_KeychainSwift



typealias completionBlock = (_ response: DataResponse<Any>?) -> Void

class SYBaseServiceClass: NSObject {
    
    
//    let staticeBaseURL = "http://staging.bldr.it:3001/"
    func getApiRequest(url:String, parameters:Dictionary<String,Any>?,completion:@escaping completionBlock) {
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .get,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { sessionData in
            
            let errorCode = self.getErrorCode(sessionData)
            if (errorCode == 403) {
                self.notifyLogout()
            }
            completion(sessionData)
        }
        
    }
    
    func putApiRequest(url:String, parameters:Dictionary<String,Any>,completion:@escaping completionBlock) {
        
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .put,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { (sessionData) in
            let errorCode = self.getErrorCode(sessionData)
            if (errorCode == 403) {
                self.notifyLogout()
            }
            
            completion(sessionData)
        }
    }
    
    
    func postApiRequest(url:String, parameters:Dictionary<String,Any>,completion:@escaping completionBlock) {
        
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .post,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { (sessionData) in
            let errorCode = self.getErrorCode(sessionData)
            if (errorCode == 403) {
                self.notifyLogout()
            }
            
            completion(sessionData)
            
        }
    }
    
    func postApiRequest(url:String, parameters:Dictionary<String,Any>,headers:Dictionary<String, Any>,completion:@escaping completionBlock) {
        
        var headers = configureCurrentSession()
        headers["AK_CLIENT_TYPE"] = "IOS"
        headers["AK_DEVICE_ID"] =     UserDefaults.standard.value(forKey: "deviceID") as! String?
        
        
        Alamofire.request(url,method: .post,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { (sessionData) in
            let errorCode = self.getErrorCode(sessionData)
            if (errorCode == 403) {
                self.notifyLogout()
            }
            completion(sessionData)
        }
    }
    
    
     func performUpload(image: UIImage, postURL: String, getURL: String, completionHandler: @escaping (_ success:Bool, _ getURL:String?) -> ()) {
        if let imageData = UIImageJPEGRepresentation(image, 0.1) { // 0.1 for high compression
            print("Uploading! Hang in there...")
            
            let request = Alamofire.upload(imageData, to: postURL, method: .put, headers: ["Content-Type":"image/jpeg"])
            
            
//            let request = Alamofire.upload(.PUT, postURL, headers: ["Content-Type":"image/jpeg"], data:imageData)
            request.validate()
            request.response(completionHandler: { (resp:DefaultDataResponse) in
                print(resp.response)
                
                print("--------------")
                
                print(resp.error)
            })
            
            
//            request.responseJSON(completionHandler: { (json:DataResponse<Any>) in
//                if json.result.error != nil {
//                    print("ERR \(json.result.error)")
//                    // dispatch compltionHandler to main thread (background processes
//                    // should never manipulate the UI, and completionHandler will
//                    // probably include a segue, or something)
////                    dispatch_async(dispatch_get_main_queue(), {
////                        completionHandler(success:false, getURL: getURL)
////                    })
//                } else {
////                    dispatch_async(dispatch_get_main_queue(), {
////                        completionHandler(success:true, getURL: getURL)
////                    })
//                }
//
//            })
        }
    }
    
    func uploadImageApiRequest(url:String, data:Data,completion:@escaping completionBlock) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10800000000000000000 // seconds
        configuration.timeoutIntervalForResource = 10800000000000000000
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "image/jpeg"
        
        
        Alamofire.upload(data, to: url, method: .put, headers: headers)
            .uploadProgress { (progress:Progress) in
//                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print(progress.localizedDescription)
//                let activityData = ActivityData(size: nil, message: progress.localizedDescription, messageFont:  UIFont(name: "CircularStd-Book", size: 12), type: nil, color: UIColor.appBackgroundColor, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Posting", subtitle: progress.localizedDescription)
                
            }
            .responseJSON { (json:DataResponse<Any>) in
                completion(json)
        }
        
        /*
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            // import image to request
            multipartFormData.append(data, withName: fileParam, fileName: "picture.png", mimeType: "image/png")
            
            // import parameters
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .put, headers: headers, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    completion(response)
                }
            case .failure( _):
                completion(nil)
            }
        })
        
        */
        
        /*
        
        Alamofire.upload(.put, url, headers: ["Content-Type": "image/png"], data: data)
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                if let uploadProgress = self.uploadProgress {
                    uploadProgress(bytesWritten, totalBytesWritten, totalBytesWritten);
                }
            }
            .response { (req, res, json, error) in
//                self.returnResult(req, res: res, json: json, error: error, tag: 0)
                return();
        }*/
        
    }

    func deleteApiRequest(url:String, parameters:Dictionary<String,Any>,completion:@escaping completionBlock) {
        
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .delete,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { (sessionData) in
            completion(sessionData)
            
        }
    }
    
    func configureCurrentSession() -> HTTPHeaders{
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 10800
        manager.session.configuration.timeoutIntervalForResource = 10800

        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        // add your custom header
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        if((User.shared.info?.token) != nil){
            headers["Authorization"] = "JWT \( User.shared.info!.token!)"
        }
        
        return headers
    }
    
    func getErrorCode(_ response: DataResponse<Any>?) -> Int {
        
        var errorCode = 121
        guard let result = response?.result.value,let abc = result as? NSDictionary else{
            return errorCode
        }
            if  let errorType = AKResponseError(JSON: abc as! [String : Any]) {
                if let errorStatusCode = errorType.responseCode {
                   errorCode = errorStatusCode
                }
            }
            return errorCode
        
    }
    
    func getErrorMessage(_ response: DataResponse<Any>?) -> String {
        
        var errorMessage = "Error"
        
        if let result = response?.result.value {
            let abc = result as! NSDictionary
            if  let errorType = AKResponseError(JSON: abc as! [String : Any]) {
                if let   errorMessageBody = errorType.message {
                    errorMessage = errorMessageBody
                    if let errorSpecified = errorType.errors {
                        if(errorSpecified.count > 0) {
                            
                            let errorSpecificMessage = errorSpecified[0]
                            if let message = errorSpecificMessage.messages {
                                
                                if(message.count > 0) {
                                    errorMessage = message[0]
                                }
                            }
                        }
                    }
                }
            }
        }
        return errorMessage
    }
    
    func notifyLogout() {
        
//        let logoutInteractor =   AKLogoutInteractor()
//        logoutInteractor.logoutOutput = AKAppController.sharedInstance
//        logoutInteractor.callLogout()
    }
}

/*
class ImagePost {
    
    static let getTokenURL = "http://localhost:3000/v1/get_signed_url"
    
    private static func performUpload(image: UIImage, postURL: String, getURL: String, completionHandler: (_ success:Bool, _ getURL:String?) -> ()) {
        if let imageData = UIImageJPEGRepresentation(image, 0.1) { // 0.1 for high compression
            print("Uploading! Hang in there...")
            let request = Alamofire.upload(.PUT, postURL, headers: ["Content-Type":"image/jpeg"], data:imageData)
            request.validate()
            request.response { (req, res, json, err) in
                if err != nil {
                    print("ERR \(err)")
                    // dispatch compltionHandler to main thread (background processes
                    // should never manipulate the UI, and completionHandler will
                    // probably include a segue, or something)
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success:false, getURL: getURL)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success:true, getURL: getURL)
                    })
                }
            }
        }
        
    }
    
    static func uploadImage(image: UIImage, completionHandler: (_ success:Bool, _ getURL: String?) -> ()) {
        let request = Alamofire.request(.GET, ImagePost.getTokenURL, encoding: .JSON)
        request.validate()
        request.responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let postURL = json["postURL"].string, let getURL = json["getURL"].string {
                        print(postURL)
                        performUpload(image, postURL: postURL, getURL: getURL, completionHandler: completionHandler)
                        return
                    }
                }
                completionHandler(success: false, getURL: nil)
            case .Failure (let error):
                print("ERR \(response) \(error)")
                completionHandler(success: false, getURL: nil)
            }
        }
    }
}

*/
