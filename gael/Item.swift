//
//  Item.swift
//  gael
//
//  Created by Benjamin Oertel on 10/16/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
