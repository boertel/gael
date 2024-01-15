//
//  Item.swift
//  gael
//
//  Created by Benjamin Oertel on 10/16/23.
//

import Foundation
import SwiftData
import SwiftUI

enum Side: String, Codable {
  case right = "right"
  case left =  "left"
  
  var id: Self {
    return self
  }
  
  var descr: String {
    switch self {
    case .right:
      "right"
    case .left:
      "left"
    }
  }
}

@Model
final class Feeding {
  @Attribute(.unique) public var id: String
  var timestamp: Date
  var side: Side
  var previous: Feeding?
  var next: Feeding?
    
  init(side: Side, previous: Feeding?, timestamp: Date = .now) {
    self.id = UUID().uuidString
    self.timestamp = timestamp
    self.side = side
    self.previous = previous
    if let p = previous {
      p.next = self
    }
  }
  
  init(side: Side, timestamp: Date = .now) {
    self.id = UUID().uuidString
    self.timestamp = timestamp
    self.side = side
  }
  
  var diff: Int? {
    get {
      if let p = previous {
        return differenceInMinutes(start: p.timestamp, end: timestamp)
      }
      return nil // Default value in case of an error
    }
  }

  func getColor(now: Date) -> Color {
    if isBefore(now) {
      return Color.blue
    }
    if isBetween(now) {
      return Color.green
    }
    if isAfter(now) {
      return Color.orange
    }
    return Color.white
  }
  
  func getStart() -> Date? {
    guard let date = addHoursToDate(timestamp, hours: 2) else {
      return nil
    }
    return date
  }
  
  func getEnd() -> Date? {
    guard let date = addHoursToDate(timestamp, hours: 4) else {
      return nil
    }
    return date
  }
  
  func isBefore(_ now: Date) -> Bool {
    guard let start = getStart() else {
      return false
    }
    return now < start
  }

  func isBetween(_ now: Date) -> Bool {
    guard let start = getStart(), let end = getEnd() else {
      return false
    }
    return start < now && now < end
  }

  func isAfter(_ now: Date) -> Bool {
    guard let end = getEnd() else {
      return false
    }
    return now > end
  }
  
  func addHoursToDate(_ date: Date, hours: Int) -> Date? {
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.hour = hours

    let date = calendar.date(byAdding: dateComponents, to: date)
    return date
  }
}
