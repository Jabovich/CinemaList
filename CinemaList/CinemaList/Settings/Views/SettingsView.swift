//
//  SettingsView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 25.03.2025.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct SettingsView: View {
    // импорт LoginViewModel для использования функции выхода
    @State private var viewModel = LoginViewModel()
    
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var showingAlertExit = false
    
    // Свойство для перехода на экран входа и регисрации
    @State private var isLoggedOut = false
    
    @State private var user: User?
    
    @State private var isLoading = false
    
    @State private var photosPickerItem: PhotosPickerItem?
    
    func loadUser() {
        guard !isLoading else { return } // Если уже в процессе загрузки, ничего не делать
        isLoading = true
        
        Task {
            do {
                user = try await getUser()
            } catch {
                print("Error loading user: \(error)")
            }
            isLoading = false // Завершаем процесс загрузки
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        AsyncImage(url: URL(string: user?.profilePhoto ?? "")) { image in
                            image
                                //.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                            
                        } placeholder: {
                            Circle()
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 55, height: 55)
                        
                        Text(user?.name ?? "Name")
                            .font(.title2)
                        
                        Text(user?.surname ?? "Surname")
                            .font(.title2)
                    }
                    
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        SettingsItemView(item: .avatar)
                    }
                    .onChange(of: photosPickerItem) { _, _ in
                        Task {
                            if let photosPickerItem,
                               let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                print("Photo was changed \(data)")
                                
                                if let image = UIImage(data: data) {
                                    uploadPhoto(photo: image)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        loadUser()
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    SettingsItemView(item: .account)
                }
                
                Section (header: Text("Процент фильмов по статусам")) {
                    VStack {
//                        HStack {
//                            Text("Процент фильмов со статусом:")
//                                .font(.title3)
//                                //.bold()
//                            Spacer()
//                        }

                        let (notFinishedPercentage, watchedPercentage, wantToWatchPercentage) = calculatePercentage(
                            notFinishedCount: user?.filmsNotFinishedCount ?? 3,
                            watchedCount: user?.filmsWatchedCount ?? 5,
                            wantToWatchCount: user?.filmsWantToWatchCount ?? 6)

                        CircularProgressView(progress: wantToWatchPercentage, description: "Хочу посмотреть")
                        
                        CircularProgressView(progress: notFinishedPercentage, description: "Не закончены")
                        
                        CircularProgressView(progress: watchedPercentage, description: "Просмотрено")
                    }
                }
                
                Section {
//                    NavigationLink(destination: Text("Do Not Disturb")) {
//                        //SettingsItemView(item: .stats)
//                        SettingsItemView(item: .playlists)
//                    }
                    
                    NavigationLink(destination: FriendsView()){
                        SettingsItemView(item: .friends)
                    }
                }
                
//                Section {
//                    SettingsItemView(item: .notifications)
//                    SettingsItemView(item: .storage)
//                }
                
                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }
                
                Section {
                    Button (action: {
                        showingAlert.toggle()
                    }){
                        SettingsItemView(item: .storage)
                    }
                    .foregroundStyle(.pink)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Очистка кэша"),
                              message: Text("Вы уверены, что хотитие очистить кэш ? Все сохраненные данные будут удалены после перезагрузки приложения."),
                              primaryButton: .destructive(Text("Да"), action: {
                                    ImageCache.default.clearMemoryCache() // Kingfisher RAM
                                    ImageCache.default.clearDiskCache()   // Kingfisher Disk
                              }),
                              secondaryButton: .cancel(Text("Нет")))
                    }
                }
                
                Section {
                    Button (action: {
                        showingAlertExit.toggle()
                    }){
                        SettingsItemView(item: .logOut)
                    }
                    .foregroundStyle(.pink)
                    .alert(isPresented: $showingAlertExit) {
                        Alert(title: Text("Выход"),
                              message: Text("Вы уверены, что хотитие выйти из аккаунта ?"),
                              primaryButton: .destructive(Text("Да"), action: {
                                  // Perform delete action here
                                    viewModel.logOut()
                                    isLoggedOut = true
                              }),
                              secondaryButton: .cancel(Text("Нет")))
                    }
                }
            }
            .navigationTitle("Настройки")
            .searchable(text: $searchText)
            .navigationDestination(isPresented: $isLoggedOut) {
                TempLNRView()
            }
        }
//        .task {
//            do {
//                user = try await getUser()
//            } catch ProfileError.invalidURL {
//                print("Invalid URL")
//            } catch ProfileError.invalidResponse {
//                print("Invalid Response")
//            } catch ProfileError.invalidData {
//                print("Invalid Data")
//            } catch {
//                print("Something went wrong \(error)")
//            }
//        }
        .onAppear {
            loadUser() // Загружаем пользователя только при появлении экрана
        }
    }
}


#Preview {
    SettingsView()
}


enum ProfileError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    
}


struct CircularProgressView: View {
    let progress: Double
    let description: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(
                        Color.pink.opacity(0.5),
                        lineWidth: 5
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.pink,
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                // 1
                    .animation(.easeOut, value: progress)
                
                Text("\(progress * 100, specifier: "%.0f")")
                    .bold()
                    .font(.system(size: 14))
            }
            .frame(width: 40, height: 40)
            
            Text(description)
                .padding(.leading)
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}


func calculatePercentage(notFinishedCount: Int, watchedCount: Int, wantToWatchCount: Int) -> (Double, Double, Double)  {
    // Суммируем все значения
    let total = Double(notFinishedCount + watchedCount + wantToWatchCount)
    
    // Если сумма равна 0, то возвращаем все как 0
    if total == 0 {
        return (0, 0, 0)
    }
    
    // Вычисляем процент для каждой переменной
    let notFinishedPercentage = (Double(notFinishedCount) * 100.0) / total / 100
    let watchedPercentage = (Double(watchedCount) * 100) / total / 100
    let wantToWatchPercentage = (Double(wantToWatchCount) * 100) / total / 100
    
    // Возвращаем результаты
    return (notFinishedPercentage, watchedPercentage, wantToWatchPercentage)
}
