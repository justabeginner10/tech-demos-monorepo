import SwiftUI

struct RecipeCard: View {
    let placeholder: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.indigo.opacity(0.25))
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.mint)
            }
            .frame(height: 130)

            Text("A slower morning")
                .font(.title2.bold())
            Text("Pour-over coffee, warm toast, and ten minutes for yourself.")
                .foregroundStyle(.secondary)
            Label("10 min · Easy", systemImage: "clock")
                .font(.caption)
        }
        .redacted(reason: placeholder ? .placeholder : [])
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: placeholder ? .ignore : .combine)
        .accessibilityLabel(placeholder ? "Loading recipe" : "A slower morning. Pour-over coffee, warm toast, and ten minutes for yourself. Ten minutes. Easy.")
    }
}
