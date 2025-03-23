import SwiftUI

struct SmartCaneIcon: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
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
    }
}

// Preview
#Preview {
    VStack(spacing: 40) {
        SmartCaneIcon(width: 150, height: 75)
    }
}
