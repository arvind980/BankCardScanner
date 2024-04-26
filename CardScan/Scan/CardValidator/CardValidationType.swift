import Foundation
import UIKit

public struct CardValidationType {
    public let group: CardGroup
    public let regex: String

    public init(group: CardGroup, regex: String) {
        self.group = group
        self.regex = regex
    }
}

extension CardValidationType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.group == rhs.group
    }
}

public struct CardScanner{

    public struct Configuration {
        let watermarkText: String
        let font: UIFont
        let accentColor: UIColor
        let watermarkWidth: CGFloat
        let watermarkHeight: CGFloat
        let drawBoxes: Bool
        let localizedCancelButton: String
        let localizedDoneButton: String

        public init(
            watermarkText: String,
            font: UIFont,
            accentColor: UIColor,
            watermarkWidth: CGFloat,
            watermarkHeight: CGFloat,
            drawBoxes: Bool,
            localizedCancelButton: String,
            localizedDoneButton: String
        ) {
            self.watermarkText = watermarkText
            self.font = font
            self.accentColor = accentColor
            self.watermarkWidth = watermarkWidth
            self.watermarkHeight = watermarkHeight
            self.drawBoxes = drawBoxes
            self.localizedCancelButton = localizedCancelButton
            self.localizedDoneButton = localizedDoneButton
        }

        public static let `default` = Configuration(
            watermarkText: "Card_Scanner",
            font: .systemFont(ofSize: 24),
            accentColor: .white,
            watermarkWidth: 150,
            watermarkHeight: 50,
            drawBoxes: false,
            localizedCancelButton: "Cancel",
            localizedDoneButton: "Done"
        )
    }
   
}

