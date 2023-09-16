//
//  APIManager.swift
//  RandomImage
//
//  Created by Aliia  on 11.09.2023.
//

import Foundation

// MARK: - API

struct APIManager {
    
    // MARK: - Private Properties
    
    private static let browseByCategory = "animals"
    private static let accessKey = "br6g-SRkWN7npMmaymet1qrxH-IcyMkEl4WoavSg-pM"
    
    // MARK: - Public methods
    
    static func getPhotoURLFromAPI() -> URL? {
        let urlString = "https://api.unsplash.com/photos/random?query=\(browseByCategory)&client_id=\(accessKey)"
        return URL(string: urlString)
    }
}
