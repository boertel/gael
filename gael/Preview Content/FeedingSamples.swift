//
//  FeedingSamples.swift
//  gael
//
//  Created by Benjamin Oertel on 11/17/23.
//

import Foundation


extension Feeding {
  static var sampleFeedings: [Feeding] {
    [
      Feeding(side: .left, timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date.now)!),
      Feeding(side: .right, timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date.now)!),
      Feeding(side: .left, timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date.now)!),
      Feeding(side: .right, timestamp: Calendar.current.date(byAdding: .hour, value: -7, to: Date.now)!),
    ]
  }
}
