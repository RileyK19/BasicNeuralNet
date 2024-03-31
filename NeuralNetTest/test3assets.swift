//
//  test3assets.swift
//  NeuralNetTest
//
//  Created by Riley Koo on 4/14/24.
//

// source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts

import SwiftUI
import Charts

struct HomeInfo {
    let neighborhoodQuality: Float
    let numberOfRooms: Float
    let squareFootage: Float
    var value: Float

    var trainingData: (features: [Float], targets: [Float]) {
        let features = [neighborhoodQuality, numberOfRooms, squareFootage]
        let target = [value]

        return (features: features, targets: target)
    }
}
class HouseBuilder: ObservableObject {
    @Published var homes: [HomeInfo] = []

    init() {
        initializeHomes()
    }

    func initializeHomes() {
        let numberOfHomes: Int = 500
        var results: [HomeInfo] = []
        for _ in 0 ..< numberOfHomes {
            let randomHome = HouseBuilder.makeRandomHouse()
            results.append(randomHome)
        }

        homes = results
    }
    static func secretFormula(neighborhoodQuality: Float,
                          numberOfRooms: Float,
                          squareFootage: Float) -> Float {

        let neighborhoodQualityCoefficient: Float = 0.25
        let numberOfRoomsCoefficient: Float = 0.35
        let squareFootageCoefficient: Float = 0.4

        var value: Float = 0
        value += neighborhoodQualityCoefficient * neighborhoodQuality
        value += numberOfRoomsCoefficient * numberOfRooms
        value += squareFootageCoefficient * squareFootage

        return value
    }
    static func makeRandomHouse() -> HomeInfo {
            // No house too big! Just between 500 square feet and 10,000 square feet.
            let squareFootage = Float.random(in: 500 ..< 10000)

            // This is where we do the normalizing by scaling between 0 and 1.
            let normalizedSquareFootage = (squareFootage - 500.0) / (10000.0 - 500.0)

            // This is a made up number clearly, just as an example.
            let neighborhoodQuality = Float.random(in: 0 ..< 1)

            let numberOfRooms = Int.random(in: 1 ..< 10)

            let normalizedRooms = Float(numberOfRooms - 1) / Float(10 - 1)

            let homeValue = secretFormula(neighborhoodQuality: neighborhoodQuality,
                                          numberOfRooms: normalizedRooms,
                                          squareFootage: normalizedSquareFootage)

            let home = HomeInfo(neighborhoodQuality: neighborhoodQuality,
                                numberOfRooms: normalizedRooms,
                                squareFootage: normalizedSquareFootage,
                                value: homeValue)
            return home
        }
    static let priceFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        currencyFormatter.maximumSignificantDigits = 4
        return currencyFormatter
    }()

    func formattedPriceValue(value: Float) -> String {
        let priceFloat = value * 1000000
        let nsNumber = NSNumber(value: priceFloat)
        let priceString = HouseBuilder.priceFormatter.string(from: nsNumber) ?? ""
        return priceString
    }
}
struct HouseThought: Identifiable {
    let id = UUID()
    var homeInfo: HomeInfo
    let predictedValue: Float
}
class Brain: ObservableObject {

    // Just creating an empty network as a placeholder
    var network: NeuralNetwork = NeuralNetwork(inputSize: 0, hiddenSize: 0, outputSize: 0)

    @Published var learnedThoughts: [HouseThought] = []
    @Published var unlearnedThoughts: [HouseThought] = []

    init() {
        initializeNetwork()
    }

    func initializeNetwork() {
        network = NeuralNetwork(inputSize: 5,
                                hiddenSize: 7,
                                outputSize: 1)
        let homes = [HouseBuilder.makeRandomHouse(),
                     HouseBuilder.makeRandomHouse(),
                     HouseBuilder.makeRandomHouse()]
        unlearnedThoughts = evaluateNetwork(withHomes: homes)
    }

    func evaluateNetwork(withHomes homes: [HomeInfo]) -> [HouseThought] {
        var evaluations: [HouseThought] = []
        for home in homes {
            let resultList = network.predict(input: home.trainingData.features)

            let predictedValue = resultList[0]

            let thought = HouseThought(homeInfo: home, predictedValue: predictedValue)

            evaluations.append(thought)
        }

        return evaluations
    }

    func learn(fromHomes homes: [HomeInfo], reporter: ProgressReporter) {
        let featureData: [[Float]] = homes.map { home in
            let trainingValues = home.trainingData.features
            return trainingValues
        }

        let targetData: [[Float]] = homes.map { home in
            let target = home.trainingData.targets
            return target
        }

        let epochs = 100
        let learningRate: Float = 0.1

        network.train(featureInput: featureData,
                      targetOutput: targetData,
                      epochs: epochs,
                      learningRate: learningRate,
                      loss: .mse,
                      reporter: reporter)
    }
}
struct TrainingView: View {
    @ObservedObject var brain: Brain
    @StateObject var reporter = ProgressReporter()
    @State var start = true
    let builder: HouseBuilder
    var body: some View {
        VStack {
            Text("Finshed Training: \(String(reporter.finished))")
                .font(.title)
                .padding()
            Chart(reporter.data) { trainingError in
                LineMark(
                    x: .value("Epoch", trainingError.epoch),
                    y: .value("Total Error", trainingError.error)
                )
            }
            .chartXAxisLabel("Epochs")
            .chartYAxisLabel("Learning Error")
            .padding()
            HStack {
                Button("Train") {
                    if reporter.finished || start {
                        if start {
                            start = false
                        }
                        brain.learn(fromHomes: builder.homes, reporter: reporter)
                    }
                }
                Button("Rebuild Network/Start over") {
                    brain.initializeNetwork()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
struct EvaluationView: View {
    @ObservedObject var brain: Brain
    let builder: HouseBuilder

    var body: some View {
        VStack {
            Button("Evaluate Network / Get Learned Thoughts / Network Predictions") {
                let homes = [HouseBuilder.makeRandomHouse(),
                             HouseBuilder.makeRandomHouse(),
                             HouseBuilder.makeRandomHouse()]
                brain.learnedThoughts = brain.evaluateNetwork(withHomes: homes)
            }
            List {
                Section(header: Text("Unlearned Thoughts")) {
                    ForEach(brain.unlearnedThoughts) { thought in
                        HouseThoughtCell(builder: builder, thought: thought)
                    }
                }
                Section(header: Text("Learned Thoughts")) {
                    ForEach(brain.learnedThoughts) { thought in
                        HouseThoughtCell(builder: builder, thought: thought)
                    }
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

struct HouseThoughtCell: View {
    let builder: HouseBuilder
    let thought: HouseThought
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Actual \(builder.formattedPriceValue(value: thought.homeInfo.value))")
                .padding(.bottom, -12)
            Text("Predicted \(builder.formattedPriceValue(value: thought.predictedValue))")
            Text("Difference \(builder.formattedPriceValue(value: abs(thought.predictedValue - thought.homeInfo.value))) ")
                .fontWeight(.bold)
        }

    }
}
struct ContentView: View {
    @StateObject var builder = HouseBuilder()
    @StateObject var brain = Brain()


    var body: some View {
        TabView {
            TrainingView(brain: brain, builder: builder)
                .tabItem {
                    Label("Train", systemImage: "train.side.front.car")
                }
            EvaluationView(brain: brain, builder: builder)
                .tabItem {
                    Label("Evaluation", systemImage: "wand.and.stars")
                }
        }
    }
}
