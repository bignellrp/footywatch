import SwiftUI

struct Player {
    var name: String
}

struct ContentView: View {
    @State var teamacount: Int = 0
    @State var teambcount: Int = 0
    @State var countsA = Array(repeating: 0, count: 5)
    @State var countsB = Array(repeating: 0, count: 5)
    @State var showingResetView = false

    let playersA = [Player(name: "Rik"), Player(name: "Joe"), Player(name: "Cal"), Player(name: "Pete"), Player(name: "Arun")]
    let playersB = [Player(name: "Darren"), Player(name: "Phil"), Player(name: "Josh"), Player(name: "Ollie"), Player(name: "Mark")]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) { // changed from HStack to VStack
                    ScrollView {
                        //Text("TeamA: \(teamacount)")
                        // Total Scores
                        Text("Team A Score: \(self.teamacount)")
                            .font(.title)
                        Text("Team B Score: \(self.teambcount)")
                            .font(.title)

                        // For Team A
                        ForEach(playersA.indices, id: \.self) { index in
                            HStack {
                                Button(action: {
                                    if countsA[index] > 0 {
                                        countsA[index] -= 1
                                        self.teamacount -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Color.red)

                                VStack(alignment: .leading) {
                                    Text("\(playersA[index].name)").font(.title)
                                    Text("Score: \(countsA[index])").font(.headline)
                                }

                                Button(action: {
                                    countsA[index] += 1
                                    self.teamacount += 1
                                }) {
                                    Image(systemName: "plus.circle")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Color.red)
                            }
                        }

                    }

                    ScrollView {
                        //Text("TeamB: \(teambcount)")

                        // For Team B
                        ForEach(playersB.indices, id: \.self) { index in
                            HStack {
                                Button(action: {
                                    if countsB[index] > 0 {
                                        countsB[index] -= 1
                                        self.teambcount -= 1
                                    } 
                                }) {
                                    Image(systemName: "minus.circle")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Color.blue)

                                VStack(alignment: .leading) {
                                    Text("\(playersB[index].name)").font(.title)
                                    Text("Score: \(countsB[index])").font(.headline)
                                }

                                Button(action: {
                                    countsB[index] += 1
                                    self.teambcount += 1
                                }) {
                                    Image(systemName: "plus.circle")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Color.blue)
                            }
                        }

                    }
                }
                .frame(maxWidth: .infinity)

                NavigationLink(destination: ResetView(teamACount: $teamacount, teamBCount: $teambcount), isActive: $showingResetView) {
                    EmptyView()
                }
            }
            .onLongPressGesture(minimumDuration: 2) {
                self.showingResetView = true
            }

            Button(action: {
                self.teamacount = 0
                self.teambcount = 0
            }) {
                Text("Reset")
            }
        }
        .onAppear {
            loadTeama()
            loadTeamB()
        }
    }

    func loadTeama() {
        guard let url = URL(string: "https://footyappdev.richardbignell.co.uk/teama.txt") else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }

            if let fileContents = String(data: data, encoding: .utf8) {
                let lines = fileContents.components(separatedBy: "\n")
                // update UI on the main thread 
                DispatchQueue.main.async {
                    // Update your UI here
                }
            }
        }.resume()
    }
    
    func loadTeamB() {
        guard let url = URL(string: "https://footyappdev.richardbignell.co.uk/teamb.txt") else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }

            if let fileContents = String(data: data, encoding: .utf8) {
                let lines = fileContents.components(separatedBy: "\n")
                
                // update UI on the main thread 
                DispatchQueue.main.async {
                    // Update your UI here
                }
            }
        }.resume()
    }
}

struct ResetView: View {
    @Binding var teamACount: Int
    @Binding var teamBCount: Int
    
    var body: some View {
        VStack {
            Text("You can reset your scores here.")
            
            Button(action: {
                self.teamACount = 0
                self.teamBCount = 0
            }) {
                Text("Reset")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}