//
//  ImageFullScreenView.swift
//  RandomImage
//
//  Created by Aliia  on 11.09.2023.
//

import SwiftUI

struct ImageFullScreenView: View {
    
    // MARK: - Public Properties
    
    let image: UIImage
    
    // MARK: - Private Properties

    @State private var isImageTapped = false
    // Для зумирования изображения
    @State private var currentScale: CGFloat = 0.0
    @State private var finalScale: CGFloat = 1.0
    
    
    // MARK: - Visual Components
    
    var body: some View {
        ZStack {
            if isImageTapped {
                Color.black.ignoresSafeArea(.all)
            } else {
                Color.white.ignoresSafeArea(.all)
            }
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea(.all)
                    .onTapGesture(){
                        isImageTapped.toggle()
                    }
                    .scaleEffect(finalScale + currentScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged({ newScale in
                                currentScale = newScale - 1
                            })
                            .onEnded({ _ in
                                finalScale += currentScale
                                currentScale = 0.0
                            })
                    )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        shareImage(image: image)
                    } label: {
                        Label("Share...", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    } label: {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                    }
                    Button {
                        UIPasteboard.general.image = image
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            label: {
                Label("More", systemImage: "ellipsis.circle")
            }
            }
        }
        .navigationBarHidden(isImageTapped)
        .statusBar(hidden: isImageTapped)
    }
    
}

// MARK: - Share Image

extension ImageFullScreenView {
    
    func shareImage(image: UIImage) {
        guard let data = image.pngData(), let shareImage = UIImage(data: data) else {
            return
        }
        let items = [shareImage]
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let mainWindow = windowScene.windows.first {
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            mainWindow.rootViewController?.present(activityController, animated: true, completion: nil)
        }
    }
    
}
