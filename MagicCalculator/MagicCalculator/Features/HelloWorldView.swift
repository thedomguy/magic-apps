import SwiftUI

struct HelloWorldView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                Text("Hello World")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    HelloWorldView()
}
