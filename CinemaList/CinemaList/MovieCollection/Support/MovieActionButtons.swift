//
//  MovieActionButtons.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 13.04.2025.
//

import SwiftUI

struct MovieActionButtons: View {
    let movieId: Int
    @Binding var isWatched: Bool
    @Binding var isScored: Bool
    @Binding var isFinished: Bool
    @Binding var isWanted: Bool
    
    @Binding var timecode: String
    @State private var time = ""
    @State private var isShowingTimecodePicker: Bool = false
    
    @State private var selectedTime = Date()
    
    @Binding var myRating: String
    @State private var selectedRating = ""
    @State private var showRatingPicker = false
    
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        Group {
            // V1
//            if (isWatched && !isScored) || (isFinished && !isScored) {
//                scoreButton
//            } else if !isWatched && isWanted && isFinished {
//                unfinishedButtons
//            } else if isWatched && isScored {
//                ratedButton
//            } else {
//                defaultButtons
//            }
            
            // V2
            if isScored {
                ratedButton
            } else if (isWatched || isFinished) {
                scoreButton
            } else if isWanted && !isFinished || !timecode.isEmpty {
                unfinishedButtons
            } else {
                defaultButtons
            }

            // V3
//            if (isWatched && !isScored) {//|| (isFinished && isScored) {
//                scoreButton
//            } else if !isWatched || isWanted || !isFinished {
//                unfinishedButtons
//            } else if isWatched && isScored {
//                ratedButton
//            } else {
//                defaultButtons
//            }
        }
        
        
//        Button(action: {
//            print("Current state:", [
//                "movieId": movieId,
//                "isWatched": isWatched,
//                "isScored": isScored,
//                "isFinished": isFinished,
//                "isWanted": isWanted,
//                "timecode": timecode,
//                "myRating": myRating
//            ])
//        }) {
//            Image(systemName: "key")
//        }
        
    }
    
    // First condition: can score
    private var scoreButton: some View {
        Button {
            showRatingPicker = true
        } label: {
            Text("Оценить фильм")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
        }
        .foregroundStyle(.black)
        .tint(.white)
//        .sheet(isPresented: $showRatingPicker) {
//            RatingPickerView(rating: $selectedRating)
//                .onDisappear {
//                    // Когда выбор завершён
//                    if selectedRating > 0 {
//                        isScored = true
//                        myRating = String(selectedRating)
//                        postRateMovie(id: movieId, rating: myRating)
//                    }
//                }
//        }
        .alert("Enter Value", isPresented: $showRatingPicker) {
            TextField("Timecode", text: $selectedRating)
                .foregroundColor(Color(.label))
                .keyboardType(.numberPad)

            Button("Принять") {
                myRating = selectedRating
                postRateMovie(id: movieId, rating: myRating)
                isScored = true
            }

            Button("Отмена", role: .cancel) {
            }
        } message: {
            Text("Введите время, где вы остановились.")
        }
    }
    
    // Second condition: didn't finish but wanted
//    private var unfinishedButtons: some View {
//        HStack {
//            if timecode.isEmpty {
//                Button {
//                    isFinished = false
//                    isShowingTimecodePicker = true
//                } label: {
//                    Text("Не закончил")
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 5)
//                }
//                .tint(.white.opacity(0.2))
//                .alert("Enter Value", isPresented: $isShowingTimecodePicker) {
//                    TextField("Timecode", text: $time)
//                        .foregroundColor(Color(.label))
//                        .keyboardType(.numberPad)
//                        .onChange(of: timecode) { oldValue, newValue in
//                            timecode = formatTimecode(newValue)
//                        }
//                    
//                    Button("Submit") {
//                        timecode = time
//                        time = ""
//                        postMovieStatus(id: movieId, status: "not_finished", timecode: timecode)
//                    }
//                    
//                    Button("Cancel", role: .cancel) {
//                        
//                    }
//                } message: {
//                    Text("Enter the timecode where you stopped.")
//                }
//            } else {
//                Button {
//                    isFinished = false
//                    isShowingTimecodePicker = true
//                } label: {
//                    Text(timecode)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 5)
//                }
//                .tint(.white.opacity(0.2))
//                .alert("Enter Value", isPresented: $isShowingTimecodePicker) {
//                    TextField("Timecode", text: $time)
//                        .foregroundColor(Color(.label))
//                        .keyboardType(.numberPad)
//                        .onChange(of: timecode) { oldValue, newValue in
//                            timecode = formatTimecode(newValue)
//                        }
//                    
//                    Button("Submit") {
//                        timecode = time
//                        time = ""
//                        postMovieStatus(id: movieId, status: "not_finished", timecode: timecode)
//                    }
//                    
//                    Button("Cancel", role: .cancel) {
//                        
//                    }
//                } message: {
//                    Text("Enter the timecode where you stopped.")
//                }
//            }
//            
//            Button {
//                isWanted.toggle()
//                postMovieStatus(id: movieId, status: "")
//            } label: {
//                Text("Убрать")
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 5)
//            }
//            .foregroundStyle(.black)
//            .tint(.white)
//        }
//    }
    private var unfinishedButtons: some View {
        HStack {
            if timecode.isEmpty {
                Button {
                    isFinished = false
                    isShowingTimecodePicker = true
                    
                    selectedTime = Date()
                    generator.notificationOccurred(.success)
                } label: {
                    Text("Не закончил")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .tint(.white.opacity(0.2))
                .sheet(isPresented: $isShowingTimecodePicker) {
                    timePickerSheet
                }
                
            } else {
                Button {
                    isFinished = false
                    isShowingTimecodePicker = true
                    
                    selectedTime = Date()
                } label: {
                    Text(timecode)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .tint(.white.opacity(0.2))
                .sheet(isPresented: $isShowingTimecodePicker) {
                    timePickerSheet
                }
            }
            
            Button {
                isWanted.toggle()
                timecode = ""
                postMovieStatus(id: movieId, status: "")
                generator.notificationOccurred(.success)
            } label: {
                Text("Убрать")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
            }
            .foregroundStyle(.black)
            .tint(.white)
        }
    }
    
    // Third condition: already scored
    private var ratedButton: some View {
        Button {
            isScored.toggle()
        } label: {
            Text("Ваша оценка фильма \(myRating)")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
        }
        .foregroundStyle(.black)
        .tint(.white)
    }
    
    private var defaultButtons: some View {
        HStack {
            Button {
                // Действие
            } label: {
                Label("Трейлер", systemImage: "tv")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
            }
            .tint(.white.opacity(0.2))
            
            Button {
                //print("isWanted before press is \(isWanted)")
                isWanted.toggle()
                //print("isWanted after press is \(isWanted)")
                postMovieStatus(id: movieId, status: "want_to_watch")
                generator.notificationOccurred(.success)
            } label: {
                Text("Добавить")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
            }
            .foregroundStyle(.black)
            .tint(.white)
        }
    }
    
    private var timePickerSheet: some View {
        VStack(spacing: 0) {
            // Заголовок
            Text("Выберите время")
                .font(.headline)
                .padding(.top, 16)
            
            // Picker времени
            DatePicker("",
                     selection: $selectedTime,
                     displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 180)
                .onAppear {
                    // Устанавливаем время 00:00
                    let calendar = Calendar.current
                    let components = DateComponents(hour: 0, minute: 0)
                    selectedTime = calendar.date(from: components) ?? Date()
                }
            
            // Разделитель
            Divider()
                .padding(.vertical, 8)
            
            // Кнопки действий
            HStack(spacing: 16) {
                Button(action: {
                    isShowingTimecodePicker = false
                }) {
                    Text("Отмена")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    timecode = formatter.string(from: selectedTime)
                    isShowingTimecodePicker = false
                    postMovieStatus(id: movieId, status: "not_finished", timecode: timecode)
                }) {
                    Text("Готово")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }

}


private func formatTimecode(_ input: String) -> String {
    var digits = input.filter { $0.isNumber }
    
    if digits.count > 6 {
        digits = String(digits.prefix(6))
    }
    
    var formatted = ""
    for (i, char) in digits.enumerated() {
        if i == 2 || i == 4 {
            formatted += ":"
        }
        formatted.append(char)
    }
    
    // Проверка на валидность времени (часы <= 23, минуты <= 59, секунды <= 59)
    if digits.count >= 2 {
        let hours = Int(digits.prefix(2)) ?? 0
        if hours > 23 {
            digits = "23" + digits.dropFirst(2)
        }
    }
    
    if digits.count >= 4 {
        let minutes = Int(digits.prefix(4).suffix(2)) ?? 0
        if minutes > 59 {
            let updatedDigits = digits.prefix(2) + "59" + digits.dropFirst(4)
            digits = String(updatedDigits)
        }
    }
    
    if digits.count == 6 {
        let seconds = Int(digits.suffix(2)) ?? 0
        if seconds > 59 {
            let updatedDigits = digits.prefix(4) + "59"
            digits = String(updatedDigits)
        }
    }
    
    return formatted
}



//struct RatingPickerView: View {
//    @Binding var rating: Int
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Колесо выбора оценки
//                Picker("Оценка", selection: $rating) {
//                    ForEach(1..<11, id: \.self) { value in
//                        Text("\(value)")
//                            .font(.title)
//                            .tag(value)
//                    }
//                }
//                .pickerStyle(.wheel)
//                .padding()
//            }
//        }
//    }
//}
