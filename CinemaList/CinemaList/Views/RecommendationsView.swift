//
//  RecommendationsView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 14.05.2025.
//

import Foundation

struct RecommendationResponse: Codable {
    let message: String
    let data: [Recommendation]
}

struct Recommendation: Identifiable, Codable {
    let id: Int
    let message: String
    let user: UserRec
    let film: Film
}

struct UserRec: Codable {
    let id: Int
    let username: String
    let profilePhoto: String
}

struct Film: Codable {
    let tmdbId: Int
    let title: String
    let poster: String
    let rating: String
}

enum RecommendationError: Error {
    case invalidURL, invalidResponse, invalidData
}

func getRecommendations() async throws -> [Recommendation] {
    let endpoint = "\(baseURL)/recommendation"
    
    guard let url = URL(string: endpoint) else {
        throw RecommendationError.invalidURL
    }

    let accessToken = getAccessToken(account: "accessToken")
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw RecommendationError.invalidResponse
    }

    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let recommendationResponse = try decoder.decode(RecommendationResponse.self, from: data)
        return recommendationResponse.data
    } catch {
        throw RecommendationError.invalidData
    }
}

import SwiftUI

struct RecommendationsView: View {
    @State private var recommendations: [Recommendation] = []
    @State private var selectedRecommendation: Recommendation?
    @State private var showSheet = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Загрузка...")
                } else {
                    List(recommendations) { rec in
                        HStack {
                            AsyncImage(url: URL(string: rec.film.poster)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 60, height: 90)
                            .cornerRadius(8)

                            VStack(alignment: .leading) {
                                Text(rec.film.title)
                                    .font(.headline)
                                Text(rec.user.username)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .onTapGesture {
                            selectedRecommendation = rec
                            showSheet = true
                        }
                    }
                }
            }
            .navigationTitle("Новости")
            .task {
                do {
                    recommendations = try await getRecommendations()
                } catch {
                    print("Ошибка при загрузке: \(error)")
                }
                isLoading = false
            }
            .sheet(isPresented: $showSheet) {
                if let rec = selectedRecommendation {
                    RecommendationDetailSheet(recommendation: rec)
                }
            }
        }
    }
}

struct RecommendationDetailSheet: View {
    let recommendation: Recommendation

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: recommendation.film.poster)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 200, height: 300)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Text(recommendation.film.title)
                        .font(.title2)
                        .bold()

                    HStack {
                        AsyncImage(url: URL(string: recommendation.user.profilePhoto)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        
                        Text(recommendation.user.username)
                            .foregroundColor(.secondary)
                    }

                    Text(recommendation.message)
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("Рекомендация")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    RecommendationsView()
}
