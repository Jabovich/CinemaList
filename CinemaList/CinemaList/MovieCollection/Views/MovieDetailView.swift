//
//  MovieDetailView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 07.02.2025.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: movie.backdropImage)) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Рейтинг: \(String(format: "%.1f", movie.rating))")
                        Text("(\(movie.ratingPeopleCount) голосов)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                    Text(movie.overview)
                        .font(.body)
                        .padding(.top, 5)
                    
                    Text("Дата выхода: \(movie.releaseDate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
