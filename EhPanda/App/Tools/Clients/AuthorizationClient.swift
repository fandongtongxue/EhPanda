//
//  AuthorizationClient.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 4/01/03.
//

import Combine
import LocalAuthentication
import ComposableArchitecture

struct AuthorizationClient {
    let passcodeNotSet: () -> Bool
    let localAuthroize: (String) -> Effect<Bool, Never>
}

extension AuthorizationClient {
    static let live: Self = .init(
        passcodeNotSet: {
            var error: NSError?
            return !LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        },
        localAuthroize: { reason in
            Future { promise in
                let context = LAContext()
                var error: NSError?

                if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { isSuccess, _ in
                        promise(.success(isSuccess))
                    }
                } else {
                    promise(.success(false))
                }
            }
            .eraseToAnyPublisher()
            .eraseToEffect()
        }
    )
}