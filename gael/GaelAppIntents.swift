//
//  GaelAppIntents.swift
//  gael
//
//  Created by Benjamin Oertel on 10/27/23.
//

import Foundation
import AppIntents
import WidgetKit
import SwiftData

struct GaelShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: StartFeedingIntent(),
      phrases: ["Tell \(.applicationName) to start the feeding"],
      shortTitle: "Start Feeding (shortcut)",
      systemImageName: "play.circle.fill"
    )
  }
}

@MainActor
func getLastFeeding(_ modelContainer: ModelContainer) -> Feeding? {
  var descriptor = FetchDescriptor<Feeding>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
  descriptor.fetchLimit = 1
  let feedings = try? modelContainer.mainContext.fetch(descriptor)
  let lastFeeding = feedings?.first
  return lastFeeding
}

@MainActor
func insertFeeding(modelContainer: ModelContainer, side: Side) {
  let previous = getLastFeeding(modelContainer)
  let feeding = Feeding(side: side, previous: previous)
  modelContainer.mainContext.insert(feeding)
  WidgetCenter.shared.reloadAllTimelines()
}

struct StartFeedingIntent: AppIntent {
  static var title: LocalizedStringResource = "Start feeding (intent)"
  
  @MainActor
  func perform() async throws -> some IntentResult {
    guard let modelContainer = try? ModelContainer(for: Feeding.self) else {
      return .result()
    }
    
    let lastFeeding = getLastFeeding(modelContainer)
    
    if let f = lastFeeding {
      let nextSide = f.side == Side.left ? Side.right : Side.left
      let feeding = Feeding(side: nextSide)
      modelContainer.mainContext.insert(feeding)
      WidgetCenter.shared.reloadAllTimelines()
    }
    
    return .result()
  }
}

struct StartRightFeeding: AppIntent {
  static var title: LocalizedStringResource = "Start right feeding"
  
  @MainActor
  func perform() async throws -> some IntentResult {
    guard let modelContainer = try? ModelContainer(for: Feeding.self) else {
      return .result()
    }
    
    insertFeeding(modelContainer: modelContainer, side: Side.right)
    
    return .result()
  }
}

struct StartLeftFeeding: AppIntent {
  static var title: LocalizedStringResource = "Start left feeding"
  
  @MainActor
  func perform() async throws -> some IntentResult {
    guard let modelContainer = try? ModelContainer(for: Feeding.self) else {
      return .result()
    }
    
    insertFeeding(modelContainer: modelContainer, side: Side.left)
    
    return .result()
  }
}
