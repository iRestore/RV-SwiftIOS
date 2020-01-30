//
//  V2ApiClient.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 04/12/19.
//  Copyright © 2019 iRestoreApp. All rights reserved.
//

import UIKit
//typealias ResultCallback<Value> = (Result<Value, Error>) -> Void
//
//enum Result<U, T> {
//    case Success(U)
//    case Failure(T)
//}
//
//
//struct APIError {
//    let errormessage: String?
//}
//struct APIResponse {
//
//    let data:[String:Any]?
//}


class V2ApiClient {
    var v2Domain : String
    init() {
        let serverParam = Environment().configuration(PlistKey.V2API)

        if Bundle.main.infoDictionary != nil {
            v2Domain = serverParam
        }
        else{
            v2Domain = ""
        }
          
    }
    
    func getReports(postData:Data,completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        
        let urlString = "https://\(v2Domain)\(Constants.GET_REPORTS_V2_URL)"
        let url = URL(string: urlString)!
        
        self.doPostRequest(url: url, requestType: "POST", postData: postData){
            result in
                print(result)
                completion(result)
        }
        
        
    }
    
    func getAllSubmittedBy(params:[String],completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        var newFilterDictionary = [String:Any]()
        newFilterDictionary["application"] = params
        do {
           let data
               = try JSONSerialization.data(withJSONObject: newFilterDictionary, options: [])
            let urlString = "https://\(v2Domain)\(Constants.SUBMITTEDBY_V2_URL)"
                   let url = URL(string: urlString)!
                   self.doPostRequest(url: url, requestType: "POST", postData: data){
                       result in
                           print(result)
                           completion(result)
                   }
        } catch {
                   print(error.localizedDescription)
        }
       
    }
    func getAllAddress(params:String,completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        var newFilterDictionary = [String:Any]()
        newFilterDictionary["address"] = params
        do {
           let data
               = try JSONSerialization.data(withJSONObject: newFilterDictionary, options: [])
            let urlString = "https://\(v2Domain)\(Constants.ADDRESS_V2_URL)"
                   let url = URL(string: urlString)!
                   self.doPostRequest(url: url, requestType: "POST", postData: data){
                       result in
                           print(result)
                           completion(result)
                   }
        } catch {
                   print(error.localizedDescription)
        }
       
    }
    func getAllTags(completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        var newFilterDictionary = [String:Any]()
        do {
           let data
               = try JSONSerialization.data(withJSONObject: newFilterDictionary, options: [])
            let urlString = "https://\(v2Domain)\(Constants.TAGS_V2_URL)"
                   let url = URL(string: urlString)!
                   self.doPostRequest(url: url, requestType: "POST", postData: data){
                       result in
                           print(result)
                           completion(result)
                   }
        } catch {
                   print(error.localizedDescription)
        }
       
    }
    func getAllFeederLine(completion: @escaping (Result<APIResponse, APIError>) -> ()) {
            var newFilterDictionary = [String:Any]()
            do {
               let data
                   = try JSONSerialization.data(withJSONObject: newFilterDictionary, options: [])
                let urlString = "https://\(v2Domain)\(Constants.FEEDERLINE_V2_URL)"
                       let url = URL(string: urlString)!
                self.doGetRequest(url: url){
//                       self.doPostRequest(url: url, requestType: "POST", postData: data){
                           result in
                               print(result)
                               completion(result)
                       }
            } catch {
                       print(error.localizedDescription)
            }
           
        }
    
    
    
    
    /*
        Generic get request
     */
    func doGetRequest(url:URL,completion: @escaping (Result<APIResponse, APIError>) -> ()){
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            let accessToken : String  = UserDefaults.standard.value(forKey: Constants.accessToken) as! String
            let accountKey : String = UserDefaults.standard.value(forKey: Constants.accountKey) as! String
            let phoneNumber = UserDefaults.standard.value(forKey:Constants.PHONE_KEY) as! String

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(accessToken , forHTTPHeaderField: "x-access-token")
            request.setValue(accountKey, forHTTPHeaderField: "x-account-key")
            request.setValue(accountKey, forHTTPHeaderField: "x-owner")
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.setValue(Constants.applicationKey, forHTTPHeaderField: "x-application")
            request.setValue(phoneNumber, forHTTPHeaderField: "x-user")
            
            getDataFromRequest(from: request as URLRequest) { data, response, error in
                guard let data = data, error == nil else {
                    let _error = APIError(errormessage:error?.localizedDescription )
                    completion(Result.Failure(_error))
                    return }
                do {
                    if let obj:[String:Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        let response = APIResponse(data: obj)
                        completion(Result.Success(response))
                    }
                    
                }
                catch {
                    let _error = APIError(errormessage:error.localizedDescription )
                    completion(Result.Failure(_error))
                    print("Error in Serializing objects" + error.localizedDescription)
                }
            }
        }
    
    
    func doPostRequest(url:URL,requestType:String,  postData:Data?, completion: @escaping (Result<APIResponse, APIError>) -> ()){
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = requestType
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let accessToken : String  = UserDefaults.standard.value(forKey: Constants.accessToken) as! String
        let accountKey : String = UserDefaults.standard.value(forKey: Constants.accountKey) as! String
        let phoneNumber = UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String
        request.setValue(accessToken , forHTTPHeaderField: "x-access-token")
        request.setValue(accountKey, forHTTPHeaderField: "x-account-key")
        request.setValue(accountKey, forHTTPHeaderField: "x-owner")
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.setValue(Constants.applicationKey, forHTTPHeaderField: "x-application")
        request.setValue(phoneNumber, forHTTPHeaderField: "x-user")
        if postData != nil {
            request.httpBody = postData!

        }
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: postObject)
//            if let json = String(data: jsonData, encoding: .utf8) {
//                print(json)
//                request.httpBody = jsonData
//            }
//        } catch {
//            print("something went wrong with parsing json")
//        }
        
        getDataFromRequest(from: request as URLRequest) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
               if let obj:[String:Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    let response = APIResponse(data: obj)
                    completion(Result.Success(response))
                }
                
            }
            catch {
                print("Error in Serializing objects" + error.localizedDescription)
                let _error = APIError(errormessage:error.localizedDescription )
                completion(Result.Failure(_error))

            }
        }
    }
    
        func getDataFromRequest(from request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> ())
        {
            URLSession.shared.dataTask(with: request, completionHandler: completion).resume() //(with: url, completionHandler: completion).resume()
        }
    
}
