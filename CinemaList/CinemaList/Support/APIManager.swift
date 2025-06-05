//
//  APIManager.swift
//  CinemaList
//
//  Created by Denis Burof on 04.04.2025.
//

import Foundation
import UIKit

let baseURL = "https://server.kinolist.space/api"

func getUser() async throws -> User {
    let endpoint = "\(baseURL)/profile/"
    
    print("Start func getUser")
    
    guard let url = URL(string: endpoint) else {
        throw ProfileError.invalidURL
    }
    
    let accessToken = getAccessToken(account: "accessToken") 
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw ProfileError.invalidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let UserResponse = try decoder.decode(UserResponse.self, from: data)
        let user = UserResponse.user
        //print("Decoded user: \(user)") // Для отладки
        return user
    } catch {
        throw ProfileError.invalidData
    }
}

func uploadPhoto(photo: UIImage) {
    guard let url = URL(string: "\(baseURL)/profile/upload/profile-photo") else {
        print("Некорректный URL")
        return
    }
    
    guard let photoData = photo.jpegData(compressionQuality: 0.1) else {
        print("Failed compression")
        return
    }
    
    let accessToken = getAccessToken(account: "accessToken")
    
    // Создание запроса
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    
    // Генерация multipart-запроса
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    // Формирование тела запроса
    var body = Data()
    
    // Добавляем файл (фотографию)
    let filename = "profile-photo.jpg" // Можно изменить расширение в зависимости от формата изображения
    let mimeType = "image/jpeg" // Можно изменить MIME-тип в зависимости от формата изображения
    
    // Конвертируем строки в Data перед добавлением в тело запроса
    body.append("--\(boundary)\r\n".data(using: .utf8)!) // Boundary start
    body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!) // Content-Disposition
    body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!) // Content-Type
    
    // Добавляем данные фотографии
    body.append(photoData)
    
    // Завершаем запрос
    body.append("\r\n".data(using: .utf8)!) // Line break
    body.append("--\(boundary)--\r\n".data(using: .utf8)!) // Boundary end
    
    request.httpBody = body
    
    // Выполнение запроса
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                print("Ошибка при отправке: \(error.localizedDescription)")
                return
            }
            
            guard data != nil else {
                print("Нет данных от сервера")
                return
            }
            
            // Обработка ответа
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Фотография успешно загружена!")
            } else {
                print("Ошибка загрузки. Статус код: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        }
    }
    
    task.resume()
}

//func getMovieData(id: Int) async throws -> MovieResponse {
//    
//    
//    do {
//        let url = URL(string: "https://server.kinolist.space/api/tmdb/films/\(id)")!
//        let (data, _) = try await URLSession.shared.data(from: url)
//        let response = try JSONDecoder().decode(MovieResponse.self, from: data)
//        
//        if response.result == "success" {
//            let movieData = response.data
//        } else {
//            print("Не удалось загрузить данные о фильме")
//        }
//    } catch {
//        print("Ошибка при загрузке данных: \(error.localizedDescription)")
//    }
//    
//   
//}

//func getMovieInfo(id: Int) async throws -> Movie {
//    //print("..........")
//    let urlString = "https://server.kinolist.space/api/tmdb/films/\(id)"
//    guard let url = URL(string: urlString) else {
//        throw URLError(.badURL)
//    }
//    
//    let (data, _) = try await URLSession.shared.data(from: url)
//    let response = try JSONDecoder().decode(getMovieResponse.self, from: data)
//    //print(response)
//    return response.data
//}

//func getMovieInfo(id: Int) async throws -> Movie {
//    let urlString = "https://server.kinolist.space/api/tmdb/films/\(id)/for-auth-user"
//    guard let url = URL(string: urlString) else {
//        throw URLError(.badURL)
//    }
//    
//    var accessToken = ""
//    
//    do {
//        let tokenData = try KeychainManager.get(account: "accessToken")
//        accessToken = String(data: tokenData, encoding: .utf8) ?? "Failed to decode token"
//        
//        print("Retrieved Access Token: \(tokenData)")
//    } catch KeychainError.notFound {
//        print("Token not found in Keychain")
//    } catch {
//        print("Error retrieving token: \(error)")
//    }
//    
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//    
//    let (data, response) = try await URLSession.shared.data(for: request)
//    
//    // Проверка статус кода (опционально)
////    if let httpResponse = response as? HTTPURLResponse {
////        if !(200...299).contains(httpResponse.statusCode) {
////            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
////        }
////    }
//    
//    let decodedResponse = try JSONDecoder().decode(getMovieResponse.self, from: data)
//    return decodedResponse.data
//}


func getMovieInfo(id: Int) async throws -> Movie {
    let urlString = "\(baseURL)/tmdb/films/\(id)/for-auth-user"
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    let accessToken = getAccessToken(account: "accessToken")


    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Логирование сырых данных (можно ограничить длину для больших данных)
//    let rawResponseString = String(data: data, encoding: .utf8)
//    print("Raw Response: \(rawResponseString ?? "Unable to decode response")...")
    
    // Проверка на успешный статус-код (200...299)
    if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
        throw URLError(.badServerResponse)
    }

    let decoded = try JSONDecoder().decode(getMovieResponse.self, from: data)
    //print("decoded: \(decoded)")
    return decoded.data
}

func postMovieStatus(id: Int, status: String, timecode: String? = nil) {
    print("Start func postMovieStatus")
    
    guard let url = URL(string: "\(baseURL)/user/content/films/add-to-mine") else {
        print("Некорректный URL")
        return
    }
    
    let accessToken = getAccessToken(account: "accessToken")
    
    
    var body: [String: Any] = [
        "tmdb_id": id,
        "status": status,
    ]
    
    if let timecode = timecode {
        body["comment"] = timecode
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {

            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                return
            }
        }
    }
    task.resume()
}

func postRateMovie(id: Int, rating: String) {
    print("Start func postRateMovie")
    
    guard let url = URL(string: "\(baseURL)/user/content/rate-film") else {
        print("Некорректный URL")
        return
    }
    
    let accessToken = getAccessToken(account: "accessToken")
    
    
    let body: [String: Any] = [
        "tmdb_id": id,
        "rating": rating,
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    
    print("request is \(request)")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {

            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                return
            }
        }
    }
    task.resume()
}

// MARK: - Friends API Methods
func getFriends() async throws -> [Friend] {
    let endpoint = "\(baseURL)/friends/"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(FriendsResponse.self, from: data)
        
        if response.result == "success" {
            return response.data
        } else {
            throw URLError(.badServerResponse)
        }
    } catch {
        print("Decoding Error:", error)
        throw error
    }
}

func getIncomingFriendRequests() async throws -> [Friend] {
    let endpoint = "\(baseURL)/friends/requests/incoming"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(FriendsResponse.self, from: data)
        
        if response.result == "success" {
            return response.data.filter { $0.status == "pending" }
        } else {
            throw URLError(.badServerResponse)
        }
    } catch {
        print("Decoding Error:", error)
        throw error
    }
}

func getOutgoingFriendRequests() async throws -> [Friend] {
    let endpoint = "\(baseURL)/friends/requests/outgoing"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(FriendsResponse.self, from: data)
        
        if response.result == "success" {
            return response.data.filter { $0.status == "pending" }
        } else {
            throw URLError(.badServerResponse)
        }
    } catch {
        print("Decoding Error:", error)
        throw error
    }
}

func searchUsers(query: String) async throws -> [SearchedUser] {
    guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        throw URLError(.badURL)
    }
    
    let endpoint = "\(baseURL)/friends/search?username=\(encodedQuery)"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(SearchResponse.self, from: data)
        
        if response.result == "success" {
            return response.users
        } else {
            throw URLError(.badServerResponse)
        }
    } catch {
        print("Decoding Error:", error)
        throw error
    }
}

func sendFriendRequest(userID: Int) async throws {
    let endpoint = "\(baseURL)/friends/request/\(userID)"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}

func acceptFriendRequest(userID: Int) async throws {
    let endpoint = "\(baseURL)/friends/accept/\(userID)"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}

func rejectFriendRequest(userID: Int) async throws {
    let endpoint = "\(baseURL)/friends/reject/\(userID)"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}

func removeFriend(userID: Int) async throws {
    let endpoint = "\(baseURL)/friends/remove/\(userID)"
    guard let url = URL(string: endpoint) else {
        throw URLError(.badURL)
    }
    
    guard let accessToken = getAccessToken(account: "accessToken") else {
        throw URLError(.userAuthenticationRequired)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}
