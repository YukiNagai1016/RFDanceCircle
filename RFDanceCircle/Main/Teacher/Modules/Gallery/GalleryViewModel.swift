//
//  GalleryViewModel.swift
//  R&FDanceCircleApp
//
//  Created by YukiNagai on 2020/01/30.
//  Copyright © 2020 YukiNagai. All rights reserved.
//

import Foundation

class GalleryViewModel {
    
    // MARK: Properties
    
    var itemViewModels: [PhotoCellViewModel] = []
    
    private let photos: [Photo] = [
        Photo(imageName: "mitsu", title: "Mitsu", about: "HIPHOP"),
        Photo(imageName: "masshimo", title: "Masshimo", about: "HIPHOP"),
        Photo(imageName: "motomi", title: "Motomi", about: "JAZZFUNK"),
        Photo(imageName: "sumire", title: "Sumire", about: "JAZZ"),
        Photo(imageName: "an", title: "Ayano", about: "HIPHOP"),
        Photo(imageName: "en", title: "En", about: "Waack, JAZZ"),
        Photo(imageName: "yuka", title: "Yuka", about: "JAZZ"),
        Photo(imageName: "hayato", title: "daishiro", about: "LOCK"),
        Photo(imageName: "arisa", title: "Alisa", about: "LOCK"),
        Photo(imageName: "haba", title: "Haba", about: "LOCK"),
        Photo(imageName: "kubo", title: "Kubosho", about: "HIPHOP"),
        Photo(imageName: "yutty", title: "Yutty", about: "LOCK"),
        Photo(imageName: "mai", title: "Mai", about: "HIPHOP"),
        Photo(imageName: "cheru", title: "Ryusei", about: "POP"),
        Photo(imageName: "konomi", title: "Konomi", about: "HIPHOP"),
        Photo(imageName: "nasunasu", title: "Nasunasu", about: "POP"),
        Photo(imageName: "morishi", title: "Morisy", about: "POP"),
        Photo(imageName: "satoshi", title: "Satoshi", about: "POP"),
        Photo(imageName: "mari", title: "Mari", about: "JAZZ"),
        Photo(imageName: "haruka", title: "Haruka", about: "VOGUE"),
        Photo(imageName: "kiyomi", title: "Kiyomi", about: "JAZZ")
    ]
    
    // MARK: Lifecycle
    
    init() {
        itemViewModels = photos.map {
            PhotoCellViewModel(imageName: $0.imageName, title: $0.title, subtitle: "by " + $0.about)
        }
    }
}

