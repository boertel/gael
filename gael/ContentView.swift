//
//  ContentView.swift
//  gael
//
//  Created by Benjamin Oertel on 10/16/23.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.colorScheme) var colorScheme
  @Query(sort: \Feeding.timestamp, order: .reverse) private var items: [Feeding]
  
  @State var editingItem: Feeding?
  
  var groupedItems: [(key: String, value: [Feeding])] {
    return Dictionary(grouping: items) { item in
      dateToString(item.timestamp)
    }
    .sorted { $0.0 > $1.0 }
  }
     
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        ScrollViewReader { scrollView in
          NavigationView {
            List {
              ForEach(groupedItems.indices, id: \.self) { groupIndex in
                let key = groupedItems[groupIndex].key
                let group = groupedItems[groupIndex].value
                Section(header: DateDisplayView(dateString: key, count: group.count)) {
                  ForEach(Array(group.enumerated()), id: \.element) { index, item in
                    FeedingItem(item: item).swipeActions(edge: .trailing) {
                      Button(role: .destructive) {
                        deleteItem(item: item)
                      } label: {
                        Label("Delete", systemImage: "trash").symbolVariant(.fill)
                      }
                    }.swipeActions(edge: .leading) {
                      Button {
                        editItem(item: item)
                      } label: {
                        Label("Edit", systemImage: "pencil").symbolVariant(.fill)
                      }.tint(.blue)
                    }.listRowInsets(EdgeInsets(top: index == 0 ? 10 : 0, leading: 22, bottom: index == group.count - 1 ? -14 : 14, trailing: 22)).listRowSeparator(.hidden)
                  }
                }
              }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.plain)
            .navigationBarTitle("", displayMode: .inline).toolbar {
              ToolbarItem(placement: .principal) {
                if let last = items.first {
                  HStack {
                    FutureFeedingItem(item: last)
                  }
                }
              }
            }
          }
        }
      }
      ActionsBar(side: items.first?.side, editingItem: $editingItem)
    }
  }
  
  private func editItem(item: Feeding) {
    editingItem = item
  }
  
  private func deleteItem(item: Feeding) {
    withAnimation {
      let previous = item.previous
      let next = item.next
      
      if let n = item.next {
        n.previous = previous
      }
      if let p = item.previous {
        p.next = next
      }
      modelContext.delete(item)
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}


struct ActionsBar: View {
  let side: Side?
  @Binding var editingItem: Feeding?
  @State private var timestamp: Date = Date()
  
  var body: some View {
    ZStack {
      // Background with blur effect
      Color.black
        .opacity(0.8)
        .blur(radius: 10)
      VStack {
        VStack {
          if let item = editingItem {
            HStack {
              DatePicker("", selection: $timestamp, displayedComponents: .hourAndMinute).labelsHidden()
              Button("Save") {
                item.timestamp = timestamp
                editingItem = nil
              }
            }.onAppear {
              timestamp = item.timestamp
            }
          }
          HStack {
            BoobButton(side: Side.left, activeSide: side, reverse: true, intent: StartLeftFeeding())
            Spacer()
            BoobButton(side: Side.right, activeSide: side, reverse: true, intent: StartRightFeeding())
          }
        }.accentColor(.white)
          .padding(.horizontal, 20)
          .padding(.vertical, 16)
          .background(.thinMaterial)
          .cornerRadius(10)
      }
    }.frame(height: 80).padding()
  }
}




struct DateDisplayView: View {
  let dateString: String
  let count: Int
  
  var body: some View {
    HStack {
      if let formattedDate = stringToDate(dateString) {
        Text(formatRelativeDate(formattedDate)).foregroundStyle(.white)
      } else {
        Text("–")
          .foregroundStyle(.red)
      }
      Spacer()
      Text("\(count)")
    }
  }
  
  func formatRelativeDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()

    if calendar.isDateInToday(date) {
        return "Today"
    } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
    } else if calendar.isDateInTomorrow(date) {
        return "Tomorrow"
    } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Display day of the week
        return dateFormatter.string(from: date)
    } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d" // Display day of the week and month/day
        return dateFormatter.string(from: date)
    } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy" // Display day of the week, month/day, and year
        return dateFormatter.string(from: date)
    }
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

struct Difference: View {
  let difference: Int
  let hasNext: Bool
  
  var body: some View {
    ZStack(alignment: .leading) {
      VStack {
        GeometryReader { geometry in
          Line()
            .stroke(style: hasNext ? StrokeStyle(lineWidth: 1) : StrokeStyle(lineWidth: 1, dash: [2]))
            .frame(width: 1 / UIScreen.main.scale, height: geometry.size.height / 2)
            .foregroundColor(.gray)
          Line()
            .offset(y: geometry.size.height / 2)
            .stroke(style: StrokeStyle(lineWidth: 1))
            .frame(width: 1 / UIScreen.main.scale, height: geometry.size.height / 2)
            .foregroundColor(.gray)
        }
      }.padding(.horizontal, 35)
      
      VStack {
        Text(minutesForHuman(difference))
          .frame(width: 70)
      }.padding(.vertical, 5)
       .background(.black)
       .foregroundColor(.accentColor)
    }
     .accentColor(.gray)
  }

}

struct TimeAgo: View {
  @State var now = Date()
  
  let timestamp: Date
  let timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()
  
  var body: some View {
    if let diff = differenceInMinutes(start: timestamp, end: now) {
      Difference(difference: diff, hasNext: false)
        .onReceive(timer, perform: { _ in
          self.now = Date()
        })
    }
  }
}

struct FeedingItem: View {
  let item: Feeding
  
  var body: some View {
    VStack(alignment: .leading) {
      if item.next == nil {
        TimeAgo(timestamp: item.timestamp).frame(height: height())
      }
      HStack {
        Text("\(dateToString(item.timestamp, format: getTimeFormat()))").font(.system(.body, design: .monospaced))
        BoobImage(side: Side.left, activeSide: item.side)
        BoobImage(side: Side.right, activeSide: item.side)
      }.accentColor(.white)
      if let diff = item.diff {
        Difference(difference: diff, hasNext: true).frame(height: height())
      }
    }
  }
  
  func height() -> CGFloat {
    let diff = item.diff ?? 0
    if diff <= 60 { // 1 hour
      return 40
    }
    if diff <= 120 { // 2 hours
      return 60
    }
    if diff <= 180 { // 3 hours
      return 80
    }
    if diff <= 240 { // 4 hours
      return 100
    }
    return 120
  }
}


#Preview {
  ContentView().modelContainer(for: Feeding.self, inMemory: true).environment(\.colorScheme, .dark)
}
