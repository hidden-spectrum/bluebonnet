//
//  Copyright (c) 2019 Theis Holdings, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


/// Register your `ServiceErrorTransformer`s and `ServiceErrorHandler` with this type.
/// - Note: An error is sent to the registered `ServiceErrorTransformer`s first (if any), and then
/// the transformed (or original) error is sent to the registered `ServiceErrorHandler`s.
public class ServiceErrorSifter {
    
    // MARK: Private
    
    public static let shared = ServiceErrorSifter()
    
    // MARK: Private
    
    private var transformers = [ServiceErrorTransformer]()
    private var handlers = [ServiceErrorHandler]()
    
    // MARK: Lifecycle
    
    private init() {
    }

    // MARK: Registry
    
    /// Adds the given `ServiceErrorTransformer to the sifter. Transformers are run through in
    /// the order added. Once a transformer transforms an error, neither the original error or
    /// transformed error are sent to any other transformers.
    public func add(_ transformer: ServiceErrorTransformer) {
        self.transformers.append(transformer)
    }
    
    /// Adds the given `ServiceErrorHandler` to the sifter. Handlers are run through in the order
    /// added. If a handler consumes an error, it is not sent to any subsequent handlers.
    public func add(_ handler: ServiceErrorHandler) {
        self.handlers.append(handler)
    }
    
    // MARK: Sifting
    
    /// Sifts the given error and accompaning response data.
    internal func sift(_ error: Error, responseData: Data? = nil) -> Error {
        var finalError = error
        
        for transformer in self.transformers {
            if let transformedError = transformer.transform(error: error, responseData: responseData) {
                finalError = transformedError
                break
            }
        }
        
        for handler in self.handlers {
            if handler.handle(error: finalError) {
                break
            }
        }
        
        return finalError
    }
}
