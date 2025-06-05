//
//  LoginViewModel.swift
//  Test
//
//  Created by Андрей Сметанин on 15.03.2025.
//

import Observation
import SwiftUI

@Observable
final class LoginViewModel {
    var user = UserData()
    var authenticated = false
    
    var isLoginButtonDisable: Bool {
        user.email.isEmpty || user.password.isEmpty
    }
    
    func logIn() {
        print("Logging in...")
        print("Now user.email is: \(user.email)")
        
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        toggleAuthentication()
    }
    
    func logOut() {
        print("Logging out...")
        user.name = ""
        user.surname = ""
        user.patronymic = ""
        user.username = ""
        user.email = ""
        user.password = ""
        
        print("Now user.name is: \(user.name)")
        
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        toggleAuthentication()
        
        do {
            try KeychainManager.delete(account: "accessToken")
            try KeychainManager.delete(account: "refreshToken")
        } catch {
            print("KeychainManager error: \(error)")
        }
        print("Tokens deleted successfully")

    }
    
    private func toggleAuthentication() {
        withAnimation{
            authenticated.toggle()
        }
    }
}
