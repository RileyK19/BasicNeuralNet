////
////  NeuralNet-test.swift
////  NeuralNetTest
////
////  Created by Riley Koo on 4/1/24.
////
//
//import Foundation
//import SwiftUI
//
//struct Neuron {
//    var weights: [Float]
//    var bias: Float
//    var value: Float = 0.0
//    mutating func calc(inputs: [Float]) -> Float {
//        value = 0
//        for x in 0..<weights.count {
//            let tmp = weights[x]*inputs[x] + bias
//            value += tmp
//        }
//        return value
//    }
//    mutating func train(_ biasAdj: Float, _ weightAdj: Float, _ changeWeight: [Bool]) -> Bool {
//        if f(value) < 0.5 {
//            bias -= biasAdj
//        } else if f(value) > 0.5 {
//            bias += biasAdj
//        }
//        for z in 0..<weights.count {
//            weights[z] += changeWeight[z] ? weightAdj : -weightAdj
//        }
//        return value > 0.5
//    }
//}
//struct Layer {
//    var neurons: [Neuron]
//    var floats: [Float]
//    mutating func calc(inputs: [Float]) {
//        for x in 0..<neurons.count {
//            neurons[x].calc(inputs: inputs)
//        }
//        calcFloats()
//    }
//    mutating func calcFloats(){
//        neurons = []
//        for neuron in neurons {
//            floats.append(neuron.value)
//        }
//    }
//    mutating func train(_ biasAdj: Float, _ weightAdj: Float, _ changeWeight: [Bool]) -> [Bool] {
//        var CWCopy: [Bool] = []
//        for y in 0..<floats.count {
//            CWCopy.append(neurons[y].train(biasAdj, weightAdj, changeWeight))
//        }
//        return CWCopy
//    }
//}
//struct LayerWrapper {
//    var layers: [Layer]
//    mutating func calc(input: [Float]) -> Float {
//        var tmpInput = input
//        for x in 0..<layers.count {
//            layers[x].calc(inputs: tmpInput)
//            tmpInput = layers[x].floats
//        }
//        return f(layers[layers.count-1].floats[0])
//    }
//    mutating func train(_ biasAdj: Float, _ weightAdj: Float) {
//        var changeWeight: [Bool] = [false, false, false, false]
//        var changeWeight2: [Bool] = []
//        for x in 0..<layers.count {
//            changeWeight2 = layers[x].train(biasAdj, weightAdj, changeWeight)
//            changeWeight = changeWeight2
//        }
//    }
//}
//func f(_ input: Float) -> Float{
//    return 1/(1+exp(-input))
//}
//class NeuralNet {
//    var cols: LayerWrapper
//    init(_ layers: Int, _ rows: Int){
//        var LW: LayerWrapper = LayerWrapper(layers: [])
//        for _ in 0..<layers {
//            var bias: [Float] = []
//            var neurons: [Neuron] = []
//            for _ in 0..<rows {
//                var floats: [Float] = []
//                for _ in 0..<rows {
//                    floats.append(Float.random(in: 0..<1))
//                }
//                let tmp = Float.random(in: 0..<1)
//                neurons.append(Neuron(weights: floats, bias: tmp))
//                bias.append(tmp)
//            }
//            LW.layers.append(Layer(neurons: neurons, floats: bias))
//        }
//        var _: [Float] = []
//        let tmp = Float.random(in: 0..<1)
//        var neuron: Neuron = Neuron(weights: [], bias: 0)
//        for _ in 0..<rows {
//            var floats: [Float] = []
//            for _ in 0..<rows {
//                floats.append(Float.random(in: 0..<1))
//            }
//            neuron = (Neuron(weights: floats, bias: tmp))
//        }
//        LW.layers.append(Layer(neurons: [neuron], floats: [tmp]))
//        cols = LW
//    }
//    func train(input: [Float], expected: Float){
//        let tmp = cols.calc(input: input)
//        if tmp > expected {
//            cols.train(0.2, 0.2)
//        } else if tmp < expected {
//            cols.train(-0.2, -0.2)
//        }
//    }
//    func predict(input: [Float]) -> Float {
//        return cols.calc(input: input)
//    }
//}
//
//struct NeuronView: View {
//    var neuron: Neuron
//    var body: some View {
//        ZStack {
//            Circle()
//                .frame(width: 50, height: 50)
//            Text("\(neuron.bias, specifier: "%.2f")")
//                .foregroundStyle(Color.white)
//        }
//    }
//}
//struct LayerView: View {
//    var layer: Layer
//    var body: some View {
//        VStack {
//            ForEach(Array(0..<layer.neurons.count), id:\.self) {x in
//                NeuronView(neuron: layer.neurons[x])
//            }
//        }
//    }
//}
//struct NNView: View {
//    @State var neuralNet: NeuralNet
//    let trains: [[Float]] = [[0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 1.0, 0.0], [0.0, 1.0, 0.0, 0.0], [1.0, 0.0, 0.0, 0.0]]
//    let trainResults: [Float] = [0.0, 1.0, 1.0, 1.0]
//    @State var curTrain = 0
//    var body: some View {
//        VStack {
//            HStack {
//                ForEach(Array(0..<neuralNet.cols.layers.count), id:\.self) {x in
//                    LayerView(layer: neuralNet.cols.layers[x])
//                }
//            }
//            Button {
//                if curTrain < trains.count {
//                    neuralNet.train(input: trains[curTrain], expected: trainResults[curTrain])
//                    curTrain += 1
//                }
//            } label: {
//                Text("Train")
//            }
//        }
//    }
//}
