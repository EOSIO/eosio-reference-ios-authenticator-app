//
//  AppError.swift
//
//  Created by Todd Bowden on 7/11/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

public enum AppErrorCode: String, Codable {

    case biometricsDisabled = "biometricsDisabled"
    case keychainError = "keychainError"
    case manifestError = "manifestError"
    case metadataError = "metadataError"
    case networkError = "networkError"
    case parsingError = "parsingError"
    case resourceIntegrityError = "resourceIntegrityError"
    case resourceRetrievalError = "resourceRetrievalError"
    case signingError = "signingError"
    case transactionError = "transactionError"
    case vaultError = "vaultError"
    case whitelistingError = "whitelistingError"
    case malformedRequestError = "malformedRequestError"
    case domainError = "domainError"
    //general catch all
    case unexpectedError = "unexpectedError"
}

open class AppError: Error, CustomStringConvertible, Codable {

    public var errorCode: AppErrorCode
    public var reason: String
    public var originalError: NSError?
    public var isReturnable = true // can this error be returned to a requesting app

    enum CodingKeys: String, CodingKey {
        case errorCode
        case reason
    }

    /// Returns a JSON string representation of the error object.
    var errorAsJsonString: String {
        let jsonDict = [
            "errorType": "AppError",
            "errorInfo": [
                "errorCode": self.errorCode.rawValue,
                "reason": self.reason
            ]
            ] as [String: Any]

        if JSONSerialization.isValidJSONObject(jsonDict),
            let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted),
            let jsonString = String(data: data, encoding: .utf8) {

            return jsonString

        }

        return "{}"

    }

    public var description: String {
        return "\(errorCode): \(reason)"
    }

    public init (_ errorCode: AppErrorCode, reason: String, originalError: NSError? = nil, isReturnable: Bool = true) {
        self.errorCode = errorCode
        self.reason = reason
        self.originalError = originalError
        self.isReturnable = isReturnable
    }
}

extension AppError: LocalizedError {

    public var errorDescription: String? {
        return "\(self.errorCode.rawValue): \(self.reason)"

    }
}

public extension Error {

    var appError: AppError {

        if let appError = self as? AppError {
            return appError
        }

        return AppError(AppErrorCode.unexpectedError, reason: self.localizedDescription)
    }

}
