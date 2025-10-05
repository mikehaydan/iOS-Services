//
//  ViewModel.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import SwiftUI

final class ViewModel: ObservableObject {

    // MARK: - Properties

    let apiService: APIService
    let keychain: Keychain

    @Published var user: UserAPIModel?

    init () {
        let apiClient = RESTClient(session: URLSession.shared)
        let requestBuilder = URLRequestBuilderImpl.defaultBuilder
        let keychain = KeychainImpl()
        let sessionHandler = SessionHandlerImpl(apiClient: apiClient, requestBuilder: requestBuilder, keychain: keychain)
        let requestExecutor = RESTRequestExecutor(
            apiClient: apiClient,
            requestBuilder: requestBuilder,
            sessionAdapter: sessionHandler
        )

        self.apiService = APIServiceImpl(requestExecutor: requestExecutor, sessionHandler: sessionHandler)
        self.keychain = keychain
    }

    // MARK: - Public

    @MainActor
    func login(userName: String, password: String) {
        Task {
            do {
                let user = try await apiService.login(userName: userName, password: password)
                let session = Session(accessToken: user.accessToken, refreshToken: user.refreshToken)
                self.keychain.save(session, for: Session.identifier)
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func getUser() {
        Task {
            do {
                self.user = nil
                let user = try await apiService.getMe()
                self.user = user
            } catch {
                print(error)
            }
        }
    }
}
