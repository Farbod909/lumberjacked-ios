//
//  Networking.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/9/24.
//

import Foundation
import SwiftUI

struct RemoteNetworkingError: Error {
    var statusCode: Int
    var error: String
    var messages: [String]
}

struct NetworkingRequest {
    var options: Networking.RequestOptions
    @Binding var errorAlertItem: ErrorAlertItem;
    @Binding var errorAlertItemIsPresented: Bool
    
    func attempt() async -> Bool {
        do {
            try await Networking.shared.request(options: options)
            return true
        } catch let error as RemoteNetworkingError {
            errorAlertItem = ErrorAlertItem(
                title: error.error,
                messages: error.messages)
            errorAlertItemIsPresented = true
        } catch {
            errorAlertItem = ErrorAlertItem(
                title: "Unknown Error",
                messages: [error.localizedDescription])
            errorAlertItemIsPresented = true
        }
        return false
    }
    
    func attempt<ResponseType: Decodable>(outputType: ResponseType.Type) async -> ResponseType? {
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            errorAlertItem = ErrorAlertItem(
                title: error.error,
                messages: error.messages)
            errorAlertItemIsPresented = true
        } catch {
            errorAlertItem = ErrorAlertItem(
                title: "Unknown Error",
                messages: [error.localizedDescription])
            errorAlertItemIsPresented = true
        }
        return nil
    }
}

class Networking {
    static let shared = Networking()
        
    struct RequestOptions {
        enum HTTPMethod {
            case GET, POST, PATCH, DELETE
        }

        var url: String
        var body: Encodable?
        var method: HTTPMethod?
        var headers = [(String?, String)]()
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
        
    @discardableResult
    func request(options: RequestOptions) async throws -> Data? {
        guard let url = URL(string: "\(Networking.host)\(options.url)") else {
            assertionFailure("Invalid URL")
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
        
        if let accessToken = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked", type: String.self
        ) {
            self.sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
        }
        let session = URLSession(configuration: self.sessionConfiguration)
        
        var response = URLResponse()
        var data = Data()
        if let requestBody = options.body {
            do {
                let encoded = try JSONEncoder().encode(requestBody)
                do {
                    (data, response) = try await session.upload(for: request, from: encoded)
                } catch {
                    assertionFailure("Failed to fetch data: \(error)")
                    return nil
                }
            } catch {
                assertionFailure("Failed to encode data: \(error)")
                return nil
            }
        } else {
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                assertionFailure("Failed to fetch data: \(error)")
                return nil
            }
        }
                
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
            if let errorResponse = try? decoder.decode(
                ErrorResponseMultiMessage.self, from: data
            ) {
                throw RemoteNetworkingError(
                    statusCode: errorResponse.statusCode,
                    error: errorResponse.error,
                    messages: errorResponse.message)
            } else if let errorResponse = try? decoder.decode(
                ErrorResponseSingleMessage.self, from: data
            ) {
                throw RemoteNetworkingError(
                    statusCode: errorResponse.statusCode,
                    error: errorResponse.error,
                    messages: [errorResponse.message])
            } else {
                throw RemoteNetworkingError(
                    statusCode: httpResponse.statusCode,
                    error: "Server error",
                    messages: [])
            }
        }
        return data
    }
    
    func request<ResponseType: Decodable>(options: RequestOptions) async throws -> ResponseType? {
        guard let data = try await request(options: options) else {
            return nil
        }
        do {
            let decodedResponse = try decoder.decode(ResponseType.self, from: data)
            return decodedResponse
        } catch {
            assertionFailure("Failed do decode data: \(error)")
        }
        return nil
    }
}
