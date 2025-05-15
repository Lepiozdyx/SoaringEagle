import SwiftUI

struct AchievementView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AchievementViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Фон приложения
            Color.eagleBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Верхняя панель с кнопкой назад и счетчиком монет
                HStack {
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3)
                    }
                    
                    Spacer()
                    
                    // Счетчик монет
                    HStack {
                        Text("\(appViewModel.coins)")
                            .gameFont(20)
                        
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Заголовок
                Text("ДОСТИЖЕНИЯ")
                    .gameFont(40)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    .padding(.top, 10)
                
                // Список достижений
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(viewModel.achievements) { achievement in
                            AchievementItemView(
                                achievement: achievement,
                                isCompleted: viewModel.isAchievementCompleted(achievement.id),
                                isNotified: viewModel.isAchievementNotified(achievement.id),
                                onClaim: {
                                    svm.play()
                                    viewModel.claimReward(for: achievement.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
            
            // Запускаем анимации с разной задержкой
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    let isCompleted: Bool
    let isNotified: Bool
    let onClaim: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Фон элемента достижения
            RoundedRectangle(cornerRadius: 15)
                .stroke(isCompleted ? Color.yellow : Color.white.opacity(0.6), lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                )
            
            HStack {
                // Иконка достижения
                Image(achievement.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.eaglePrimary)
                            .shadow(color: isCompleted ? .yellow.opacity(0.7) : .black.opacity(0.5), radius: 5)
                    )
                    .scaleEffect(animate && isCompleted && !isNotified ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
                    .onAppear {
                        animate = true
                    }
                
                // Информация о достижении
                VStack(alignment: .leading, spacing: 5) {
                    Text(achievement.title)
                        .gameFont(18)
                    
                    Text(achievement.description)
                        .gameFont(12)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                .padding(.leading, 5)
                
                Spacer()
                
                // Кнопка получения награды или статус
                VStack {
                    if isCompleted {
                        if isNotified {
                            // Статус "Выполнено"
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.green)
                        } else {
                            // Кнопка получения награды
                            Button(action: onClaim) {
                                HStack {
                                    Text("+\(achievement.reward)")
                                        .gameFont(14)
                                    
                                    Image("coin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.yellow)
                                        .shadow(color: .black.opacity(0.5), radius: 3)
                                )
                                .scaleEffect(animate ? 1.05 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: animate
                                )
                            }
                        }
                    } else {
                        // Статус "Не выполнено"
                        Image(systemName: "lock.fill")
                            .resizable()
                            .frame(width: 20, height: 25)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 80)
            }
            .padding()
        }
        .frame(maxWidth: 350, minHeight: 100)
    }
}

#Preview {
    AchievementView()
        .environmentObject(AppViewModel())
}

