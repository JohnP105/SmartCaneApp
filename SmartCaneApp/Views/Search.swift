import SwiftUI

struct Search: View {
    @State private var animateRipple = false
    @State private var animateDots = false

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let circleSize = screenWidth * 0.6

        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(1.0)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            // Ripple Effect Animation
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: circleSize * (1.5 + CGFloat(index) * 0.5),
                               height: circleSize * (1.5 + CGFloat(index) * 0.5))
                        .scaleEffect(animateRipple ? 1.3 : 1)
                        .opacity(animateRipple ? 0 : 1)
                        .animation(Animation.easeOut(duration: 1.8).repeatForever().delay(Double(index) * 0.3), value: animateRipple)
                }
            }
            .onAppear {
                animateRipple = true
            }

            // Centered Icon with Circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(1), lineWidth: 2)
                    .fill(Color.blue.opacity(0.9))
                    .frame(width: circleSize, height: circleSize)

                SmartCaneIcon(width: circleSize * 0.6, height: circleSize * 0.3)
            }

            VStack {
                Spacer()
                
                // Loading Dots Animation
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animateDots ? 1.2 : 1)
                            .opacity(animateDots ? 0.5 : 1)
                            .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2), value: animateDots)
                    }
                }
                .padding(.bottom, 5)
                .onAppear {
                    animateDots = true
                }

                // Searching Text
                Text("Searching")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Please Wait")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            .offset(y: screenHeight * 0.3)

            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Action to close or dismiss the view
                    }) {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

// Preview
#Preview {
    Search()
}
