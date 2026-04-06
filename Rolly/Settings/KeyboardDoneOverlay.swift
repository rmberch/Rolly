//
//  KeyboardDoneOverlay.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI
import Combine

/// Observes keyboard show/hide notifications and exposes visibility + height.
final class KeyboardObserver: ObservableObject {
    @Published var isVisible = false
    @Published var height: CGFloat = 0

    private var bag = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                self.isVisible = true
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.height = frame.height
                }
            }
            .store(in: &bag)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.isVisible = false
                self?.height = 0
            }
            .store(in: &bag)
    }
}

/// ViewModifier that shows a single floating "Done" button while keyboard is visible.
struct KeyboardDoneOverlay: ViewModifier {
    @StateObject private var k = KeyboardObserver()

    func body(content: Content) -> some View {
        ZStack {
            content

            if k.isVisible {
                // Floating button placed bottom-right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                        }) {
                            // You can change this to "Done" or any icon you prefer
                            Text("Done")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                        }
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .shadow(radius: 3)
                        .padding(.trailing, 16)
                        .padding(.bottom, 13)
                    }
                }
                .animation(.easeInOut, value: k.isVisible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

extension View {
    /// Apply this near the top of the screen (only once) to display a single Done control when keyboard is visible.
    func keyboardDoneOverlay() -> some View {
        modifier(KeyboardDoneOverlay())
    }
}
