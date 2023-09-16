//
//  Photo.swift
//  RandomImage
//
//  Created by Aliia  on 15.09.2023.
//

import Foundation

// MARK: - JSON

struct Photo: Decodable {
    let urls: Urls
    
    struct Urls: Decodable {
        // regular - returns the photo in jpg format with a width of 1080 pixels.
        let regular: String
    }
}
