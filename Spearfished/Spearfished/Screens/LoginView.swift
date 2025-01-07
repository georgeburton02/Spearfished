//
//  LoginView.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack{
                VStack {
                    Text("Gone Fishing 🐠")
                        .font(.system(size: 41, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    
                    VStack(alignment: .leading, spacing: 12.0){

                        
                        Text("Email")
                            .font(.system(size: 25, design: .monospaced))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 17.0)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        Text("Password")
                            .font(.system(size: 25, design: .monospaced))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 17.0)
                            .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.bottom, 18.0)
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    HStack{
                        Button("login") {
                            Task {
                                do {
                                    try await authManager.signIn(email: email, password: password)
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .frame(width: 172, height: 40)
                        .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8))
                        
                        Button("Sign Up") {
                            showingSignUp = true
                        }
                        .frame(width: 172.0, height: 40)
                        .background(Color(hue: 0.534, saturation: 0.282, brightness: 0.8))
                    }
                }
                .frame(width: 358.0, height: 900.0)
                .background(Color(hue: 0.492, saturation: 0.18, brightness: 0.921))
                }
                .frame(width: 500, height: 900)
                .background(Color(hue: 0.492, saturation: 0.18, brightness: 0.921))
                .padding()
                .sheet(isPresented: $showingSignUp) {
                    SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager()) // <-- For the preview to work, pass an instance of AuthManager into the environment
}
