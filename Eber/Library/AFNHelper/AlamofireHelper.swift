//
//  AlamofireHelper.swift
//  Eber
//
//  Created by Elluminati on 07/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

extension URLSession {
    func cancelTasks(completionHandler: @escaping (() -> Void)) {
        self.getAllTasks { (tasks: [URLSessionTask]) in 
            for task in tasks {
                if let url = task.originalRequest?.url?.absoluteString {
                    printE("\(#function) \(url) cancel")
                }
                //task.cancel()
            }

            DispatchQueue.main.async(execute: {
                completionHandler()
            })
        }
    }
}

typealias voidRequestCompletionBlock = (_ response:[String:Any],_ error:Any?) -> (Void)

class AlamofireHelper: NSObject
{
    static let POST_METHOD = "POST"
    static let GET_METHOD = "GET"
    static let PUT_METHOD = "PUT"

    var dataBlock:voidRequestCompletionBlock={_,_ in};

    static var manager: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        let manager = Alamofire.Session(
            configuration: URLSessionConfiguration.default
        )
        return manager
    }()

    deinit {
        printE("\(self) \(#function)")
    }

    override init() {
        super.init()
    }

    func getResponseFromURL(url:String, methodName:String, paramData:[String:Any]?, block:@escaping voidRequestCompletionBlock) {
        self.dataBlock = block
        var finalUrl:String = WebService.BASE_URL + url
        if url.contains(MODULE_NAME.PAMENTS) {
            finalUrl = WebService.PAYMENT_BASE_URL + url
        } else if url.contains(MODULE_NAME.HISTORY) || url.contains(MODULE_NAME.EARNING) {
            finalUrl = WebService.HISTORY_BASE_URL + url
        } else if url.contains("bouncerideshare.com.au") {
            finalUrl = url
        }
        
        let header:[String:String] = [:]
        let headers:HTTPHeaders = HTTPHeaders(header)
        self.dataBlock = block
        print("URL : \(finalUrl) \n Parameters \(String(describing: paramData))")
        if methodName == AlamofireHelper.POST_METHOD {
            AF.request(finalUrl, method: .post, parameters: paramData, encoding: JSONEncoding.default ,headers: headers).response { response in
                if response.response?.statusCode ?? 0 == 0 && !(finalUrl.contains("/\(WebService.GET_USER_SETTING_DETAIL)") || finalUrl.contains("/\(WebService.get_all_country_details)")) {
                    self.getResponseFromURL(url: url, methodName: methodName, paramData: paramData, block: block)
                    return
                }
                if self.isValidResponse(response: response, url: url) {
                    switch response.result {
                    case .success:
                        do {
                            if let data = response.data {
                                if let responseDics = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                                    print(Utility.convertDictToJson(dict: responseDics))
                                    block(responseDics, nil)
                                }
                            }
                        } catch let err {
                            print(err.localizedDescription)
                            block([:], response.error)
                        }
                        break
                    default :
                        block([:], response.error)
                        break
                    }
                }else{
                    block([:], response.error)
                }
            }
        } else if methodName == AlamofireHelper.GET_METHOD {
            AF.request(finalUrl,headers: headers).response { response in
                if response.response?.statusCode ?? 0 == 0 && !(finalUrl.contains("/\(WebService.get_all_country_details)")) {
                    self.getResponseFromURL(url: url, methodName: methodName, paramData: paramData, block: block)
                    return
                }
                if self.isValidResponse(response: response, url: url) {
                    switch response.result {
                    case .success:
                        do {
                            if let data = response.data {
                                if let responseDics = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                                    print(Utility.convertDictToJson(dict: responseDics))
                                    block(responseDics, nil)
                                }
                            }
                        } catch let err {
                            print(err.localizedDescription)
                            block([:], response.error)
                        }
                        break
                    default :
                        block([:], response.error)
                        break
                    }
                }else{
                    block([:], response.error)
                }
            }
        }
    }

    func getResponseFromURL(url:String, paramData:[String:Any]?, image:UIImage!, block:@escaping voidRequestCompletionBlock) {
        self.dataBlock = block
        var urlString:String = WebService.BASE_URL + url
        if urlString.contains(MODULE_NAME.PAMENTS) {
            urlString = WebService.PAYMENT_BASE_URL + url
        }
        let imgData = image.jpegData(compressionQuality: 0.2) ?? Data.init()
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: PARAMS.IMAGE_URL,fileName: "picture_data", mimeType: "image/jpg")
            for (key, value) in paramData! {
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                } else if let intValue = value as? Int {
                    multipartFormData.append("\(intValue)".data(using: .utf8)!, withName: key)
                } else if let doubleValue = value as? Double {
                    multipartFormData.append("\(doubleValue)".data(using: .utf8)!, withName: key)
                } else if let boolValue = value as? Bool {
                    multipartFormData.append("\(boolValue)".data(using: .utf8)!, withName: key)
                } else {
                    print("Unsupported value type for key: \(key)")
                }
            }
        },to:urlString).response { response in
            if self.isValidResponse(response: response, url: url) {
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let responseDics = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                                print(Utility.convertDictToJson(dict: responseDics))
                                block(responseDics, nil)
                            }
                        }
                    } catch let err {
                        print(err.localizedDescription)
                        block([:], response.error)
                    }
                    break
                default :
                    block([:], response.error)
                    break
                }
            }
        }
    }

    func isValidResponse(response:AFDataResponse<Data?>, url:String = "") -> Bool {
        var statusCode = response.response?.statusCode
        if let error = response.error?.asAFError {
            let status = "HTTP_ERROR_CODE_" + String(statusCode ?? 0)
            Utility.showToast(message: status.localized)
            statusCode = error._code
            Utility.hideLoading()
            return false
        } else {
            return true
        }
    }
}
