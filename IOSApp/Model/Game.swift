//
//  Game.swift
//  IOSApp
//
//  Created by Dimitar on 17.2.21.
//

import Foundation


enum Moves: String, Comparable, Codable, CaseIterable {
    case idle
    case rock
    case scissors
    case paper
    
    static func < (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .paper):
            return true
        case (.paper, .scissors):
            return true
        case (.scissors, .rock):
            return true
        case (.idle, .paper):
            return true
        case (.idle, .rock):
            return true
        case (.idle, .scissors):
            return true
        default:
            return false
        }
    }
    static func == (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .rock):
            return true
        case (.scissors, .scissors):
            return true
        case (.paper, .paper):
            return true
        case (.idle, .idle):
            return true
        default:
            return false
        }
     }
}

struct Game: Codable {
    enum GameState: String, Codable {
        case starting
        case inprogress
        case finished
    }
    
    var id: String
    var players: [User]
    var moves = [String:Moves]()
    var playerIds: [String]
    var winner: User?
    var createdAt: TimeInterval
    var state: GameState
    
    init(id: String, players: [User], moves: [String:Moves]) {
        self.id = id
        self.players = players
        self.moves = moves
        playerIds = players.compactMap( { $0.id } )
        //Not in arguments because they have same values for every game witch is not yet started
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
