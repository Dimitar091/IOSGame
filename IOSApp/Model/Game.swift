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
    var id: String
    var players: [User]
    var playersIds: [String]
    var winner: User?
    var createdAt: TimeInterval
    var state: GameState
    
    init(id: String, players: [User]) {
        self.id = id
        self.players = players
        playersIds = players.compactMap( { $0.id } )
        //Not in arguments because they have same values for every game witch is not yet started
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
