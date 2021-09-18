//
//  ContentView.swift
//  WordScrumble, project 5
//
//  Created by Ivan Stajcer on 18.09.2021..
//

import SwiftUI

struct ContentView: View {
  @ObservedObject private var scrumbleModelController: ScrumbleModelController
  
  init(scrumbleModelController: ScrumbleModelController) {
    self.scrumbleModelController = scrumbleModelController
  }
  
  var body: some View {
    NavigationView {
      VStack {
        Text(scrumbleModelController.model.rootWord)
          .font(.largeTitle)
        TextField("Root words", text: $scrumbleModelController.model.typedWord, onCommit: onWordEntered)
          .autocapitalization(.none)
          .padding()
        
        List(scrumbleModelController.model.usedWords, id: \.self){
          word in
          Image(systemName: "\(word.count).circle")
          Text("\(word)")
        }
        .listStyle(GroupedListStyle())
      }
      .navigationBarTitle("WordScrumble")
      .onAppear(perform: startGame)
      .alert(isPresented: $scrumbleModelController.isAlertShown, content: {
        Alert(title: Text("Word is not okay"), message: Text(scrumbleModelController.model.errorMessage), dismissButton: .some(.cancel()))
      })
      
    }
  }
}

private extension ContentView {
  func startGame() {
    if let url =  Bundle.main.url(forResource: "start", withExtension: ".txt")
    {
      if let wordsString = try? String(contentsOf: url) {
        let words = wordsString.components(separatedBy: "\n")
        let word = words.randomElement() ?? "Moonshine"
        scrumbleModelController.model.rootWord = word
        print("Word loaded good hehe, \(word)")
        return
      }
    }
    
    fatalError("No words file found!")
  }
  
  func onWordEntered() {
    let word = scrumbleModelController.model.typedWord.lowercased().trimmingCharacters(in: .whitespaces)
    if !(word.count > 0) {
      return
    }
    if !isWordGood(word){
      scrumbleModelController.isAlertShown = true
    }else{
      scrumbleModelController.model.usedWords.insert(word, at: 0)
    }
    scrumbleModelController.model.typedWord = ""
  }
}

private extension ContentView {
  // MARK: - Word checking
  func isWordGood(_ word: String) -> Bool {
    if !isWordReal(word) {
      scrumbleModelController.model.errorMessage = "Word does not exist."
      return false
    }
    if !isWordOriginal(word) {
      scrumbleModelController.model.errorMessage = "Word was allready typed."
      return false
    }
    if !isWordFromRootWord(word) {
      scrumbleModelController.model.errorMessage = "Word is not made up from root."
      return false
    }
    return true
  }
  
  func isWordOriginal(_ word: String) -> Bool {
    !scrumbleModelController.model.usedWords.contains(word)
  }
  
  func isWordFromRootWord(_ word: String) -> Bool {
    var tempWord = scrumbleModelController.model.rootWord
    for letter in word {
      if let index = tempWord.firstIndex(where: { tempChar in
        tempChar == letter
      })
      {
        tempWord.remove(at: index)
      }else{
        return false
      }
    }
    return true
  }
  
  func isWordReal(_ word: String) -> Bool {
    let textChecker = UITextChecker()
    let textCheckingRange = NSRange(location: 0, length: word.count)
    let misspeledRange = textChecker.rangeOfMisspelledWord(in: word, range: textCheckingRange, startingAt: 0, wrap: false, language: "en")
    
    return misspeledRange.location == NSNotFound
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(scrumbleModelController: ScrumbleModelController())
  }
}
