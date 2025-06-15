//
//  MovieViewModel.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 07.02.2025.
//

import Foundation

class MovieViewModel: ObservableObject {
    @Published var movie: [Movie] = []
    
    func loadMovies(endpoint: String) {
        guard let url = URL(string: "https://server.kinolist.space/api/\(endpoint)") else {
            print("Некорректный URL")
            return
        }
        
        let accessToken = getAccessToken(account: "accessToken")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET" 
        request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Некорректный ответ сервера")
                return
            }
            
            print("Код статуса: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                print("Ошибка авторизации: неверный токен")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Некорректный ответ сервера: \(httpResponse.statusCode)")
                return
            }

            guard let data = data else {
                print("Нет данных")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    self.movie = decodedResponse.data
                }
            } catch {
                print("Ошибка при разборе JSON: \(error)")
            }
        }.resume()
    }
}
