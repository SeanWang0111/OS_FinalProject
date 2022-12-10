//
//  ApiManager.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/9.
//

import Foundation

class APIManager {
    
    /// 集中管理使用到的字串
    private enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case value = "application/json"
        case type = "Content-Type"
        case header = "Accept"
    }
    
    private enum NotificationMode: String {
        case `default` = "APINotification"
        case fail = "APIFailedNotification"
    }
    
    static func httpGet<T>(apiName: String, resClass: T.Type) where T: Decodable {
        let address: String = apiName.contains("https") ? "\(apiName)" : "\(KeyManager.API_URL)\(apiName)"
        guard let addressURL = URL(string: address) else { return }
        
        var urlRequest = URLRequest(url: addressURL)
        urlRequest.httpMethod = RequestMethod.get.rawValue
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("http error ", error.debugDescription)
                return
            }

            dump(data)
            
            do {
                let res = try JSONDecoder().decode(resClass, from: data)
                dump(res)
                NotificationCenter.default.post(name: Notification.Name(NotificationMode.default.rawValue), object: res)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    static func httpGetHtml(urlStr: String, complete: @escaping ((String) -> Void)) {
        guard let urlString: String = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url: URL = URL(string: urlString) else { return }
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = RequestMethod.get.rawValue
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data: Data = data, error == nil else {
                print("http error",error.debugDescription)
                return
            }
            
            guard let responseString: String = String(data: data, encoding: .utf8) else {
                print("Response encode failed")
                return
            }
            complete(responseString)
        }
        task.resume()
    }
    
    /// http Post
    /// - Parameters:
    ///   - host: 伺服器 host 名稱，預設為 KeyManager.API_URL
    ///   - apiName: API 名稱
    ///   - req: API request 物件
    ///   - resClass: API response 型別
    ///   - preHandler: 打廣播前的預處理閉包
    static func httpPost<T>(host: String = KeyManager.API_URL, apiName: String, req: Encodable, resClass: T.Type , preHandler: ((Data, Decodable) -> Void)? = nil) where T: Decodable {
        dump(req)
        
        guard let addressURL: URL = URL(string: "\(host)\(apiName)") else { return }
        var urlRequest: URLRequest = URLRequest(url: addressURL)
        urlRequest.httpMethod = RequestMethod.post.rawValue
        
        do {
            let reqData: Data = try req.toData()
            urlRequest.httpBody = reqData
            urlRequest.addValue(RequestMethod.value.rawValue, forHTTPHeaderField: RequestMethod.type.rawValue)
            urlRequest.addValue(RequestMethod.value.rawValue, forHTTPHeaderField: RequestMethod.header.rawValue)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data: Data = data, error == nil else {
                    print("http error", error.debugDescription)
                    // API Failed Broadcast
                    NotificationCenter.default.post(name: Notification.Name(NotificationMode.fail.rawValue), object: req)
                    return
                }
                
                do {
                    let res = try data.toObject(resClass: resClass)
                    dump(res)
                    preHandler?(data, res)
                    NotificationCenter.default.post(name: Notification.Name(NotificationMode.default.rawValue), object: res)
                    
                } catch let DecodingError.dataCorrupted(context) {
                    print("DataCorrupted: \(context)")
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found: \(context.debugDescription)")
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch: \(context.debugDescription)")
                    print("codingPath: \(context.codingPath)")
                } catch {
                    print("decode error: \(error.localizedDescription)")
                }
            }
            task.resume()
        } catch {
            print("encode \(error.localizedDescription)")
        }
    }
}

/// 編碼拓展 encode
extension Encodable {
    func toData(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}

/// 解碼拓展 decode
extension Data {
    func toObject<T>(resClass: T.Type)throws -> T? where T: Decodable {
        let res = try JSONDecoder().decode(resClass, from: self)
        return res
    }
}

