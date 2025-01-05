import SwiftUI

struct BioAndPromptsView: View {
    @Binding var bio: String
    @Binding var selectedPrompts: [User.ProfilePrompt]
    let availablePrompts: [String]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add a bio and some prompts to help others get to know you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bio")
                    .font(.headline)
                
                TextEditor(text: $bio)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Text("\(bio.count)/300")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Prompts")
                    .font(.headline)
                
                ForEach(0..<3) { index in
                    PromptSelectionView(
                        prompt: index < selectedPrompts.count ? selectedPrompts[index] : nil,
                        availablePrompts: availablePrompts,
                        onPromptSelected: { prompt, answer in
                            updatePrompt(at: index, prompt: prompt, answer: answer)
                        }
                    )
                }
            }
        }
        .padding(.vertical)
    }
    
    private func updatePrompt(at index: Int, prompt: String, answer: String) {
        let newPrompt = User.ProfilePrompt(question: prompt, answer: answer)
        
        if index < selectedPrompts.count {
            selectedPrompts[index] = newPrompt
        } else {
            selectedPrompts.append(newPrompt)
        }
    }
}

struct PromptSelectionView: View {
    let prompt: User.ProfilePrompt?
    let availablePrompts: [String]
    let onPromptSelected: (String, String) -> Void
    
    @State private var selectedPrompt: String
    @State private var answer: String
    @State private var isEditing = false
    
    init(prompt: User.ProfilePrompt?, availablePrompts: [String], onPromptSelected: @escaping (String, String) -> Void) {
        self.prompt = prompt
        self.availablePrompts = availablePrompts
        self.onPromptSelected = onPromptSelected
        
        _selectedPrompt = State(initialValue: prompt?.question ?? availablePrompts[0])
        _answer = State(initialValue: prompt?.answer ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Menu {
                ForEach(availablePrompts, id: \.self) { prompt in
                    Button(prompt) {
                        selectedPrompt = prompt
                        onPromptSelected(prompt, answer)
                    }
                }
            } label: {
                HStack {
                    Text(selectedPrompt)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            TextField("Your answer", text: $answer, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .onChange(of: answer) { newValue in
                    onPromptSelected(selectedPrompt, newValue)
                }
        }
    }
} 