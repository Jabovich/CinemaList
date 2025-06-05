//
//  User.swift
//  Test
//
//  Created by Андрей Сметанин on 15.03.2025.
//

struct LoginNRegisterResponse: Codable {
    let message: String
    let data: LoginNRegisterData
}

struct LoginNRegisterData: Codable {
    let user: User
    let access_token: String
    let refresh_token: String
}

struct UserResponse: Codable {
    let user: User
}

struct User: Codable {
    let name: String
    let surname: String
    let patronymic: String
    let username: String
    let email: String
    let profilePhoto: String? //Используется в SettingsView
    let filmsNotFinishedCount: Int?
    let filmsWatchedCount: Int?
    let filmsWantToWatchCount: Int?
}

struct UserData {
    var name = ""
    var surname = ""
    var patronymic = ""
    var username = ""
    var email = ""
    var password = ""
}


struct RefreshActionResponse: Codable{
    let message: String
    let data: RefreshData
}

struct RefreshData: Codable{
    let access_token: String
    let refresh_token: String
}
