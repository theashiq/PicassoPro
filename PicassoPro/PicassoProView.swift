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
    @State var isAlertPresented: Bool = false
    
    var body: some View {
        VStack{
            Text("Picasso Pro")
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
                .padding()
            
            VStack{
                inputSection
                outputSection
            }
            
            Spacer()
            
            inputButton.disabled(viewModel.isGeneratingImage)
        }
        .onChange(of: viewModel.error){ error in
            if error != nil{
                isAlertPresented.toggle()
            }
        }
        .sheet(isPresented: $isInputViewPresented){
            PromptInputView(viewModel: PromptInputViewModel(prompt: $viewModel.prompt), isPresented: $isInputViewPresented)
                .presentationDetents([.medium, .fraction(0.75)])
        }
        .alert(viewModel.error?.rawValue ?? "Alert", isPresented: $isAlertPresented, presenting: viewModel.error)
        { _ in
            Button("Ok", role: .cancel) {
                viewModel.error = nil
            }
        } message: {
            Text($0.localizedDescription)
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
            
            ZStack{
                AsyncImage(
                    url: URL(string: viewModel.imageUrl),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                    },
                    placeholder: {
                        if viewModel.prompt.isEmpty{
                            emptyPrompt
                        }
                    }
                ).opacity(viewModel.isGeneratingImage ? 0.2 : 1)
                
                if viewModel.isGeneratingImage{
                    ProgressView().foregroundColor(.accentColor)
                }
            }
            .frame(maxHeight: 500)
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


