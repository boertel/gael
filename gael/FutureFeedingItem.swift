//
//  FutureFeedingItem.swift
//  gael
//
//  Created by Benjamin Oertel on 10/26/23.
//

import SwiftUI

struct FutureFeedingItem: View {
  let item: Feeding
  
  @State var now = Date()
  let timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()
  
  var body: some View {
    let activeColor = item.getColor(now: now)
    Group {
      FeedingLabel(start: item.getStart(), isNow: FeedingTimeLabel().font(.caption), isAfter: Text("Next:"), now: now)
      Spacer()
      FutureInterval(start: item.getStart(), end: item.getEnd(), now: now).font(.system(.body, design: .monospaced))
      Spacer()
      HStack {
        BoobImage(side: Side.left, activeSide: item.side, reverse: true)
        BoobImage(side: Side.right, activeSide: item.side, reverse: true)
      }
    }.accentColor(activeColor).foregroundColor(.accentColor)
  }
}


struct FeedingLabel<IsNowContent: View, IsAfterContent: View>: View {
  let start: Date?
  @ViewBuilder let isNow: IsNowContent
  @ViewBuilder let isAfter: IsAfterContent
  let now: Date?
  
  init(start: Date?, isNow: IsNowContent, isAfter: IsAfterContent, now: Date? = nil) {
    self.start = start
    self.isNow = isNow
    self.isAfter = isAfter
    self.now = now ?? Date()
  }
  
  var body: some View {
    if let n = now {
      if let s = start {
        if s < n {
          isNow
        } else {
          isAfter
        }
      } else {
        Text("No feeding")
      }
    } else {
      Text("")
    }
  }
}

struct FeedingTimeLabel: View {
  var body: some View {
    HStack {
      Image(systemName: "fork.knife")
      Text("Feeding time")
    }
  }
}



struct FutureInterval: View {
  let start: Date?
  let end: Date?
  let now: Date?
  
  var body: some View {
    let format = getTimeFormat()
    HStack {
      if let s = start {
        Text("~\(dateToString(s, format: format))")
      }
      if let e = end {
        Text("– \(dateToString(e, format: format))")
      }
    }
  }
}

#Preview {
  FutureInterval(start: Date(timeInterval: -2 * 3600, since: Date()), end: Date(), now: Date())
}

#Preview {
  VStack {
    HStack {
      FutureFeedingItem(item: Feeding(side: Side.left))
    }
    HStack {
      FutureFeedingItem(item: Feeding(side: Side.right, timestamp: Date(timeInterval: -2 * 3600, since: Date()))) // fed 2 hours before now
    }
    HStack {
      FutureFeedingItem(item: Feeding(side: Side.left, timestamp: Date(timeInterval: -4 * 3600, since: Date())))   // fed 4 hours before now
    }
  }
}
