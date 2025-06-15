//
//  MovieCardView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 09.04.2025.
//

import SwiftUI
import Kingfisher

public struct MovieCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let id: Int
    @State public var color: Color
    
    @State private var movieData: Movie?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isColorLoading = false
    
    private var parentHorizontalPadding: CGFloat = 15
    private var size: CGSize = UIScreen.main.bounds.size
    
    @State private var isWatched = false // watched
    @State private var isScored = false
    @State private var isWanted = false // want_to_watch
    @State private var isFinished = false // not_finished
    @State private var timecode = ""
    @State private var myRating = ""
    
    
    @State private var scrollProperties: ScrollGeometry = .init(
        contentOffset: .zero,
        contentSize: .zero,
        contentInsets: .init(),
        containerSize: .zero
    )
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isPageScrolled = false
    
    public init(id: Int, color: Color = .gray) {
        self.id = id
        self._color = State(initialValue: color)
    }
    
    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let movie = movieData {
                filmContentView(movie: movie)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        )
                    )
            } else {
                Text("Данные не загружены")
                    .foregroundColor(.orange)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: movieData?.id ?? 0)
        .task {
            await loadMovieData()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func filmContentView(movie: Movie) -> some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 15) {
                TopCardView(movie: movie)
                    .containerRelativeFrame(.vertical) { value, _ in
                        value * 0.85
                    }
                
                OtherBookTextContents(movie: movie)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: size.width - (parentHorizontalPadding * 2))
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, -parentHorizontalPadding * scrollProperties.topInsetProgress)
        }
        .padding(.horizontal, 15)
        .background(.gray.opacity(0.15))
        .scrollPosition($scrollPosition)
        .scrollClipDisabled()
        .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }) { oldValue, newValue in
            scrollProperties = newValue
            isPageScrolled = newValue.offsetY > 0
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(BookScrollEnd(topInset: scrollProperties.contentInsets.top))
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 15,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 15
            )
            .fill(.background)
            .ignoresSafeArea(.all, edges: .bottom)
            .offset(y: scrollProperties.offsetY > 0 ? 0 : -scrollProperties.offsetY)
            .padding(.horizontal, -parentHorizontalPadding * scrollProperties.topInsetProgress)
        }
    }
    
    private func loadMovieData() async {
        guard movieData == nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            movieData = try await getMovieInfo(id: id)
            
            setCurrentMovieStatus()
            
            if let posterURL = movieData?.poster {
                await loadDominantColor(from: posterURL)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadDominantColor(from urlString: String) async {
        guard let url = URL(string: urlString), !isColorLoading else { return }
        
        isColorLoading = true
        defer { isColorLoading = false }
        
        await withCheckedContinuation { continuation in
            getDominantColor(from: url) { newColor in
                if let newColor = newColor {
                    withAnimation(.easeInOut) {
                        self.color = newColor
                    }
                }
                continuation.resume()
            }
        }
    }
    
    private func setCurrentMovieStatus() {
        if movieData?.myStatus == "watched" {
            isWatched = true
        }
        
        if movieData?.myStatus == "want_to_watch" {
            isWanted = true
        }
        
        if movieData?.myStatus == "not_finished" {
            isFinished = false
        }
        
        if movieData?.myRating == nil {
            isScored = false
        } else {
            isScored = true
        }

        
        print("movieData?.myRating \(movieData?.myRating ?? "X")")
        print("isScored \(isScored)")
        
        //if movieData?.timecode != nil {
            timecode = movieData?.timecode ?? ""
        //}
        
        //if movieData?.myRating != nil {
            myRating = movieData?.myRating ?? ""
        //}
    }
    
    @ViewBuilder
    private func TopCardView(movie: Movie) -> some View {
        VStack(spacing: 5) {
            FixedHeaderView(movie: movie) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    dismiss()
                }
            }
            
            AsyncImage(url: URL(string: movie.poster)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 400)
                        .cornerRadius(15)
                        .padding(.top, 10)
                        .padding(.bottom, 15)
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 250, height: 400)
                case .empty:
                    ProgressView()
                        .frame(height: 400)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Label(movie.rating, systemImage: "star.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Text("Фильм,")
                    Text("\(movie.runtime ?? 0) мин")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                HStack(spacing: 10) {
                    //                    switch (isWatched, isScored, isFinished, isWanted) {
                    //                        case (true, false, _, _), (_, false, true, _):
                    //                            Button {
                    //                                isScored.toggle()
                    //                            } label: {
                    //                                Text("Оценить фильм")
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .padding(.vertical, 5)
                    //                            }
                    //                            .foregroundStyle(.black)
                    //                            .tint(.white)
                    //
                    //                        case (false, _, false, true):
                    //                            Button {
                    //                                isFinished = false
                    //                            } label: {
                    //                                Text("Не закончил")
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .padding(.vertical, 5)
                    //                            }
                    //                            .foregroundStyle(.black)
                    //                            .tint(.white)
                    //
                    //                            Button {
                    //                                isWanted.toggle()
                    //                            } label: {
                    //                                Text("Убрать")
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .padding(.vertical, 5)
                    //                            }
                    //                            .foregroundStyle(.black)
                    //                            .tint(.white)
                    //
                    //                        case (true, true, _, _):
                    //                            Button {
                    //                                isScored.toggle()
                    //                            } label: {
                    //                                Text("Ваша оценка фильма \(movieData?.myRating ?? 9.0)")
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .padding(.vertical, 5)
                    //                            }
                    //                            .foregroundStyle(.black)
                    //                            .tint(.white)
                    //
                    //                        default:
                    //                            Button {
                    //                                // Действие
                    //                            } label: {
                    //                                Label("Трейлер", systemImage: "tv")
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .padding(.vertical, 5)
                    //                            }
                    //                            .tint(.white.opacity(0.2))
                    //
                    //                            Button {
                    //                                isWanted.toggle()
                    //                            } label: {
                    //                                Text("Добавить")
                    //                                    .frame(maxWidth: .infinity)
                    //                                    .padding(.vertical, 5)
                    //                            }
                    //                            .foregroundStyle(.black)
                    //                            .tint(.white)
                    //                    }
                    MovieActionButtons(
                        movieId: movie.id,
                        isWatched: $isWatched,
                        isScored: $isScored,
                        isFinished: $isFinished,
                        isWanted: $isWanted,
                        timecode: $timecode,
                        myRating: $myRating
                    )
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 5)
            }
            .padding(15)
            .background(.white.opacity(0.2), in: .rect(cornerRadius: 15))
        }
        .foregroundStyle(.white)
        .padding(15)
        .frame(maxWidth: size.width - (parentHorizontalPadding * 2))
        .frame(maxWidth: .infinity)
        .background {
            Rectangle().fill(color.gradient)
        }
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 15,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 15
        ))
    }
    
    @ViewBuilder
    private func OtherBookTextContents(movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(movie.overview)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .lineLimit(5)
            
//            Text("Requairements")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .padding(.top, 15)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Дата выхода в прокат")
//                    .padding(.top, 5)
//                
//                Text(convertDateString(movie.releaseDate) ?? "Неизвестно")
//                    .foregroundStyle(.secondary)
//                
//                Text("iBooks")
//                    .padding(.top, 5)
//                
//                Text("Requires iBooks and ios 4.3 or later")
//                    .foregroundStyle(.secondary)
//                
//                Text("Versions")
//                    .fontWeight(.semibold)
//                    .padding(.top, 5)
//                
//                Text("Updated Mar 16 2022")
//                    .foregroundStyle(.secondary)
//            }
//            .padding(.top, 5)
            
            Text("Актеры")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 15)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 15) {
                    ForEach(movie.actors ?? [], id: \.id) { actor in
                        VStack {
                            AsyncImage(url: URL(string: actor.photo ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 90, height: 90)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                                        .frame(width: 90, height: 90)
                                case .empty:
                                    ProgressView()
                                        .frame(width: 90, height: 90)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            Text(actor.name)
                                .font(.caption)
                                .frame(width: 80)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(.top, 5)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private func FixedHeaderView(movie: Movie, dismissAction: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            Button(action: dismissAction) {
                Image(systemName: "xmark.circle.fill")
            }
            
            Spacer()
            
            if isWatched {
                Button {
                    // Срабатывает когда фильм был "просмотрен"
                    
                    // Очистка статуса фильма
                    postMovieStatus(id: movie.id, status: "")
                    isWatched.toggle()
                    
                    // Очистка оценки фильма
                    postRateMovie(id: movie.id, rating: "")
                    isScored = false
                    myRating = ""
                } label: {
                    Image(systemName: "eye.slash.circle.fill")
                }
            } else {
                Button {
                    // Срабатывает когда фильм еще не был "просмотрен"
                    postMovieStatus(id: movie.id, status: "watched")
                    isWatched.toggle()
                } label: {
                    Image(systemName: "eye.circle.fill")
                }
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    scrollPosition.scrollTo(edge: .top)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
            }
        }
        .buttonStyle(.plain)
        .font(.title)
        .foregroundStyle(.white, .white.tertiary)
        .background {
            Color.clear
                .overlay(alignment: .bottom) {
                    TransparentBlurView()
                        .frame(height: scrollProperties.contentInsets.top + 60)
                        .blur(radius: 10, opaque: false)
                }
                .opacity(scrollProperties.topInsetProgress)
        }
        .padding(.horizontal, -parentHorizontalPadding * scrollProperties.topInsetProgress)
        .offset(y: scrollProperties.offsetY < 20 ? 0 : scrollProperties.offsetY - 20)
        .zIndex(1000)
    }
}

// Вспомогательные структуры
struct BookScrollEnd: ScrollTargetBehavior {
    var topInset: CGFloat
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < topInset {
            target.rect.origin = .zero
        }
    }
}

extension ScrollGeometry {
    var offsetY: CGFloat {
        contentOffset.y + contentInsets.top
    }
    
    var topInsetProgress: CGFloat {
        guard contentInsets.top > 0 else { return 0 }
        return max(min(offsetY / contentInsets.top, 1), 0)
    }
}

// Предварительный просмотр
#Preview {
    NavigationStack {
        MovieCardView(id: 50824)
    }
}
