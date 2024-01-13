//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


/// A type representing an empty Encodable/Decodable type. Use this for ``ServiceRequest``s that have
/// empty parameters or body data.
public struct Empty: Codable {
}


public protocol ServiceRequest {
    
    /// The environment of the ``Service`` used in `service` parameter. This will be auto-defined by
    /// the compiler.
    associatedtype Env: Environment
    
    /// The type you are using for parameters of the request. Use ``Empty`` if there are none.
    associatedtype Parameters: Encodable
    
    /// The type that the response's body should be decoded into.
    associatedtype ServiceResponseContent: Decodable
    
    /// The HTTP method to use for this request. See ``HTTPMethod`` for more info.
    var method: HTTPMethod { get }
    
    /// The service this request should hit. See ``Service`` for more info.
    var service: Service<Env> { get }
    
    /// The path for this request, appeneded to the baseUrl returned by ``service``.
    var path: String { get }
    
    /// Any parameters to send with this request. Defaults to Empty.
    var parameters: Parameters { get }
    
    /// The authentication method to use for this request. There is no default so that you can
    /// set one via an extension in your application.
    var authentication: Authentication? { get }
    
    /// The JSONEncoder to use for `POST`/`PUT`/`PATCH` requests. Defaults to
    /// `JSONEncoder.bluebonnetDefault`.
    var jsonEncoder: JSONEncoder { get }
    
    /// The JSONDecoder to use. Defaults to `JSONDecoder.bluebonnetDefault`.
    var jsonDecoder: JSONDecoder { get }
    
    /// Builds the underlying data task loads data via the `URLSession`. This method is implemented by the default extension.
    func start() async throws -> ServiceResponseContent?
    
    /// Decodes the response data. Only called on a successful response (2xx). If
    /// ``ServiceResponseContent`` == Empty then this method always returns ``Empty``.
    func decodeResponseContent(from data: Data?, in response: URLResponse, for request: URLRequest) throws -> ServiceResponseContent
}

public extension ServiceRequest {
    
    var jsonEncoder: JSONEncoder {
        return .bluebonnetDefault
    }
    
    var jsonDecoder: JSONDecoder {
        return .bluebonnetDefault
    }
    
    func sift(_ error: Error, with data: Data? = nil) -> Error {
        return ServiceErrorSifter.shared.sift(error, responseData: data)
    }
    
    @discardableResult
    func start() async throws -> ServiceResponseContent? {
        let request = try urlRequest()
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = BluebonnetError.receivedNonHTTPURLResponse
                logError(error, from: request, response: response)
                throw sift(error, with: data)
            }
            
            let httpStatusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) ?? .unknown
            let successStatusCodes: [HTTPStatusCode] = [.success, .created, .noContent, .accepted]
            guard successStatusCodes.contains(httpStatusCode) else {
                let error = BluebonnetError.unexpectedStatusCode(httpStatusCode)
                logError(error, from: request, response: httpResponse, responseData: data)
                throw sift(error, with: data)
            }
            
            return try decodeResponseContent(from: data, in: httpResponse, for: request)
        } catch {
            logError(error, from: request, response: nil)
            throw error
        }
    }
    
    func decodeResponseContent(from data: Data?, in response: URLResponse, for request: URLRequest) throws -> ServiceResponseContent {
        guard let data = data, !data.isEmpty else {
            throw sift(BluebonnetError.unexpectedlyReceivedEmptyResponseBody)
        }
        
        do {
            return try jsonDecoder.decode(ServiceResponseContent.self, from: data)
        } catch let error {
            logError(error, from: request, response: response, responseData: data)
            throw sift(error, with: data)
        }
    }
}

private extension ServiceRequest {
    
    var logger: Logger { Bluebonnet.logger }
    
    func urlRequest() throws -> URLRequest {
        let urlString = service.baseUrlForCurrentEnvironment.appendingPathComponent(path)
        
        guard var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false) else {
            throw BluebonnetError.couldNotGenerateRequestURL
        }
        
        if !(parameters is Empty) && method == .get {
            urlComponents.queryItems = try URLQueryEncoder().encode(parameters, baseEncoder: jsonEncoder)
        }
        
        guard let completeUrl = urlComponents.url else {
            throw BluebonnetError.couldNotGenerateRequestURL
        }
        
        var request = URLRequest(url: completeUrl)
        request.httpMethod = method.rawValue
        
        if !(parameters is Empty) && [.post, .patch, .put].contains(method) {
            request.httpBody = try jsonEncoder.encode(parameters)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        if let authentication = authentication {
            switch authentication {
            case .basic(let username, let password):
                let credentialsData = "\(username):\(password)".data(using: .utf8)!
                request.setValue("Basic \(credentialsData.base64EncodedString())", forHTTPHeaderField: "Authorization")
            case .bearer(let token):
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    private func logError(_ error: Error, from request: URLRequest, response: URLResponse? = nil, responseData: Data? = nil) {
        logger.error("\(String(describing: error))")
        logger.info("Request: \(request.httpMethod ?? "<UNKNOWN HTTP METHOD>") \(request.debugDescription)")
        
        request.allHTTPHeaderFields?.forEach { key, value in
            logger.info("\t\(key): \(value)")
        }
        
        if let response = response as? HTTPURLResponse {
            logger.info("Response: \(response.debugDescription)")
            logger.info("Response Data: \(stringFromData(responseData))")
        }
    }
    
    private func stringFromData(_ data: Data?) -> String {
        return String(data: data ?? Data(), encoding: .utf8) ?? "<None>"
    }
}

extension ServiceRequest where ServiceResponseContent == Empty {
    func decodeResponseContent(from data: Data?, in response: URLResponse, for request: URLRequest) throws -> ServiceResponseContent {
        return Empty()
    }
}

extension ServiceRequest where Parameters == Empty {
    public var parameters: Parameters {
        return Empty()
    }
}
