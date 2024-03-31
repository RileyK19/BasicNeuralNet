////
////  ContentView.swift
////  NeuralNetTest
////
////  Created by Riley Koo on 3/30/24.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
////        mainView()
//        NNView(neuralNet: NeuralNet(4, 3))
////        NNView(neuralNet: NeuralNet(cols: LayerWrapper(layers:
////            [Layer(neurons: [
////                Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                   Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                   Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                ],
////                   floats: [0.0, 0.0, 0.0, 0.0]
////                  ),
////             Layer(neurons: [
////                 Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                 Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                    Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                    Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                 ],
////                    floats: [0.0, 0.0, 0.0, 0.0]
////                   ),
////             Layer(neurons: [
////                 Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                 Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                 ],
////                    floats: [0.0, 0.0, 0.0, 0.0]
////                   ),
////             Layer(neurons: [
////                 Neuron(weights: [Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1)], bias: Float.random(in: 0..<1)),
////                 ],
////                    floats: [0.0, 0.0, 0.0, 0.0]
////                   )
////             ]
////        )
////        )
////        )
//    }
//}
////
////struct mainView: View {
////    @State var network: NeuralNetwork = NeuralNetwork()
////    @State var curLayer: Int = 0
////    @State var result = ""
////    var body: some View {
////        VStack {
////            Buttons
////            Spacer()
////            Text(String(curLayer))
////            if network.views.count != 0 {
////                network.views[curLayer]
////            }
////            Spacer()
////        }
////    }
////    var Buttons: some View {
////        HStack {
////            Button {
////                network = NeuralNetwork()
////                
////                network.learningRate = 0.5
////                network.epochs = 30
////                network.batchSize = 8
////                
////                network.layers = [
////                    Dense(inputSize: 4, neuronsCount: 4, functionRaw: .sigmoid),
////                    Dense(inputSize: 4, neuronsCount: 4, functionRaw: .sigmoid),
////                    Dense(inputSize: 4, neuronsCount: 1, functionRaw: .sigmoid)
////                ]
////                
////                let set = Dataset(items: [
////                    .init(input: .init(size: .init(width: 4), body: [0.0, 0.0, 0.0, 1.0]), output: .init(size: .init(width: 1), body: [0.0])),
////                    .init(input: .init(size: .init(width: 4), body: [1.0, 0.0, 0.0, 1.0]), output: .init(size: .init(width: 1), body: [0.0])),
////                    .init(input: .init(size: .init(width: 4), body: [0.0, 1.0, 1.0, 1.0]), output: .init(size: .init(width: 1), body: [0.0])),
////                    .init(input: .init(size: .init(width: 4), body: [0.0, 0.0, 1.0, 0.0]), output: .init(size: .init(width: 1), body: [1.0])),
////                    .init(input: .init(size: .init(width: 4), body: [0.0, 1.0, 0.0, 0.0]), output: .init(size: .init(width: 1), body: [1.0])),
////                    .init(input: .init(size: .init(width: 4), body: [1.0, 0.0, 0.0, 0.0]), output: .init(size: .init(width: 1), body: [1.0]))
////                ])
////                
////                network.train(set: set, save: true)
////            } label: {
////                ZStack {
////                    RoundedRectangle(cornerRadius: 25)
////                        .frame(width: 175, height: 100)
////                        .foregroundStyle(Color.blue)
////                    Text("Initialize")
////                        .foregroundStyle(Color.white)
////                }
////            }
////            Button {
////                if curLayer < network.views.count-1 {
////                    curLayer += 1
////                }
////            } label: {
////                ZStack {
////                    RoundedRectangle(cornerRadius: 25)
////                        .frame(width: 175, height: 100)
////                        .foregroundStyle(Color.blue)
////                    Text("Next")
////                        .foregroundStyle(Color.white)
////                }
////            }
////        }
////    }
////}
////
////public struct LayerView: View {
////    @State var layers: [Layer]
////    public var body : some View {
////        HStack {
////            ForEach(Array(0..<layers.count), id:\.self) {layersIndx in
////                OneLayerView(layer: layers[layersIndx])
////            }
////        }
////    }
////}
////struct OneLayerView: View {
////    @State var layer: Layer
////    var body: some View {
////        VStack {
////            ForEach(Array(0..<layer.neurons.count), id:\.self) {neuronsIndx in
////                NeuronView(neuron: layer.neurons[neuronsIndx])
////            }
////        }
////    }
////}
////struct NeuronView: View {
////    @State var neuron: Neuron
////    var body: some View {
////        VStack {
//////            Text(String(neuron.bias))
////            ForEach(Array(0..<neuron.weights.count), id:\.self) {x in
////                Text(String((neuron.weights[x] + neuron.weightsDelta[x]).decimals(3)))
////            }
////        }
////        .padding()
////        .background(
////            RoundedRectangle(cornerRadius: 25)
////                .foregroundStyle(Color.blue)
////        )
////    }
////}
////extension Float {
////    func decimals(_ nbr: Int) -> String {
////        return String(self.formatted(.number.precision(.fractionLength(nbr))))
////    }
////}
