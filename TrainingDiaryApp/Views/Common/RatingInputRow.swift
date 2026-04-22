import SwiftUI

struct RatingInputRow: View {
    let title: String
    let range: ClosedRange<Int>
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value)")
                    .fontWeight(.semibold)
            }

            Stepper("", value: $value, in: range)
                .labelsHidden()
        }
    }
}
