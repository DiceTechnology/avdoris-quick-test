//
//  NetworkingManager.swift
//  dice-shield-ios-example
//
//  Created by Yaroslav lvov on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

enum NetworkingManagerError: Error {
    case noData
    case noResponse
    case statusCode(code: Int)
}

class RefreshTokenData {
    var realm: String
    var apiKey: String
    var baseURL: String
    var tokens: Tokens
    
    init(realm: String, apiKey: String, baseURL: String, tokens: Tokens) {
        self.realm = realm
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.tokens = tokens
    }
}

struct RefreshTokenAPIModel: Codable {
    let authorisationToken: String
}

class Tokens: Codable {
    var authorisationToken: String
    var refreshToken: String
    
    init(token: String, refreshToken: String) {
        self.authorisationToken = token
        self.refreshToken = refreshToken
    }
}

class DiceHeaders: Codable {
    var realm: String
    var apiKey: String
    var baseURL: String
    
    init(realm: String, apiKey: String, baseURL: String) {
        self.realm = realm
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}
    
class DiceDownloadInfo: Codable {
    let hls: DiceHLSInfo
}

class DiceHLSInfo: Codable {
    let url: String
    let drm: DiceDRMInfo
}

class DiceDRMInfo: Codable {
    let url: String
    let jwtToken: String
}

class DownloadInfoUrlCallback: Codable {
    let playerUrlCallback: String
}

class NetworkingManager {
    ///authorize
    func authorize(headers: DiceHeaders, username: String, password: String, success: @escaping (Tokens) -> Void, failure: @escaping (Error?) -> Void) {
        let componetnts = URLComponents(string: "\(headers.baseURL)/api/v2/login")!
        
        var request = URLRequest(url: componetnts.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue(headers.realm, forHTTPHeaderField: "Realm")
        request.setValue(headers.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = """
        {
        "id": "\(username)",
        "secret": "\(password)"
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = error {
                    failure(error)
                    return
                }
                
                guard let data = data else {
                    failure(NetworkingManagerError.noData)
                    return
                }
                
                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    failure(NetworkingManagerError.noResponse)
                    return
                }
                
                guard urlResponse.statusCode == 201 else {
                    failure(NetworkingManagerError.statusCode(code: urlResponse.statusCode))
                    return
                }
                
                do {
                    let tokens = try JSONDecoder().decode(Tokens.self, from: data)
                    success(tokens)
                } catch {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    ///refresh token
    func refreshToken(headers: DiceHeaders, tokens: Tokens, success: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        let componetnts = URLComponents(string: "\(headers.baseURL)/api/v2/token/refresh")!
        
        var request = URLRequest(url: componetnts.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("Bearer \(tokens.authorisationToken)", forHTTPHeaderField: "Authorization")
        request.setValue(headers.realm, forHTTPHeaderField: "Realm")
        request.setValue(headers.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = """
        {
            "refreshToken": "\(tokens.refreshToken)"
        }
        """.data(using: .utf8)
                
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    failure(error)
                    return
                }
                
                guard let data = data else {
                    print("no data for request permission check")
                    failure(NetworkingManagerError.noData)
                    return
                }
                
                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    failure(NetworkingManagerError.noResponse)
                    return
                }
                
                guard urlResponse.statusCode == 201 else {
                    failure(NetworkingManagerError.statusCode(code: urlResponse.statusCode))
                    return
                }
                
                do {
                    let token = try JSONDecoder().decode(RefreshTokenAPIModel.self, from: data)
                    success(token.authorisationToken)
                } catch {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    
    ///getDownloadInfo
    func getUrlCallback(id: String, headers: DiceHeaders, tokens: Tokens, success: @escaping (DownloadInfoUrlCallback) -> Void, failure: @escaping (Error?) -> Void) {
        let componetnts = URLComponents(string: "\(headers.baseURL)/api/v2/download/vod/\(id)/MEDIUM/eng")!
        
        var request = URLRequest(url: componetnts.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("Bearer \(tokens.authorisationToken)", forHTTPHeaderField: "Authorization")
        request.setValue(headers.realm, forHTTPHeaderField: "Realm")
        request.setValue(headers.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    failure(error)
                    return
                }
                
                guard let data = data else {
                    print("no data for request permission check")
                    failure(NetworkingManagerError.noData)
                    return
                }
                
                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    failure(NetworkingManagerError.noResponse)
                    return
                }
                
                guard urlResponse.statusCode == 200 else {
                    failure(NetworkingManagerError.statusCode(code: urlResponse.statusCode))
                    return
                }
                
                do {
                    let callback = try JSONDecoder().decode(DownloadInfoUrlCallback.self, from: data)
                    success(callback)
                } catch {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    ///getDownloadInfo
    func getDownloadInfo(url: DownloadInfoUrlCallback, headers: DiceHeaders, tokens: Tokens, success: @escaping (DiceDownloadInfo) -> Void, failure: @escaping (Error?) -> Void) {
        let componetnts = URLComponents(string: url.playerUrlCallback)!
        
        var request = URLRequest(url: componetnts.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("Bearer \(tokens.authorisationToken)", forHTTPHeaderField: "Authorization")
        request.setValue(headers.realm, forHTTPHeaderField: "Realm")
        request.setValue(headers.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    failure(error)
                    return
                }
                
                guard let data = data else {
                    print("no data for request permission check")
                    failure(NetworkingManagerError.noData)
                    return
                }
                
                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    failure(NetworkingManagerError.noResponse)
                    return
                }
                
                guard urlResponse.statusCode == 200 else {
                    failure(NetworkingManagerError.statusCode(code: urlResponse.statusCode))
                    return
                }
                
                do {
                    let info = try JSONDecoder().decode(DiceDownloadInfo.self, from: data)
                    success(info)
                } catch {
                    failure(error)
                }
            }
        }
        task.resume()
    }
}
