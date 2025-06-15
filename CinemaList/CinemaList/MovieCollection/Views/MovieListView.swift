//
//  MovieListView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 07.02.2025.
//

import SwiftUI
import Kingfisher

struct MovieListView: View {
    @StateObject var viewModel = MovieViewModel()
    @State private var selectedStatusIndex = 0
    
    let statusOptions = [
        ("В очереди", "want_to_watch"),
        ("Не закончены", "not_finished"),
        ("Просмотрены", "watched")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Segmented Control для выбора статуса
                Picker("Статус просмотра", selection: $selectedStatusIndex) {
                    ForEach(0..<statusOptions.count, id: \.self) { index in
                        Text(statusOptions[index].0).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedStatusIndex) { oldValue, newValue in
                    let status = statusOptions[newValue].1
                    viewModel.loadMovies(endpoint: "user/content/films/get?status=\(status)")
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(viewModel.movie) { movie in
                            NavigationLink(destination: MovieCardView(id: movie.id)) {
                                VStack {
                                    KFImage(URL(string: movie.poster))
                                        .placeholder {
                                            ProgressView()
                                                .frame(width: 150, height: 225)
                                        }
                                        .resizable()
                                        .fade(duration: 0.25)
                                        .scaledToFit()
                                        .frame(width: 150, height: 225)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                    
                                    Text(movie.title)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .padding(.top, 5)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Мои фильмы")
        }
        .onAppear {
            // Загружаем фильмы со статусом "Хочу посмотреть" при первом открытии
            let initialStatus = statusOptions[selectedStatusIndex].1
            viewModel.loadMovies(endpoint: "user/content/films/get?status=\(initialStatus)")
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MovieListView()
}
