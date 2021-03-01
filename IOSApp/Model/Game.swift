//
//  Game.swift
//  IOSApp
//
//  Created by Dimitar on 17.2.21.
//

import Foundation

struct Game: Codable {
    enum GameState: String, Codable {
        case starting
        case inprogress
        case finished
    }
    enum Gameplay: String, Equatable, Codable {
        case rock
        case scissors
        case paper
        case random
    }
    var id: String
    var players: [User]
    var playerIds: [String]
    var winner: User?
    var createdAt: TimeInterval
    var state: GameState
    var gameplay: Gameplay?
    var gameplayOpinion: [String]?
    
    init(id: String, players: [User]) {
        self.id = id
        self.players = players
        playerIds = players.compactMap( { $0.id } )
        //Not in arguments because they have same values for every game witch is not yet started
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
