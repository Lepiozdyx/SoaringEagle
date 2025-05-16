//
//  BgView.swift
//  SoaringEagle
//
//  Created by Alex on 16.05.2025.
//

import SwiftUI

struct BgView: View {
    var body: some View {
        Image(.bg)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BgView()
}
