//
//  FeedingItem.swift
//  gael
//
//  Created by Benjamin Oertel on 10/19/23.
//

import SwiftUI



#Preview {
  let first = Feeding(side: Side.left)
  return VStack {
    FeedingItem(item: first)
    FutureFeedingItem(item: Feeding(side: Side.left, previous: nil, timestamp: Date()))
  }
}
