import SwiftUI

struct Test: View {
    let width: CGFloat
    let height: CGFloat
    let showBackgroundCircle: Bool // toggle circle visibility
    
    var body: some View {
        let screenHeight = UIScreen.main.bounds.height
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(1.0)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 70) {
                Text("SmartCane")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                // SmartCane Icon
                ZStack {
                    // Background Circle
                    if showBackgroundCircle {
                        Circle()
//                            .stroke(Color.white.opacity(1), lineWidth: 3)
                            .fill(Color.blue.opacity(1))
                            .frame(width: width * 1.8, height: width * 1.8)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                    
                    // Overlapping Ellipses
                    Ellipse()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: width, height: height)
                        .rotationEffect(.degrees(135))
                        .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)

                    Ellipse()
                        .fill(Color.yellow.opacity(0.9))
                        .frame(width: width, height: height)
                        .rotationEffect(.degrees(90))
                        .shadow(color: Color.yellow.opacity(0.3), radius: 4, x: 0, y: 2)

                    Ellipse()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: width, height: height)
                        .rotationEffect(.degrees(45))
                        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                
                VStack(spacing: 5) {
                    Text("Find SmartCane beacons near you!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Text("Make sure your device’s Bluetooth is on")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, screenHeight * 0.1)
        }
    }
}

// Preview
#Preview {
    VStack(spacing: 40) {
        Test(width: 150, height: 75, showBackgroundCircle: true)
    }
}
