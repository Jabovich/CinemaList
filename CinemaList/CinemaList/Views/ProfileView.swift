//
//  ProfileView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = LoginViewModel()
    @State private var isLoggedOut = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Logout") {
                    viewModel.logOut()
                    isLoggedOut = true
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.red)
            }
            // Определяем переход при изменении isLoggedOut
            .navigationDestination(isPresented: $isLoggedOut) {
                TempLNRView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
