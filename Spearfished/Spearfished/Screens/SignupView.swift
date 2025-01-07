//
//  SignupView.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack{
                VStack(spacing: 20) {
                    Text("Signup:")
                        .font(.system(size: 41, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 35.0)
                        .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    
                    VStack(alignment: .leading, spacing: 12.0){
                        Text("Email:")
                            .font(.system(size: 25, design: .monospaced))
                            .multilineTextAlignment(.leading)
                            .padding(3.0)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        Text("Password:")
                            .font(.system(size: 25, design: .monospaced))
                            .multilineTextAlignment(.leading)
                            .padding(3.0)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button("Signup") {
                        Task {
                            do {
                                try await authManager.signUp(email: email, password: password)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .frame(width: 120, height: 40)
                    .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8))
                    
                }
                .frame(width: 358.0, height: 900.0)
                .background(Color(hue: 0.492, saturation: 0.18, brightness: 0.921))
            }
            .frame(width: 500, height: 900.0)
            .background(Color(hue: 0.492, saturation: 0.18, brightness: 0.921))
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        
    }
}


#Preview {
    SignUpView()
}
