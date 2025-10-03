//
//  ContentView.swift
//  RestAPIProject
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import SwiftUI

struct ContentView: View {
    
    enum TextFieldFous {
        case name
        case surname
    }
    
    @State var username = "emilys"
    @State var password = "emilyspass"
    
    @FocusState var textFieldFouce: TextFieldFous?
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            TextField("UserName", text: $username)
                .padding()
                .overlay(
                    Rectangle()
                        .strokeBorder(lineWidth: 2)
                )
                .focused($textFieldFouce, equals: .name)
            TextField("Password", text: $password)
                .padding()
                .overlay(
                    Rectangle()
                        .strokeBorder(lineWidth: 2)
                )
                .focused($textFieldFouce, equals: .surname)
            
            HStack(spacing: 4) {
                Button(action: {
                    viewModel.login(userName: username, password: password)
                }, label: {
                    Text("Login")
                })
                
                Button(action: {
                    viewModel.getUser()
                }, label: {
                    Text("Get User")
                })
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 20)
            
            
            if let user = viewModel.user {
                VStack(spacing: 8) {
                    Group {
                        Text("id: \(user.id)")
                        Text("username: \(user.username)")
                        Text("email: \(user.email)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

