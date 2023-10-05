import SwiftUI
import Combine

struct Player {
    var name: String
}

struct TeamAResponse: Decodable {
    let teamA: [[String]]
    let date: String
    let colourA: String
}

struct TeamBResponse: Decodable {
    let teamB: [[String]]
    let date: String
    let colourB: String
}

protocol ScorePosting {
    func postScores(_ token: String, teamAScore: Int, teamBScore: Int, gameDate: String)
    func postFinalScores()
    func fetchToken() -> String
}

extension ContentView: ScorePosting { }

// SwiftUI does not natively support hex colors, so you can use an extension like this:
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {

    @State var teamacount: Int = 0
    @State var teambcount: Int = 0
    @State var countsA = Array(repeating: 0, count: 5)
    @State var countsB = Array(repeating: 0, count: 5)
    @State var showingResetView = false

    @State var playersA: [Player] = []
    @State var playersB: [Player] = []
    @State var gameDate: String = ""
    @State var colourA: String = ""
    @State var colourB: String = ""

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
                    .background(colourForName(self.colourA))
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
                    .background(colourForName(self.colourB))
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
                    gameDate: $gameDate,
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

    let colourMap: [String: String] = [
        "green": "#00FF00",
        "blue": "#4169E1",
        "black": "#000000",
        "darrenschoice": "#ADD8E6",
        "multicoloured": "#FF0000",
        "pink": "#FF69B4",
        "red": "#FF0000",
        "stripes": "#000000",
        "white": "#FFFFFF",
        "yellow": "#FFFF00"
    ]

    func colourForName(_ colourName: String) -> Color {
        let hexString = colourMap[colourName]
        return Color(hex: hexString ?? "#000000") // default to black if color not found
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

    func postScores(_ token: String, teamAScore: Int, teamBScore: Int, gameDate: String) {
        guard let url = URL(string: "https://footyapp-api-dev.richardbignell.co.uk/games/updatescore/\(gameDate)") else { return }
        
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

        // Create a JSONDecoder instance here
        let decoder = JSONDecoder()

        // Request for Team A
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: requestA) { (data, response, error) in
            if let error = error {
                print("Error:", error)
            } else if let data = data {
                do {
                    let result = try decoder.decode(TeamAResponse.self, from: data)

                    DispatchQueue.main.async {
                        self.playersA = result.teamA.flatMap { $0.map { Player(name: $0) } }
                        self.countsA = Array(repeating: 0, count: self.playersA.count)
                        self.gameDate = result.date
                        self.colourA = result.colourA
                    }
                } catch {
                    print("Failed to decode: \(error)")
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
                    let result = try decoder.decode(TeamBResponse.self, from: data)

                    DispatchQueue.main.async {
                        self.playersB = result.teamB.flatMap { $0.map { Player(name: $0) } }
                        self.countsB = Array(repeating: 0, count: self.playersB.count)
                        self.gameDate = result.date
                        self.colourB = result.colourB
                    }
                } catch {
                    print("Failed to decode: \(error)")
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
    @Binding var gameDate: String

    // Add a variable of type ScorePosting
    var scorePoster: ScorePosting

    // Update the body to call functions on scorePoster
    var body: some View {
        VStack {
            Text("Menu:")
            Button(action: {
                self.scorePoster.postScores(self.scorePoster.fetchToken(), 
                                            teamAScore: self.teamACount,
                                            teamBScore: self.teamBCount,
                                            gameDate: self.gameDate)
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
