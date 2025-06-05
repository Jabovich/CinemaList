//
//  SettingsItem.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 25.03.2025.
//

import Foundation
import SwiftUI

struct SettingsItem {
    let imageName: String
    var imageType: ImageType = .systemImage
    let backgroundColor: Color
    let title: String
    
    enum ImageType {
        case systemImage, assetImage
    }
}

// MARK: Settings Data
extension SettingsItem {
    static let avatar = SettingsItem(
        imageName: "photo",
        backgroundColor: .blue,
        title: "Сменить фото профиля"
    )
    
    static let stats = SettingsItem(
        imageName: "gauge.with.dots.needle.bottom.50percent",
        backgroundColor: .green,
        title: "Статистика"
    )
    
    static let playlists = SettingsItem(
        imageName: "play.square.stack",
        backgroundColor: .yellow,
        title: "Плейлисты"
    )
    
    static let account = SettingsItem(
        imageName: "key.fill",
        backgroundColor: .blue,
        title: "Редактировать аккаунт"
    )
    
    
    static let friends = SettingsItem(
        imageName: "person.2",
        backgroundColor: .green,
        title: "Друзья"
    )
    
    static let notifications = SettingsItem(
        imageName: "bell.badge.fill",
        backgroundColor: .red,
        title: "Уведомления"
    )
    
    static let storage = SettingsItem(
        imageName: "arrow.up.arrow.down",
        backgroundColor: .green,
        title: "Очистить кэш приложения"
    )
    
    static let help = SettingsItem(
        imageName: "message",
        backgroundColor: .blue,
        title: "Помощь"
    )
    
    static let tellFriend = SettingsItem(
        imageName: "heart.fill",
        backgroundColor: .red,
        title: "Поделиться с друзьями"
    )
    
    static let logOut = SettingsItem(
        imageName: "door.left.hand.open",
        backgroundColor: .red,
        title: "Выйти"
    )
}
