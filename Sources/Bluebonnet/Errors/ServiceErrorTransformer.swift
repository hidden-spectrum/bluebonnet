//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


/**
 Conform to this protocol to transform an error from a ``ServiceRequest`` to another error.
 When a  ``ServiceRequest`` receives anything other than a 2xx or Bluebonnet generates an error internally you can handle the error and any possible data globally with a transformer.
 This is useful if your services return errors in a standard JSON format.
 See ``ServiceErrorSifter`` for more
 */
public protocol ServiceErrorTransformer {
    
    /// Transform the error/response data. Return the transformed error or nil if the transformer
    /// is not appropriate for that error.
    func transform(error: Error, responseData: Data?) -> Error?
}
