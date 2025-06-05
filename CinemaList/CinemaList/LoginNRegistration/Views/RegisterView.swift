//
//  RegisterView.swift
//  Test
//
//  Created by Андрей Сметанин on 01.03.2025.
//

import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var patronymic: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    // TODO: Test navigation
    @State private var navigateToLogin = false
    
    private var isRegisterButtonDisable: Bool {
        name.isEmpty || surname.isEmpty || patronymic.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || passwordConfirmation.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Регистрация")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Имя", text: $name)
                    .tfStyle()
                
                TextField("Фамилия", text: $surname)
                    .tfStyle()
                
                TextField("Отчество", text: $patronymic)
                    .tfStyle()
                
                TextField("Username", text: $username)
                    .tfStyle()
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .tfStyle()
                
                SecureField("Пароль", text: $password)
                    .tfStyle()
                
                SecureField("Подтверждение пароля", text: $passwordConfirmation)
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
                
                Button(action: registerUser) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Зарегистрироваться")
                            .tbStyle()
                            .background(RoundedRectangle(cornerRadius: 15)
                                .fill(isRegisterButtonDisable ? .gray : .pink))
                    }
                }
                .disabled(isLoading)
                .disabled(isRegisterButtonDisable)
                
                // TODO: Test navigation
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView()
                }
            }
            .padding()
        }
    }
    
    func registerUser() {
        guard password == passwordConfirmation else {
            errorMessage = "Пароли не совпадают"
            return
        }

        guard let url = URL(string: "https://server.kinolist.space/api/auth/register") else {
            errorMessage = "Некорректный URL"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let userData: [String: Any] = [
            "name": name,
            "surname": surname,
            "patronymic": patronymic,
            "username": username,
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
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
                    
                    
                    // TODO: Test navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        navigateToLogin = true
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
    RegisterView()
}
