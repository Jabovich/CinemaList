//
//  MovieViewModel.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 07.02.2025.
//

import Foundation

class MovieViewModel: ObservableObject {
    @Published var movie: [Movie] = []
    
//    func loadMovies() {
//        guard let url = Bundle.main.url(forResource: "new_data", withExtension: "json") else {
//            print("Файл не найден")
//            return
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let decodedResponse = try JSONDecoder().decode(MoviesResponse.self, from: data)
//            DispatchQueue.main.async {
//                self.movies = decodedResponse.data
//            }
//        } catch {
//            print("Ошибка при разборе JSON: \(error)")
//        }
//    }
    
    func loadMovies(page: Int = 1) {
        guard let url = URL(string: "https://server.kinolist.space/api/tmdb/films?page=\(page)") else {
            print("Некорректный URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Некорректный ответ сервера")
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
