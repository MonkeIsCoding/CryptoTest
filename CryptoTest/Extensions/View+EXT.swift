//
//  View+EXT.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import SwiftUI

extension View {
    func hairlineField() -> some View {
        modifier(HairlineFieldModifier())
    }

    func filledButton() -> some View {
        buttonStyle(FilledCapsuleButtonStyle())
    }

    func hairlineButton(color: Color) -> some View {
        buttonStyle(HairlineOutlinedButtonStyle(color: color))
    }
}
