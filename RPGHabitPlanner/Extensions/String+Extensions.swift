import Foundation

extension String {
    // MARK: - Asset Name Conversion
    
    /// Converts preview asset names to actual asset names by removing the "_preview" suffix
    var actualAssetName: String {
        if self.hasSuffix("_preview") {
            return String(self.dropLast(8)) // Remove "_preview" suffix
        }
        return self
    }
    
    // MARK: - Validation
    
    var isValidNickname: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && trimmed.count <= 16
    }
    
    // MARK: - Formatting
    
    func truncate(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
}
