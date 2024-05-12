//
//  ApiManager.swift
//  DemoApp
//

import Foundation
import UIKit

typealias Response<T:Decodable> = (Result<T,Error>) -> Void

struct ApiManager<T:Decodable>{
    static func api(urlString:String,method:HttpMethod.RawValue,param: [String:Any]? = nil,token:String, compplition: @escaping Response<T>){
        guard let url = URL(string: urlString) else{return}
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !token.isEmpty{
            request.addValue("Bearer\(token)", forHTTPHeaderField: "Authorizatio")
        }
        if let parameter = param{
            var component = URLComponents(string: urlString)
            var quaryItems = [URLQueryItem]()
            for (key,value) in parameter{
                let quaryItem = URLQueryItem(name: key, value: value as? String)
                quaryItems.append(quaryItem)
            }
            component?.queryItems = quaryItems
            request.url = component?.url
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, ressponse, error in
            if let error{
                compplition(.failure(error))
            }else if let data{
                do{
                    let decode = try JSONDecoder().decode(T.self, from: data)
                    compplition(.success(decode))
                }catch{
                    compplition(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // Mark -: Multipart Api
    
    static func multipartApi(urlString:String,method:HttpMethod.RawValue,param: [String:String]? = nil,token:String, mediaData:[Media]?, compplition: @escaping Response<T>){
        guard let url = URL(string: urlString) else{return}
        var request = URLRequest(url: url)
        let boundary = getBoundary()
        request.httpMethod = method
        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        let dataBody = createDataBody(withParameters: param, media: mediaData, boundary: boundary)
        request.httpBody = dataBody
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, ressponse, error in
            if let error{
                compplition(.failure(error))
            }else if let data{
                do{
                    let decode = try JSONDecoder().decode(T.self, from: data)
                    compplition(.success(decode))
                }catch{
                    compplition(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // Mark -: Body for Multipart Api
    
    static func createDataBody(withParameters params: [String: String]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    // Mark -: Genrate Boundary for Multipart Api
    
    static func getBoundary() -> String{
        return "Boundary-\(NSUUID().uuidString)"
    }
}

// Mark -: Media Multipart Api

struct Media{
    let key: String
    let mimeType: String
    let data: Data
    let fileName: String
    init?(forKey key: String, withImage image: UIImage) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.fileName = "\(arc4random()).jpeg"
        guard let data = image.jpegData(compressionQuality: 0.5) else{return nil}
        self.data = data
    }
}
// Mark -: Convert string to Data

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// Mark -: Api Methods

enum HttpMethod:String{
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}


// Mark -: Use Of Multipart Api

//func updateProfile(image:UIImage?){
//  let param = ["key1": "value1", "keu2": "value2"]
//    var media = [Media]()
//    if let image {
//        if let mediaSingle = Media(forKey: "your media key", withImage: image) {
//            media.append(mediaSingle)
//        }
//    }
//    ApiManager<UpdateProfileModal>.multipartApi(urlString: "your url", method: HttpMethod.post.rawValue, param: param, token: token, mediaData: media) { response in
//        switch response{
//        case .success(let res):
//        print(res)
//        case .failure(let error):
//            print(error)
//            
//        }
//    }
//}
