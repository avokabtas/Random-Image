//
//  ContentView.swift
//  RandomImage
//
//  Created by Aliia  on 11.09.2023.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Private Properties
    
    private let navBarAppearence = UINavigationBarAppearance()
    @StateObject private var imageLoader = ImageLoader()
    @State private var isButtonPressed = false
    
    // MARK: - UINavigationBar
    
    init() {
        UINavigationBar.appearance().standardAppearance = navBarAppearence
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearence
    }
    
    // MARK: - Visual Components
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Random Image")
                    .fontWeight(.bold)
                    .font(.system(.title, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                if let image = imageLoader.image {
                    NavigationLink(
                        destination: ImageFullScreenView(image: image),
                        label: {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 350, height: 400)
                                .cornerRadius(10)
                                .padding()
                        }
                    )
                } else {
                    if isButtonPressed {
                        ProgressView("Loading...")
                    } else {
                        Text("There is no loaded image\n😔")
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    isButtonPressed.toggle()
                    imageLoader.loadImageFromURL()
                }) {
                    Text("Get image 🎉")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .background(.black)
                        .cornerRadius(10)
                }
                .onAppear()
            }
        }
    }
    
}

// MARK: - Preview Canvas

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
