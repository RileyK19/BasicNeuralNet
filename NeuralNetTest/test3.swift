//
//  test3.swift
//  NeuralNetTest
//
//  Created by Riley Koo on 4/14/24.
//

// source: https://www.cephalopod.studio/blog/a-casual-yet-thorough-amp-hands-on-explanation-of-neural-networks-with-swift-swiftui-and-charts

import SwiftUI
enum ActivationFunction {
    case sigmoid
    case blank

    func forward(x: Float) -> Float {
        switch self {
        case .sigmoid:
            return 1 / (1 + exp(-x))
        case .blank:
            return x * 1
        }
    }

    func derivative(x: Float) -> Float {
        switch self {
        case .sigmoid:
            return x * (1 - x)
        case .blank:
            return 1
        }
    }
}
public class Neuron {
    var weights: [Float]
    var bias: Float
    var inputCache: [Float] = []
    var outputCache: Float = 0
    var delta: Float = 0
    var activation: ActivationFunction
    
    init(weightCount: Int, activation: ActivationFunction) {
        self.activation = activation
        bias = Float.random(in: 0 ..< 1)
        weights = []
        for _ in 0 ..< weightCount {
            weights.append(Float.random(in: 0 ..< 1))
        }
    }
    
    func activate(inputs: [Float]) -> Float {
        var value = bias
        for (index, weight) in weights.enumerated() {
            if index < inputs.count {
                value += weight * inputs[index]
            }
        }
        
        value = activation.forward(x: value)
        
        outputCache = value
        inputCache = inputs
        
        return value
    }
    func backward(error: Float, learningRate: Float, errorsForPreviousLayer: [Float]) -> [Float] {
        var errorsToPassBackward = errorsForPreviousLayer
        let outputDerivativeError = error * self.activation.derivative(x: outputCache)
        
        // The index of the weight will correspond to the index of the neuron in the previous layer.
        for (weightIndex, weight) in weights.enumerated() {
            errorsToPassBackward[weightIndex] += outputDerivativeError * weight
        }
        
        // Now that we have that error, we can update the weights of our current neuron
        for (inputIndex, input) in inputCache.enumerated() {
            var currentWeight = weights[inputIndex]
            currentWeight -= learningRate * outputDerivativeError * input
            weights[inputIndex] = currentWeight
        }
        
        bias -= learningRate * outputDerivativeError
        
        return errorsToPassBackward
    }
}
public class Layer {
    var neurons: [Neuron] = []
    var inputSize = 0
    var activation: ActivationFunction

    init(inputSize: Int, outputSize: Int, activation: ActivationFunction) {
        for _ in 0 ..< outputSize {
            let neuron = Neuron(weightCount: inputSize, activation: activation)
            neurons.append(neuron)
        }

        self.inputSize = inputSize
        self.activation = activation
    }

    func forward(inputs: [Float]) -> [Float] {
        var newInputs: [Float] = []
        for neuron in neurons {
            let activationValue = neuron.activate(inputs: inputs)
            newInputs.append(activationValue)
        }
        return newInputs
    }

    func backward(errors: [Float], learningRate: Float) -> [Float] {
        var errorsForPreviousLayer: [Float] = []

        // Here we prepare errors that we will pass to the layer behind us.
        for _ in 0 ..< self.inputSize {
            errorsForPreviousLayer.append(0)
        }

        for (neuronIndex, neuron) in neurons.enumerated() {
            let error = errors[neuronIndex]

            // The neurons wil update their weigths with the errors, and also update the errors that will be passed to the previous layer.
            errorsForPreviousLayer = neuron.backward(error: error, learningRate: learningRate, errorsForPreviousLayer: errorsForPreviousLayer)
        }

        // Finally, we pass those errors to the layer behind us.
        return errorsForPreviousLayer
    }
}
public class NeuralNetwork {
    private var layers: [Layer] = []
    public init(inputSize: Int, hiddenSize: Int, outputSize: Int) {
        self.layers.append(Layer(inputSize: inputSize, outputSize: hiddenSize, activation: .sigmoid))
        self.layers.append(Layer(inputSize: hiddenSize, outputSize: outputSize, activation: .sigmoid))
    }

    func forward(data: [Float]) -> [Float] {
        var inputs = data
        for layer in layers {
            let newInput = layer.forward(inputs: inputs)
            inputs = newInput
        }

        return inputs
    }

    func backward(errors: [Float], learningRate: Float) {
        var errors = errors
        for layer in layers.reversed() {
            errors = layer.backward(errors: errors, learningRate: learningRate)
        }
    }

    func predict(input: [Float]) -> [Float] {
        let output = forward(data: input)
        return output
    }
    
    func train(featureInput: [[Float]], targetOutput: [[Float]], epochs: Int, learningRate: Float, loss: LossFunction, reporter: ProgressReporter) {
        Task {

            await reporter.setFinished(false)

            var learningErrors: [ProgressReporter.LearningError] = []
            for epoch in 0 ..< epochs {
                var averageEpochError: Float = 0
                for (featureIndex, features) in featureInput.enumerated() {
                    let outputs = forward(data: features)

                    let expected = targetOutput[featureIndex]

                    let error = loss.loss(forExpected: expected, predicted: outputs)

                    // Total error is just for our reporting
                    averageEpochError += (error / 2.0)

                    let derivativeError = loss.derivative(expected: expected, predicted: outputs)

                    backward(errors: [derivativeError], learningRate: learningRate)
                }

                let errorToReport = ProgressReporter.LearningError(epoch: epoch, error: averageEpochError)
                learningErrors.append(errorToReport)
                let errorsToReport = learningErrors
                Task {
                    await reporter.setData(newData: errorsToReport)
                }
            }

            await reporter.setFinished(true)
        }
    }
}
class ProgressReporter: ObservableObject {
    struct LearningError: Identifiable {
        var id: Int {
            epoch
        }
        let epoch: Int
        let error: Float
    }

    @MainActor
    func setData(newData: [LearningError]) async {
        data = newData
    }

    @MainActor
    func setFinished(_ finished: Bool) async {
        self.finished = finished
    }

    @Published var data: [LearningError] = []

    @Published var finished = false
}
enum LossFunction {
    case mse

    func loss(forExpected expected: [Float], predicted: [Float]) -> Float {
        let squaredDifference = zip(expected, predicted).map{ expectedResult, predictedResult in
            pow(expectedResult - predictedResult, 2.0)
        }

        let average = squaredDifference.reduce(0, +) / Float(predicted.count)

        return average
    }

    func derivative(expected: [Float], predicted: [Float]) -> Float {
        let difference = zip(expected, predicted).map{ expectedResult, predictedResult in
            2 * (expectedResult - predictedResult)
        }

        let sum = difference.reduce(0, +)
        return -(sum / Float(expected.count))
    }
}
