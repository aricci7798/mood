// Aynsley Ricci
// Monday, February 26, 2024
// MoodMeter App
// Mood Journal

import SwiftUI
import UIKit

struct MoodJournalEntry {
    var date: Date
    var mood: String
    var entry: String
}

struct ContentView: View {
    @State private var entries: [MoodJournalEntry] = []
    @State private var isInputtingEntry = false
    @State private var isInputViewPresented = false
    @State private var isConfirmingEntry = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isInputViewFocused = false
    @State private var selectedMood: String? = "Happy"
    @State private var entry: String = " "
    @AppStorage("isFirstTimeUser") var isFirstTimeUser = true
    
    var isTextFieldFocusedBinding: Bool {
        isTextFieldFocused
    }
    
        var body: some View {
            NavigationView {
                Group {
                    if isFirstTimeUser {
                        SignInView(isFirstTimeUser: $isFirstTimeUser)
                    } else {
                        VStack {
                            Text("How are you feeling today?")
                            Picker("", selection: $selectedMood){
                                ForEach(["Happy", "Sad", "Angry", "Tired", "Anxious"], id: \.self) { mood in
                                    Text(mood).tag(mood)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: {
                            if let selectedMood = selectedMood {
                                saveEntry(with: selectedMood)
                            }
                            isConfirmingEntry = true
                        }) {
                            Text("Submit")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        Spacer()
                        
                        NavigationLink(destination: EntriesForTodayView(entries: filteredEntries)) {
                            Text("Mood Calendar")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    .navigationTitle("Mood Journal")
                    .alert(isPresented: $isConfirmingEntry) {
                        Alert(
                            title: Text("Would you like to Journal Today?"),
                            primaryButton: .default(Text("Yes")) {
                                isInputViewPresented = true
                            },
                            secondaryButton: .cancel(Text("No")) {
                                // If user chooses not to journal, save mood entry with 'N/A' for entry
                                saveEntry(with: "N/A")
                            }
                        )
                    }
                    .sheet(isPresented: $isInputViewPresented) {
                        EntryInputView(isInputtingEntry: $isInputtingEntry, entry: $entry, mood: selectedMood ?? "", saveEntry: saveEntry, isInputViewFocused: $isTextFieldFocused)
                    }
                }
            }
        }
    
        .navigationViewStyle(StackNavigationViewStyle())
    }
    private var filteredEntries: [MoodJournalEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func saveEntry(with mood: String) {
        let today = Calendar.current.startOfDay(for: Date())
        let newEntry = MoodJournalEntry(date: today, mood: mood, entry: entry)
        entries.append(newEntry)
        entry = ""
        isInputViewPresented = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
    
struct SignInView: View {
    @Binding var isFirstTimeUser: Bool
            
    var body: some View {
        VStack {
            Text("Welcome to Mood Journal")
                .font(.title)
                .padding()
            Button(action: {
                isFirstTimeUser = false
            }) {
                Text("Sign In")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
        }
    }
struct EntriesForTodayView: View {
    var entries: [MoodJournalEntry]
    
    var body: some View {
        VStack {
            Text("Recent Entries")
                .font(.headline)
                .padding(.top)
            
            List(entries, id: \.date) { entry in
                VStack(alignment: .leading) {
                    Text("Date: \(entry.date, formatter: DateFormatter.shortDate)")
                    Text("Mood: \(entry.mood)")
                    Text("Entry: \(entry.entry)")
                }
            }
            .frame(height: 200)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
        }
        .padding()
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct EntryInputView: View {
    @Binding var isInputtingEntry: Bool
    @Binding var entry: String
    var mood: String
    var saveEntry: (String, String) -> Void
    
    var isInputViewFocused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack {
            Text("Enter Your Journal Entry")
                .font(.headline)
                .padding()
            
            TextEditor(text: $entry)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
                .focused(isInputViewFocused)
            
            Button(action: {
                saveEntry(mood, entry)
                isInputtingEntry = false
            }) {
                Text("Save Entry")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Journal Entry")
    }
}
struct HomeView: View {
    @State private var isNavigationActive = false
    private let greeting: String
    
    init() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        default:
            greeting = "Good Night"
        }
    }
    
    var body: some View {
        VStack {
            Text("Mood Meter")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            
            Text(greeting + " User")
                .font(.title)
                .padding()
            
            Spacer()
            
            Button(action: {
                isNavigationActive = true
            }) {
                Text("Get Started")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            .padding()
            .fullScreenCover(isPresented: $isNavigationActive, content: {
                ContentView()
            })
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        ContentView()
            .preferredColorScheme(.dark)
    }
}

