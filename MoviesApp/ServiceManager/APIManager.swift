//
//  APIManager.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import Foundation
import SwiftUI

enum APIError: Error {
    case failedTogetData
}

class APIManager {
    
    static let shared = APIManager()
    
    func getTrendingMovies(completion: @escaping (Result<[Title], Error>) -> ()) {
        
        guard
            let url = URL(string: "\(Constants.baseUrl)/3/trending/movie/day?api_key=\(Constants.API_KEY)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func getTrendingTv(completion: @escaping (Result<[Title], Error>) -> ()) {
        
        guard
            let urlString = URL(string: "\(Constants.baseUrl)/3/trending/tv/day?api_key=\(Constants.API_KEY)") else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func upcomingMovies(completion: @escaping (Result<[Title], Error>) -> ()) {
        
        guard
            let urlString = URL(string: "\(Constants.baseUrl)/3/movie/upcoming?api_key=\(Constants.API_KEY)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
    }
    
    func getPopular(completion: @escaping (Result<[Title], Error>) -> ()) {
        
        guard
            let urlString = URL(string: "\(Constants.baseUrl)/3/movie/popular?api_key=\(Constants.API_KEY)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }

        }
        task.resume()
    }
    
    func getTopRated(completion: @escaping (Result<[Title], Error>) -> ()) {
        
        guard
            let urlString = URL(string: "\(Constants.baseUrl)/3/movie/top_rated?api_key=\(Constants.API_KEY)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }

        }
        task.resume()
    }
    
    func getDiscoverMovies(completion: @escaping (Result<[Title], Error>) -> ()) {
        
        guard let urlString = URL(string: "\(Constants.baseUrl)/3/discover/movie?api_key=\(Constants.API_KEY)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }

        }
        task.resume()
    }
    
    func search(with query: String, completion: @escaping (Result<[Title], Error>) -> ()) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard
            let url = URL(string: "\(Constants.baseUrl)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)") else { return }
        
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(resultsData.results))
            } catch {
                completion(.failure(APIError.failedTogetData))
            }

        }
        task.resume()
    }
    
    func getMovie(with query: String, completion: @escaping (Result<VideoElement, Error>) -> ()) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard
            let url = URL(string: "\(Constants.youTubeBaseUrl)q=\(query)&key=\(Constants.YOU_TUBE_API_KEY)") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let resultsData = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                completion(.success(resultsData.items[0]))
                
            } catch {
                completion(.failure(APIError.failedTogetData))
            }

        }
        task.resume()
    }
}
