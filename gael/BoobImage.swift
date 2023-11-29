//
//  BoobImage.swift
//  gael
//
//  Created by Benjamin Oertel on 10/26/23.
//

import SwiftUI
import AppIntents

struct BoobImage: View {
  @Environment(\.colorScheme) var colorScheme
  let side: Side
  var activeSide: Side?
  var reverse: Bool = false
  
  var body: some View {
    Image(systemName: getSystemName())
      .foregroundColor(getForegroundColor())
      .symbolRenderingMode(getSymbolRenderingMode())
  }
  
  private func getForegroundColor() -> Color {
    if isActive {
      return .accentColor
    } else {
      return .gray
    }
  }
  
  private func getSymbolRenderingMode() -> SymbolRenderingMode {
    if isActive {
      return .monochrome
    } else {
      if colorScheme == .dark {
        return .hierarchical
      } else {
        return .monochrome
      }
    }
  }
  
  var isActive: Bool {
    get {
      if reverse {
        return activeSide != side
      } else {
        return activeSide == side
      }
    }
  }
  
  func getSystemName() -> String {
    let systemName = side == Side.left ? "l.circle.fill" : "r.circle.fill"
    return systemName
  }
}


struct BoobButton: View {
  let side: Side
  let activeSide: Side?
  let reverse: Bool
  var size: CGFloat? = 30
  
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      BoobImage(side: side, activeSide: activeSide, reverse: reverse)
        .font(.system(size: size ?? 30))
    }.buttonStyle(.plain)
  }
}

struct BoobIntentButton: View {
  let side: Side
  let activeSide: Side?
  let reverse: Bool
  var size: CGFloat? = 30
  
  let intent: any AppIntent

  var body: some View {
    Button(intent: intent) {
      BoobImage(side: side, activeSide: activeSide, reverse: reverse)
        .font(.system(size: size ?? 30))
    }.buttonStyle(.plain)
  }
}


#Preview {
  VStack(spacing: 20) {
    HStack(spacing: 4) {
      BoobImage(side: Side.left)
      BoobImage(side: Side.left, activeSide: Side.right)
      BoobImage(side: Side.left, activeSide: Side.left)
    }
    
    HStack(spacing: 4) {
      BoobImage(side: Side.right)
      BoobImage(side: Side.right, activeSide: Side.right)
      BoobImage(side: Side.right, activeSide: Side.left)
    }
    
    HStack(spacing: 4) {
      BoobImage(side: Side.right)
      BoobImage(side: Side.left, activeSide: Side.left)
      BoobImage(side: Side.left, activeSide: Side.left)
    }.accentColor(.green)
  }
}
