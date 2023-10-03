import SwiftUI
import Combine

struct Player {
    var name: String
}

// Define the ScorePosting protocol:
protocol ScorePosting {
    func postScores(_ token: String, teamAScore: Int, teamBScore: Int)
    func postFinalScores()
    func fetchToken() -> String
}

// Make ContentView conform to this protocol:
extension ContentView: ScorePosting { }

struct ContentView: View {

    @State var teamacount: Int = 0
    @State var teambcount: Int = 0
    @State var countsA = Array(repeating: 0, count: 5)
    @State var countsB = Array(repeating: 0, count: 5)
    @State var showingResetView = false

    @State var playersA: [Player] = []
    @State var playersB: [Player] = []

    //let playersA = [Player(name: "Rik"), Player(name: "Joe"), Player(name: "Cal"), Player(name: "Pete"), Player(name: "Arun")]
    //let playersB = [Player(name: "Darren"), Player(name: "Phil"), Player(name: "Josh"), Player(name: "Ollie"), Player(name: "Mark")]

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

                NavigationLink(destination: ResetView(
                    teamACount: $teamacount,
                    teamBCount: $teambcount,
                    countsA: $countsA,
                    countsB: $countsB,
                    scorePoster: self),  // Pass self as the scorePoster
                    isActive: $showingResetView) {
                        EmptyView()
                }
            }
            .onLongPressGesture(minimumDuration: 2) {
                self.showingResetView = true
            }
        }
        .onAppear {
            let token = fetchToken()
            loadTeams(urlStringA: "https://footyapp-api-dev.richardbignell.co.uk/games/teama",urlStringB: "https://footyapp-api-dev.richardbignell.co.uk/games/teamb", token: token)
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
 
    func fetchToken() -> String {
        guard let token = ProcessInfo.processInfo.environment["API_TOKEN"] else {
            fatalError("Missing API token from environment variables")
        }
        
        return token
    }

    func postScores(_ token: String, teamAScore: Int, teamBScore: Int) {
        guard let url = URL(string: "https://footyapp-api-dev.richardbignell.co.uk/games/updatescore/2023-10-04") else { return }
    
        let scoreData = ["scoreTeamA": teamAScore, "scoreTeamB": teamBScore]
            
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        let jsonData = try! JSONEncoder().encode(scoreData)
            
        URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print ("Error:", error)
                } else if let data = data {
                    let str = String(data: data, encoding: .utf8)
                    print("Received data:\n\(str ?? "")")
                }
            }
        }.resume()
    }

    func postPlayerScore(_ token: String, playerName: String, playerScore: Int) {
        print("Posting score for \(playerName) with value \(playerScore)")
        guard let url = URL(string: "https://footyapp-api-dev.richardbignell.co.uk/players/goals/\(playerName)") else { return }
    
        let scoreData = ["goals": playerScore]
            
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        let jsonData = try! JSONEncoder().encode(scoreData)
            
        URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print ("Error:", error)
                } else if let data = data, let response = response as? HTTPURLResponse {
                    let str = String(data: data, encoding: .utf8)
                    print("Received data:\n\(str ?? ""), Status Code: \(response.statusCode)")
                }
            }
        }.resume()
    }

    func postFinalScores() {
        for index in 0..<playersA.count {
            let playerName = playersA[index].name
            let playerScore = countsA[index]
            self.postPlayerScore(self.fetchToken(), playerName: playerName, playerScore: playerScore)
        }

        for index in 0..<playersB.count {
            let playerName = playersB[index].name
            let playerScore = countsB[index]
            self.postPlayerScore(self.fetchToken(), playerName: playerName, playerScore: playerScore)
        }
    }

    func loadTeams(urlStringA: String, urlStringB: String, token: String) {
        guard let urlA = URL(string: urlStringA), let urlB = URL(string: urlStringB) else { return }
        
        let dispatchGroup = DispatchGroup()
        
        var requestA = URLRequest(url: urlA)
        var requestB = URLRequest(url: urlB)
        requestA.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        requestB.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Request for Team A
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: requestA) { (data, response, error) in
            if let error = error {
                print("Error:", error)
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let teamMembers = try decoder.decode([[String]].self, from: data)

                    DispatchQueue.main.async {
                        self.playersA = teamMembers[0].map { Player(name: $0) }
                        self.countsA = Array(repeating: 0, count: self.playersA.count)
                    }
                } catch {
                    print("Failed to decode JSON for Team A: \(error)")
                }
            }
            dispatchGroup.leave()
        }.resume()

        // Request for Team B
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: requestB) { (data, response, error) in
            if let error = error {
                print("Error:", error)
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let teamMembers = try decoder.decode([[String]].self, from: data)

                    DispatchQueue.main.async {
                        self.playersB = teamMembers[0].map { Player(name: $0) }
                        self.countsB = Array(repeating: 0, count: self.playersB.count)
                    }
                } catch {
                    print("Failed to decode JSON for Team B: \(error)")
                }
            }
            dispatchGroup.leave()
        }.resume()

        // Notify when both requests are done
        dispatchGroup.notify(queue: .main) {
            print("Both playersA and playersB are populated.")
        }
    }
}

struct ResetView: View {
    @Binding var teamACount: Int
    @Binding var teamBCount: Int
    @State private var showAlert = false
    @Binding var countsA: [Int]
    @Binding var countsB: [Int]

    // Add a variable of type ScorePosting
    var scorePoster: ScorePosting

    // Update the body to call functions on scorePoster
    var body: some View {
        VStack {
            Text("Menu:")
            Button(action: {
                self.scorePoster.postScores(self.scorePoster.fetchToken(), 
                    teamAScore: self.teamACount,
                    teamBScore: self.teamBCount)
                self.scorePoster.postFinalScores()
                self.showAlert = true
                // Now Scores are posted, reset the values back to zero
                self.teamACount = 0
                self.teamBCount = 0
                self.countsA = Array(repeating: 0, count: countsA.count)
                self.countsB = Array(repeating: 0, count: countsB.count)
            }) {
                Text("Post")
            }
            .alert(isPresented: $showAlert) { 
            Alert(title: Text("Posting Goals and Scores..."), 
                  message: Text("Post Successful!"), 
                  dismissButton: .default(Text("OK!"))
            )
            }
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
