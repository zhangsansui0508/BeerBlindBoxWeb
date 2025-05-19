import TokamakShim

struct ContentView: View {
    var body: some View {
        Page1()
    }
}

struct Page1: View {
    @State private var navigateToPage2 = false
    @State private var scale: CGFloat = 0.95
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景图片
                Image("pagg1背景")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                // 右上角入口
                Image("入口")
                    .resizable()
                    .frame(width: 72, height: 22)
                    .scaleEffect(scale)
                    .position(x: 300, y: 50)
                    .onTapGesture {
                        navigateToPage2 = true
                    }
                    .onAppear {
                        // 开始循环动画
                        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            scale = 1.1
                        }
                    }
            }
            .navigationDestination(isPresented: $navigateToPage2) {
                Page2()
            }
        }
    }
}

struct Page2: View {
    @State private var showCard = false
    @State private var currentWineIndex = 0
    @State private var wineImages = ["酒1", "酒2", "酒3"]
    @State private var showBlindBoxCard = true
    @State private var isFlying = false
    @State private var showToast = false
    @State private var currentCardIndex = 0
    @State private var isAnimating = false
    @State private var showConfetti = false
    @State private var isFirstCard = true
    @State private var usedCardIndices: [Int] = []
    @Environment(\.dismiss) private var dismiss
    
    private let cardImages = ["盲盒卡片1", "盲盒卡片2", "盲盒卡片3", "盲盒卡片4", "盲盒卡片5"]
    
    private func getRandomCardIndex(excluding currentIndex: Int) -> Int {
        // 如果还没有遍历完所有卡片
        if usedCardIndices.count < cardImages.count {
            // 从未使用的卡片中随机选择
            var availableIndices = Array(0..<cardImages.count)
            availableIndices.removeAll { usedCardIndices.contains($0) }
            let newIndex = availableIndices.randomElement()!
            usedCardIndices.append(newIndex)
            return newIndex
        } else {
            // 已经遍历完所有卡片，完全随机选择
            var newIndex: Int
            repeat {
                newIndex = Int.random(in: 0..<cardImages.count)
            } while newIndex == currentIndex
            return newIndex
        }
    }
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("pagg2背景")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // 返回按钮
            Button(action: {
                dismiss()
            }) {
                Image("返回")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .position(x: 20 + 10, y: 31 + 10)
            
            if !showCard {
                // 扫码区域
                VStack(spacing: 20) {
                    ZStack {
                        // 扫码背景
                        Image("扫码背景")
                            .resizable()
                            .frame(width: 195, height: 195)
                        
                        // 酒瓶图片
                        Image(wineImages[currentWineIndex])
                            .resizable()
                            .frame(width: 150, height: 150)
                            .onAppear {
                                // 开始定时切换图片
                                startWineImageTimer()
                            }
                        
                        // 扫描动画
                        ScanAnimationView()
                    }
                    
                    // 提示文字
                    HStack(spacing: 0) {
                        Text("酒瓶正在输入中")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                        LoadingDots()
                    }
                }
                .offset(y: -60)
            } else {
                // 盲盒卡片和换一换按钮
                VStack(spacing: 32) {
                    // 盲盒卡片区域（固定高度）
                    ZStack {
                        if showBlindBoxCard {
                            BlindBoxCard(cardImage: cardImages[currentCardIndex], shouldAnimate: true, isNewCard: !isFlying)
                                .scaleEffect(isFlying ? 0.3 : 1.0)
                                .offset(x: isFlying ? -480 : 0, y: isFlying ? -699 : 0)
                                .opacity(isFlying ? 0 : 1)
                                .animation(.easeIn(duration: 0.5), value: isFlying)
                                .id(currentCardIndex)
                        }
                        
                        // 粒子效果
                        if showConfetti {
                            ConfettiView()
                                .frame(width: 320, height: 466)
                                .cornerRadius(16)
                        }
                    }
                    .frame(height: 466)
                    
                    // 换一换按钮
                    Button(action: {
                        guard !isAnimating else { return }
                        isAnimating = true
                        
                        // 执行飞出动画
                        withAnimation(.easeIn(duration: 0.5)) {
                            isFlying = true
                        }
                        
                        // 延迟更新卡片
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            currentCardIndex = getRandomCardIndex(excluding: currentCardIndex)
                            isFlying = false
                            isAnimating = false
                            
                            // 立即显示粒子效果
                            showConfetti = true
                            
                            // 1秒后隐藏粒子效果
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showConfetti = false
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image("换一换")
                                .resizable()
                                .frame(width: 18, height: 18)
                            Text("换一换")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // 两个按钮
                    HStack(spacing: 12) {
                        // 保存按钮
                        Button(action: {
                            // 显示Toast提示
                            withAnimation {
                                showToast = true
                            }
                            // 2秒后隐藏Toast
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image("下载")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("保存")
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                            }
                            .frame(width: (320 - 12) / 2, height: 44)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FFE74D"),
                                        Color(hex: "#FFE74D")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(40)
                        }
                        
                        // 分享按钮
                        Button(action: {
                            // 按钮点击事件
                        }) {
                            HStack(spacing: 6) {
                                Image("分享")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("分享")
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                            }
                            .frame(width: (320 - 12) / 2, height: 44)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FFE74D"),
                                        Color(hex: "#FFE74D")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(40)
                        }
                    }
                }
                .offset(y: -10)
            }
            
            // Toast提示
            if showToast {
                ToastView(message: "已保存到系统相册")
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // 2.4秒后切换到卡片
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation {
                    showCard = true
                }
                
                // 第一张卡片显示时添加粒子效果
                if isFirstCard {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showConfetti = true
                        
                        // 1秒后隐藏粒子效果
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showConfetti = false
                            isFirstCard = false
                        }
                    }
                }
            }
        }
    }
    
    // 定时切换酒瓶图片
    private func startWineImageTimer() {
        // 每0.5秒切换一次图片
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                // 随机选择下一张图片，确保不重复
                var nextIndex: Int
                repeat {
                    nextIndex = Int.random(in: 0..<wineImages.count)
                } while nextIndex == currentWineIndex
                
                currentWineIndex = nextIndex
            }
        }
    }
}

// 扫描动画视图
struct ScanAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            Image("扫描线")
                .resizable()
                .frame(width: geometry.size.width, height: 6)
                .position(x: geometry.size.width / 2,
                         y: isAnimating ? geometry.size.height : 0)
                .animation(
                    Animation.linear(duration: 2.1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
        .frame(width: 195, height: 195)
    }
}

// 粒子结构
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var scale: CGFloat
    var rotation: Double
    var velocity: CGPoint
    var gravity: CGFloat
    var shape: ParticleShape
    var swingPhase: Double
}

// 粒子形状枚举
enum ParticleShape {
    case rectangle
    case triangle
    case diamond
    
    @ViewBuilder
    func view(color: Color) -> some View {
        switch self {
        case .rectangle:
            Rectangle()
                .fill(color)
        case .triangle:
            Triangle()
                .fill(color)
        case .diamond:
            Diamond()
                .fill(color)
        }
    }
}

// 三角形形状
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// 菱形形状
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// 礼花粒子视图
struct ConfettiView: View {
    @State private var particles: [Particle] = []
    let colors: [Color] = [
        Color(hex: "#FF69B4"),
        Color(hex: "#FFD700"),
        Color(hex: "#1E90FF")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    particle.shape.view(color: particle.color)
                        .frame(width: 6, height: 6)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(particle.position)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        for _ in 0..<60 {
            let angle = Double.random(in: 0..<360)
            let distance = Double.random(in: 75...225)
            let velocity = CGPoint(
                x: cos(angle * .pi / 180) * distance,
                y: sin(angle * .pi / 180) * distance
            )
            
            particles.append(Particle(
                position: center,
                color: colors.randomElement()!,
                scale: CGFloat.random(in: 0.75...2.25),
                rotation: Double.random(in: 0...360),
                velocity: velocity,
                gravity: CGFloat.random(in: 0.5...1.5),
                shape: [.rectangle, .triangle, .diamond].randomElement()!,
                swingPhase: Double.random(in: 0...2 * .pi)
            ))
        }
        
        // 爆炸阶段
        withAnimation(.easeOut(duration: 0.5)) {
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x
                particles[i].position.y += particles[i].velocity.y
            }
        }
        
        // 下落阶段
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 1.0)) {
                for i in particles.indices {
                    // 添加重力效果
                    particles[i].position.y += 200 * particles[i].gravity
                    
                    // 添加摇摆效果
                    let swingAmount = 30.0
                    let swingFrequency = 2.0
                    let time = 1.0
                    let swing = swingAmount * sin(swingFrequency * time + particles[i].swingPhase)
                    particles[i].position.x += CGFloat(swing)
                    
                    // 添加旋转效果
                    particles[i].rotation += Double.random(in: -180...180)
                    
                    // 逐渐消失
                    particles[i].scale = 0
                }
            }
        }
    }
}

// 盲盒卡片视图
struct BlindBoxCard: View {
    @State private var isFlipped = false
    let cardImage: String
    let shouldAnimate: Bool
    let isNewCard: Bool
    
    init(cardImage: String, shouldAnimate: Bool = true, isNewCard: Bool = false) {
        self.cardImage = cardImage
        self.shouldAnimate = shouldAnimate
        self.isNewCard = isNewCard
    }
    
    var body: some View {
        ZStack {
            // 正面（白色）
            Image(cardImage)
                .resizable()
                .frame(width: 320, height: 466)
                .cornerRadius(16)
                .opacity(isFlipped ? 0 : 1)
            
            // 背面（灰色）
            Image(cardImage)
                .resizable()
                .frame(width: 320, height: 466)
                .cornerRadius(16)
                .scaleEffect(x: -1, y: 1)
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onAppear {
            if shouldAnimate {
                if isNewCard {
                    // 新卡片直接显示正面，然后执行翻转
                    isFlipped = false
                    withAnimation(Animation.linear(duration: 0.3)) {
                        isFlipped = true
                    }
                } else {
                    // 原有卡片的动画逻辑
                    withAnimation(Animation.linear(duration: 0.3)) {
                        isFlipped = true
                    }
                }
            } else {
                isFlipped = true
            }
        }
    }
}

// 简单的省略号动画视图
struct LoadingDots: View {
    @State private var dotCount = 0
    
    var body: some View {
        Text(String(repeating: ".", count: dotCount))
            .font(.system(size: 17))
            .foregroundColor(.white)
            .onAppear {
                // 使用Timer定时更新点的数量
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    dotCount = (dotCount + 1) % 4
                }
            }
    }
}

// Toast提示视图
struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
    }
}

// 颜色扩展，用于支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 