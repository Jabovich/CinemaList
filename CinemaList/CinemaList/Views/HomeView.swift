//
//  HomeView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                
                HStack {
                    Text("Продолжить просмотр")
                        .font(.title)
                    Spacer()
                }
                .padding()
                
                PostersScrollView()
                
                HStack {
                    Text("Отложенные")
                        .font(.title)
                    Spacer()
                }
                .padding()
                
                PostersScrollView()
                
            }
            .navigationTitle("Коллекция фильмов")
        }
    }
}

#Preview {
    HomeView()
}
