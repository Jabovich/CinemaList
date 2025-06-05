//
//  LoginView.swift
//  Test
//
//  Created by Андрей Сметанин on 06.03.2025.
//

import SwiftUI

struct LoginView: View {
    @Bindable var viewModel = LoginViewModel()
    
    @State private var isLoading: Bool = false
    
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вход")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $viewModel.user.email)
                .keyboardType(.emailAddress)
                .tfStyle()
            

            SecureField("Пароль", text: $viewModel.user.password)
                .tfStyle()
            

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.footnote)
            }
            
            Button(action: {
                viewModel.logIn()
                loginUser()
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Войти")
                        .tbStyle()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                            .fill(viewModel.isLoginButtonDisable ? .gray : .pink))
                }
            }
            .padding(.horizontal)
            .disabled(isLoading)
            .disabled(viewModel.isLoginButtonDisable)
        }
        .padding()
    }
    
    func loginUser() {
        print("Start func loginUser")
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://server.kinolist.space/api/auth/login") else {
            errorMessage = "Некорректный URL"
            return
        }
        
        let userData: [String: Any] = [
            "email": viewModel.user.email,
            "password": viewModel.user.password
            
//            "email": "kimberly7710@navalcadets.com",
//            "password": "kimberly"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: userData)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "Нет данных от сервера"
                    return
                }

                do {
                    let response = try JSONDecoder().decode(LoginNRegisterResponse.self, from: data)
                    successMessage = response.message
                    
                    viewModel.user.name = response.data.user.name
                    viewModel.user.surname = response.data.user.surname
                    viewModel.user.patronymic = response.data.user.patronymic
                    viewModel.user.username = response.data.user.username
                    
                    print("Now viewModel.user.name is \(viewModel.user.name)")
                    
                    
                    //TODO: Move KeychainManager calls to LoginViewModel
                    do {
                        try KeychainManager.save(
                            token: response.data.access_token.data(using: .utf8) ?? Data(),
                            account: "accessToken"
                        )
                    } catch {
                        print("KeychainManager error: \(error)")
                    }
                    
                    do {
                        try KeychainManager.save(
                            token: response.data.refresh_token.data(using: .utf8) ?? Data(),
                            account: "refreshToken"
                        )
                    } catch {
                        print("KeychainManager error: \(error)")
                    }
                    
                } catch {
                    errorMessage = "Ошибка декодирования ответа: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
}


#Preview {
    LoginView(viewModel: LoginViewModel())
}
