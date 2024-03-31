////
////  Test2.swift
////  NeuralNetTest
////
////  Created by Riley Koo on 4/14/24.
////
//
//import SwiftUI
//
//struct Matrix {
//    var matrix : [[Float]]
//    var n : Int, m : Int
//    func getNum(_ x: Int, _ y: Int) -> Float{
//        return matrix[x][y]
//    }
//    mutating func setNum(_ x: Int, _ y: Int, _ set: Float) {
//        matrix[x][y] = set
//    }
//    mutating func initMatrix(_ n: Int, _ m: Int){ // matrix m x n
//        matrix = []
//        for _ in 0..<m {
//            matrix.append(Array(repeating: 0, count: n))
//        }
//    }
//    func getVector(col: Int = -1, row: Int = -1) -> [Float] {
//        var ret: [Float] = []
//        for x in 0..<(col == -1 ? n : m) {
//            ret.append(matrix[col == -1 ? row : x][col == -1 ? x : col])
//        }
//        return ret
//    }
//    mutating func setVector(col: Int = -1, row: Int = -1, _ set: [Float]) {
//        for x in 0..<(col == -1 ? n : m) {
//            matrix[col == -1 ? row : x][col == -1 ? x : col] = set[x]
//        }
//    }
//    static func *(lhs: Matrix, rhs: Matrix) -> Matrix {
//        var ret: Matrix = Matrix(matrix: [], n: rhs.n, m: lhs.m)
//        ret.initMatrix(ret.n, ret.m)
//        for x in 0..<lhs.m {
//            var row = lhs.getVector(row: x)
//            for y in 0..<rhs.n {
//                var col = rhs.getVector(col: y)
//                var tmp: Float = 0
//                for z in 0..<lhs.n {
//                    tmp += row[z] * col[z]
//                }
//                ret.setNum(x, y, tmp)
//            }
//        }
//        return ret
//    }
//    func runFunc(_ f: ActivationFunction, _ forward: Bool = true) -> Matrix {
//        var m2 = matrix
//        for x in 0..<n {
//            for y in 0..<m {
//                m2[y][x] = forward ? f.forward(x: matrix[y][x]) : f.derivative(x: matrix[y][x])
//            }
//        }
//        return Matrix(matrix: m2, n: n, m: m)
//    }
//    mutating func makeRandom() -> Matrix {
//        for x in 0..<m {
//           for y in 0..<n {
//                matrix[x][y] = Float.random(in: 0..<1)
//            }
//        }
//        return self
//    }
//}
//
//struct NNCol {
//    var matrix: Matrix
//    var numIn: Int
//    var numNodes: Int
//    var inputs: [Float]
//    var outputs: [Float]
//    var function: ActivationFunction
//    mutating func initMatrix() {
//        matrix = Matrix(matrix: [], n: numNodes, m: numIn + 1)
//        matrix.initMatrix(matrix.n, matrix.m)
//    }
//    mutating func setBias(_ bias: [Float]){
//        matrix.setVector(row: numIn, bias)
//    }
//    mutating func setWeight(_ node: Int, _ weights: [Float]) {
//        matrix.setVector(row: node, weights)
//    }
//    mutating func run(_ inputs: Matrix) -> Matrix {
//        self.inputs = inputs.getVector(row: 0)
//        let tmp = inputs*matrix.runFunc(function)
//        outputs = tmp.getVector(col: 0)
//        return tmp
//    }
//    mutating func backward(error: Float, learningRate: Float, errorsForPreviousLayer: [Float], neuronNum: Int) -> [Float]{
////source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts
//        var weights = matrix.getVector(row: neuronNum)
//        var errorsToPassBackward = errorsForPreviousLayer
//        let outputDerivativeError = error * self.function.derivative(x: outputs[neuronNum])
//
//        // The index of the weight will correspond to the index of the neuron in the previous layer.
//        for (weightIndex, weight) in weights.enumerated() {
////            errorsToPassBackward[weightIndex] += outputDerivativeError * weight
//        }
//
//        // Now that we have that error, we can update the weights of our current neuron
//        for (inputIndex, input) in inputs.enumerated() {
//            var currentWeight = weights[inputIndex]
//            currentWeight -= learningRate * outputDerivativeError * input
//            weights[inputIndex] = currentWeight
//        }
//
//        matrix.setNum(matrix.m, neuronNum,
//                      matrix.matrix[matrix.m][neuronNum] - learningRate * outputDerivativeError)
//
//        matrix.setVector(row: neuronNum, weights)
//        
//        return errorsToPassBackward
//    }
//    mutating func backwardAll(errors: [Float], learningRate: Float) -> [Float] {
////source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts
//        var errorsForPreviousLayer: [Float] = []
//
//        // Here we prepare errors that we will pass to the layer behind us.
//        for _ in 0 ..< self.inputs.count {
//            errorsForPreviousLayer.append(0)
//        }
//
//        for x in 0..<outputs.count {
//            let error = errors[x]
//
//            // The neurons wil update their weigths with the errors, and also update the errors that will be passed to the previous layer.
//            errorsForPreviousLayer = backward(error: error, learningRate: learningRate, errorsForPreviousLayer: errorsForPreviousLayer, neuronNum: x)
//        }
//
//        // Finally, we pass those errors to the layer behind us.
//        return errorsForPreviousLayer
//    }
//    init(inputSize: Int, outputSize: Int, activation: ActivationFunction) {
//        matrix = Matrix(matrix: [], n: inputSize, m: outputSize)
//        matrix.initMatrix(inputSize, outputSize)
//        matrix.makeRandom()
//        numIn = inputSize
//        numNodes = outputSize
//        inputs = []
//        outputs = []
//        function = activation
//    }
//}
//enum ActivationFunction {
//    case sigmoid
//    case blank
//
//    func forward(x: Float) -> Float {
//        switch self {
//        case .sigmoid:
//            return 1 / (1 + exp(-x))
//        case .blank:
//            return x * 1
//        }
//    }
//
//    func derivative(x: Float) -> Float {
//        switch self {
//        case .sigmoid:
//            return x * (1 - x)
//        case .blank:
//            return 1
//        }
//    }
//}
//class NN: ObservableObject {
//    var layers: [NNCol]
//    init(layers: [NNCol]) {
//        self.layers = layers
//    }
//    public init(inputSize: Int, hiddenSize: Int, outputSize: Int) {
//        layers = []
//        self.layers.append(NNCol(inputSize: inputSize, outputSize: hiddenSize, activation: .sigmoid))
//        self.layers.append(NNCol(inputSize: hiddenSize, outputSize: outputSize, activation: .sigmoid))
//    }
//    func forward(data: [Float]) -> [Float] {
//        var inputs = data
//        for x in 0..<layers.count {
//            let newInput = layers[x].run(Matrix(matrix: [inputs], n: inputs.count, m: 1))
//            inputs = newInput.getVector(col: 0)
//        }
//
//        return inputs
//    }
//    func backward(errors: [Float], learningRate: Float) {
//        var errors = errors
//        for x in 0..<layers.count {
//            errors = layers[layers.count-x-1].backwardAll(errors: errors, learningRate: learningRate)
//        }
//    }
//
//    func predict(input: [Float]) -> [Float] {
//        let output = forward(data: input)
//        return output
//    }
//    func train(featureInput: [[Float]], targetOutput: [[Float]], epochs: Int, learningRate: Float, loss: LossFunction, reporter: ProgressReporter) {
////source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts
//        Task {
//
//            await reporter.setFinished(false)
//
//            var learningErrors: [ProgressReporter.LearningError] = []
//            for epoch in 0 ..< epochs {
//                var averageEpochError: Float = 0
//                for (featureIndex, features) in featureInput.enumerated() {
//                    let outputs = forward(data: features)
//
//                    let expected = targetOutput[featureIndex]
//
//                    let error = loss.loss(forExpected: expected, predicted: outputs)
//
//                    // Total error is just for our reporting
//                    averageEpochError += (error / 2.0)
//
//                    let derivativeError = loss.derivative(expected: expected, predicted: outputs)
//
//                    backward(errors: [derivativeError], learningRate: learningRate)
//                }
//
//                let errorToReport = ProgressReporter.LearningError(epoch: epoch, error: averageEpochError)
//                learningErrors.append(errorToReport)
//                let errorsToReport = learningErrors
//                Task {
//                    await reporter.setData(newData: errorsToReport)
//                }
//            }
//
//            await reporter.setFinished(true)
//        }
//    }
//}
//class ProgressReporter: ObservableObject {
//    //source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts
//    struct LearningError: Identifiable {
//        var id: Int {
//            epoch
//        }
//        let epoch: Int
//        let error: Float
//    }
//
//    @MainActor
//    func setData(newData: [LearningError]) async {
//        data = newData
//    }
//
//    @MainActor
//    func setFinished(_ finished: Bool) async {
//        self.finished = finished
//    }
//
//    @Published var data: [LearningError] = []
//
//    @Published var finished = false
//}
//enum LossFunction {
//    //source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts
//    case mse
//
//    func loss(forExpected expected: [Float], predicted: [Float]) -> Float {
//        let squaredDifference = zip(expected, predicted).map{ expectedResult, predictedResult in
//            pow(expectedResult - predictedResult, 2.0)
//        }
//
//        let average = squaredDifference.reduce(0, +) / Float(predicted.count)
//
//        return average
//    }
//
//    func derivative(expected: [Float], predicted: [Float]) -> Float {
//        let difference = zip(expected, predicted).map{ expectedResult, predictedResult in
//            2 * (expectedResult - predictedResult)
//        }
//
//        let sum = difference.reduce(0, +)
//        return -(sum / Float(expected.count))
//    }
//}
