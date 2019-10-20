//
//  ClientAPI.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation
import Alamofire

class ClientAPI {
    private static var apiKey = "fd2b04342048fa2d5f728561866ad52a"
    private static let baseURLString = "https://api.themoviedb.org/3/movie"
    private static let baseImageURLString = "https://image.tmdb.org/t/p/"
    
    private static func makeRequest<Type>(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        type: Type.Type,
        onResponse: @escaping (Type?, HTTPURLResponse?) -> Void) where Type: Decodable
    {
        let request = AF.request(url,
                                 method: method,
                                 parameters: parameters,
                                 headers: headers)
        
        request.response { (response) in
            if let data = response.data {
                let decoder = JSONDecoder()
                DispatchQueue.global(qos: .background).async {
                    var object: Type? = nil
                    
                    if let responseObject = try? decoder.decode(type, from: data) {
                        object = responseObject
                    }
                    
                    DispatchQueue.main.async {
                        onResponse(object, response.response)
                    }
                }
            }
        }
    }
    
    private static func makeRequest(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        onResponse: @escaping (AFDataResponse<Any>) -> Void)
    {
        let request = AF.request(url,
                                 method: method,
                                 parameters: parameters,
                                 headers: headers)
        
        request.responseJSON { (response) in
            onResponse(response)
        }
    }
    
    private static func endPoint(_ path: String) -> String {
        return baseURLString + path
    }
    
    private static func defaultParams() -> [String: Any] {
        return [
            "language": "en-US",
            "api_key": apiKey
        ]
    }
}


// MARK: - Movie

extension ClientAPI {
    public static func getPopularMovies(_ page: Int, onResponse: @escaping (MovieListResponse?, HTTPURLResponse?)-> Void) {
        let endPoint = self.endPoint("/popular")
        var params = defaultParams()
        params["page"] = page
        
        makeRequest(endPoint,
                    parameters: params,
                    type: MovieListResponse.self) { (response, httpResponse) in
                        onResponse(response, httpResponse)
        }
    }
    
    public static func getMovieDetail(_ movieId: Int, onResponse: @escaping (Movie?, HTTPURLResponse?)-> Void) {
        let endPoint = self.endPoint("/\(movieId)")
        
        makeRequest(endPoint,
                    parameters: defaultParams(),
                    type: Movie.self) { (response, httpResponse) in
                        onResponse(response, httpResponse)
        }
    }
}


// MARK: - Image URL

enum ImageWidthType: String {
    case original = "original"
    case w200 = "w200"
    case w300 = "w300"
    case w400 = "w400"
    case w500 = "w500"
}

extension ClientAPI {
    public static func imageURL(_ type: ImageWidthType = .w200, path: String?) -> URL? {
        guard let p = path else { return nil }
        return URL(string: baseImageURLString + type.rawValue + p)
    }
}
