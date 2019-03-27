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

import os.log


/// This type holds all global configuration options and miscellaneous variables.
public struct Bluebonnet {
    
    /// The `URLSesssion` to use. See `URLSession` for more info.
    public static var urlSession = URLSession.shared
}


/// Errors specific to Bluebonnet.
public enum BluebonnetError: Error {
    case couldNotGenerateRequestURL
    case receivedNonHTTPURLResponse
    case unexpectedlyReceivedEmptyResponseBody
    case unexpectedStatusCode(HTTPStatusCode)
}


internal extension OSLog {
    
    /// Log for `os_log` calls.
    static let bluebonnet = OSLog(subsystem: "com.theisholdings.bluebonnet", category: "Bluebonnet")
}
