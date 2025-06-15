//
//  MatchedView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 15.06.2025.
//

import SwiftUI
import Vortex

struct MatchedView: View {
    @Environment(\.presentationMode) var presentationMode
    let likedItem: CardItem
  
      @State private var isActive = false
      @State private var isHeartActive = false
      
      var body: some View {
        ZStack {
          VortexView(createHeartBubble()) {
            Circle()
              .fill(.clear)
              .tag("circle")
              .overlay {
                Image(systemName: "star.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 36)
                  .foregroundStyle(.yellow)
                  .blur(radius: 5)
                  .opacity(0.5)
              }
          }
          .ignoresSafeArea()
          
          VStack {
            Spacer()

            VStack {
              ProfileCardView(imageName: likedItem.imageName, width: 300, height: 533.33)
                .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 4)
                .opacity(isActive ? 1 : 0)
            }
            .padding(.bottom, 32)
            
            Text(likedItem.name)
              .font(.system(size: 36, weight: .bold))
              .padding(.bottom, 4)
              .opacity(isActive ? 1 : 0)
              .offset(y: isActive ? 0 : 10)
            
            Text("Именно этот фильм выбрали вы и ваш друг")
              .font(.system(size: 16, weight: .medium, design: .default))
              .opacity(isActive ? 1 : 0)
              .offset(y: isActive ? 0 : 10)
            
            Spacer()
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
              Capsule()
                .frame(height: 60)
                .foregroundStyle(.pink)
                .padding(.horizontal)
                .overlay {
                  Text("Готово")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                }
                .opacity(isActive ? 1 : 0)
                .offset(y: isActive ? 0 : 10)
            }
          }
        }
        .onAppear {
          withAnimation(.spring(.smooth(duration: 1))) {
            isActive.toggle()
          }
          
          withAnimation(.spring(.bouncy(duration: 1, extraBounce: 0.3))) {
            isHeartActive.toggle()
          }
        }
      }
      
      func createHeartBubble() -> VortexSystem {
        let system: VortexSystem = .snow
        system.position = [0.5, 1]
        system.angle = .degrees(0)
        system.emissionLimit = 500
        return system
      }
}

#Preview {
  let item = CardItem(id: UUID(), imageName: "f2", name: "Claire")
  MatchedView(likedItem: item)
}
