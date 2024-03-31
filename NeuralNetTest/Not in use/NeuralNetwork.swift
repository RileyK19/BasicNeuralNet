////
////  NeuralNetwork.swift
////  NeuralNetTest
////
////  Created by Riley Koo on 3/30/24.
////
//
//import Foundation
//import SwiftUI
////source: https://github.com/stefjen07/NeuralNetwork.git
//
////Core
//public enum DataSizeType: Int, Codable {
//    case oneD = 1
//    case twoD
//    case threeD
//}
//
//public struct DataSize: Codable {
//    var type: DataSizeType
//    var width: Int
//    var height: Int?
//    var depth: Int?
//    
//    public init(width: Int) {
//        type = .oneD
//        self.width = width
//    }
//    
//    public init(width: Int, height: Int) {
//        type = .twoD
//        self.width = width
//        self.height = height
//    }
//    
//    public init(width: Int, height: Int, depth: Int) {
//        type = .threeD
//        self.width = width
//        self.height = height
//        self.depth = depth
//    }
//    
//}
//
//public struct DataPiece: Codable, Equatable {
//    public static func == (lhs: DataPiece, rhs: DataPiece) -> Bool {
//        return lhs.body == rhs.body
//    }
//    
//    public var size: DataSize
//    public var body: [Float]
//    
//    func get(x: Int) -> Float {
//        return body[x]
//    }
//    
//    func get(x: Int, y: Int) -> Float {
//        return body[x+y*size.width]
//    }
//    
//    func get(x: Int, y: Int, z: Int) -> Float {
//        return body[z+(x+y*size.width)*size.depth!]
//    }
//    
//    public init(size: DataSize, body: [Float]) {
//        var flatSize = size.width
//        if let height = size.height {
//            flatSize *= height
//        }
//        if let depth = size.depth {
//            flatSize *= depth
//        }
//        if flatSize != body.count {
//            fatalError("DataPiece body does not conform to DataSize.")
//        }
//        self.size = size
//        self.body = body
//    }
//    
//    public init(image: CGImage) {
//        let colorSpace = CGColorSpaceCreateDeviceGray()
//        let width = 32
//        let height = 32
//        let bitsPerComponent = image.bitsPerComponent
//        let bytesPerRow = image.bytesPerRow
//        let totalBytes = height * bytesPerRow
//        var buffer = Array(repeating: UInt8.zero, count: totalBytes)
//        let contextRef = CGContext(data: &buffer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)!
//        contextRef.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
//        self.size = .init(width: width, height: height)
//        var body = [Float]()
//        buffer.withUnsafeBufferPointer { bufferPtr in
//            let pixelValues = Array<UInt8>(bufferPtr)
//            body = pixelValues.map { v in
//                return Float(v)/Float(UInt8.max)
//            }
//        }
//        self.body = body
//    }
//}
//
//public struct DataItem: Codable {
//    var input: DataPiece
//    var output: DataPiece
//    
//    public init(input: DataPiece, output: DataPiece) {
//        self.input = input
//        self.output = output
//    }
//    
//    public init(input: [Float], inputSize: DataSize, output: [Float], outputSize: DataSize) {
//        self.input = DataPiece(size: inputSize, body: input)
//        self.output = DataPiece(size: outputSize, body: output)
//    }
//}
//
//public struct Dataset: Codable {
//    public var items: [DataItem]
//    
//    public func save(to url: URL) {
//        let encoder = JSONEncoder()
//        guard let encoded = try? encoder.encode(self) else {
//            print("Unable to encode model.")
//            return
//        }
//        do {
//            try encoded.write(to: url)
//        } catch {
//            print("Unable to write model to disk.")
//        }
//    }
//    
//    public init(from url: URL) {
//        let decoder = JSONDecoder()
//        guard let data = try? Data(contentsOf: url) else {
//            fatalError("Unable to get data from Dataset file.")
//        }
//        guard let decoded = try? decoder.decode(Dataset.self, from: data) else {
//            fatalError("Unable to decode data from Dataset file.")
//        }
//        self.items = decoded.items
//    }
//    
//    public init(items: [DataItem]) {
//        self.items = items
//    }
//    
//    public init(folderPath: String) {
//        self.items = []
//        let manager = FileManager.default
//        var inputs = [DataPiece]()
//        var outputs = [Int]()
//        var classCount = 0
//        do {
//            for content in try manager.contentsOfDirectory(atPath: folderPath) {
//                let isDirectory = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
//                let path = folderPath+"/"+content
//                if manager.fileExists(atPath: path, isDirectory: UnsafeMutablePointer<ObjCBool>(isDirectory)) {
//                    if isDirectory.pointee.boolValue {
//                        for file in try manager.contentsOfDirectory(atPath: path) {
//                            let isDirectory = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
//                            let path = path+"/"+file
//                            if manager.fileExists(atPath: path, isDirectory: UnsafeMutablePointer<ObjCBool>(isDirectory)) {
//                                if !isDirectory.pointee.boolValue {
//                                    let url = URL(fileURLWithPath: path)
//                                    let splits = file.split(separator: ".")
//                                    if splits.count < 2 {
//                                        continue
//                                    }
//                                    if splits.last  == "png" {
//                                        let data = try Data(contentsOf: url)
//                                        guard let provider = CGDataProvider(data: NSData(data: data)) else { fatalError() }
//                                        guard let image = CGImage(pngDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { fatalError() }
//                                        inputs.append(.init(image: image))
//                                        outputs.append(classCount)
//                                    }
//                                }
//                            }
//                        }
//                        classCount += 1
//                    }
//                }
//            }
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//        for i in 0..<inputs.count {
//            items.append(.init(input: inputs[i], output: classifierOutput(classes: classCount, correct: outputs[i])))
//        }
//    }
//}
//
//final public class NeuralNetwork: Codable {
//    public var layers: [Layer] = []
//    public var learningRate = Float(0.05)
//    public var epochs = 30
//    public var batchSize = 16
//    var dropoutEnabled = true
//    
//    @Published var views: [LayerView] = []
//    
//    private enum CodingKeys: String, CodingKey {
//        case layers
//        case learningRate
//        case epochs
//        case batchSize
//    }
//    
//    public func printSummary() {
//        for rawLayer in layers {
//            switch rawLayer {
//            case _ as Flatten:
//                print("Flatten layer")
//            case let layer as Convolutional2D:
//                print("Convolutional 2D layer: \(layer.filters.count) filters")
//            case let layer as Dense:
//                print("Dense layer: \(layer.neurons.count) neurons")
//            case let layer as Dropout:
//                print("Dropout layer: \(layer.neurons.count) neurons, \(layer.probability) probability")
//            default:
//                break
//            }
//        }
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        let wrappers = layers.map { LayerWrapper($0) }
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(wrappers, forKey: .layers)
//        try container.encode(learningRate, forKey: .learningRate)
//        try container.encode(epochs, forKey: .epochs)
//        try container.encode(batchSize, forKey: .batchSize)
//    }
//    
//    public init(fileName: String) {
//        let decoder = JSONDecoder()
//        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(fileName)
//        guard let data = try? Data(contentsOf: url) else {
//            print("Unable to read model from file.")
//            return
//        }
//        guard let decoded = try? decoder.decode(NeuralNetwork.self, from: data) else {
//            print("Unable to decode model.")
//            return
//        }
//        self.layers = decoded.layers
//        self.learningRate = decoded.learningRate
//        self.epochs = decoded.epochs
//        self.batchSize = decoded.batchSize
//    }
//    
//    public init() {
//        
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let wrappers = try container.decode([LayerWrapper].self, forKey: .layers)
//        self.layers = wrappers.map { $0.layer }
//        self.learningRate = try container.decode(Float.self, forKey: .learningRate)
//        self.epochs = try container.decode(Int.self, forKey: .epochs)
//        self.batchSize = try container.decode(Int.self, forKey: .batchSize)
//    }
//    
//    public func saveModel(fileName: String) {
//        let encoder = JSONEncoder()
//        guard let encoded = try? encoder.encode(self) else {
//            print("Unable to encode model.")
//            return
//        }
//        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(fileName)
//        do {
//            try encoded.write(to: url)
//        } catch {
//            print("Unable to write model to disk.")
//        }
//    }
//    
//    public func train(set: Dataset, save: Bool) -> Float {
//        dropoutEnabled = true
//        var error = Float.zero
//        for epoch in 0..<epochs {
//            var shuffledSet = set.items.shuffled()
//            error = Float.zero
//            while !shuffledSet.isEmpty {
//                let batch = shuffledSet.prefix(batchSize)
//                for item in batch {
//                    let predictions = forward(networkInput: item.input)
//                    for i in 0..<item.output.body.count {
//                        error+=pow(item.output.body[i]-predictions.body[i], 2)/2
//                    }
//                    backward(expected: item.output)
//                    deltaWeights(row: item.input)
//                }
//                for layer in layers {
//                    layer.updateWeights()
//                }
//                shuffledSet.removeFirst(min(batchSize,shuffledSet.count))
//            }
//            print("Epoch \(epoch+1), error \(error).")
//            
//            if save {views.append(LayerView(layers: layers))}
//        }
//        return error
//    }
//    
//    public func predict(input: DataPiece) -> Int {
//        dropoutEnabled = false
//        let output = forward(networkInput: input)
//        var maxi = 0
//        for i in 1..<output.body.count {
//            if(output.body[i]>output.body[maxi]) {
//                maxi = i
//            }
//        }
//        return maxi
//    }
//    
//    private func deltaWeights(row: DataPiece) {
//        var input = row
//        for i in 0..<layers.count {
//            input = layers[i].deltaWeights(input: input, learningRate: learningRate)
//        }
//    }
//    
//    private func forward(networkInput: DataPiece) -> DataPiece {
//        var input = networkInput
//        for i in 0..<layers.count {
//            input = layers[i].forward(input: input, dropoutEnabled: dropoutEnabled)
//        }
//        return input
//    }
//    
//    private func backward(expected: DataPiece) {
//        var input = expected
//        var previous: Layer? = nil
//        for i in (0..<layers.count).reversed() {
//            input = layers[i].backward(input: input, previous: previous)
//            if !(layers[i] is Dropout) {
//                previous = layers[i]
//            }
//        }
//    }
//}
//
//public struct Neuron: Codable {
//    var weights: [Float]
//    var weightsDelta: [Float]
//    var bias: Float
//    var delta: Float
//}
//
//public func classifierOutput(classes: Int, correct: Int) -> DataPiece {
//    if correct>=classes {
//        fatalError("Correct class must be less than classes number.")
//    }
//    var output = Array(repeating: Float.zero, count: classes)
//    output[correct] = 1.0
//    return DataPiece(size: .init(width: classes), body: output)
//}
//
////Layers
//public struct LayerWrapper: Codable {
//    let layer: Layer
//    
//    private enum CodingKeys: String, CodingKey {
//        case base
//        case payload
//    }
//
//    private enum Base: Int, Codable {
//        case dense = 0
//        case dropout
//        case conv2d
//        case flatten
//        case pooling2d
//    }
//    
//    init(_ layer: Layer) {
//        self.layer = layer
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        switch layer {
//        case let payload as Dense:
//            try container.encode(Base.dense, forKey: .base)
//            try container.encode(payload, forKey: .payload)
//        case let payload as Dropout:
//            try container.encode(Base.dropout, forKey: .base)
//            try container.encode(payload, forKey: .payload)
//        case let payload as Convolutional2D:
//            try container.encode(Base.conv2d, forKey: .base)
//            try container.encode(payload, forKey: .payload)
//        case let payload as Flatten:
//            try container.encode(Base.flatten, forKey: .base)
//            try container.encode(payload, forKey: .payload)
//        case let payload as Pooling2D:
//            try container.encode(Base.pooling2d, forKey: .base)
//            try container.encode(payload, forKey: .payload)
//        default:
//            fatalError()
//        }
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let base = try container.decode(Base.self, forKey: .base)
//        
//        switch base {
//        case .dense:
//            self.layer = try container.decode(Dense.self, forKey: .payload)
//        case .dropout:
//            self.layer = try container.decode(Dropout.self, forKey: .payload)
//        case .conv2d:
//            self.layer = try container.decode(Convolutional2D.self, forKey: .payload)
//        case .flatten:
//            self.layer = try container.decode(Flatten.self, forKey: .payload)
//        case .pooling2d:
//            self.layer = try container.decode(Pooling2D.self, forKey: .payload)
//        }
//    }
//
//}
//
//public class Layer: Codable {
//    public var neurons: [Neuron] = []
//    fileprivate var function: ActivationFunction
//    fileprivate var output: DataPiece?
//    
//    private enum CodingKeys: String, CodingKey {
//        case neurons
//        case function
//        case output
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(function.rawValue, forKey: .function)
//        try container.encode(neurons, forKey: .neurons)
//        try container.encode(output, forKey: .output)
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let activationRaw = try container.decode(Int.self, forKey: .function)
//        function = getActivationFunction(rawValue: activationRaw)
//        neurons = try container.decode([Neuron].self, forKey: .neurons)
//        output = try container.decode(DataPiece.self, forKey: .output)
//    }
//    
//    func forward(input: DataPiece, dropoutEnabled: Bool) -> DataPiece {
//        return input
//    }
//    
//    func backward(input: DataPiece, previous: Layer?) -> DataPiece {
//        return input
//    }
//    
//    func deltaWeights(input: DataPiece, learningRate: Float) -> DataPiece {
//        return input
//    }
//    
//    func updateWeights() {
//        return
//    }
//    
//    fileprivate init(function: ActivationFunction) {
//        self.function = function
//    }
//}
//
//class Filter: Codable {
//    var kernel: [Float]
//    var delta: [Float]
//    
//    public init(kernelSize: Int) {
//        kernel = []
//        delta = Array(repeating: Float.zero, count: kernelSize*kernelSize)
//        for _ in 0..<kernelSize*kernelSize {
//            kernel.append(Float.random(in: -1...1))
//        }
//    }
//}
//
//public class Flatten: Layer {
//    
//    public init(inputSize: Int) {
//        super.init(function: Plain())
//        output = DataPiece(size: .init(width: inputSize), body: Array(repeating: Float.zero, count: inputSize))
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//    }
//    
//    override func forward(input: DataPiece, dropoutEnabled: Bool) -> DataPiece {
//        var newWidth = input.size.width
//        if let height = input.size.height {
//            newWidth *= height
//        }
//        if let depth = input.size.depth {
//            newWidth *= depth
//        }
//        output?.body = input.body
//        output?.size = .init(width: newWidth)
//        return output!
//    }
//    
//    override func backward(input: DataPiece, previous: Layer?) -> DataPiece {
//        return output!
//    }
//    
//    override func deltaWeights(input: DataPiece, learningRate: Float) -> DataPiece {
//        return output!
//    }
//}
//
//public class Convolutional2D: Layer {
//    var filters: [Filter]
//    var filterErrors: [Float]
//    var kernelSize: Int
//    var stride: Int
//    private var lastInput: DataPiece?
//    
//    private enum CodingKeys: String, CodingKey {
//        case filters
//        case kernelSize
//        case stride
//        case errors
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(filters, forKey: .filters)
//        try container.encode(kernelSize, forKey: .kernelSize)
//        try container.encode(stride, forKey: .stride)
//        try container.encode(filterErrors, forKey: .errors)
//        try super.encode(to: encoder)
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.filters = try container.decode([Filter].self, forKey: .filters)
//        self.kernelSize = try container.decode(Int.self, forKey: .kernelSize)
//        self.stride = try container.decode(Int.self, forKey: .stride)
//        self.filterErrors = try container.decode([Float].self, forKey: .errors)
//        try super.init(from: decoder)
//    }
//    
//    public init(filters: Int, kernelSize: Int, stride: Int, functionRaw: ActivationFunctionRaw) {
//        let function = getActivationFunction(rawValue: functionRaw.rawValue)
//        self.filters = []
//        self.kernelSize = kernelSize
//        self.stride = stride
//        for _ in 0..<filters {
//            self.filters.append(Filter(kernelSize: kernelSize))
//        }
//        self.filterErrors = Array(repeating: Float.zero, count: filters)
//        super.init(function: function)
//    }
//    
//    override func forward(input: DataPiece, dropoutEnabled: Bool) -> DataPiece {
//        lastInput = input
//        if input.size.type == .twoD {
//            lastInput?.size = DataSize(width: input.size.width, height: input.size.height!, depth: 1)
//        } else if input.size.type == .oneD {
//            fatalError("Convolutional 2D input must be at least two-dimensional.")
//        }
//        
//        let inputSize = lastInput!.size
//        let outputSize = DataSize(width: (inputSize.width - kernelSize) / stride + 1, height: (inputSize.height! - kernelSize) / stride + 1, depth: filters.count*inputSize.depth!)
//        output = DataPiece(size: outputSize, body: Array(repeating: Float.zero, count: outputSize.width*outputSize.height!*outputSize.depth!))
//        output!.body.withUnsafeMutableBufferPointer { outputPtr in
//            filters.withUnsafeBufferPointer { filtersPtr in
//                DispatchQueue.concurrentPerform(iterations: outputSize.height!, execute: { outY in
//                    let tempY = outY * stride
//                    DispatchQueue.concurrentPerform(iterations: outputSize.width, execute: { outX in
//                        let tempX = outX * stride
//                        DispatchQueue.concurrentPerform(iterations: filtersPtr.count, execute: { i in
//                            filtersPtr[i].kernel.withUnsafeBufferPointer { kernelPtr in
//                                DispatchQueue.concurrentPerform(iterations: inputSize.depth!, execute: { j in
//                                    var piece = Float.zero
//                                    for y in tempY ..< tempY + kernelSize {
//                                        for x in tempX ..< tempX + kernelSize {
//                                            piece += kernelPtr[(y-tempY)*kernelSize+x-tempX] * lastInput!.get(x: x, y: y, z: j)
//                                        }
//                                    }
//                                    outputPtr[outY*outputSize.width*outputSize.depth!+outX*outputSize.depth!+i*inputSize.depth!+j] = function.activation(input: piece)
//                                })
//                            }
//                        })
//                    })
//                })
//            }
//        }
//        return output!
//    }
//    
//    override func backward(input: DataPiece, previous: Layer?) -> DataPiece {
//        guard let lastInput = lastInput else {
//            fatalError("Backward propagation executed before forward propagation.")
//        }
//        let inputSize = lastInput.size
//        let outputSize = DataSize(width: (inputSize.width - kernelSize) / stride + 1, height: (inputSize.height! - kernelSize) / stride + 1, depth: filters.count*inputSize.depth!)
//        var resizedInput = input
//        for i in 0..<resizedInput.body.count {
//            resizedInput.body[i] = function.derivative(output: resizedInput.body[i])
//        }
//        resizedInput.size = outputSize
//        var output = Array(repeating: Float.zero, count: outputSize.width * outputSize.height! * outputSize.depth!)
//        filters.withUnsafeBufferPointer { filtersPtr in
//            output.withUnsafeMutableBufferPointer { outputPtr in
//                filterErrors.withUnsafeMutableBufferPointer { filterErrorsPtr in
//                    DispatchQueue.concurrentPerform(iterations: filtersPtr.count, execute: { filter in
//                        filtersPtr[filter].kernel.withUnsafeBufferPointer { kernelPtr in
//                            var error = Float.zero
//                            DispatchQueue.concurrentPerform(iterations: outputSize.height!, execute: { outY in
//                                let tempY = outY * stride
//                                DispatchQueue.concurrentPerform(iterations: outputSize.width, execute: { outX in
//                                    let tempX = outX * stride
//                                    DispatchQueue.concurrentPerform(iterations: inputSize.depth!, execute: { j in
//                                        var piece = Float.zero
//                                        for y in tempY ..< tempY + kernelSize {
//                                            for x in tempX ..< tempX + kernelSize {
//                                                piece += lastInput.get(x: x, y: y, z: j)
//                                            }
//                                        }
//                                        error += piece * resizedInput.get(x: outX, y: outY)
//                                        var tempKernel = filtersPtr[filter].kernel
//                                        for i in 0..<tempKernel.count {
//                                            tempKernel[i] *= resizedInput.get(x: outX, y: outY)
//                                        }
//                                        let cof = resizedInput.get(x: outX, y: outY)
//                                        for y in tempY ..< tempY + kernelSize {
//                                            for x in tempX ..< tempX + kernelSize {
//                                                outputPtr[outY*outputSize.width*outputSize.depth!+outX*outputSize.depth!+filter*inputSize.depth!+j] += cof * kernelPtr[(y-tempY)*kernelSize+x-tempX]
//                                            }
//                                        }
//                                    })
//                                })
//                            })
//                            filterErrorsPtr[filter] = error
//                        }
//                    })
//                }
//            }
//        }
//        return DataPiece(size: .init(width: inputSize.height!, height: inputSize.width, depth: filters.count*inputSize.depth!), body: output)
//    }
//    
//    override func deltaWeights(input: DataPiece, learningRate: Float) -> DataPiece {
//        for i in 0..<filters.count {
//            for j in 0..<filters[i].kernel.count {
//                filters[i].delta[j] += learningRate * filterErrors[i]
//            }
//        }
//        return output!
//    }
//    
//    override func updateWeights() {
//        for i in 0..<filters.count {
//            for j in 0..<filters[i].kernel.count {
//                filters[i].kernel[j] += filters[i].delta[j]
//            }
//        }
//    }
//    
//}
//
//public enum PoolingMode: Int {
//    case average = 0
//    case max
//}
//
//public class Pooling2D: Layer {
//    var kernelSize: Int
//    var stride: Int
//    var mode: PoolingMode
//    private var lastInput: DataPiece?
//    
//    private enum CodingKeys: String, CodingKey {
//        case kernelSize
//        case stride
//        case mode
//    }
//    
//    public init(kernelSize: Int, stride: Int, mode: PoolingMode, functionRaw: ActivationFunctionRaw) {
//        let function = getActivationFunction(rawValue: functionRaw.rawValue)
//        self.kernelSize = kernelSize
//        self.stride = stride
//        self.mode = mode
//        super.init(function: function)
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        kernelSize = try container.decode(Int.self, forKey: .kernelSize)
//        stride = try container.decode(Int.self, forKey: .stride)
//        mode = PoolingMode(rawValue: try container.decode(Int.self, forKey: .mode)) ?? .average
//        try super.init(from: decoder)
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(kernelSize, forKey: .kernelSize)
//        try container.encode(stride, forKey: .stride)
//        try container.encode(mode.rawValue, forKey: .mode)
//        try super.encode(to: encoder)
//    }
//    
//    override func forward(input: DataPiece, dropoutEnabled: Bool) -> DataPiece {
//        lastInput = input
//        if input.size.type == .twoD {
//            lastInput?.size = DataSize(width: input.size.width, height: input.size.height!, depth: 1)
//        } else if input.size.type == .oneD {
//            fatalError("Pooling 2D input must be at least two-dimensional.")
//        }
//        
//        let inputSize = lastInput!.size
//        let outputSize = DataSize(width: (inputSize.width - kernelSize) / stride + 1, height: (inputSize.height! - kernelSize) / stride + 1, depth: inputSize.depth!)
//        output = DataPiece(size: outputSize, body: Array(repeating: Float.zero, count: outputSize.width*outputSize.height!*outputSize.depth!))
//        output!.body.withUnsafeMutableBufferPointer { outputPtr in
//            DispatchQueue.concurrentPerform(iterations: outputSize.height!, execute: { outY in
//                let tempY = outY * stride
//                DispatchQueue.concurrentPerform(iterations: outputSize.width, execute: { outX in
//                    let tempX = outX * stride
//                    DispatchQueue.concurrentPerform(iterations: inputSize.depth!, execute: { i in
//                        var piece = mode == .max ? lastInput!.get(x: tempX, y: tempY, z: i) : Float.zero
//                        for y in tempY ..< tempY + kernelSize {
//                            for x in tempX ..< tempX + kernelSize {
//                                if mode == .max {
//                                    piece = max(piece, lastInput!.get(x: x, y: y, z: i))
//                                } else {
//                                    piece += lastInput!.get(x: x, y: y, z: i)
//                                }
//                            }
//                        }
//                        if mode == .average {
//                            piece /= Float(kernelSize * kernelSize)
//                        }
//                        outputPtr[outY*outputSize.width*outputSize.depth!+outX*outputSize.depth!+i] = function.activation(input: piece)
//                    })
//                })
//            })
//        }
//        return output!
//    }
//    
//    override func backward(input: DataPiece, previous: Layer?) -> DataPiece {
//        guard let lastInput = lastInput else {
//            fatalError("Backward propagation executed before forward propagation.")
//        }
//        let inputSize = lastInput.size
//        let outputSize = DataSize(width: (inputSize.width - kernelSize) / stride + 1, height: (inputSize.height! - kernelSize) / stride + 1, depth: inputSize.depth!)
//        var resizedInput = input
//        for i in 0..<resizedInput.body.count {
//            resizedInput.body[i] = function.derivative(output: resizedInput.body[i])
//        }
//        resizedInput.size = outputSize
//        output = DataPiece(size: inputSize, body: Array(repeating: Float.zero, count: inputSize.width*inputSize.height!*inputSize.depth!))
//        output!.body.withUnsafeMutableBufferPointer { outputPtr in
//            DispatchQueue.concurrentPerform(iterations: outputSize.height!, execute: { outY in
//                let tempY = outY * stride
//                DispatchQueue.concurrentPerform(iterations: outputSize.width, execute: { outX in
//                    let tempX = outX * stride
//                    DispatchQueue.concurrentPerform(iterations: outputSize.depth!, execute: { j in
//                        let val = resizedInput.get(x: outX, y: outY, z: j) / Float(kernelSize * kernelSize)
//                        if mode == .average {
//                            for y in tempY ..< tempY + kernelSize {
//                                for x in tempX ..< tempX + kernelSize {
//                                    outputPtr[y*inputSize.width*inputSize.depth!+x*inputSize.depth!+j] += val
//                                }
//                            }
//                        } else {
//                            var maxV = lastInput.get(x: tempX, y: tempY, z: j)
//                            for y in tempY ..< tempY + kernelSize {
//                                for x in tempX ..< tempX + kernelSize {
//                                    maxV = max(maxV, lastInput.get(x: x, y: y, z: j))
//                                }
//                            }
//                            for y in tempY ..< tempY + kernelSize {
//                                for x in tempX ..< tempX + kernelSize {
//                                    if lastInput.get(x: x, y: y, z: j) == maxV {
//                                        outputPtr[y*inputSize.width*inputSize.depth!+x*inputSize.depth!+j] += val
//                                    }
//                                }
//                            }
//                        }
//                    })
//                })
//            })
//        }
//        return output!
//    }
//}
//
//public class Dense: Layer {
//    
//    private let queue = DispatchQueue.global(qos: .userInitiated)
//    
//    public init(inputSize: Int, neuronsCount: Int, functionRaw: ActivationFunctionRaw) {
//        let function = getActivationFunction(rawValue: functionRaw.rawValue)
//        super.init(function: function)
//        output = .init(size: .init(width: neuronsCount), body: Array(repeating: Float.zero, count: neuronsCount))
//        
//        for _ in 0..<neuronsCount {
//            var weights = [Float]()
//            for _ in 0..<inputSize {
//                weights.append(Float.random(in: -1.0 ... 1.0))
//            }
//            neurons.append(Neuron(weights: weights, weightsDelta: .init(repeating: Float.zero, count: weights.count), bias: 0.0, delta: 0.0))
//        }
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//    }
//    
//    override func forward(input: DataPiece, dropoutEnabled: Bool) -> DataPiece {
//        input.body.withUnsafeBufferPointer { inputPtr in
//            output?.body.withUnsafeMutableBufferPointer { outputPtr in
//                neurons.withUnsafeBufferPointer { neuronsPtr in
//                    DispatchQueue.concurrentPerform(iterations: neuronsPtr.count, execute: { i in
//                        var out = neuronsPtr[i].bias
//                        neuronsPtr[i].weights.withUnsafeBufferPointer { weightsPtr in
//                            DispatchQueue.concurrentPerform(iterations: neuronsPtr[i].weights.count, execute: { i in
//                                out += weightsPtr[i] * inputPtr[i]
//                            })
//                        }
//                        outputPtr[i] = function.activation(input: out)
//                    })
//                }
//            }
//        }
//        return output!
//    }
//    
//    override func backward(input: DataPiece, previous: Layer?) -> DataPiece {
//        var errors = Array(repeating: Float.zero, count: neurons.count)
//        if let previous = previous {
//            for j in 0..<neurons.count {
//                for neuron in previous.neurons {
//                    errors[j] += neuron.weights[j]*neuron.delta
//                }
//            }
//        } else {
//            for j in 0..<neurons.count {
//                errors[j] = input.body[j] - output!.body[j]
//            }
//        }
//        for j in 0..<neurons.count {
//            neurons[j].delta = errors[j] * function.derivative(output: output!.body[j])
//        }
//        return output!
//    }
//    
//    override func deltaWeights(input: DataPiece, learningRate: Float) -> DataPiece {
//        neurons.withUnsafeMutableBufferPointer { neuronsPtr in
//            input.body.withUnsafeBufferPointer { inputPtr in
//                DispatchQueue.concurrentPerform(iterations: neuronsPtr.count, execute: { i in
//                    neuronsPtr[i].weightsDelta.withUnsafeMutableBufferPointer { deltaPtr in
//                        DispatchQueue.concurrentPerform(iterations: deltaPtr.count, execute: { j in
//                            deltaPtr[j] += learningRate * neuronsPtr[i].delta * inputPtr[j]
//                        })
//                        neuronsPtr[i].bias += learningRate * neuronsPtr[i].delta
//                    }
//                })
//            }
//        }
//        return output!
//    }
//    
//    override func updateWeights() {
//        let neuronsCount = neurons.count
//        neurons.withUnsafeMutableBufferPointer { neuronsPtr in
//            DispatchQueue.concurrentPerform(iterations: neuronsCount, execute: { i in
//                neuronsPtr[i].weights.withUnsafeMutableBufferPointer { weightsPtr in
//                    neuronsPtr[i].weightsDelta.withUnsafeMutableBufferPointer { deltaPtr in
//                        let weightsCount = deltaPtr.count
//                        DispatchQueue.concurrentPerform(iterations: weightsCount, execute: { j in
//                            weightsPtr[j] += deltaPtr[j]
//                            deltaPtr[j] = 0
//                        })
//                    }
//                }
//            })
//        }
//    }
//    
//}
//
//public class Dropout: Layer {
//    var probability: Int
//    var cache: [Bool]
//    
//    private enum CodingKeys: String, CodingKey {
//        case probability
//        case cache
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(probability, forKey: .probability)
//        try container.encode(cache, forKey: .cache)
//        try super.encode(to: encoder)
//    }
//    
//    public init(inputSize: Int, probability: Int) {
//        self.probability = probability
//        self.cache = Array(repeating: true, count: inputSize)
//        super.init(function: Plain())
//        for _ in 0..<inputSize {
//            neurons.append(Neuron(weights: [], weightsDelta: [], bias: 0.0, delta: 0.0))
//        }
//        output = DataPiece(size: .init(width: inputSize), body: Array(repeating: Float.zero, count: inputSize))
//        #warning("Add 2D and 3D support")
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.probability = try container.decode(Int.self, forKey: .probability)
//        self.cache = try container.decode([Bool].self, forKey: .cache)
//        try super.init(from: decoder)
//    }
//    
//    override func forward(input: DataPiece, dropoutEnabled: Bool) -> DataPiece {
//        output = input
//        if dropoutEnabled {
//            cache.withUnsafeMutableBufferPointer { cachePtr in
//                output?.body.withUnsafeMutableBufferPointer { outputPtr in
//                    DispatchQueue.concurrentPerform(iterations: outputPtr.count, execute: { i in
//                        if Int.random(in: 0...100) < probability {
//                            cachePtr[i] = false
//                            outputPtr[i] = 0
//                        } else {
//                            cachePtr[i] = true
//                        }
//                    })
//                }
//            }
//        }
//        return output!
//    }
//    
//    override func backward(input: DataPiece, previous: Layer?) -> DataPiece {
//        return output!
//    }
//    
//    override func deltaWeights(input: DataPiece, learningRate: Float) -> DataPiece {
//        return output!
//    }
//}
//
//fileprivate func getActivationFunction(rawValue: Int) -> ActivationFunction {
//    switch rawValue {
//    case ActivationFunctionRaw.reLU.rawValue:
//        return ReLU()
//    case ActivationFunctionRaw.sigmoid.rawValue:
//        return Sigmoid()
//    default:
//        return Plain()
//    }
//}
//
//public enum ActivationFunctionRaw: Int {
//    case sigmoid = 0
//    case reLU
//    case plain
//}
//
//protocol ActivationFunction: Codable {
//    var rawValue: Int { get }
//    func activation(input: Float) -> Float
//    func derivative(output: Float) -> Float
//}
//
//fileprivate struct Sigmoid: ActivationFunction, Codable {
//    public var rawValue: Int = 0
//    
//    public func activation(input: Float) -> Float {
//        return 1.0/(1.0+exp(-input))
//    }
//    
//    public func derivative(output: Float) -> Float {
//        return output * (1.0-output)
//    }
//}
//
//fileprivate struct ReLU: ActivationFunction, Codable {
//    public var rawValue: Int = 1
//    
//    public func activation(input: Float) -> Float {
//        return max(Float.zero, input)
//    }
//    
//    public func derivative(output: Float) -> Float {
//        return output < 0 ? 0 : 1
//    }
//}
//
//fileprivate struct Plain: ActivationFunction, Codable {
//    public var rawValue: Int = 2
//    
//    public func activation(input: Float) -> Float {
//        return input
//    }
//    
//    public func derivative(output: Float) -> Float {
//        return 1
//    }
//}
//
//#if DEBUG
//func getActivationFunctionMirror(rawValue: Int) -> ActivationFunction {
//    getActivationFunction(rawValue: rawValue)
//}
//#endif
