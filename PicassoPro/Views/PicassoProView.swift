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
        VStack {
            Text("Picasso Pro")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.accentColor)
            
            if viewModel.showEmptyPromptSign {
                Spacer()
                emptyPrompt
            }
            else {
                Text(viewModel.prompt.expression)
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .padding(.horizontal)
                Spacer()
                
                outputSection
            }
            
            Spacer()
            inputButton
        }
        .onChange(of: viewModel.alertStatus) { error in
            if error != .none {
                isAlertPresented.toggle()
            }
        }
        .sheet(isPresented: $isInputViewPresented) {
            PromptInputView(viewModel: PromptInputViewModel(prompt: $viewModel.prompt), isPresented: $isInputViewPresented)
                .presentationDetents([.medium, .fraction(0.75)])
        }
        .alert(viewModel.alertStatus.title, isPresented: $isAlertPresented) {
            Button("Ok", role: .cancel) {
                viewModel.alertStatus = .none
            }
        } message: {
            Text(viewModel.alertStatus.message)
        }
    }
    
    private var emptyPrompt: some View {
        Text("Prompt is Empty\nEnter Prompt Below")
            .multilineTextAlignment(.center)
            .font(.title3)
            .foregroundColor(.accentColor)
            .lineSpacing(CGFloat(10))
    }
    
    private var outputSection: some View {
        ZStack {
            AsyncImage(
                url: URL(string: viewModel.imageUrl),
                content: { image in
                    
                    image.resizable().scaledToFit()
                        .padding(5)
                        .border(Color.accentColor)
                    
                    HStack(spacing: 50) {
                        ShareLink("Share", item: image, preview: SharePreview(viewModel.prompt.expression, image: image))
                        
                        Button {
                            withAnimation(.easeInOut(duration: 1)) {
                                viewModel.saveImage(image: image)
                            }
                        } label: {
                            switch viewModel.imageSaveState {
                            case .toBeDone:
                                Label("Save", systemImage: "square.and.arrow.down")
                            case .doing:
                                Label("Saving...", systemImage: "timer")
                                    .foregroundColor(.gray)
                            case .done:
                                Label("Saved", systemImage: "checkmark.circle")
                                    .foregroundColor(.green)
                            case .failed:
                                Label("Retry Save", systemImage: "externaldrive.badge.exclamationmark")
                                    .foregroundColor(.red)
                            }
                        }
                        .disabled(viewModel.imageSaveState == .doing || viewModel.imageSaveState == .done)
                    }
                    .foregroundColor(.accentColor)
                    .padding()
                },
                placeholder: {
                    if !viewModel.imageUrl.isEmpty {
                        ProgressView("Loading").foregroundColor(.accentColor)
                    }
                }
            ).opacity(viewModel.isGeneratingImage ? 0.2 : 1)
            
            if viewModel.isGeneratingImage {
                ProgressView("Processing").foregroundColor(.accentColor)
            }
        }
        .frame(maxHeight: 500)
        
    }
    
    private  var inputButton: some View {
        
        Button {
            isInputViewPresented = true
        } label: {
            Image(systemName: "pencil.circle.fill")
                .bold()
                .scaleEffect(3)
                .padding(.bottom, viewModel.showEmptyPromptSign ? 50 : 20)
        }
        .disabled(viewModel.isGeneratingImage)
        .overlay {
            if viewModel.showEmptyPromptSign {
                inputButtonIndicator
                    .onAppear {
                        animateInputButtonIndicator = viewModel.showEmptyPromptSign
                    }
            }
        }
    }
    private var inputButtonIndicator: some View {
        Image(systemName: "arrowshape.right.fill")
            .rotationEffect(Angle(degrees: 90))
            .scaleEffect(animateInputButtonIndicator ? 1.5 : 1)
            .foregroundColor(animateInputButtonIndicator ? .accentColor: .accentColor.opacity(0.5))
            .offset(y: animateInputButtonIndicator ? -90 : -120)
            .animation(.easeInOut(duration: 1).repeatForever(), value: animateInputButtonIndicator)
    }
}


struct PicassoProView_Previews: PreviewProvider {
    static var previews: some View {
        PicassoProView()
    }
}


//A calm and peaceful nature scene with text on top "Be good to others, that will protect you against evil."
