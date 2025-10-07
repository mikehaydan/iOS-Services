//
//  Flow2SubView.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

struct Flow2SubView: View {

    @StateObject var viewModel: Flow2SubflowViewModel

    init(makeViewModel: @autoclosure @escaping () -> Flow2SubflowViewModel) {
        _viewModel = StateObject(wrappedValue: makeViewModel())
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Hello, World!")
            Button(action: {
                viewModel.showMessage()
            }, label: {
                Text("Show Message")
            })
            Spacer()
        }
    }
}

 #Preview {
     Flow2SubView(
        makeViewModel: Flow2SubflowViewModel(
            coordinator: Flow2CoordinatorPreview()
        )
     )
 }
