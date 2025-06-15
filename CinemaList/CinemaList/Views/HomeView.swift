//
//  HomeView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject var searchViewModel = MovieViewModel()
    @State private var showSearchSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Продолжить просмотр")
                            .font(.title)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    PostersScrollView(endpoint: "user/content/films/get?status=not_finished")
                    
                    HStack {
                        Text("Выбор критиков")
                            .font(.title)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    PostersScrollView(endpoint: "tmdb/films/?rating-min=9")
                }
            }
            .navigationTitle("Главная")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearchSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(8)
                            //.background(Color.pink)
                            .foregroundColor(.pink)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showSearchSheet) {
                SearchView(viewModel: searchViewModel, searchText: $searchText)
            }
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: MovieViewModel
    @Binding var searchText: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Название фильма", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onSubmit {
                            searchMovies()
                        }
                    
                    Button(action: searchMovies) {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing)
                    }
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
            .navigationTitle("Поиск фильмов")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchMovies() {
        guard !searchText.isEmpty else { return }
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        viewModel.loadMovies(endpoint: "tmdb/search-films?query=\(query)")
    }
}

#Preview {
    HomeView()
}
