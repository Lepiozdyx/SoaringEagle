//
//  LoadingView.swift
//  SoaringEagle
//
//  Created by Alex on 19.05.2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var loading: CGFloat = 0
    
    var body: some View {
        ZStack {
            BgView()
            
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Loading...")
                        .gameFont(36)
                    
                        Capsule()
                            .foregroundStyle(.black.opacity(0.4))
                            .frame(maxWidth: 300, maxHeight: 20)
                            .overlay {
                                Capsule()
                                    .stroke(.gray, lineWidth: 1)
                            }
                            .overlay(alignment: .top) {
                                Capsule()
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(height: 4)
                                    .padding(.horizontal, 10)
                                    .padding(.top, 3)
                            }
                            .shadow(radius: 2)
                            .overlay(alignment: .leading) {
                                // Заполнение прогресса
                                Capsule()
                                    .foregroundStyle(.grayLight)
                                    .frame(width: 298 * loading, height: 18)
                                    .padding(.horizontal, 1)
                            }
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5)) {
                loading = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
