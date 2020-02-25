//
//  V1ApiClient.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 04/12/19.
//  Copyright © 2019 iRestoreApp. All rights reserved.
//

import UIKit
typealias ResultCallback<Value> = (Result<Value, Error>) -> Void

enum Result<U, T> {
    case Success(U)
    case Failure(T)
}


struct APIError {
    let errormessage: String?
}
struct APIResponse {
    
    let data:[String:Any]?
}


class V1ApiClient {
    var v1Domain : String
    init() {
        if Bundle.main.infoDictionary != nil {
            let serverParam = Environment().configuration(PlistKey.V1API)
            v1Domain = ("https://\(serverParam).irestore.info")// infodict["V1_API"] as! String
        }
        else{
            v1Domain = ""
        }
          
    }
    
    func getLocationCategory(categoryValue:String, completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        let signupString = "\(v1Domain)\(Constants.LOCATION_REGION)\(categoryValue)"
        let url = URL(string: signupString)!
        self.doGetRequest(url:url){
            result in
                print(result)
                completion(result)
        }
    }
    
    func signUpWithEmailAndPhone(email:String,phone:String, completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        let signupString = "\(v1Domain)\(Constants.SIGNUP)email=\(email)&phone=\(phone)"
        let url = URL(string: signupString)!
        self.doGetRequest(url:url){
            result in
                completion(result)
        }
    }
    func getOTP( completion: @escaping (Result<APIResponse, APIError>) -> ()) {

        let _phone =  UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String //value(Constants.PHONE_KEY) as! String
        let signupString = "\(v1Domain)\(Constants.GET_OTP_API)phone=\(_phone)"
        let url = URL(string: signupString)!
        self.doGetRequest(url:url){
            result in
                completion(result)
        }
    }
    
    func checkApprovalStatus( completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        let _phone =  UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String
            let signupString = "\(v1Domain)\(Constants.ADMIN_APPROVAL_API)appIdentifier=\(_phone)&application=\(Constants.applicationKey)"
               let url = URL(string: signupString)!
               self.doGetRequest(url:url){
                   result in
                       completion(result)
               }
    }
    
    func deleteProfile( completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        let _email =  UserDefaults.standard.value(forKey: Constants.EMAIL_KEY) as! String
        let _phone =  UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String
        
        
        let signupString = "\(v1Domain)\(Constants.DELETE_PROFILE_API)email=\(_email)&phone=\(_phone)&application=\(Constants.applicationKey)"
        
                      let url = URL(string: signupString)!
                      self.doGetRequest(url:url){
                          result in
                              completion(result)
                      }
        self.doPostRequest(url: url, requestType: "DELETE", postData: nil){
                  result in
                      completion(result)
              }
        
    }
    func syncAPI( completion: @escaping (Result<APIResponse, APIError>) -> ())  {
        var newSignUPString = "\(v1Domain)\(Constants.SYNC_API)"
        let phoneNumber = UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String
        let email =  UserDefaults.standard.value(forKey: Constants.EMAIL_KEY) as! String
        newSignUPString = newSignUPString.replacingOccurrences(of: Constants.emailParamValue, with: email)
        newSignUPString = newSignUPString.replacingOccurrences(of: Constants.applicationParamValue, with: Constants.applicationKey)
        newSignUPString = newSignUPString.replacingOccurrences(of: Constants.phoneParamValue, with: phoneNumber)
        
        let url = URL(string: newSignUPString)!
        self.doGetRequest(url:url){
            result in
                completion(result)
        }
        
    }
    
    func updateDeviceConfiguration( completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        let pref = UserDefaults.standard
        let urlString = "\(v1Domain)\(Constants.TERMS_CONDITIONS_API)\(Constants.applicationKey)"
        let url = URL(string: urlString)!
        
        let currentDate : Date = Date.init()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: currentDate)
        
        
        let latLongDict : [String :Any] = ["isAccepted" : true , "time" : dateString ]
        
        
        var latlongstr :String = ""
        do {
            let obj = try JSONSerialization.data(withJSONObject: latLongDict, options: [])
            latlongstr = String(data: obj, encoding: .utf8)!
        } catch {
            print(error.localizedDescription)
        }
        
        let osVersionString : String = UIDevice.current.systemVersion
        let osTypeString  :String = UIDevice.current.systemName
        let makeString  :String = "Apple"
        let modelString  :String = UIDevice.current.model
        let deviceString  : String = pref.object(forKey: "RandomNumber") as! String
        let email  = pref.value(forKey: Constants.EMAIL_KEY) as! String
        let phone  = pref.value(forKey: Constants.PHONE_KEY) as! String
        
        var  deviceDict = ["os" : osVersionString, "type" : osTypeString, "make":makeString , "model":modelString , "deviceString":deviceString]
        if let pushNotification = pref.value(forKey: Constants.pushNotificationKey) as? String {
            deviceDict["pushNotificationToken"] =  pushNotification
        }
        
        var devicesStringstr :String = ""
        do {
            let obj = try JSONSerialization.data(withJSONObject: deviceDict, options: [])
            devicesStringstr = String(data: obj, encoding: .utf8)!
            
        } catch {
            print(error.localizedDescription)
        }
        
        
        let appVersion : String  = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString" ) as! String
        
        
        let params :String = "email=\(email)&application=\(Constants.applicationKey)&terms=\(latlongstr)&device=\(devicesStringstr)&phone=\(phone)&version=\(appVersion)"
        print(params)
        guard let postData = params.data(using: String.Encoding.utf8) else {
            let _error = APIError(errormessage:"Error in formating parameters" )
                           completion(Result.Failure(_error))
            return
        }
        
        self.doPostRequest(url: url, requestType: "PUT", postData: postData){
            result in
                completion(result)
        }
    

    }
    
    func createProfile(postData:Data, completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        
        let urlString = "\(v1Domain)\(Constants.CREATE_PROFILE_API)"
        let url = URL(string: urlString)!
        self.doPostRequest(url: url, requestType: "POST", postData: postData){
            result in
                completion(result)
        }
    }
    func updateProfile(postData:Data, completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        
        let urlString = "\(v1Domain)\(Constants.UPDATE_PROFILE_API)"
        let url = URL(string: urlString)!
        self.doPostRequest(url: url, requestType: "PUT", postData: postData){
            result in
                completion(result)
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
        let phoneNumber =  UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String //value(Constants.PHONE_KEY) as! String

//            let phoneNumber = "9886612580"//UserDefaults.standard.value(forKey: "phoneKey") as! String

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
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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
            request.httpBody = postData
        }

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
