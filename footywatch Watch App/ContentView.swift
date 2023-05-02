//
//  ContentView.swift
//  footywatch Watch App
//
//  Created by Rik Bignell on 30/04/2023.
//

import SwiftUI

struct ContentView: View {
    @State var count: Int = 0
    let theWords = ["Pete","Rik","Chris","Cal","Joe","Harry","Louis","Oli","Ben","Lily"]
    
    let columns: [GridItem] =
             Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
            LazyVGrid(columns: columns) {
                ForEach(theWords, id: \.self) { word in
                    Button(action:{self.count += 1})
                    { Text(word)}.buttonStyle(PlainButtonStyle())
                }
            }
        VStack {
            Text("TeamA Score: \(count)")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
