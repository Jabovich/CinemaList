//
//  NewsView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 06.02.2025.
//

import SwiftUI

struct NewsView: View {
    let news = [
            NewsItem(title: "Новый фильм Нолана анонсирован", summary: "Кристофер Нолан работает над новым проектом. Ожидается, что фильм выйдет в 2026 году.", imageUrl: "https://icdn.lenta.ru/images/2022/12/14/16/20221214161843745/square_320_1eedc36e88e7b0479861e19320ba5e3c.jpg"),
            NewsItem(title: "Marvel перенесла очередной фильм", summary: "Студия объявила дату выхода нового фильма про Мстителей. Подробности сюжета пока держатся в секрете.", imageUrl: "https://d3g9pb5nvr3u7.cloudfront.net/sites/53e8dd87f883f8a50b2fcd3a/-206371713/256.jpg"),
            NewsItem(title: "Фестиваль в Каннах 2025", summary: "Организаторы раскрыли программу предстоящего Каннского кинофестиваля. В списке лучшие режиссеры мира.", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKpu0FQweCuvMVePDl8Ac8l9QtBtsQ5GkMQA&s")
        ]
        
        var body: some View {
            NavigationView {
                List(news) { item in
                    NavigationLink(destination: NewsDetailView(newsItem: item)) {
                        HStack {
                            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                if let image = phase.image {
                                    image.resizable()
                                } else if phase.error != nil {
                                    Image(systemName: "photo") // Иконка-заглушка
                                        .resizable()
                                        .foregroundColor(.gray)
                                } else {
                                    ProgressView() // Индикатор загрузки
                                }
                            }
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.summary)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(5)
                    }
                }
                .navigationTitle("Киноновости")
            }
        }
}

#Preview {
    NewsView()
}

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let imageUrl: String
}

struct NewsDetailView: View {
    let newsItem: NewsItem
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: newsItem.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                }
            }
            .scaledToFit()
            .frame(height: 250)
            .cornerRadius(10)
            
            Text(newsItem.title)
                .font(.title)
                .bold()
                .padding(.top, 10)
            
            Text(newsItem.summary)
                .font(.body)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Новость")
    }
}
