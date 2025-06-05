//
//  LoginNRegisterStyles.swift
//  Test
//
//  Created by Андрей Сметанин on 16.03.2025.
//

import SwiftUI

struct TFStyleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        
        content
            .padding()
            .frame(width: 350)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct TBStyleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        
        content
            .bold()
            .padding()
            .foregroundColor(.white)
            .frame(width: 350, height: 60)
            //.clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

extension View {
    public func tfStyle() -> some View {
        modifier(TFStyleViewModifier())
    }
    
    public func tbStyle() -> some View {
        modifier(TBStyleViewModifier())
    }
}
