//
//  StorageManager.swift
//  CDMovie
//
//  Created by Cagatay on 20.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation

class StorageManager {
    
    private let fileName = "saved_movies.json"
    
    public private(set) var savedMovies: [Movie]
    
    public static let shared = StorageManager()
    
    private init() {
        if Storage.fileExists(fileName, in: .caches) {
            savedMovies = Storage.retrieve(fileName, from: .caches, as: [Movie].self)
            
        } else {
            savedMovies = []
        }
    }
    
    private func indexOfMovie(_ id: Int) -> Int? {
        return savedMovies.firstIndex(where: {$0.id == id})
    }
    
    private func saveMovieList() {
        Storage.store(savedMovies, to: .caches, as: fileName)
    }
    
    public func addMovieToSavedList(_ movie: Movie) {
        if let index = indexOfMovie(movie.id) {
            // update existData
            savedMovies.remove(at: index)
            savedMovies.insert(movie, at: index)
            
            saveMovieList()
            // not need for notification
            return
        }
        
        savedMovies.append(movie)
        saveMovieList()
        
        notifyChanges(movie.id)
    }
    
    public func removeMovieFromSavedList(_ id: Int) {
        guard let index = indexOfMovie(id) else {
           return
        }
        
        savedMovies.remove(at: index)
        saveMovieList()
        
        notifyChanges(id)
    }
    
    public func isMovieSaved(_ id: Int) -> Bool {
        return indexOfMovie(id) != nil
    }
    
    private func notifyChanges(_ id: Int) {
        NotificationCenter.default.post(name: .MovieSavedStatusDidChange, object: id)
    }
}

extension Movie {
    var isSaved: Bool {
        return StorageManager.shared.isMovieSaved(id)
    }
}
