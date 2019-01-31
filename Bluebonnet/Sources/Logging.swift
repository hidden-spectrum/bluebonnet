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


extension Bluebonnet {
    internal static let log = OSLog(subsystem: "com.theisholdings.bluebonnet", category: "Networking")
}


internal func bb_log_debug(_ message: StaticString, _ args: CVarArg...) {
    bb_log(message, type: .debug, args)
}

internal func bb_log_info(_ message: StaticString, _ args: CVarArg...) {
    bb_log(message, type: .info, args)
}

internal func bb_log_error(_ message: StaticString, _ args: CVarArg...) {
    bb_log(message, type: .error, args)
}

private func bb_log(_ message: StaticString, type: OSLogType, _ args: CVarArg...) {
    os_log(message, log: Bluebonnet.log, type: type, args)
}
