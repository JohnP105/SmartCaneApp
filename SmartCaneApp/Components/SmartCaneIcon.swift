import SwiftUI

struct SmartCaneIcon: View {
    var body: some View {
        // Screen Width & Height
        let screenWidth = UIScreen.main.bounds.width

        
        // Icons size
        let iconWidth = screenWidth * 0.5
        let iconHeight = screenWidth * 0.2
        
        
        ZStack {
            // Overlapping Ellipses
            Ellipse()
                .fill(Color.green.opacity(0.8))
                .frame(width: iconWidth, height: iconHeight)
                .rotationEffect(.degrees(135))
                .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                
            Ellipse()
                .fill(Color.yellow.opacity(0.9))
                .frame(width: iconWidth, height: iconHeight)
                .rotationEffect(.degrees(90))
                .shadow(color: Color.yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                
            Ellipse()
                .fill(Color.red.opacity(0.8))
                .frame(width: iconWidth, height: iconHeight)
                .rotationEffect(.degrees(45))
                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// Preview
#Preview {
    SmartCaneIcon()
}
