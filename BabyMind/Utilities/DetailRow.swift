//
//  DetailRow.swift
//  BabyMind
//
//  Ortak detay satırı komponenti
//

import SwiftUI

struct DetailRow: View {
    let title: String
    let value: Any
    var dateStyle: Text.DateStyle?
    let theme: ColorTheme
    
    init(title: String, value: Any, dateStyle: Text.DateStyle? = nil, theme: ColorTheme) {
        self.title = title
        self.value = value
        self.dateStyle = dateStyle
        self.theme = theme
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(theme.text.opacity(0.7))
            
            Spacer()
            
            if let date = value as? Date, let style = dateStyle {
                Text(date, style: style)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(theme.text)
            } else {
                Text("\(value)")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(theme.text)
            }
        }
    }
}

