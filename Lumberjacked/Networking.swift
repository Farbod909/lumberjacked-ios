//
//  Networking.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/9/24.
//

import Foundation

class Networking {
        
    struct RequestOptions {
        enum HTTPMethod {
            case GET, POST, PATCH, DELETE
        }

        var url: String
        var body: Encodable?
        var method: HTTPMethod?
        var headers = [(String?, String)]()
    }
    
    static let host = "https://lumberjacked-dev-22i67fnysq-wl.a.run.app/api/v1"
    var sessionConfiguration: URLSessionConfiguration
    let decoder: JSONDecoder
                
    init(sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        self.sessionConfiguration = sessionConfiguration
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func request<ResponseType: Decodable>(options: RequestOptions) async -> ResponseType? {
        guard let url = URL(string: "\(Networking.host)\(options.url)") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
            
        for headerTuple in options.headers {
            request.setValue(headerTuple.0, forHTTPHeaderField: headerTuple.1)
        }
        
        switch options.method {
        case .GET:
            request.httpMethod = "GET"
            break
        case .POST:
            request.httpMethod = "POST"
            break
        case .PATCH:
            request.httpMethod = "PATCH"
            break
        case .DELETE:
            request.httpMethod = "DELETE"
            break
        case .none: break // do nothing
        }
        

        if let accessToken = Keychain.standard.read(service: "accessToken", account: "lumberjacked", type: String.self) {
            self.sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
        }
        let session = URLSession(configuration: self.sessionConfiguration)
        
        do {
            let data: Data
            if let requestBody = options.body {
                guard let encoded = try? JSONEncoder().encode(requestBody) else {
                    print("Failed to encode data")
                    return nil
                }

                (data, _) = try await session.upload(for: request, from: encoded)
            } else {
                (data, _) = try await session.data(for: request)
            }
                        
            if let decodedResponse = try? decoder.decode(ResponseType.self, from: data) {
                return decodedResponse
            }
        } catch {
            print("Invalid data")
        }
        return nil
    }
    
    func request(options: RequestOptions) async {
        guard let url = URL(string: "\(Networking.host)\(options.url)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
            
        for headerTuple in options.headers {
            request.setValue(headerTuple.0, forHTTPHeaderField: headerTuple.1)
        }
        
        switch options.method {
        case .GET:
            request.httpMethod = "GET"
            break
        case .POST:
            request.httpMethod = "POST"
            break
        case .PATCH:
            request.httpMethod = "PATCH"
            break
        case .DELETE:
            request.httpMethod = "DELETE"
            break
        case .none: break // do nothing
        }
        
        if let accessToken = Keychain.standard.read(service: "accessToken", account: "lumberjacked", type: String.self) {
            self.sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
        }
        let session = URLSession(configuration: self.sessionConfiguration)
        
        do {
            if let requestBody = options.body {
                guard let encoded = try? JSONEncoder().encode(requestBody) else {
                    print("Failed to encode data")
                    return
                }

                let _ = try await session.upload(for: request, from: encoded)
            } else {
                let _ = try await session.data(for: request)
            }
        } catch {
            print("Invalid data")
        }
        return
    }

}
