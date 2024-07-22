//
//  Networking.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/9/24.
//

import Foundation

struct HttpError: Error {
    var statusCode: Int
    var error: String
    var messages: [String]
}

struct LocalNetworkingError: Error {
    var message: String
}

struct ErrorResponseMultiMessage: Codable {
    var statusCode: Int
    var error: String
    var message: [String]
}

struct ErrorResponseSingleMessage: Codable {
    var statusCode: Int
    var error: String
    var message: String
}

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
    
    func request<ResponseType: Decodable>(options: RequestOptions) async throws -> ResponseType {
        guard let url = URL(string: "\(Networking.host)\(options.url)") else {
            print("Invalid URL")
            throw LocalNetworkingError(message: "Invalid URL")
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
        
        var data = Data()
        var response = URLResponse()
        do {
            if let requestBody = options.body {
                guard let encoded = try? JSONEncoder().encode(requestBody) else {
                    print("Failed to encode data")
                    throw LocalNetworkingError(message: "Failed to encode data")
                }
                
                (data, response) = try await session.upload(for: request, from: encoded)
            } else {
                (data, response) = try await session.data(for: request)
            }
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            throw LocalNetworkingError(message: "Failed to fetch data: \(error.localizedDescription)")
        }
            
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("HTTP error: \(httpResponse)")
            if let errorResponse = try? decoder.decode(ErrorResponseMultiMessage.self, from: data) {
                throw HttpError(statusCode: errorResponse.statusCode, error: errorResponse.error, messages: errorResponse.message)
            } else if let errorResponse = try? decoder.decode(ErrorResponseSingleMessage.self, from: data) {
                throw HttpError(statusCode: errorResponse.statusCode, error: errorResponse.error, messages: [errorResponse.message])
            } else {
                throw HttpError(statusCode: httpResponse.statusCode, error: "Server error", messages: [])
            }
        }
                
        guard let decodedResponse = try? decoder.decode(ResponseType.self, from: data) else {
            print("Failed to decode data")
            throw LocalNetworkingError(message: "Failed to decode data")
        }
        
        return decodedResponse
    }
    
    func request(options: RequestOptions) async throws {
        guard let url = URL(string: "\(Networking.host)\(options.url)") else {
            print("Invalid URL")
            throw LocalNetworkingError(message: "Invalid URL")
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
        
        var response = URLResponse()
        var data = Data()
        do {
            if let requestBody = options.body {
                guard let encoded = try? JSONEncoder().encode(requestBody) else {
                    print("Failed to encode data")
                    throw LocalNetworkingError(message: "Failed to encode data")
                }

                (data, response) = try await session.upload(for: request, from: encoded)
            } else {
                (data, response) = try await session.data(for: request)
            }
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            throw LocalNetworkingError(message: "Failed to fetch data: \(error.localizedDescription)")
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("HTTP error: \(httpResponse)")
            if let errorResponse = try? decoder.decode(ErrorResponseMultiMessage.self, from: data) {
                throw HttpError(statusCode: errorResponse.statusCode, error: errorResponse.error, messages: errorResponse.message)
            } else if let errorResponse = try? decoder.decode(ErrorResponseSingleMessage.self, from: data) {
                throw HttpError(statusCode: errorResponse.statusCode, error: errorResponse.error, messages: [errorResponse.message])
            } else {
                throw HttpError(statusCode: httpResponse.statusCode, error: "Server error", messages: [])
            }
        }
    }
}
