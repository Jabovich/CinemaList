//
//  PostersScrollView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI

struct PostersScrollView: View {
    @State private var selectedItem = 0 // Индекс текущего элемента
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 36) {
                    ForEach(0..<10, id: \.self) { index in
                        Text("Item \(index)")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                            .frame(width: 220, height: 330)
                            .background(.red)
                            .cornerRadius(10)
                            .id(index) // Присваиваем идентификатор каждому элементу
                    }
                }
                .padding(.horizontal, (UIScreen.main.bounds.width - 220) / 2) // Центрирование
                .contentShape(Rectangle()) // Упрощает распознавание жестов
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let scrollDistance = value.translation.width
                            let offsetThreshold: CGFloat = 100 // Порог прокрутки

                            if scrollDistance < -offsetThreshold {
                                selectedItem = min(selectedItem + 1, 9) // Следующий элемент
                            } else if scrollDistance > offsetThreshold {
                                selectedItem = max(selectedItem - 1, 0) // Предыдущий элемент
                            }

                            // Прокрутка к ближайшему элементу
                            withAnimation {
                                proxy.scrollTo(selectedItem, anchor: .center)
                            }
                        }
                )
            }
        }
    }
}

#Preview {
    PostersScrollView()
}
