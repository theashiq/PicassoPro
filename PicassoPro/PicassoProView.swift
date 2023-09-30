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
    @State var animateInputButtonIndicator: Bool = false
    
    var body: some View {
        VStack{
            Text("Picasso Pro")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.accentColor)
            
            if viewModel.showEmptyPromptSign{
                Spacer()
                emptyPrompt
            }
            else{
                inputSection
                outputSection
            }
            
            Spacer()
            inputButton
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
        Text("Prompt is Empty\nEnter Prompt Below")
            .multilineTextAlignment(.center)
            .font(.title3)
            .foregroundColor(.accentColor)
            .lineSpacing(CGFloat(10))
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
                        image.resizable().scaledToFit()
                    },
                    placeholder: {
                        ProgressView("Loading").foregroundColor(.accentColor)
                    }
                ).opacity(viewModel.isGeneratingImage ? 0.2 : 1)
                
                if viewModel.isGeneratingImage{
                    ProgressView("Processing").foregroundColor(.accentColor)
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
                .padding(.bottom, viewModel.showEmptyPromptSign ? 50 : 20)
        }
        .disabled(viewModel.isGeneratingImage)
        .overlay{
            if viewModel.showEmptyPromptSign{
                inputButtonIndicator
                    .onAppear {
                        animateInputButtonIndicator = viewModel.showEmptyPromptSign
                    }
            }
        }
    }
    private var inputButtonIndicator: some View{
        Image(systemName: "arrowshape.right.fill")
            .rotationEffect(Angle(degrees: 90))
            .scaleEffect(CGSize(width: 1.5, height: 1.5))
            .foregroundColor(.accentColor)
            .offset(y: animateInputButtonIndicator ? -90 : -120)
            .imageScale(animateInputButtonIndicator ? .large : .small)
            .opacity(animateInputButtonIndicator ? 1 : 0.2)
            .animation(.easeInOut(duration: 1).repeatForever(), value: animateInputButtonIndicator)
    }
}


struct PicassoProView_Previews: PreviewProvider {
    static var previews: some View {
        PicassoProView()
    }
}


