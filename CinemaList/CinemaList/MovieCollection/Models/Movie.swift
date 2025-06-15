//
//  Movie.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 07.02.2025.
//

import Foundation

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let poster: String
    let backdropImage: String?
    let releaseDate: String
    let popularity: String
    let rating: String
    let ratingPeopleCount: Int
    //let genreIds: [Int]
    let runtime: Int?
    let actors: [Actor]?
    let studios: [Studio]?
    let team: [TeamMember]?
    let myStatus: String?
    let myRating: String?
    let timecode: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "tmdb_id"
        case title, overview, poster, backdropImage = "backdrop_image", releaseDate = "release_date", popularity, rating, ratingPeopleCount = "rating_people_count"
        //, genreIds = "genre_ids"
        case runtime, actors, studios, team
        case myStatus = "my_status", myRating = "my_rating", timecode = "my_timecodeComment"
    }
}

struct MovieResponse: Codable {
    let data: [Movie]
}

struct getMovieResponse: Codable {
    let data: Movie
    let result: String
}

struct Actor: Codable {
    let id: Int
    let name: String
    let popularity: String
    let photo: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "tmdb_id"
        case name, popularity, photo
    }
}

struct Studio: Codable {
    let id: Int
    let name: String
    let logo: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "tmdb_id"
        case name, logo
    }
}

struct TeamMember: Codable {
    let id: Int
    let name: String
    let job: String
    
    enum CodingKeys: String, CodingKey {
        case id = "tmdb_id"
        case name, job
    }
}
