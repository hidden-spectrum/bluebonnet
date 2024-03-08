//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/**
 Register your ``ServiceErrorTransformer`` types and ``ServiceErrorHandler`` with this type.
 - Note: An error is sent to the registered ``ServiceErrorTransformer`` types first (if any), and then  the transformed (or original) error is sent to the registered ``ServiceErrorHandler`` types.
 */
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
    
    /**
     Adds the given ``ServiceErrorTransformer`` to the sifter. Transformers are run through in the order added.
     Once a transformer transforms an error, neither the original error or transformed error are sent to any other transformers.
     */
    public func add(_ transformer: ServiceErrorTransformer) {
        transformers.append(transformer)
    }
    
    /**
     Adds the given ``ServiceErrorHandler`` to the sifter. Handlers are run through in the order added.
     If a handler consumes an error, it is not sent to any subsequent handlers.
     */
    public func add(_ handler: ServiceErrorHandler) {
        handlers.append(handler)
    }
    
    // MARK: Sifting
    
    /// Sifts the given error and accompaning response data.
    internal func sift(_ error: Error, responseData: Data? = nil) -> Error {
        var finalError = error
        
        for transformer in transformers {
            if let transformedError = transformer.transform(error: error, responseData: responseData) {
                finalError = transformedError
                break
            }
        }
        
        for handler in handlers {
            if handler.handle(error: finalError) {
                break
            }
        }
        
        return finalError
    }
}
