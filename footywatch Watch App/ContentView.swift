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
                VStack(spacing: 20) { 
                    
                    HStack {
                        Text("Team A")
                            .font(.title)
                            .foregroundColor(.white)
                            
                        Text("Score: \(self.teamacount)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.init(top: 3, leading: 8, bottom: 3, trailing: 8)) // Adjust padding here
                    .background(Color.red)
                    .cornerRadius(10)

                    HStack {
                        Text("Team B")
                            .font(.title)
                            .foregroundColor(.white)
                            
                        Text("Score: \(self.teambcount)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.init(top: 3, leading: 8, bottom: 3, trailing: 8)) // Adjust padding here
                    .background(Color.blue)
                    .cornerRadius(10)


                    Spacer().frame(height: 30)
                    
                    ForEach(playersA.indices, id: \.self) { index in
                        playerView(player: playersA[index], count: $countsA[index], teamCount: $teamacount, color: Color.red)
                    }
                    
                    Spacer().frame(height: 30)

                    ForEach(playersB.indices, id: \.self) { index in
                        playerView(player: playersB[index], count: $countsB[index], teamCount: $teambcount, color: Color.blue)
                    }
                    
                }.frame(maxWidth: .infinity)

                NavigationLink(destination: ResetView(teamACount: $teamacount, teamBCount: $teambcount, countsA: $countsA, countsB: $countsB), isActive: $showingResetView) {
                    EmptyView()
                }
            }
            .onLongPressGesture(minimumDuration: 2) {
                self.showingResetView = true
            }
        }
        .onAppear {
            loadTeama()
            loadTeamB()
        }
    }

    func playerView(player: Player, count: Binding<Int>, teamCount: Binding<Int>, color: Color) -> some View {
        return HStack {
            Button(action: {
                if count.wrappedValue > 0 {
                    count.wrappedValue -= 1
                    teamCount.wrappedValue -= 1
                }
            }) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(PlainButtonStyle())
            .background(color)

            VStack(alignment: .leading) {
                Text("\(player.name)").font(.title)
                Text("Score: \(count.wrappedValue)").font(.headline)
            }

            Button(action: {
                count.wrappedValue += 1
                teamCount.wrappedValue += 1
            }) {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(PlainButtonStyle())
            .background(color)
        }
    }
 
    func loadTeama() {
        guard let url = URL(string: "https://footyappdev.richardbignell.co.uk/teama.txt") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }

            if let fileContents = String(data: data, encoding: .utf8) {
                let lines = fileContents.components(separatedBy: "\n")
                
                DispatchQueue.main.async {
                    // Update your UI here
                }
            }
        }.resume()
    }

    func loadTeamB() {
        guard let url = URL(string: "https://footyappdev.richardbignell.co.uk/teamb.txt") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }

            if let fileContents = String(data: data, encoding: .utf8) {
                let lines = fileContents.components(separatedBy: "\n")
                
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

    @Binding var countsA: [Int]
    @Binding var countsB: [Int]

    var body: some View {
        VStack {
            Text("You can reset your scores here.")

            Button(action: {
                self.teamACount = 0
                self.teamBCount = 0
                self.countsA = Array(repeating: 0, count: countsA.count)
                self.countsB = Array(repeating: 0, count: countsB.count)
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
