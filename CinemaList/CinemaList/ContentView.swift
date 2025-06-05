//
//  ContentView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
            
            CollectionView()
                .tabItem {
                    Label("Коллекция", systemImage: "tray.full.fill")
                }
            
            MeetView()
                .tabItem {
                    Label("Встреча", systemImage: "person.2.crop.square.stack.fill")
                }
            
            //NewsView()
            RecommendationsView()
                .tabItem {
                    Label("Новости", systemImage: "newspaper.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Профиль", systemImage: //"person.crop.square"
                          "ellipsis.circle.fill"
                    )
                }
        }
        .tint(Color.pink)
        .labelStyle(.iconOnly)
    }
        
}


#Preview {
    ContentView()
}
