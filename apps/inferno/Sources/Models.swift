import SwiftUI

/// App-drawn poster the shaders sample. Not an Inferno type.
struct ShaderPoster: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.46, blue: 0.16),
                    Color(red: 0.62, green: 0.12, blue: 0.42),
                    Color(red: 0.08, green: 0.14, blue: 0.42),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 140, height: 140)
                .offset(x: 180, y: -160)

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)

                Text("Inferno")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text("Metal color, distortion, and transition effects.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}
