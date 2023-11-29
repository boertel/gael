//
//  GaelWidget.swift
//  GaelWidget
//
//  Created by Benjamin Oertel on 10/25/23.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
  private let modelContext = ModelContext(Self.container)
  
  func placeholder(in context: Context) -> FeedingEntry {
   .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (FeedingEntry) -> ()) {
    completion(.placeholder)
  }

  @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let timeline = Timeline(entries: [FeedingEntry(date: .now, lastFeeding: getLastFeeding())], policy: .after(.now.advanced(by: 60 * 1)))
    /*
    let lastFeeding = getLastFeeding()
    var entries: [FeedingEntry] = []
    
    entries.append(FeedingEntry(date: .now, lastFeeding: lastFeeding))
    if let start = lastFeeding?.getStart() {
      entries.append(FeedingEntry(date: start, lastFeeding: lastFeeding))
    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    */
    completion(timeline)
  }
  
  @MainActor
  private func getLastFeeding() -> Feeding? {
    var descriptor = FetchDescriptor<Feeding>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
    descriptor.fetchLimit = 1
    let feedings = try? modelContext.fetch(descriptor)
    
    return feedings?.first
  }
  
  private static let container: ModelContainer = {
    do {
      return try ModelContainer(for: Feeding.self)
    } catch {
      fatalError("\(error)")
    }
  }()
}


struct FeedingEntry: TimelineEntry {
  let date: Date
  let lastFeeding: Feeding?
  
  static var placeholder: Self {
    .init(date: Date(), lastFeeding: Feeding.sampleFeedings[0])
  }
  
  static var feedingTime: Self {
    .init(date: Date(), lastFeeding: Feeding.sampleFeedings[1])
  }
}

struct GaelWidgetEntryView : View {
  var entry: Provider.Entry
  
  @Environment(\.widgetFamily) var family
  
  @ViewBuilder
  var body: some View {
    switch family {
    case .accessoryRectangular:
      RectangularWidgetView(entry: entry)
    default:
      HomeScreenWidgetView(entry: entry, family: family)
    }
  }
}

/*
func generateDatesEvery15Minutes(start: Date, end: Date) -> [Date] {
  var dates: [Date] = [start]
  var currentDate = start

  while currentDate <= end {
    dates.append(currentDate)
    guard let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) else { break }
    currentDate = nextDate
  }
  
  dates.append(end)
  return dates
}

let calendar = Calendar.current

let now = Date.now
let minutes = calendar.component(.minute, from: now)
var closestMinutes = 0
if minutes < 15 {
  closestMinutes = 15
} else if minutes < 30 {
  closestMinutes = 30
} else if minutes < 45 {
  closestMinutes = 45
} else if minutes < 60 {
  closestMinutes = 60
}

let value = closestMinutes - minutes
let nextDate = calendar.date(bySetting: .second, value: 0, of: calendar.date(byAdding: .minute, value: value - 1, to: now)!)!

var entries = generateDatesEvery15Minutes(start: nextDate, end: s)

print("entries", entries)
*/

struct RectangularWidgetView: View {
  let entry: FeedingEntry
  
  func getBackgroundColor(feeding: Feeding) -> Color {
    var background = Color.clear
    if let s = feeding.getStart() {
      if Date() > s {
        background = Color.gray.opacity(0.2)
      }
    }
    
    return background
  }

  var body: some View {
    if let feeding = entry.lastFeeding {
      
      VStack {
        FeedingLabel(start: feeding.getStart(), isNow: FeedingTimeLabel(), isAfter: Text("Next feeding")).font(.caption2)
        Spacer()
        FutureInterval(start: feeding.getStart(), end: feeding.getEnd(), now: Date())
          .font(.system(.body, design: .monospaced))
        Spacer()
        HStack {
          BoobImage(side: Side.left, activeSide: feeding.side, reverse: true)
          BoobImage(side: Side.right, activeSide: feeding.side, reverse: true)
        }
      }
      .padding(.vertical, 2)
      .containerBackground(for: .widget) {
        RoundedRectangle(cornerRadius: 8).fill(getBackgroundColor(feeding: feeding))
      }

    } else {
      Text("No feeding")
    }
  }
}

struct HomeScreenWidgetView: View {
  let entry: FeedingEntry
  let family: WidgetFamily
  
  var body: some View {
      VStack {
        if let feeding = entry.lastFeeding {
          let now = Date()
          let activeColor = feeding.getColor(now: now)
          
          VStack {
            FeedingLabel(
              start: feeding.getStart(),
              isNow: FeedingTimeLabel(),
              isAfter: Text(
                "Next feeding between"
              )
            ).font(
              .system(
                size: family == .systemSmall ? 12 : 16
              )
            )
            Spacer()
            FutureInterval(start: feeding.getStart(), end: feeding.getEnd(), now: Date())
              .font(.system(size: family == .systemSmall ? 15 : 16, design: .monospaced))
            Spacer()
            HStack {
              BoobIntentButton(side: Side.left, activeSide: feeding.side, reverse: true, intent: StartLeftFeeding())
              BoobIntentButton(side: Side.right, activeSide: feeding.side, reverse: true, intent: StartRightFeeding())
            }
            Spacer()
            //Text("\(minutesForHuman(diff)) ago").foregroundStyle(.gray).font(.caption)
            Text(feeding.timestamp, style: .relative)
              .multilineTextAlignment(.center)
              .foregroundStyle(.gray)
              .font(.caption)
          }.accentColor(activeColor).foregroundColor(.accentColor)
        } else {
          Text("No feeding yet")
        }
      }.padding(10)
      .containerBackground(.fill.tertiary, for: .widget)
  }
}

struct GaelWidget: Widget {
  let kind: String = "GaelWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      GaelWidgetEntryView(entry: entry)
    }
    .contentMarginsDisabled()
    .containerBackgroundRemovable(false)
    .configurationDisplayName("Gael")
    .description("Keep track of your feedings")
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .systemLarge,
      
      .accessoryRectangular,
    ])
  }
}

#Preview("small", as: .systemSmall) {
  return GaelWidget()
} timeline: {
  FeedingEntry.placeholder
  FeedingEntry.feedingTime
}

#Preview("medium", as: .systemMedium) {
  return GaelWidget()
} timeline: {
  FeedingEntry.placeholder
  FeedingEntry.feedingTime
}

#Preview("large", as: .systemLarge) {
  return GaelWidget()
} timeline: {
  FeedingEntry.placeholder
  FeedingEntry.feedingTime
}

#Preview("accessory rectangular", as: .accessoryRectangular) {
  return GaelWidget()
} timeline: {
  FeedingEntry.placeholder
  FeedingEntry.feedingTime
}
