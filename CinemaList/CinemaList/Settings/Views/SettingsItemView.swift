//
//  SettingsItemView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 25.03.2025.
//

import SwiftUI

struct SettingsItemView: View {
    let item: SettingsItem
    
    var body: some View {
        HStack {
            iconImageView()
                .frame(width: 30, height: 30)
                //.foregroundStyle(.white)
                //.background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            Text(item.title)
                .font(.system(size: 18))
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func iconImageView() -> some View {
        
        switch item.imageType {
        case .systemImage:
            Image(systemName: item.imageName)
                .bold()
                .font(.callout)
            
        case .assetImage:
            Image(item.imageName)
                .renderingMode(.template)
                .padding(3)
        }
    }
}

#Preview {
    SettingsItemView(item: .notifications)
}
