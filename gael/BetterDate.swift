//
//  BetterDate.swift
//  gael
//
//  Created by Benjamin Oertel on 10/26/23.
//

import Foundation


func formatTime(_ date: Date) -> String {
  let dateFormatter = DateFormatter()
  return dateFormatter.string(from: date)
}

func getTimeFormat() -> String {
  return dateFormatIs24Hour() ? "HH:mm" : "H:mm a"
}

func dateFormatIs24Hour() -> Bool {
  guard let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale: Locale.current) else {
    return false
  }
  return !dateFormat.contains("a")
}

func dateToString(_ date: Date, format: String = "yyyy-MM-dd") -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = format
  return dateFormatter.string(from: date)
}

func stringToDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Date? {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = format
  
  if let date = dateFormatter.date(from: dateString) {
    return date
  } else {
    return nil
  }
}

func minutesForHuman(_ minutes: Int?) -> String {
  guard let m = minutes else {
    return ""
  }
  
  let hours = m / 60
  let remainingMinutes = m % 60
  
  if hours == 0 {
    return "\(remainingMinutes)m"
  } else if remainingMinutes == 0 {
    return "\(hours)h"
  } else {
    return String(format: "%01dh %02dm", hours, remainingMinutes)
  }
}

func differenceInMinutes(start: Date, end: Date) -> Int? {
  let calendar = Calendar.current
  let components = calendar.dateComponents([.minute], from: start, to: end)
  
  if let minutesDifference = components.minute {
    return minutesDifference
  }
  
  return nil
}
