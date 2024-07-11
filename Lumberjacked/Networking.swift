//
//  Networking.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/9/24.
//

import Foundation

class Networking {
    
    static let DEFAULT_ACCESS_TOKEN = "44b0b258a667b0e93aff0f4f3dcc9d37ab04c94f104cbb5a6f4ad8c043ed53a331b5fd7f7b7795ec37a9a285071ef18c"

    struct RequestOptions {
        enum HTTPMethod {
            case GET, POST, PATCH, DELETE
        }

        var url: String
        var body: Encodable?
        var method: HTTPMethod?
        var headers = [(String?, String)]()
    }
    
    var sessionConfiguration: URLSessionConfiguration
    let decoder: JSONDecoder
    let session: URLSession
    
    static func withDefaultAccessToken() -> Networking {
        return Networking(accessToken: Networking.DEFAULT_ACCESS_TOKEN)
    }
        
    private convenience init(sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default, accessToken: String) {
        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        self.init(sessionConfiguration: sessionConfiguration)
    }
    
    private init(sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        self.sessionConfiguration = sessionConfiguration
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        self.session = URLSession(configuration: self.sessionConfiguration)
    }
    
    func request<ResponseType: Decodable>(options: RequestOptions) async -> ResponseType? {
        guard let url = URL(string: options.url) else {
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
}
