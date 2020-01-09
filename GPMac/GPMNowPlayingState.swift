//
//  GPMNowPlayingState.swift
//  GPMac
//
//  Created by user on 2019/12/07.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation

struct GPMArtist: Codable {
    var id: String
    var text: String
}

struct GPMAlbum: Codable {
    var id: String
    var text: String
}

struct GPMSeek: Codable {
    var current: Int
    var length: Int
}

struct GPMCanSkip: Codable {
    var previous: Bool
    var next: Bool
}

struct GPMNowPlayingState: Codable {
    var title: String
    var artist: GPMArtist?
    var album: GPMAlbum?
    var albumArt: URL?
    var seek: GPMSeek?
    var canSkip: GPMCanSkip
}
