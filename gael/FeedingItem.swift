//
//  FeedingItem.swift
//  gael
//
//  Created by Benjamin Oertel on 10/19/23.
//

import SwiftUI

struct Example: View {
  @State private var height: CGFloat = 0
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(0...10, id: \.self) { hour in
          HStack {
            Spacer()
            Text("\(hour)")
          }.frame(height: 100)
        }
      }.overlay(alignment: .topLeading) {
        ZStack {
          VStack {
            ZStack(alignment: .topLeading) {
              Rectangle().fill(.red.opacity(0.3)).frame(width: 100, height: 100).offset(y: 0)
              Rectangle().fill(.yellow.opacity(0.3)).frame(width: 100, height: 200).offset(y: 200)
            }
          }
        }
      }
      .border(.green)
      .background {
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              height = geometry.size.height
              print(height)
            }
        }
      }
    }
  }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Example()
    }
}

/*
#Preview {
  let first = Feeding(side: Side.left)
  return VStack {
    FeedingItem(feeding: first)
    FutureFeedingItem(item: Feeding(side: Side.left, previous: nil, timestamp: Date()))
  }
}

*/
