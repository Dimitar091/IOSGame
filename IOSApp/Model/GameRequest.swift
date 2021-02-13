//
//  GameRequest.swift
//  IOSApp
//
//  Created by Dimitar on 3.2.21.
//

import Foundation
import UIKit

struct GameRequest: Codable {
    var id: String
    var from: String
    var to: String
    var createdAt: TimeInterval
    var fromUsername: String?
}
