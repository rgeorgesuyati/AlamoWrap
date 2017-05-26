//
//  SYBaseServiceClass.swift
//  Suyati Technologies
//
//  Created by Rijo George on 11/8/16.
//  Copyright © 2016 Rijo George. All rights reserved.
//

import Alamofire

typealias completionBlock = (_ response: DataResponse<Any>?) -> Void

class SYBaseServiceClass: NSObject {
    func getApiRequest(url:String, parameters:Dictionary<String,Any>?,completion:@escaping completionBlock) {
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .get,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { sessionData in
            
            
            completion(sessionData)
        }
        
    }
    
    func putApiRequest(url:String, parameters:Dictionary<String,Any>,completion:@escaping completionBlock) {
        
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .put,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { (sessionData) in
           
            
            completion(sessionData)
        }
    }
    
    
    func postApiRequest(url:String, parameters:Dictionary<String,Any>,completion:@escaping completionBlock) {
        
        let headers = configureCurrentSession()
        Alamofire.request(url,method: .post,parameters: parameters,encoding : JSONEncoding.default,headers:headers).responseJSON { (sessionData) in
            
            
            completion(sessionData)
            
        }
    }

     func performUpload(image: UIImage, postURL: String, getURL: String, completionHandler: @escaping (_ success:Bool, _ getURL:String?) -> ()) {
        if let imageData = UIImageJPEGRepresentation(image, 0.1) { // 0.1 for high compression
            print("Uploading! Hang in there...")
            
            let request = Alamofire.upload(imageData, to: postURL, method: .put, headers: ["Content-Type":"image/jpeg"])
            request.validate()
            request.response(completionHandler: { (resp:DefaultDataResponse) in
                print(resp.response)
                
                print("--------------")
                
                print(resp.error)
            })
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
                print(progress.localizedDescription)
                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Posting", subtitle: progress.localizedDescription)
                
            }
            .responseJSON { (json:DataResponse<Any>) in
                completion(json)
        }
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
}
