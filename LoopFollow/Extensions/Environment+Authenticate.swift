//
//  Environment+Authenticate.swift
//  LoopFollow
//
//  Created by peng on 2022/9/25.
//  Copyright © 2022 Jon Fawcett. All rights reserved.
//

import LocalAuthentication
import SwiftUI

public typealias AuthenticationChallenge = (_ description: String, _ completion: @escaping (Result<Void, Error>) -> Void) -> Void

fileprivate struct UnknownError: Swift.Error { }

public struct LocalAuthentication {
    public static let deviceOwnerCheck: AuthenticationChallenge = { authenticationChallengeDescription, completion in
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: authenticationChallengeDescription,
                                   reply: { (success, error) in
                                    DispatchQueue.main.async {
                                        assert(success || error != nil)
                                        completion(success ? .success(()) : .failure(error ?? UnknownError()))
                                    }
            })
        } else {
            // The logic here is to not fail to execute completion just because there is no authentication set up on the iPhone
            completion(.success(()))
        }
    }
}

private struct AuthenticationChallengeKey: EnvironmentKey {
    static let defaultValue: AuthenticationChallenge = LocalAuthentication.deviceOwnerCheck
}

extension EnvironmentValues {
    public var authenticate: AuthenticationChallenge {
        get { self[AuthenticationChallengeKey.self] }
        set { self[AuthenticationChallengeKey.self] = newValue }
    }
}
