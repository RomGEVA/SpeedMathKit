import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false
    @State private var showPrivacyPolicy = false
    @State private var showAbout = false
    @State private var userName: String
    @State private var selectedAvatar: String
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._userName = State(initialValue: viewModel.userProfile.name)
        self._selectedAvatar = State(initialValue: viewModel.userProfile.avatar)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ProfileSectionView(userName: $userName, selectedAvatar: $selectedAvatar, avatarOptions: avatarOptions)
                        DataManagementSectionView(showResetAlert: $showResetAlert, resetAction: {
                            viewModel.resetData()
                            userName = viewModel.userProfile.name
                            selectedAvatar = viewModel.userProfile.avatar
                        })
                        AppInfoSectionView(showPrivacyPolicy: $showPrivacyPolicy, showAbout: $showAbout, rateApp: rateApp)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
        .alert("Reset All Data", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetData()
                userName = viewModel.userProfile.name
                selectedAvatar = viewModel.userProfile.avatar
            }
        } message: {
            Text("This will permanently delete all your game data, scores, and progress. This action cannot be undone.")
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
    
    private var avatarOptions: [String] {
        [
            "😀", "😎", "🤓", "🥳", "👽", "👾", "🦄", "🐱", "🐶", "🐵"
        ]
    }
    
    private func saveSettings() {
        viewModel.userProfile.name = userName
        viewModel.userProfile.avatar = selectedAvatar
        viewModel.updateSettings(viewModel.settings)
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

private struct ProfileSectionView: View {
    @Binding var userName: String
    @Binding var selectedAvatar: String
    let avatarOptions: [String]
    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            ProfileCard(userName: $userName, selectedAvatar: $selectedAvatar, avatarOptions: avatarOptions)
        }
    }

    private struct ProfileCard: View {
        @Binding var userName: String
        @Binding var selectedAvatar: String
        let avatarOptions: [String]
        var body: some View {
            VStack(spacing: 20) {
                AvatarGrid(selectedAvatar: $selectedAvatar, avatarOptions: avatarOptions)
                NameField(userName: $userName)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private struct AvatarGrid: View {
        @Binding var selectedAvatar: String
        let avatarOptions: [String]
        var body: some View {
            VStack(spacing: 12) {
                Text("Avatar")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        AvatarButton(avatar: avatar, isSelected: selectedAvatar == avatar) {
                            selectedAvatar = avatar
                        }
                    }
                }
            }
        }

        private struct AvatarButton: View {
            let avatar: String
            let isSelected: Bool
            let action: () -> Void
            var body: some View {
                Button(action: action) {
                    Text(avatar)
                        .font(.system(size: 32))
                        .frame(width: 60, height: 60)
                        .background(isSelected ? Color.blue : Color.clear)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                        )
                        .accessibilityLabel(Text(isSelected ? "Selected avatar" : "Avatar"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private struct NameField: View {
        @Binding var userName: String
        var body: some View {
            VStack(spacing: 8) {
                Text("Name")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
        }
    }
}

private struct DataManagementSectionView: View {
    @Binding var showResetAlert: Bool
    let resetAction: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text("Data Management")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 16) {
                SettingRow(
                    icon: "trash.fill",
                    title: "Reset All Data",
                    subtitle: "Delete all game data and start fresh",
                    color: .red
                ) {
                    Button("Reset") {
                        showResetAlert = true
                        resetAction()
                    }
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct AppInfoSectionView: View {
    @Binding var showPrivacyPolicy: Bool
    @Binding var showAbout: Bool
    let rateApp: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text("App Info")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                SettingRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy"
                ) {
                    Button("View") {
                        if let url = URL(string: "https://telegra.ph/Privacy-Policy-for-Speed-Math-08-07") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                
                SettingRow(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Rate SpeedMath on the App Store"
                ) {
                    Button("Rate") {
                        rateApp()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                
                SettingRow(
                    icon: "info.circle.fill",
                    title: "About",
                    subtitle: "App version and information"
                ) {
                    Button("About") {
                        showAbout = true
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let content: Content
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        color: Color = .primary,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("SpeedMath respects your privacy. This app does not collect, store, or transmit any personal information to external servers.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                    
                    Text("Data Storage")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("All game data, including scores, progress, and settings, are stored locally on your device using UserDefaults. This data is not shared with any third parties.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                    
                    Text("Analytics")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("SpeedMath does not use any analytics or tracking services. Your gameplay data remains private and local to your device.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App icon
                Image(systemName: "function")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .frame(width: 120, height: 120)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                
                VStack(spacing: 8) {
                    Text("SpeedMath")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    Text("Version 1.0.0")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Text("Train your mental math skills with SpeedMath! Challenge yourself with different game modes, track your progress, and improve your calculation speed.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Features:")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "timer", text: "Time Attack Mode")
                        FeatureRow(icon: "number.circle.fill", text: "Count Challenge Mode")
                        FeatureRow(icon: "flame.fill", text: "Daily Streak Mode")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Progress Tracking")
                        FeatureRow(icon: "star.fill", text: "Level Progression")
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
    }
}

#Preview {
    SettingsView(viewModel: GameViewModel())
} 
