import SwiftUI
import AVFoundation

struct BeaconFound: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel = BeaconFoundViewModel()

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let circleSize = screenWidth * 0.7

        VStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 65) {
                    // Close Button ("X" to go back)
                    HStack {
                        Spacer()
                        Button(action: {
                            navViewModel.navigate(to: .homeSearch(startInSearchMode: false))
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                )
                        }
                        .padding(.trailing, 20)
                    }

                    // Location Info
                    VStack(spacing: 5) {
                        Text("You are currently in the")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.9))

                        Text("Library")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .frame(height: 80)

                    // SmartCane Icon Inside a Circle
                    ZStack {
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.65))
                                    .frame(width: circleSize, height: circleSize)
                                SmartCaneIcon()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .task {
                            try? await Task.sleep(nanoseconds: 200_000_000)
                        }
                        .allowsHitTesting(false)
                    }

                    Spacer() // Pushes everything up, keeping the nav bar at the bottom
                }
                .padding(.bottom, 80) // Ensures proper spacing above nav bar
            }

            // Bottom Navigation Bar - Always Fixed at the Bottom
            HStack {
                navBarItem(icon: "location.circle", label: ["My", "Location"], message: "You are currently in the library")
                    .frame(maxWidth: .infinity)
                
                navBarItem(icon: "arrow.triangle.branch", label: ["Around", "Me"], message: "You are near room 101")
                    .frame(maxWidth: .infinity)
                
                navBarItem(icon: "mappin.and.ellipse", label: ["Nearby", "Beacons"], message: "You are around the entrance")
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 70)
            .padding(.top, 25)
            .background(Color.gray.opacity(0.2))
        }
        .navigationBarBackButtonHidden(true)
    }

    // Navigation Bar Item Function with Voice Feedback
    private func navBarItem(icon: String, label: [String], message: String) -> some View {
        Button(action: {
            viewModel.speak(message)
        }) {
            VStack(spacing: 10) { // Reduced spacing for a tighter look
                Image(systemName: icon)
                    .font(.system(size: 45))
                    .frame(height: 45)

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

// Preview
#Preview {
    BeaconFound()
        .environmentObject(NavigationViewModel())
}
