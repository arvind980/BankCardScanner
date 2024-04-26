import UIKit
import AVFoundation

class ScannerOverlayView: UIView {
    
    private let configuration: CardScanner.Configuration
    
    // MARK: - Init
    required init(configuration: CardScanner.Configuration) {
        self.configuration = configuration

        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        layer.mask = maskLayer
    }
    
    // MARK: - Mask Layer
    lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillRule = .evenOdd
        return layer
    }()
    
    // MARK: - Region of interest (ROI) - Static!
    var desiredHeightRatio: Double { 0.5 }
    var desiredWidthRatio: Double { 0.6 }
    var maxPortraitWidth: Double { 0.8 }
    var minLandscapeHeightRatio: Double { 0.6 }
    
    // Region of video data output buffer that recognition should be run on.
    // Gets recalculated once the bounds of the preview layer are known.
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    // Orientation of text to search for in the region of interest.
    var textOrientation = CGImagePropertyOrientation.up
    
    // MARK: - Coordinate transforms
    var uiRotationTransform = CGAffineTransform.identity
    // Transform bottom-left coordinates to top-left.
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    // Transform coordinates in ROI to global coordinates (still normalized).
    var roiToGlobalTransform = CGAffineTransform.identity
    // Vision -> AVF coordinate transform.
    var visionToAVFTransform = CGAffineTransform.identity
    
    var bufferAspectRatio: Double = 1_920.0 / 1_080.0
    
    // MARK: - Device Orientation
    // Device orientation.Updated whenever the orientation changes
    // to a different supported orientation.
    var currentOrientation = UIDeviceOrientation.portrait {
        didSet {
            // update ROI if orientation changes
            updateRegionOfInterest()
        }
    }
    
    // MARK: - Preview View
    var previewView: PreviewView?
}

extension ScannerOverlayView {
    func updateRegionOfInterest() {
        calculateRegionOfInterest()
        setupOrientationAndTransform()
        DispatchQueue.main.async { [weak self] in
            self?.updateCutout()
        }
    }
    @objc open func calculateRegionOfInterest() {
        let size: CGSize
        if currentOrientation.isPortrait || currentOrientation == .unknown {
            size = CGSize(
                width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth),
                height: desiredHeightRatio / bufferAspectRatio
            )
        } else {
            size = CGSize(width: desiredWidthRatio, height: max(desiredHeightRatio, minLandscapeHeightRatio))
        }
        
        // Make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        
        print("Region of interest: \(regionOfInterest)")
    }
    
    func setupOrientationAndTransform() {
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        
        // Compensate for orientation (buffers always come in the same orientation).
        switch currentOrientation {
        case .landscapeLeft:
            textOrientation = CGImagePropertyOrientation.up
            uiRotationTransform = CGAffineTransform.identity
        case .landscapeRight:
            textOrientation = CGImagePropertyOrientation.down
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
        case .portraitUpsideDown:
            textOrientation = CGImagePropertyOrientation.left
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
        default: // We default everything else to .portraitUp
            textOrientation = CGImagePropertyOrientation.right
            uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        }
    
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
    }
    
    @objc func updateCutout() {
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let transformedRoi = regionOfInterest.applying(roiRectTransform)
        guard let cutout = previewView?.previewLayer.layerRectConverted(fromMetadataOutputRect: transformedRoi) else { return }
        
        // Create the mask.
        let path = UIBezierPath(rect: frame)
        path.append(UIBezierPath(roundedRect: cutout, cornerRadius: 10))
        maskLayer.path = path.cgPath
        
        layer.sublayers?.removeAll()
        addOverlays(cutout)
    }
    
    @objc open func addOverlays(_ cutout: CGRect) {
        addRoundedRectangle(around: cutout)
    }
}

// MARK: - Custom Layers
extension ScannerOverlayView {
    
    func addRoundedRectangle(around cutout: CGRect) {
        
        print("Cutout: \(cutout)")
        guard cutout.size != .zero else { return }
        
        let cornersPath = UIBezierPath(rect: CGRect(x: cutout.minX - 3, y: cutout.minY - 3, width: 60, height: 60))
        cornersPath.append(UIBezierPath(rect: CGRect(x: cutout.maxX - 57, y: cutout.minY - 3, width: 60, height: 60)))
        cornersPath.append(UIBezierPath(rect: CGRect(x: cutout.minX - 3, y: cutout.maxY - 57, width: 60, height: 60)))
        cornersPath.append(UIBezierPath(rect: CGRect(x: cutout.maxX - 57, y: cutout.maxY - 57, width: 60, height: 60)))
        let cornersMask = CAShapeLayer()
        cornersMask.lineWidth = 8
        cornersMask.strokeColor = UIColor.white.cgColor
        cornersMask.path = cornersPath.cgPath
        cornersMask.fillColor = UIColor.white.cgColor
        cornersMask.fillRule = .nonZero
        
        let roundedRect = CAShapeLayer()
        roundedRect.strokeColor = configuration.accentColor.cgColor
        roundedRect.lineWidth = 6
        roundedRect.path = UIBezierPath(roundedRect: cutout.insetBy(dx: -3, dy: -3), cornerRadius: 10).cgPath
        roundedRect.fillColor = UIColor.clear.cgColor
        roundedRect.mask = cornersMask // remove here to have rounded rect instead of rounded corners
        layer.addSublayer(roundedRect)
    }
    
    func addWatermark() {

        let watermark = CATextLayer()
        watermark.string = configuration.watermarkText
        watermark.foregroundColor = configuration.accentColor.cgColor
        watermark.isWrapped = true
        watermark.alignmentMode = .left
        watermark.contentsScale = UIScreen.main.scale
        watermark.font = CTFontCreateWithName(configuration.font.fontName as CFString, configuration.font.pointSize, nil)
        watermark.fontSize = configuration.font.pointSize
        watermark.frame = CGRect(
            x: frame.width - configuration.watermarkWidth,
            y: frame.height - 50,
            width: configuration.watermarkWidth,
            height: 40
        )
        layer.addSublayer(watermark)
    }
}
