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
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(viewModel.movie) { movie in
                        NavigationLink(destination: MovieCardView(id: movie.id)) {
//                            VStack {
//                                AsyncImage(url: URL(string: movie.poster)) { image in
//                                    image.resizable()
//                                        .scaledToFit()
//                                        .frame(width: 150, height: 225)
//                                        .cornerRadius(10)
//                                } placeholder: {
//                                    ProgressView()
//                                        .frame(width: 150, height: 225)
//                                }
//                                
//                                Text(movie.title)
//                                    .font(.caption)
//                                    .lineLimit(1)
//                                    .padding(.top, 5)
//                            }
                            VStack {
                                // Заменяем AsyncImage на KFImage
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
            .navigationTitle("Коллекция фильмов")
        }
        .onAppear {
            viewModel.loadMovies()
        }
        //.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    MovieListView()
}
