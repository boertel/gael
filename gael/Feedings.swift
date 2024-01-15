//
//  Feedings.swift
//  gael
//
//  Created by Benjamin Oertel on 11/9/23.
// xcrun simctl --set previews delete all

import SwiftUI


struct Feedings: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var vStackHeight: CGFloat = 0
  @State private var now = Date()
  //@State private var now = dateFromTime("15:00")
  
  let feedings: [Feeding]
  var end: Date {
    var timeInterval = gael.hours(4)
    let lastFeeding = feedings.last
    if let s = lastFeeding?.getStart() {
      if now > s {
        timeInterval = gael.hours(1)
      }
    }
    let tmp = Date(timeInterval: timeInterval, since: now)
    return Calendar.current.date(bySetting: .minute, value: 0, of: tmp)!
  }
  
  let timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()
  
  let INTERVAL: Int = 23
  
  private var _hours: [Date] {
    var tmp: [Date] = []
    for hour in 0...INTERVAL {
      var d = Date(timeInterval: TimeInterval(-hour * 3600), since: end)
      d = Calendar.current.date(bySetting: .minute, value: 0, of: d)!
      tmp.append(d)
    }
    return tmp
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(_hours, id: \.self) { hour in
          HStack {
            Line()
              .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
              .frame(height: 1)
            Text("\(formatTime(hour))").font(.system(.body, design: .monospaced))
          }
          .padding(.horizontal, 10)
          .frame(height: 60, alignment: .top)
          .opacity(0.2)
        }
      }.overlay(alignment: .topLeading) {
        ZStack {
          VStack {
            ZStack(alignment: .topLeading) {
              if !feedings.isEmpty {
                FutureFeedingRange(lastFeeding: feedings.last, now: now, getOffsetY: getOffsetY)
              }
              
              NowTick(date: now)
                .offset(y: getOffsetY(now))
                .onReceive(timer, perform: { _ in
                  now = Date()
                })
              
              ForEach(feedings, id: \.self) { feeding in
                Tick {
                  FeedingItem(feeding: feeding)
                    .padding(.trailing, 10)
                    .background(getBackground())
                  HLine()
                }
                .offset(y: getOffsetY(feeding.timestamp))
              }
            }
          }
        }.offset(y: 10)
      }
      .background(
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              vStackHeight = geometry.size.height
            }
        }
      )
    }
  }
  
  func getBackground() -> Color {
    return colorScheme == .dark ? .black : .white
  }
  
  func getOffsetY(_ start: Date) -> CGFloat {
    guard let diff = differenceInMinutes(start: start, end: end) else {
      return CGFloat(0)
    }
    let y = diff * Int(vStackHeight) / ((INTERVAL + 1) * 60)
    return CGFloat(y)
  }
}

struct Line: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    return path
  }
}

struct HLine: View {
  var body: some View {
    Line().stroke(style: StrokeStyle(lineWidth: 1)).frame(height: 1)
  }
}

struct Tick<Content: View>: View {
  @ViewBuilder let child: Content
  
  var body: some View {
    VStack {
      HStack(spacing: 0) {
        child
      }.padding(.horizontal, 10).offset(y: -10)
    }
  }
}


struct NowTick: View {
  @Environment(\.colorScheme) var colorScheme
  let date: Date
  
  var body: some View {
    Tick {
      HLine()
      Text(formatTime(date))
        .padding(.leading, 10)
        .font(.system(.body, design: .monospaced))
        // TODO have padding but right now it moves the content to the wrong place
        .background(getBackground())
    }.foregroundStyle(.red)
  }
  
  func getBackground() -> Color {
    return colorScheme == .dark ? .black : .white
  }
  
  
  func getPadding() -> CGFloat {
    let minutes = Calendar.current.component(.minute, from: date)
    if minutes < 15 {
      return 12
    } else if  minutes >= 55 {
      return 20
    } else {
      return 4
    }
  }
}

struct FutureFeedingRange: View {
  let lastFeeding: Feeding?
  let now: Date
  let getOffsetY: (Date) -> CGFloat
  
  var body: some View {
    if let l = lastFeeding {
      if let e = l.getEnd(), let s = l.getStart() {
        let color = l.getColor(now: now)
        HStack {
          VStack {
            HStack {
              Text(formatTime(e)).font(.system(.body, design: .monospaced))
              Spacer()
              FeedingLabel(start: s, isNow: FeedingTimeLabel(), isAfter: Text("next feeding between"))
                .font(.callout)
                .padding(.trailing, 55)
            }
            Spacer()
            HStack {
              Text(formatTime(s)).font(.system(.body, design: .monospaced))
              Spacer()
            }
          }
          .padding(.vertical, 6)
          .foregroundStyle(color)
          Spacer()
        }
        .padding(.horizontal, 10)
        .background(color.opacity(0.2))
        .cornerRadius(8)
        .frame(height: getOffsetY(s) - getOffsetY(e))
        .offset(y: getOffsetY(e))
      }
    }
  }
}


struct FeedingItem: View {
  let feeding: Feeding
  
  var body: some View {
    HStack {
      Text("\(dateToString(feeding.timestamp, format: getTimeFormat()))").font(.system(.body, design: .monospaced))
      BoobImage(side: Side.left, activeSide: feeding.side)
      BoobImage(side: Side.right, activeSide: feeding.side)
    }.accentColor(.white)
  }
}

func hours(_ hour: Int) -> TimeInterval {
  return TimeInterval(hour * 3600)
}

func dateFromTime(_ t: String) -> Date {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
  
  let date = dateFormatter.date(from: "2023-11-17 \(t)")
  return date!
}
  

#Preview {
  var feedings: [Feeding] {
    return [
      Feeding(side: Side.left, timestamp: dateFromTime("14:00")),
      /*
      Feeding(side: Side.left, timestamp: Date(timeInterval: hours(-1), since: since)),
      Feeding(side: Side.left, timestamp: Date(timeInterval: hours(-2), since: since)),
      Feeding(side: Side.left, timestamp: Date(timeInterval: gael.hours(-4), since: since)),
      Feeding(side: Side.left, timestamp: Date(timeInterval: gael.hours(-12), since: since)),
      */
    ].reversed()
  }
  return Feedings(feedings: feedings)
}
