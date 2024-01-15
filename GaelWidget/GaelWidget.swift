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
  @MainActor func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), lastFeeding: getLastFeeding())
  }

  @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), lastFeeding: getLastFeeding())
    completion(entry)
  }

  @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let timeline = Timeline(entries: [SimpleEntry(date: .now, lastFeeding: getLastFeeding())], policy: .after(.now.advanced(by: 60 * 1)))
    completion(timeline)
  }
  
  
  @MainActor
  private func getLastFeeding() -> Feeding? {
    guard let modelContainer = try? ModelContainer(for: Feeding.self) else {
      return nil
    }
    var descriptor = FetchDescriptor<Feeding>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
    descriptor.fetchLimit = 1
    let feedings = try? modelContainer.mainContext.fetch(descriptor)
    
    return feedings?.first
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let lastFeeding: Feeding?
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

struct RectangularWidgetView: View {
  let entry: SimpleEntry

  var body: some View {
    if let feeding = entry.lastFeeding {
      VStack {
        Text("Next feeding").font(.caption2)
        Spacer()
        FutureInterval(start: feeding.getStart(), end: feeding.getEnd(), now: Date())
          .font(.system(.body, design: .monospaced))
        Spacer()
        HStack {
          BoobImage(side: Side.left, activeSide: feeding.side, reverse: true)
          BoobImage(side: Side.right, activeSide: feeding.side, reverse: true)
        }
      }
    } else {
      Text("No feeding")
    }
  }
}

struct HomeScreenWidgetView: View {
  let entry: SimpleEntry
  let family: WidgetFamily
  
  var body: some View {
      VStack {
        if let feeding = entry.lastFeeding {
          let now = Date()
          let activeColor = feeding.getColor(now: now)
          
          VStack {
            Text("Next feeding between").font(.system(size: family == .systemSmall ? 12 : 16))
            Spacer()
            FutureInterval(start: feeding.getStart(), end: feeding.getEnd(), now: Date())
              .font(.system(size: family == .systemSmall ? 15 : 16, design: .monospaced))
            Spacer()
            HStack {
              BoobIntentButton(side: Side.left, activeSide: feeding.side, reverse: true, intent: StartLeftFeeding())
              BoobIntentButton(side: Side.right, activeSide: feeding.side, reverse: true, intent: StartRightFeeding())
            }
            if let diff = differenceInMinutes(start: feeding.timestamp, end: now) {
              Spacer()
              Text("\(minutesForHuman(diff)) ago").foregroundStyle(.gray).font(.caption)
            }
          }.accentColor(activeColor).foregroundColor(.accentColor)
        } else {
          Text("No feeding yet")
        }
      }.padding(10)
  }
}

struct GaelWidget: Widget {
  let kind: String = "GaelWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      GaelWidgetEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .contentMarginsDisabled()
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

#Preview(as: .systemSmall) {
  GaelWidget()
} timeline: {
  SimpleEntry(date: .now, lastFeeding: Feeding(side: Side.left))
}
