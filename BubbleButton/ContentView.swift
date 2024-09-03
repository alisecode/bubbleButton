//
//  ContentView.swift
//  BubbleButton
//
//  Created by Alisa Serhiienko on 02.09.2024.
//

import SwiftUI


struct BubbleButton: View {
    @State private var toggleState: ToggleState = .inactive
    let layout: VisualConfiguration
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            FloatingHearts(layout: layout, toggleState: $toggleState, colorScheme: colorScheme)
            
            ZStack {
                FlowerView(layout: layout, toggleState: $toggleState, colorScheme: colorScheme)
                
                VStack {
                    Image("securityShield")
                        .padding(.bottom, 12)
                    Text(toggleState.label)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(width: 220, height: 200)
            .foregroundColor(buttonForegroundColor)
            .onTapGesture { handleToggleAction() }
        }
        .frame(width: 220, height: 200)
    }
    
    private func handleToggleAction() {
        withAnimation {
            toggleState = switch toggleState {
            case .inactive: .processing
            case .processing: .active
            case .active: .inactive
            }
        }
    }
    
    private var buttonForegroundColor: Color {
        switch toggleState {
        case .inactive: return colorScheme.inactive
        case .processing: return colorScheme.processing
        case .active: return colorScheme.active
        }
    }
}


enum ToggleState {
    case inactive, processing, active
    
    var label: String {
        switch self {
        case .inactive: return "TAP TO LIKE"
        case .processing: return "THANK YOU!"
        case .active: return "TAP TO UNLIKE"
        }
    }
}

struct VisualConfiguration {
    var petals: [FlowerPetal] = []
    var hearts: [FloatingHeart] = []
    
    struct FlowerPetal {
        var initialAngle: CGFloat = .zero
        var displacement: CGPoint = .zero
        var spinVelocity: Double = 1
    }
    
    struct FloatingHeart {
        var area: CGRect = .zero
        var appearanceDelay: Double = .zero
        var lowestOpacity: Double = 0
        var peakOpacity: Double = 1
    }
}

struct FlowerView: View {
    let layout: VisualConfiguration
    @Binding var toggleState: ToggleState
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            ForEach(layout.petals.indices, id: \.self) { index in
                PetalShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [colorScheme.gradientStart, colorScheme.gradientEnd]),
                            startPoint: .init(x: -0.49, y: 0.5),
                            endPoint: .init(x: 0.4, y: 1.59)
                        )
                    )
                    .frame(width: 220, height: 200)
                    .opacity(0.2)
                    .rotationEffect(.degrees(layout.petals[index].initialAngle))
                    .offset(x: layout.petals[index].displacement.x, y: layout.petals[index].displacement.y)
                    .modifier(SpinningEffect(velocity: spinVelocity, clockwise: index.isMultiple(of: 2)))
            }
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [colorScheme.gradientStart, colorScheme.gradientEnd]),
                        startPoint: .init(x: 0.4, y: 1.59),
                        endPoint: .init(x: -0.49, y: 0.5)
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(coreOpacity)
        }
    }
    
    private var coreOpacity: Double {
        switch toggleState {
        case .inactive: return 0.4
        case .processing, .active: return 1.0
        }
    }
    
    private var spinVelocity: Double {
        switch toggleState {
        case .inactive, .processing: return 1.0
        case .active: return 0.4
        }
    }
}

struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 220.08, y: 76))
            path.addCurve(to: CGPoint(x: 100.58, y: 200), control1: CGPoint(x: 220.08, y: 131.228), control2: CGPoint(x: 155.808, y: 200))
            path.addCurve(to: CGPoint(x: 0.58, y: 100), control1: CGPoint(x: 45.3512, y: 200), control2: CGPoint(x: 0.58, y: 155.228))
            path.addCurve(to: CGPoint(x: 100.58, y: 0), control1: CGPoint(x: 0.58, y: 44.7715), control2: CGPoint(x: 45.3512, y: 0))
            path.addCurve(to: CGPoint(x: 220.08, y: 76), control1: CGPoint(x: 155.808, y: 0), control2: CGPoint(x: 220.08, y: 20.7715))
            path.closeSubpath()
        }
    }
}

struct SpinningEffect: ViewModifier {
    let velocity: Double
    let clockwise: Bool
    @State private var angle: Angle = .zero
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(angle)
            .onAppear {
                withAnimation(.linear(duration: velocity * 3.5).repeatForever(autoreverses: false)) {
                    angle = .degrees(clockwise ? 360 : -360)
                }
            }
    }
}

struct FloatingHearts: View {
    let layout: VisualConfiguration
    @Binding var toggleState: ToggleState
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            ForEach(layout.hearts.indices, id: \.self) { index in
                HeartView(heart: layout.hearts[index], isFloating: toggleState == .processing, colorScheme: colorScheme)
            }
        }
    }
}

struct HeartView: View {
    let heart: VisualConfiguration.FloatingHeart
    let isFloating: Bool
    let colorScheme: ColorScheme
    
    @State private var opacity: Double = 0
    @State private var verticalOffset: CGFloat = 0
    @State private var horizontalOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HeartShape()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [colorScheme.gradientStart, colorScheme.gradientEnd]),
                    startPoint: .init(x: -0.49, y: 0.5),
                    endPoint: .init(x: 0.4, y: 1.59)
                )
            )
            .frame(width: heart.area.width, height: heart.area.height)
            .position(x: heart.area.midX, y: heart.area.midY)
            .opacity(opacity)
            .offset(x: horizontalOffset, y: verticalOffset)
            .scaleEffect(scale)
            .shadow(color: colorScheme.gradientStart.opacity(0.3), radius: 5, x: 0, y: 0)
            .onAppear {
                if isFloating {
                    animateHeart()
                }
            }
            .onChange(of: isFloating) { newValue in
                if newValue {
                    animateHeart()
                } else {
                    resetAnimation()
                }
            }
    }
    
    private func animateHeart() {
        let duration = Double.random(in: 4...6)
        let delay = heart.appearanceDelay * 0.5
        
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
            opacity = heart.peakOpacity
            verticalOffset = -100 - CGFloat.random(in: 0...50)
            horizontalOffset = CGFloat.random(in: -15...15)
        }
        
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            scale = 1.1
        }
    }
    
    private func resetAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0
            verticalOffset = 0
            horizontalOffset = 0
            scale = 1.0
        }
    }
}





struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { path in
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.25))
            
            path.addCurve(
                to: CGPoint(x: 0, y: height * 0.35),
                control1: CGPoint(x: width * 0.35, y: height * 0.1),
                control2: CGPoint(x: 0, y: height * 0.2)
            )
            
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height),
                control1: CGPoint(x: 0, y: height * 0.6),
                control2: CGPoint(x: width * 0.25, y: height * 0.9)
            )
            
            path.addCurve(
                to: CGPoint(x: width, y: height * 0.35),
                control1: CGPoint(x: width * 0.75, y: height * 0.9),
                control2: CGPoint(x: width, y: height * 0.6)
            )
            
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.25),
                control1: CGPoint(x: width, y: height * 0.2),
                control2: CGPoint(x: width * 0.65, y: height * 0.1)
            )
        }
    }
}





struct BubbleButton_Previews: PreviewProvider {
    static var previews: some View {
        BubbleButton(layout: previewLayout, colorScheme: vibrantEnergyScheme)
    }
    
    static var previewLayout: VisualConfiguration {
        var layout = VisualConfiguration()
        layout.petals = [
            .init(initialAngle: 0, displacement: CGPoint(x: 8, y: -2), spinVelocity: 0.7),
            .init(initialAngle: 70, displacement: CGPoint(x: 7, y: 7), spinVelocity: 0.5),
            .init(initialAngle: 60, displacement: CGPoint(x: -12, y: 4), spinVelocity: 0.5),
            .init(initialAngle: 5, displacement: CGPoint(x: -15, y: 8), spinVelocity: 0.3),
            .init(initialAngle: -10, displacement: CGPoint(x: -11, y: 0), spinVelocity: 0.2)
        ]
        
        layout.hearts = [
            .init(area: CGRect(x: 10, y: 170, width: 18, height: 18), appearanceDelay: 0.2, peakOpacity: 0.4),
            .init(area: CGRect(x: -20, y: 80, width: 25, height: 25), appearanceDelay: 0.4, peakOpacity: 0.7),
            .init(area: CGRect(x: 15, y: 20, width: 30, height: 30), appearanceDelay: 0.3),
            .init(area: CGRect(x: 200, y: 180, width: 22, height: 22), appearanceDelay: 0.5, peakOpacity: 0.4),
            .init(area: CGRect(x: 210, y: 70, width: 20, height: 20), appearanceDelay: 0.6),
                .init(area: CGRect(x: 95, y: 190, width: 15, height: 15), appearanceDelay: 0.1, peakOpacity: 0.6),
                .init(area: CGRect(x: 105, y: 195, width: 20, height: 20), appearanceDelay: 0.3, peakOpacity: 0.5),
                .init(area: CGRect(x: 115, y: 185, width: 18, height: 18), appearanceDelay: 0.2, peakOpacity: 0.7),
                .init(area: CGRect(x: 90, y: 5, width: 22, height: 22), appearanceDelay: 0.4, peakOpacity: 0.6),
                .init(area: CGRect(x: 110, y: 10, width: 16, height: 16), appearanceDelay: 0.5, peakOpacity: 0.5),
                .init(area: CGRect(x: 130, y: 8, width: 20, height: 20), appearanceDelay: 0.3, peakOpacity: 0.7),
                .init(area: CGRect(x: -5, y: 100, width: 18, height: 18), appearanceDelay: 0.2, peakOpacity: 0.5),
                .init(area: CGRect(x: -10, y: 120, width: 15, height: 15), appearanceDelay: 0.4, peakOpacity: 0.6),
                .init(area: CGRect(x: 205, y: 100, width: 20, height: 20), appearanceDelay: 0.3, peakOpacity: 0.7),
                .init(area: CGRect(x: 215, y: 120, width: 16, height: 16), appearanceDelay: 0.5, peakOpacity: 0.5)
        ]
        
        return layout
    }
    
    static var vibrantEnergyScheme: ColorScheme {
        ColorScheme(
            inactive: Color(hex: 0xFFE4E1),
            processing: Color(hex: 0xFFE4E1),
            active: Color(hex: 0xFFE4E1),
            gradientStart: Color(hex: 0xFF1493),
            gradientEnd: Color(hex: 0xFFA07A)
        )
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct ColorScheme {
    let inactive: Color
    let processing: Color
    let active: Color
    let gradientStart: Color
    let gradientEnd: Color
}


struct ContentView: View {
    var body: some View {
        BubbleButton(layout: BubbleButton_Previews.previewLayout, colorScheme: BubbleButton_Previews.vibrantEnergyScheme)
    }
}
