//
//  FriendsView.swift
//  CinemaList
//
//  Created by Denis Burof on 25.04.2025.
//

//
//  FriendsView.swift
//  CinemaList
//
//  Created by Denis Burof on 25.04.2025.
//

import SwiftUI

struct FriendsView: View {
    enum TabSelection {
        case friends, incomingRequests, outgoingRequests
    }
    
    @State private var selectedTab: TabSelection = .friends
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var showSearchSheet = false
    @State private var searchResults: [SearchedUser] = []
    
    @State private var friends: [Friend] = []
    @State private var incomingRequests: [Friend] = []
    @State private var outgoingRequests: [Friend] = []
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Selection", selection: $selectedTab) {
                    Text("Друзья").tag(TabSelection.friends)
                    Text("Входящие").tag(TabSelection.incomingRequests)
                    Text("Исходящие").tag(TabSelection.outgoingRequests)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        switch selectedTab {
                        case .friends:
                            friendsSection
                        case .incomingRequests:
                            incomingRequestsSection
                        case .outgoingRequests:
                            outgoingRequestsSection
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        loadData()
                    }
                }
            }
            .navigationTitle("Друзья")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearchSheet = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onAppear {
                loadData()
            }
            .onChange(of: selectedTab) { _, _ in
                loadData()
            }
            .alert("Ошибка", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Неизвестная ошибка")
            }
            .sheet(isPresented: $showSearchSheet, onDismiss: {
                searchQuery = ""
                isSearching = false
                searchResults = []
            }) {
                SearchSheetView(
                    searchQuery: $searchQuery,
                    isSearching: $isSearching,
                    searchResults: $searchResults,
                    onSearch: performSearch,
                    onSendRequest: sendFriendRequest
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - List Sections
    private var friendsSection: some View {
        Section {
            if friends.isEmpty {
                Text("Нет друзей")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(friends) { friend in
                    FriendRow(friend: friend) {
                        removeFriend(userID: friend.id)
                    }
                }
            }
        }
    }
    
    private var incomingRequestsSection: some View {
        Section {
            if incomingRequests.isEmpty {
                Text("Нет входящих запросов")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(incomingRequests) { friend in
                    RequestRow(friend: friend, isIncoming: true) {
                        acceptRequest(userID: friend.id)
                    } rejectAction: {
                        rejectRequest(userID: friend.id)
                    }
                }
            }
        }
    }
    
    private var outgoingRequestsSection: some View {
        Section {
            if outgoingRequests.isEmpty {
                Text("Нет исходящих запросов")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(outgoingRequests) { friend in
                    RequestRow(friend: friend, isIncoming: false) {
                        // Нет действия для исходящих запросов
                    } rejectAction: {
                        cancelRequest(userID: friend.id)
                    }
                }
            }
        }
    }
    
    // MARK: - API Methods
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        switch selectedTab {
        case .friends:
            loadFriends()
        case .incomingRequests:
            loadIncomingRequests()
        case .outgoingRequests:
            loadOutgoingRequests()
        }
    }
    
    private func loadFriends() {
        Task {
            do {
                let friends = try await getFriends()
                DispatchQueue.main.async {
                    self.friends = friends
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadIncomingRequests() {
        Task {
            do {
                let requests = try await getIncomingFriendRequests()
                DispatchQueue.main.async {
                    self.incomingRequests = requests
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadOutgoingRequests() {
        Task {
            do {
                let requests = try await getOutgoingFriendRequests()
                DispatchQueue.main.async {
                    self.outgoingRequests = requests
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        Task {
            do {
                let results = try await searchUsers(query: searchQuery)
                DispatchQueue.main.async {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                    isSearching = false
                }
            }
        }
    }
    
    private func sendFriendRequest(userID: Int) {
        Task {
            do {
                try await sendFriendRequest(userID: userID)
                DispatchQueue.main.async {
                    loadOutgoingRequests()
                }
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func acceptRequest(userID: Int) {
        Task {
            do {
                try await acceptFriendRequest(userID: userID)
                DispatchQueue.main.async {
                    loadFriends()
                    loadIncomingRequests()
                }
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func rejectRequest(userID: Int) {
        Task {
            do {
                try await rejectFriendRequest(userID: userID)
                DispatchQueue.main.async {
                    loadIncomingRequests()
                }
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func cancelRequest(userID: Int) {
        Task {
            do {
                try await rejectFriendRequest(userID: userID)
                DispatchQueue.main.async {
                    loadOutgoingRequests()
                }
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func removeFriend(userID: Int) {
        Task {
            do {
                try await removeFriend(userID: userID)
                DispatchQueue.main.async {
                    loadFriends()
                }
            } catch {
                DispatchQueue.main.async {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}

// MARK: - Components
struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var searchQuery: String
    @Binding var isSearching: Bool
    @Binding var searchResults: [SearchedUser]
    var onSearch: () -> Void
    var onSendRequest: (Int) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $searchQuery, isSearching: $isSearching, onSearch: onSearch)
                    .padding()
                
                List {
                    if searchResults.isEmpty {
                        if isSearching {
                            Text("Пользователи не найдены")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("Введите имя пользователя для поиска")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } else {
                        ForEach(searchResults) { user in
                            SearchResultRow(user: user) {
                                onSendRequest(user.id)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Поиск друзей")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    let removeAction: () -> Void
    
    var body: some View {
        HStack {
            UserProfileView(
                avatarURL: friend.avatarURL,
                displayName: friend.displayName,
                username: friend.username
            )
            
            Spacer()
            
            Button(action: removeAction) {
                Image(systemName: "person.badge.minus")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
    }
}

struct RequestRow: View {
    let friend: Friend
    let isIncoming: Bool
    let acceptAction: () -> Void
    let rejectAction: () -> Void
    
    var body: some View {
        HStack {
            UserProfileView(
                avatarURL: friend.avatarURL,
                displayName: friend.displayName,
                username: friend.username
            )
            
            Spacer()
            
            if isIncoming {
                Button(action: acceptAction) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                .buttonStyle(.borderless)
            }
            
            Button(action: rejectAction) {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
    }
}

//struct SearchResultRow: View {
//    let user: SearchedUser
//    let addAction: () -> Void
//    
//    var body: some View {
//        HStack {
//            UserProfileView(
//                avatarURL: user.avatarURL,
//                displayName: user.displayName,
//                username: user.username
//            )
//            
//            Spacer()
//            
//            Button(action: addAction) {
//                Image(systemName: "person.badge.plus")
//                    .foregroundColor(.blue)
//            }
//            .buttonStyle(.borderless)
//        }
//    }
//}

struct SearchResultRow: View {
    let user: SearchedUser
    let addAction: () -> Void
    
    var body: some View {
        HStack {
            UserProfileView(
                avatarURL: user.avatarURL,
                displayName: user.displayName,
                username: user.username
            )
            
            Spacer()
            
            if user.friendRequestStatus == "none" {
                Button(action: addAction) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
            } else {
                Text("Запрос отправлен")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
    }
}

//struct UserProfileView: View {
//    let avatarURL: URL?
//    let displayName: String
//    let username: String
//    
//    var body: some View {
//        HStack {
//            if let avatarURL = avatarURL {
//                AsyncImage(url: avatarURL) { image in
//                    image.resizable()
//                        .aspectRatio(contentMode: .fill)
//                } placeholder: {
//                    Color.gray
//                }
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//            } else {
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.gray)
//            }
//            
//            VStack(alignment: .leading) {
//                Text(displayName)
//                    .font(.headline)
//                Text(username)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//        }
//    }
//}

struct UserProfileView: View {
    let avatarURL: URL?
    let displayName: String
    let username: String
    
    var body: some View {
        HStack {
            if let avatarURL = avatarURL {
                AsyncImage(url: avatarURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(displayName)
                    .font(.headline)
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Поиск пользователей", text: $text, onCommit: {
                    isSearching = true
                    onSearch()
                })
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray5))
            .cornerRadius(8)
            
            if isSearching {
                Button("Отмена") {
                    text = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .foregroundColor(.blue)
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
