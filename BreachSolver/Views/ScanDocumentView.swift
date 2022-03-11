import SwiftUI
import VisionKit
import Vision

struct ScanDocumentView: UIViewControllerRepresentable {
    
    @Binding var recognizedText: RecognisedBreachText?
    @Environment(\.presentationMode) var presentationMode
  
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
                // nothing to do here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
}

struct RecognisedBreachText {
    var matrix: [[String]]
    var daemons: [[String]]
    
    var canSolve: Bool {
        for code in matrix.flatMap({ $0 }) {
            if !Constants.allowedCodes.contains(code) {
                return false
            }
        }
        
        for code in daemons.flatMap({ $0 }) {
            if !Constants.allowedCodes.contains(code) {
                return false
            }
        }
        
        return true
    }
}

class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
  
    var recognizedText: Binding<RecognisedBreachText?>
    var parent: ScanDocumentView
    
    init(recognizedText: Binding<RecognisedBreachText?>, parent: ScanDocumentView) {
        self.recognizedText = recognizedText
        self.parent = parent
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let extractedImages = extractImages(from: scan)
        let processedText = recognizeText(from: extractedImages)
        processedText.map({ self.recognizedText.wrappedValue = $0 })
//        recognizedText.wrappedValue = processedText
        parent.presentationMode.wrappedValue.dismiss()
    }
    
    private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
        var extractedImages = [CGImage]()
        for index in 0..<scan.pageCount {
            let extractedImage = scan.imageOfPage(at: index)
            guard let cgImage = extractedImage.cgImage else { continue }
            
            extractedImages.append(cgImage)
        }
        return extractedImages
    }
    
    private func recognizeText(from images: [CGImage]) -> RecognisedBreachText? {
        guard images.count == 2 else { return nil }

        // First image should be grid
        let gridImage = images[0]
        var gridText: [String] = []
        let recognizeTextRequest = VNRecognizeTextRequest  { (request, error) in
            guard error == nil else { return }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let maximumRecognitionCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
                gridText.append(candidate.string)
            }
        }
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = true
        recognizeTextRequest.customWords = [
            "1C",
            "BD",
            "FF",
            "7A",
            "E9",
            "55"
        ]
        let requestHandler = VNImageRequestHandler(cgImage: gridImage, options: [:])
        try? requestHandler.perform([recognizeTextRequest])
        
        let flattened = gridText.reduce("") { partialResult, nextString in
            return partialResult + " " + nextString
        }
        let separated = flattened.split(separator: " ").map({ String($0) })
        
        let gridSize = sqrt(Double(separated.count))
        guard floor(gridSize) == gridSize else {
            print("Grid size could not be calculated")
            return nil
        }
        
        var grid: [[String]] = []
        for i in stride(from: 0, through: separated.count-Int(gridSize), by: Int(gridSize)) {
            let slice = Array(separated[i..<i+Int(gridSize)])
            grid.append(slice)
        }
        for r in grid {
            print(r)
        }
        
        
        // Second image should be daemons
        let daemonImage = images[1]
        var daemonText: [String] = []
        let daemonTextRequest = VNRecognizeTextRequest  { (request, error) in
            guard error == nil else { return }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let maximumRecognitionCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
                daemonText.append(candidate.string)
            }
        }
        daemonTextRequest.recognitionLevel = .accurate
        daemonTextRequest.usesLanguageCorrection = true
        daemonTextRequest.customWords = [
            "1C",
            "BD",
            "FF",
            "7A",
            "E9",
            "55"
        ]
        let daemonRequestHandler = VNImageRequestHandler(cgImage: daemonImage, options: [:])
        try? daemonRequestHandler.perform([daemonTextRequest])
        
        let daemons = daemonText.map({ $0.split(separator: " ").map({ String($0) }) })
        print(daemons)
        
//        let flattened = daemonText.reduce("") { partialResult, nextString in
//            return partialResult + " " + nextString
//        }
//        let separated = flattened.split(separator: " ").map({ String($0) })
//
//        let gridSize = sqrt(Double(separated.count))
//        guard floor(gridSize) == gridSize else {
//            print("Grid size could not be calculated")
//            return ""
//        }
//
//        var grid: [[String]] = []
//        for i in stride(from: 0, through: separated.count-Int(gridSize), by: Int(gridSize)) {
//            let slice = Array(separated[i..<i+Int(gridSize)])
//            grid.append(slice)
//        }
//        for r in grid {
//            print(r)
//        }
        
        return RecognisedBreachText(matrix: grid, daemons: daemons)
    }
}
