//
//  RequestAction.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import Foundation

class HttpRequest {
    
    static let shared = HttpRequest()
    
    private init () {}
    
    private struct HandlerStruct<D> {
        let successResponse: (_ success: D) -> Void
        let onFailureResponse: ((_ error: String, _ errorCode: HttpStatusCode) -> Void)?
    }
    
    typealias SuccessHandler<D: Decodable> = (D) -> Void
    typealias ErrorHandler = (_ error: String, _ errorCode: HttpStatusCode) -> Void
    
    private let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = false
        let uSession = URLSession(configuration: configuration)
        return uSession
    }()
    
    private func getFullPath(actionPath: String) -> URL? {
        return HitssTest.apiURL?.appendingPathComponent(actionPath)
    }
    
}

extension HttpRequest {
    
    func makeRequest<D: Decodable> (onAction: RequestAction, response type: D.Type,
                                    onSuccess: @escaping SuccessHandler<D>,
                                    onFailure: ErrorHandler?) {
        
        let handlerStruct = HandlerStruct<D>(successResponse: onSuccess, onFailureResponse: onFailure)
        guard let request = getURLRequest(onAction) else { return }
        urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                onFailure?(error.localizedDescription, .noInternet)
                return
            }
            if let httpResponse = response as? HTTPURLResponse, let data = data {
                let statusCode = HttpStatusCode(rawValue: httpResponse.statusCode)
                debugPrint("StatusCde: \(statusCode)")
                switch statusCode {
                case .success, .created:
                    self?.parseData(type, data, handlerStruct)
                default:
                    onFailure?("Error: ", statusCode)
                }
            } else {
                onFailure?("Error al parsear el data", .parseError)
            }
        }.resume()
    }
    
    private func getURLRequest(_ actionData: RequestAction) -> URLRequest? {
        guard let url = getFullPath(actionPath: actionData.path) else { return nil }
        debugPrint("Making request to \(url)")
        guard var urlComponent = URLComponents(string: url.absoluteString) else { return  nil}
        urlComponent.queryItems = actionData.components
        guard let urlWithComponents = urlComponent.url else { return nil }
        var request =  URLRequest(url: urlWithComponents)
        
        let token: String = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzNmVlZGI5MTk0NGI3MTMyY2NiOGVlNTViMzI4ZjBhZiIsInN1YiI6IjYwYzBmZTQzMzlhNDVkMDA1N2RhYjBmMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fdHj6JSGwf8NzdOR3fqllj0ZvXIdrQmZehpoDHm2_k4"
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        
        let method = actionData.method
        
        if  method == .POST || method == .PUT || method == .DELETE {
            request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        request.httpMethod = actionData.method.rawValue
        let body = actionData.getBodyInData()
        request.httpBody = body
        return request
    }
    
    private func parseData<D: Decodable>(_ stringType: D.Type, _ data: Data, _ handlerStruct: HandlerStruct<D> ) {
        do {
            let json = try JSONDecoder().decode(stringType, from: data)
            handlerStruct.successResponse(json)
        } catch let err {
            handlerStruct.onFailureResponse?("Parsing Error \(err)", .parseError)
        }
    }
}
