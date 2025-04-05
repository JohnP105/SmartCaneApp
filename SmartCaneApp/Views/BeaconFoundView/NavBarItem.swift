import SwiftUI

struct NavBarItem<Icon: View>: View {
    var icon: Icon
    var label: [String]
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                icon
                    .font(.system(size: 50))
                    .frame(height: 50)
                VStack(alignment: .center, spacing: 2) {
                    ForEach(label, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 15, weight: .medium))
                    }
                }
            }
            .foregroundColor(.black)
            .frame(maxHeight: .infinity)
            .padding(.top, 30)
        }
    }
}
