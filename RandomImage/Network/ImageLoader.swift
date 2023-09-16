//
//  ImageLoader.swift
//  RandomImage
//
//  Created by Aliia  on 11.09.2023.
//

import Foundation
import SwiftUI
//import Combine

final class ImageLoader: ObservableObject {

    // MARK: - Public Properties

    @Published var image: UIImage?

    // MARK: - Private Properties

    private let session = URLSession.shared
    private static let сache = NSCache<NSURL, UIImage>()

    // MARK: - Public methods

    func loadImageFromURL() {
        guard let url = APIManager.getPhotoURLFromAPI() else { return }
        session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            if !(200..<300).contains(httpResponse.statusCode) {
                print("Unexpected status code: \(httpResponse.statusCode)")
                return
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            // Парсим JSON response
            do {
                let photo = try JSONDecoder().decode(Photo.self, from: data)
                self.fetchImageFromJSON(from: photo.urls.regular)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    // MARK: - Private Methods

    private func fetchImageFromJSON(from urlJSON: String) {
        guard let url = URL(string: urlJSON) else { return }
        // Сначала проверяем наличие закэшированного изображения в NSCache
        if let cachedImage = ImageLoader.сache.object(forKey: url as NSURL) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
        } else {
            // И только потом отправляем запрос на загрузку изображения в случае отсутствия кэша
            session.dataTask(with: url) { data, response, error in
                // Проверяем, что можем создать UIImage из полученных данных
                guard let data = data, let loadedImage = UIImage(data: data) else {
                    print("Error fetching image data")
                    return
                }
                // Сохраняем загруженное изображение в NSCache
                ImageLoader.сache.setObject(loadedImage, forKey: url as NSURL)
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }.resume()
        }
    }

}


/*

// Or with Combine
 
// MARK: - NetworkError
 
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case unexpectedStatus(reason: String)
    case errorFetching
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response"
        case .unexpectedStatus:
            return "Unexpected status code"
        case .errorFetching:
            return "Error fetching image data"
        }
    }
}

// MARK: - ImageLoader
 
final class ImageLoader: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published var image: UIImage?
    
    // MARK: - Private Properties
    
    private static let cache = NSCache<NSURL, UIImage>()
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public methods
    
    func loadImageFromURL() {
        guard let url = APIManager.getPhotoURLFromAPI() else { return }
        
        session.dataTaskPublisher(for: url)
        // Преобразовываем каждый элемент издателя (ответ сервера и данные)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkError.unexpectedStatus(reason: String(httpResponse.statusCode))
                }
                return data
            }
        // Чтобы переключиться на главную очередь перед обработкой данных и обновлением состояния
            .receive(on: DispatchQueue.main)
        // Чтобы определить, что делать при получении значения или завершении издателя
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] data in
                do {
                    let photo = try JSONDecoder().decode(Photo.self, from: data)
                    self?.fetchImageFromJSON(from: photo.urls.regular)
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            })
        // Сохраняем подписку (cancellable) в cancellables, чтобы в дальнейшем отменить подписку, когда это необходимо
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func fetchImageFromJSON(from urlJSON: String) {
        guard let url = URL(string: urlJSON) else { return }
        
        if let cachedImage = ImageLoader.cache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        session.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage in
                guard let loadedImage = UIImage(data: data) else {
                    throw NetworkError.errorFetching
                }
                ImageLoader.cache.setObject(loadedImage, forKey: url as NSURL)
                return loadedImage
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] loadedImage in
                self?.image = loadedImage
            })
            .store(in: &cancellables)
    }
    
}

*/
