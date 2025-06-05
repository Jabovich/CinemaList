//
//  universalFuncs.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 12.04.2025.
//

import SwiftUI

// Used in MovieCardView to convert realise date to ru format
func convertDateString(_ inputString: String,
                       from inputFormat: String = "yyyy-MM-dd",
                       to outputFormat: String = "dd.MM.yyyy") -> String? {
    
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = inputFormat
    
    guard let date = inputFormatter.date(from: inputString) else {
        return nil
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = outputFormat
    
    return outputFormatter.string(from: date)
}

// Вынесенная функция для определения цвета (можно в отдельный файл)
func getDominantColor(from url: URL, completion: @escaping (Color?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let imageData = try? Data(contentsOf: url),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Получаем преобладающий цвет как UIColor
        let uiColor = image.dominantColor()
        
        // Конвертируем в SwiftUI Color
        DispatchQueue.main.async {
            completion(uiColor.map(Color.init))
        }
    }
}

// Расширение для UIImage (можно вынести в отдельный файл)
extension UIImage {
    func dominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )
        
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: extentVector
            ]
        ),
        let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: nil)
        
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }
}
