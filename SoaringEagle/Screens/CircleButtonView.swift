//
//  CircleButtonView.swift
//  SoaringEagle
//
//  Created by Alex on 16.05.2025.
//

import SwiftUI

struct CircleButtonView: View {
    let iconName: String
    let height: CGFloat
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Image(.buttonC)
                    .resizable()
                    .scaledToFit()
                    .frame(height: height)
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .foregroundStyle(.black.opacity(0.6))
            }
        }
    }
}

#Preview {
    CircleButtonView(iconName: "gift.fill", height: 60, action: {})
}
