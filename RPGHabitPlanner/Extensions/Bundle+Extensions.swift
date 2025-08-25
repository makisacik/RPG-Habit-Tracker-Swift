import Foundation

extension Bundle {
    var isTestFlight: Bool {
        #if DEBUG
        return false
        #else
        return appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }
}
