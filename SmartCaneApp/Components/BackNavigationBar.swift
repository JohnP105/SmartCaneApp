import SwiftUI

struct BackNavigationBar: View {
    let action: () -> Void

    private let backNavigationFrameHeight = 155
    var body: some View {
        HStack {
            Button(action: action) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)

                    Text("Back")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color.blue)
        .frame(height: CGFloat(backNavigationFrameHeight))
        .edgesIgnoringSafeArea(.top)
    }
}
