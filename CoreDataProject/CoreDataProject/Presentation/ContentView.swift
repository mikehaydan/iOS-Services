//
//  ContentView.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//

import SwiftUI

struct ContentView: View {
    
    enum TextFieldFous {
        case name
        case surname
    }
    
    @State var name = "Name 1"
    @State var surname = "Surname 1"
    
    @FocusState var textFieldFouce: TextFieldFous?
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .padding()
                .overlay(
                    Rectangle()
                        .strokeBorder(lineWidth: 2)
                )
                .focused($textFieldFouce, equals: .name)
            TextField("Surname", text: $surname)
                .padding()
                .overlay(
                    Rectangle()
                        .strokeBorder(lineWidth: 2)
                )
                .focused($textFieldFouce, equals: .surname)
            
            HStack(spacing: 4) {
                Button(action: {
                    viewModel.save(name: name, surname: surname)
                }, label: {
                    Text("Save")
                })
                
                Button(action: {
                    viewModel.getAllUsers()
                }, label: {
                    Text("Get All")
                })
                
                Button(action: {
                    viewModel.delete()
                }, label: {
                    Text("Delete All")
                })
                
                Button(action: {
                    viewModel.update()
                }, label: {
                    Text("Update All")
                })
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 20)
            
            Text("Core data:")
                .padding(16)
            
            List(viewModel.users, id: \.id) { user in
                Text("Name: '\(user.name)' and Surname: '\(user.surname)'")
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
