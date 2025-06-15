//
//  DatingView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 15.06.2025.
//

import SwiftUI

struct DatingView: View {
  let generator = UINotificationFeedbackGenerator()
  @GestureState private var dragOffset: CGSize = .zero
  @State private var positionOffset: CGSize = .zero
  @State private var dragProgress: Double = 0
  @State private var items: [CardItem] = [
    "Рейс навылет",
    "Мастер",
    "Новокаин",
    "Вся жизнь",
    "Элиас",
    "В никуда",
  ]
    .enumerated()
    .map { index, name in
      CardItem(id: UUID(), imageName: "f\(index + 1)", name: name)
    }
  
  @State private var likedItem: CardItem?
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if items.isEmpty {
          Text("В следующий раз повезет")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.gray)
            .transition(.opacity)
        } else {
          ForEach(Array(items.enumerated().reversed()), id: \.element) { index, item in
            let imageName = item.imageName
            
            switch index {
            case 0:
              ProfileCardView(
                imageName: imageName,
                width: geometry.size.width - 64,
                height: (geometry.size.width - 64) * 16 / 9
              )
              .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
              .offset(y: -10 * CGFloat(index))
              .offset(x: dragOffset.width + positionOffset.width)
              .offset(y: dragOffset.height + positionOffset.height)
              .rotationEffect(.degrees(-10 * dragOffset.width / 150.0))
              .opacity(Double(max(0, 1 - 0.3 * Double(index))))
              .gesture(
                DragGesture()
                  .updating($dragOffset) { value, state, _ in
                    state = value.translation
                  }
                  .onEnded { value in
                    if value.translation.width >= 0.5 * (geometry.size.width - 64) {
                      // Like
                      // 1. Move the card to the right
                      positionOffset.width += 400
                      
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // 2. Update the card list
                        items.removeFirst()
                        generator.notificationOccurred(.success)
                        
                        // 3. Reset states
                        dragProgress = 0
                        positionOffset = .zero
                        
                        // 4. Perform like
                        like(item)
                      }
                    } else if value.translation.width <= -0.5 * (geometry.size.width - 64) {
                      // Dislike
                      // 1. Move the card to the left
                      positionOffset.width -= 400
                      
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // 2. Update the card list
                        items.removeFirst()
                        generator.notificationOccurred(.error)
                        
                        // 3. Reset states
                        dragProgress = 0
                        positionOffset = .zero
                      }
                    }
                  }
              )
              .animation(.spring(.snappy(duration: 0.25)), value: dragOffset)
              
            case 1, 2, 3:
              ProfileCardView(
                imageName: imageName,
                width: geometry.size.width - 64,
                height: (geometry.size.width - 64) * 16 / 9
              )
              .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
              .offset(y: -25 * (Double(index) - dragProgress))
              .rotationEffect(.degrees(5.0 * (Double(index) - dragProgress)))
              .opacity(Double(max(0, 1 - 0.33 * (Double(index) - dragProgress))))
              .scaleEffect(
                x: 1 - (0.05 * CGFloat(index)) + 0.05 * dragProgress,
                y: 1 - (0.05 * CGFloat(index)) + 0.05 * dragProgress
              )
              
            default:
              EmptyView()
            }
          }
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .onChange(of: dragOffset) { oldValue, newValue in
        if abs(newValue.width) > abs(oldValue.width) && abs(newValue.height) > abs(oldValue.height) {
          dragProgress = min(1, abs(dragOffset.width + positionOffset.width) / 150.0)
        } else {
          withAnimation(.spring(.snappy(duration: 0.25))) {
            dragProgress = min(1, abs(dragOffset.width + positionOffset.width) / 150.0)
          }
        }
      }
    }
    .ignoresSafeArea()
    .fullScreenCover(item: $likedItem) { item in
      MatchedView(likedItem: item)
    }
  }
  
  func like(_ item: CardItem) {
    likedItem = item
  }
}

struct CardItem: Identifiable, Hashable {
  let id: UUID
  let imageName: String
  let name: String
}

#Preview {
  DatingView()
}
