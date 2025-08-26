import Foundation

extension Bundle {
    var isTestFlight: Bool {
        #if DEBUG
        return false
        #else
        // Check if this is a TestFlight build by looking for the sandbox receipt
        // or if running in a development environment (like release build from Xcode)
        if let receiptURL = appStoreReceiptURL {
            return receiptURL.lastPathComponent == "sandboxReceipt"
        } else {
            // If no receipt URL exists, we're likely running a development build
            // (release build from Xcode, simulator, etc.)
            return false
        }
        #endif
    }
    
    /// Returns true if the app is running in a development environment
    /// (DEBUG builds, release builds from Xcode, simulator, etc.)
    var isDevelopmentBuild: Bool {
        #if DEBUG
        return true
        #else
        // Check if we're running in simulator or have no receipt (development environment)
        #if targetEnvironment(simulator)
        return true
        #else
        return appStoreReceiptURL == nil
        #endif
        #endif
    }
}
