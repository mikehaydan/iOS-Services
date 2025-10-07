//
//  AlertModifier.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

struct AlertModifier: ViewModifier {

    @Binding var model: AlertModel?

    func body(content: Content) -> some View {
        content
            .alert(
                model?.title ?? "",
                isPresented: Binding(
                    get: { self.model != nil },
                    set: { newValue in
                        if !newValue {
                            self.model = nil
                        }
                    }
                ),
                actions: {
                    Button("OK", role: .cancel, action: {
                        self.model = nil
                    })
                }, message: {
                    if let msg = model?.message {
                        Text(msg)
                    }
                }
            )
    }
}

extension View {
    func alert(model: Binding<AlertModel?>) -> some View {
        self.modifier(AlertModifier(model: model))
    }
}
