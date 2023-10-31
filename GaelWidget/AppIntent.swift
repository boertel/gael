//
//  AppIntent.swift
//  GaelWidget
//
//  Created by Benjamin Oertel on 10/20/23.
//

import WidgetKit
import AppIntents
import SwiftData

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Feeding"
    static var description = IntentDescription("Track a new feeding")
  

    // An example configurable parameter.
    @Parameter(title: "Feeding")
    var feeding: FeedingItemEntity?
}

struct FeedingItemEntity: AppEntity, Identifiable, Hashable {
  typealias DefaultQuery = <#type#>
  
  static func == (lhs: FeedingItemEntity, rhs: FeedingItemEntity) -> Bool {
    <#code#>
  }
  
  static var typeDisplayRepresentation: TypeDisplayRepresentation
  
  var displayRepresentation: DisplayRepresentation
  
  var id: Item.ID
  var timestamp: Date
  var side: Side
    
  init(timestamp: Date, side: Side) {
        self.timestamp = timestamp
        self.side = side
    }
    
    init(from item: Item) {
      self.timestamp = item.timestamp
      self.side = item.side
    }
}
