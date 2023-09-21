//
//  PicassoProView.swift
//  PicassoPro
//
//  Created by mac 2019 on 9/20/23.
//

import SwiftUI

struct PicassoProView: View {
    
    @StateObject var viewModel: PicassoProViewModel = PicassoProViewModel()
    
    @State var isInputViewPresented: Bool = false
    
    var body: some View {
        VStack{
            Text("Picasso Pro")
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
                .padding()
            
            ZStack{
                VStack{
                    inputSection
                    outputSection
                }
                if viewModel.prompt.isEmpty{
                    emptyPrompt
                }
            }
            
            Spacer()
            
            inputButton
        }
        .sheet(isPresented: $isInputViewPresented){
            PromptInputView(viewModel: PromptInputViewModel(prompt: $viewModel.prompt), isPresented: $isInputViewPresented)
                .presentationDetents([.medium, .fraction(0.75)])
        }
    }
    
    private var emptyPrompt: some View{
        ZStack(alignment: .center){
            Color(uiColor: .systemBackground)
            Text("Empty Prompt\nEnter Prompt Below")
                .multilineTextAlignment(.center)
                .font(.title3)
        }
    }
    
    private var inputSection: some View{
        Section{
            Text("Input")
                .bold()
                .opacity(0.5)
            
            Text(viewModel.prompt.expression)
                .font(.title2)
                .padding()
                .frame(height: 100)
        }
    }
    private var outputSection: some View{
        
        Section{
            Text("Output")
                .bold()
                .opacity(0.5)
            if viewModel.fetchState == .generating{
                VStack{
                    Spacer()
                    ProgressView{
                        Text("Generating Image")
                    }
                    .foregroundColor(.accentColor)
                    .font(.largeTitle)
                    Spacer()
                }
            }
            else{
                AsyncImage(
                    url: URL(string: viewModel.outputUrl),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                    },
                    placeholder: {
                        switch viewModel.fetchState{
                        case .generating:
                            Text("Generating")
                        case .generated:
                            Text("Success")
                                .foregroundColor(.accentColor)
                                .font(.largeTitle)
                        case .emptyPrompt(let message):
                            Text(message)
                        case .error(let message):
                            Text(message).foregroundColor(.red.opacity(0.8))
                        
                        }
                    }
                )
                .frame(maxHeight: 350)
            }
        }
    }
    
    private  var inputButton: some View{
        
        Button(action: {
            isInputViewPresented = true
        }){
            Image(systemName: "pencil.circle.fill")
                .bold()
                .scaleEffect(3)
                .padding(20)
        }
        .buttonStyle(.borderless)
    }
}


struct PicassoProView_Previews: PreviewProvider {
    static var previews: some View {
        PicassoProView()
    }
}


