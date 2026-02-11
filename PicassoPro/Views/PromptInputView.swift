//
//  PromptInputView.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import SwiftUI

struct PromptInputView: View {
    enum FocusedField {
        case expression, exclusions
    }
    
    @ObservedObject var viewModel: PromptInputViewModel
    @Binding var isPresented: Bool
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Enter Prompt").padding(.top)
            Form {
                Section("Expression") {
                    TextField("Describe the Image", text: $viewModel.expression)
                        .focused($focusedField, equals: .expression)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .exclusions
                        }
                    
                }
                
                Section("Optional") {
                    if viewModel.excludedWords.count > 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack {
                                ForEach(Array(viewModel.excludedWords), id: \.self) { word in
                                    ExcludedWordButton(title: word) {
                                        viewModel.removeExcludedWord(word: word)
                                    }
                                }
                            }
                        }
                    }
                    HStack {
                        TextField("Enter Excluded Features", text: $viewModel.excludedWordInput)
                            .focused($focusedField, equals: .exclusions)
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = nil
                            }
                        Spacer()
                        Button {
                            viewModel.addExcludedWord()
                        } label: {
                            Label("Add", systemImage: "plus.app").labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
                
            Spacer()
            
            Button {
                isPresented = false
                viewModel.submit()
            } label: {
                Text("Generate")
                    .frame(width: 120, height: 55)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct ExcludedWordButton: View {
    var title: String
    var action: () -> Void = {
        
    }
    var body: some View {
        HStack {
            Text(title)
            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(0.3))
        .cornerRadius(25)
    }
}


struct PromptInputView_PreviewContainer: View {
    @State var prompt: InputPrompt = .empty
    @Binding var isPresented: Bool
    var body: some View {
        Text("Hello")
            .sheet(isPresented: $isPresented) {
                PromptInputView(viewModel: PromptInputViewModel(prompt: $prompt), isPresented: .constant(true))
                    .presentationDetents([.medium, .fraction(0.75)])
            }
    }
}

struct PromptInputView_Previews: PreviewProvider {
    static var previews: some View {
        PromptInputView_PreviewContainer(isPresented: .constant(true))
    }
}
