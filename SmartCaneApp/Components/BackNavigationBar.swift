import SwiftUI

struct BackNavigationBar: View {
    let title: String
    let action: () -> Void

    var body: some View {
        ZStack {
            HStack {
                Button(action: action) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(.white)

                        Text("Back")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }

            // Centered Title
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color.blue)
        .frame(height: CGFloat(155))
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    BackNavigationBar(title: "Beacon Found") {
    }
    .environmentObject(NavigationViewModel())
    Spacer()
}
