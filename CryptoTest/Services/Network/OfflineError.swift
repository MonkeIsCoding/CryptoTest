//
//  OfflineError.swift
//  CryptoTest
//
//  Created by Kiko on 23/07/2026.
//

import Foundation

extension Error {

    var isOfflineError: Bool {
        let nsError = self as NSError

        switch nsError.domain {
        case NSURLErrorDomain:
            return [
                NSURLErrorNotConnectedToInternet,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorCannotConnectToHost,
                NSURLErrorCannotFindHost,
                NSURLErrorTimedOut,
                NSURLErrorDataNotAllowed,
                NSURLErrorInternationalRoamingOff
            ].contains(nsError.code)

        case "FIRFirestoreErrorDomain":
            return nsError.code == 14

        default:
            return false
        }
    }
}
