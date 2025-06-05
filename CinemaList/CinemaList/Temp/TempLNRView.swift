//
//  TempLNRView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 25.03.2025.
//

import SwiftUI

struct TempLNRView: View {
    @State private var viewModel = LoginViewModel()
    @State private var isLoginView = true
    
    
    var body: some View {
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
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    TempLNRView()
}
