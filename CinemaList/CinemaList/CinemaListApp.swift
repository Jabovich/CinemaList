//
//  CinemaListApp.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI

@main
struct CinemaListApp: App {
    @State private var viewModel = LoginViewModel()
    @State private var isLoginView = true
    
    init(){
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            viewModel.authenticated.toggle()
            print("Вход в аккаунт был выполнен в прошлой сессии")
            refreshToken()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    if !viewModel.authenticated {
                        if isLoginView {
                            LoginView(viewModel: viewModel)
                        } else {
                            RegisterView()
                        }
                        
                        Button(action: {
                            isLoginView.toggle()
                        }) {
                            Text(isLoginView ? "Нет аккаунта? Зарегистрироваться" : "Уже есть аккаунт? Войти")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ContentView()
                    }
                }
            }
        }
    }
    
    func refreshToken() {
        print("Start func refreshToken")
        
        guard let url = URL(string: "https://server.kinolist.space/api/auth/refreshToken") else {
            print("Некорректный URL")
            return
        }
        
        var accessToken = ""
        
        do {
            let tokenData = try KeychainManager.get(account: "refreshToken")
            accessToken = String(data: tokenData, encoding: .utf8) ?? "Failed to decode token"
            
            print("Retrieved Access Token: \(tokenData)")
        } catch KeychainError.notFound {
            print("Token not found in Keychain")
            viewModel.logOut()
        } catch {
            print("Error retrieving token: \(error)")
            viewModel.logOut()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("Нет данных от сервера")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(RefreshActionResponse.self, from: data)
                    print(response.message)
                    
                    do {
                        try KeychainManager.update(
                            token: response.data.access_token.data(using: .utf8) ?? Data(),
                            account: "accessToken"
                        )
                    } catch {
                        print("KeychainManager error: \(error)")
                    }
                    
                    do {
                        try KeychainManager.update(
                            token: response.data.refresh_token.data(using: .utf8) ?? Data(),
                            account: "refreshToken"
                        )
                    } catch {
                        print("KeychainManager error: \(error)")
                    }
                    
                } catch {
                    print("Ошибка декодирования ответа: \(error.localizedDescription)")
                    viewModel.logOut()
                }
            }
        }
        task.resume()
    }
}
