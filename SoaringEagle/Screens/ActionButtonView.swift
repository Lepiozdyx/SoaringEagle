//
//  ActionButtonView.swift
//  SoaringEagle
//
//  Created by Alex on 16.05.2025.
//

import SwiftUI

struct ActionButtonView: View {
    let title: String
    let fontSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    var isPaid: Bool = false
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Image(.buttonM)
                    .resizable()
                    .frame(maxWidth: width, maxHeight: height)
                
                VStack(spacing: 4) {
                    Text(title)
                        .gameFont(fontSize)
                   
                    if isPaid {
                        HStack {
                            Image(.coin)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                            
                            Text("100")
                                .gameFont(16)
                        }
                    }
                }
            }
        }
        .withSound()
    }
}

#Preview {
    ActionButtonView(title: "Tournament", fontSize: 20, width: 250, height: 100) {}
}
