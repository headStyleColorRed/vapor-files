//
//  StringExtensions.swift
//  StringExtensions
//
//  Created by Rodrigo Labrador Serrano on 11/8/21.
//

import Foundation

extension String {
    /// Returns the string as a generic error with no domain or code.
    /// Just the string's value as .localizedDescription
    var asError: Error {
        return NSError(domain: "", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: self])
    }
}
