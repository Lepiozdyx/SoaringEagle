//
//  CoinBoardView.swift
//  SoaringEagle
//
//  Created by Alex on 16.05.2025.
//

import SwiftUI

struct CoinBoardView: View {
    let coins: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Image(.buttonM)
            .resizable()
            .frame(maxWidth: width, maxHeight: height)
            .overlay {
                Text("\(coins)")
                    .gameFont(20)
                    .offset(x: 5)
            }
            .overlay(alignment: .leading) {
                ZStack {
                    Image(.buttonC)
                        .resizable()
                        .scaledToFit()
                    
                    Image(.coin)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                }
                .offset(x: -20)
            }
    }
}

#Preview {
    CoinBoardView(coins: 1999, width: 150, height: 60)
}
