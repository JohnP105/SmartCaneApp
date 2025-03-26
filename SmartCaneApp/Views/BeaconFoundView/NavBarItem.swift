import SwiftUI

struct NavBarItem<Icon: View>: View {
    var icon: Icon
    var label: [String]
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) { // Reduced spacing for a tighter look
                icon
                VStack(alignment: .center, spacing: 2) { // Stacks text properly
                    ForEach(label, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 15, weight: .medium))
                    }
                }
            }
            .frame(maxWidth: .infinity) // Ensures even spacing across items
            .foregroundColor(.black)
        }
    }
}
