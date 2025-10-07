//
//  Flow1SubView.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

struct Flow1SubView: View {

    @StateObject var viewModel: Flow1SubflowViewModel

    init(makeViewModel: @autoclosure @escaping () -> Flow1SubflowViewModel) {
        print("Flow1SubView init")
        _viewModel = StateObject(wrappedValue: makeViewModel())
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Flow1SubView index: \(viewModel.index)")
            Button(action: {
                viewModel.showNext()
            }, label: {
                Text("Show Next")
            })
            Button(action: {
                viewModel.showMessage()
            }, label: {
                Text("Show Message")
            })
        }
    }
}

 #Preview {
     Flow1SubView(
        makeViewModel: Flow1SubflowViewModel(
            coordinator: Flow1CoordinatorPreview(), index: 22
        )
     )
 }
