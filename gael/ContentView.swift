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
  static var since: Date {
    let since = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    return since
  }
  @Query(filter: #Predicate<Feeding> { feeding in
    return feeding.timestamp >= since
  }, sort: \Feeding.timestamp) private var feedings: [Feeding]
  
  var body: some View {
    return NavigationView {
      ZStack(alignment: .bottom) {
        if feedings.isEmpty {
          ContentUnavailableView("Start your first feeding", systemImage: "fork.knife.circle.fill").offset(y: -20)
        } else {
          VStack {
            Feedings(feedings: feedings)
          }
        }
        ActionsBar(side: feedings.last?.side)
      }
      /*
      .navigationBarTitle("", displayMode: .inline).toolbar {
        ToolbarItem(placement: .principal) {
          HStack {
            Text("gael").foregroundStyle(.gray)
          }
        }
      }
      */
    }
    
  }
}


struct ActionsBar: View {
  @Environment(\.colorScheme) var colorScheme
  let side: Side?
  
  private func getBackgroundColor() -> Color {
    colorScheme == .dark ? .black : .white
  }
  
  var body: some View {
    ZStack {
      // Background with blur effect
      getBackgroundColor()
        .opacity(0.8)
        .blur(radius: 10)
      VStack {
        Spacer()
        HStack {
          BoobButton(
            side: Side.left,
            activeSide: side,
            reverse: true,
            size: 40,
            intent: StartLeftFeeding()
          )
          Spacer()
          BoobButton(
            side: Side.right,
            activeSide: side,
            reverse: true,
            size: 40,
            intent: StartRightFeeding()
          )
        }
        Spacer()
      }.accentColor(.white)
       .padding(.horizontal, 20)
       .background(.thinMaterial)
       .cornerRadius(10)
    }.frame(height: 80)
      .padding(.vertical, 16)
      .padding(.horizontal, 6)
  }
}


#Preview {
  let preview = Preview(Feeding.self)
  preview.addExamples(Feeding.sampleFeedings)
  return ContentView()
    .modelContainer(preview.container)
}
