//
//  Friends.swift
//  CinemaList
//
//  Created by Denis Burof on 30.04.2025.
//

import Foundation

struct FriendsResponse: Codable {
    let result: String
    let data: [Friend]
}

struct Friend: Identifiable, Codable {
    let id: Int
    let name: String
    let surname: String
    let patronymic: String?
    let username: String
    let email: String
    let avatarURL: URL?
    let status: String
    let roomId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "friend_id"
        case name, surname, patronymic, username, email, status
        case avatarURL = "profile_photo"
        case roomId = "room_id"
    }
    
    var displayName: String {
        [surname, name, patronymic].compactMap { $0 }.joined(separator: " ")
    }
}

//struct SearchResponse: Codable {
//    let result: String
//    let users: [SearchedUser]
//}
//
//struct SearchedUser: Identifiable, Codable {
//    let id: Int
//    let username: String
//    let displayName: String
//    let avatarURL: URL?
//    
//    enum CodingKeys: String, CodingKey {
//        case id, username
//        case displayName = "display_name"
//        case avatarURL = "avatar_url"
//    }
//}

struct SearchResponse: Codable {
    let result: String
    let users: [SearchedUser]
}

struct SearchedUser: Identifiable, Codable {
    let id: Int
    let name: String
    let surname: String
    let patronymic: String?
    let username: String
    let email: String
    let avatarURL: URL?
    let friendRequestStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id = "friend_id"
        case name, surname, patronymic, username, email
        case avatarURL = "profile_photo"
        case friendRequestStatus = "friend_request_status"
    }
    
    var displayName: String {
        [surname, name, patronymic].compactMap { $0 }.joined(separator: " ")
    }
}
