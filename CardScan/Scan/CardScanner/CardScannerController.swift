import UIKit
import Vision
import CoreHaptics

protocol CardScannerDelegate: AnyObject {
    func didTapCancel()
    func didTapDone(number: String?, expDate: String?, holder: String?)
    func didScanCard(number: String?, expDate: String?, holder: String?)
}

public class CardScannerController : VisionController {
    // MARK: - Delegate
    weak var delegate: CardScannerDelegate?
    
    // MRAK: - Ovelay View
    override var overlayViewClass: ScannerOverlayView.Type {
        return CardOverlayView.self
    }
    
    // MARK: - Views
    
    lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Card Scanner"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var brandLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var expDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cardHolderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cvvLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitle(vv.localizedCancelButton, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var firstNameSuggestion: String = ""
    var lastNameSuggestion: String = ""

    var numberTracker = StringTracker()
    var expDateTracker = StringTracker()
    var fullNameTracker = StringTracker()
    var cvvTracker = StringTracker()
    
    var foundNumber : String?
    var foundExpDate : String?
    var foundCardHolder : String?
    var foundCVV : String?
    var foundType: String?
    
    var isScannedForFront = false
    var isScannedForCVV = false

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        //setupButton()
        setupTitleLabel()
        showToastForScaning()
    }
    
    func showToastForScaning(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.showToastMessage(message: "Card scanning process, Please position the front side of your card within the frame provided for scanning")
        }
    }
    
    func resetRescan(){
         foundNumber = nil
        foundExpDate = nil
        foundCardHolder = nil
        foundCVV = nil
        foundType = nil
        isScannedForFront = false
        isScannedForCVV = false
        
        cvvLabel.text = ""
        cardHolderLabel.text = ""
        expDateLabel.text = ""
        brandLabel.text = ""
        cardNumberLabel.text = ""
        
        firstNameSuggestion = ""
        lastNameSuggestion = ""

        numberTracker = StringTracker()
        expDateTracker = StringTracker()
        fullNameTracker = StringTracker()
        cvvTracker = StringTracker()
    }

    @objc func doneButtonAction() {
        if button.title(for: .normal) == vv.localizedCancelButton {
            stopLiveStream()
            delegate?.didTapCancel()
        } else {
            delegate?.didTapDone(number: foundNumber, expDate: foundExpDate, holder: foundCardHolder)
        }
    }
    
    func setupLabels() {
        let stack = UIStackView(arrangedSubviews: [cardNumberLabel, brandLabel, expDateLabel,cvvLabel, cardHolderLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
       
        view.addSubview(stack)
        // constraint labels
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
    }
    
    func setupButton() {
        view.addSubview(button)
        // constraint button
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    }
    
    func setupTitleLabel() {
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        
        titleView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
       
        titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    }

    override var usesLanguageCorrection: Bool {
        return true
    }
    
    override var recognitionLevel: VNRequestTextRecognitionLevel {
        return .accurate
    }
    
    public override func observationsHandler(observations: [VNRecognizedTextObservation] ) {
        
        var numbers = [StringRecognition]()
        var expDates = [StringRecognition]()
        var CVV = [StringRecognition]()
        
        // Create a full transcript to run analysis on.
        var text : String = ""
        
        if observationsCount == 20 && (foundNumber == nil) && cameraBrightness < 0 {
            // toggleTorch(on: true)
        }
        
        let maximumCandidates = 1
        for observation in observations {
            
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            print("[Text recognition] ", candidate.string)
            
            if foundNumber == nil, let cardNumber = candidate.string.checkCardNumber() {
                let box = observation.boundingBox
                numbers.append((cardNumber, box))
            }
            
            if foundCVV == nil, let cvv = candidate.string.checkCVV() {
                let box = observation.boundingBox
                CVV.append((cvv, box))
            }
            
            if foundExpDate == nil, let expDate = candidate.string.extractExpDate() {
                let box = boundingBox(of: expDate, in: candidate)
                expDates.append((expDate, box))
            }
            text += candidate.string + " "
            highlightBox(observation.boundingBox, color: UIColor.white)
        }
        
        if foundNumber == nil, let cardNumber = text.extractCardNumber() {
            numbers.append((cardNumber, nil))
        }
       
        if isScannedForFront{
            self.searchCVV(CVV)
        }else{
            searchCardNumber(numbers)
            searchExpDate(expDates)
            searchCardHolder(text)
        }
        shouldStopScanner()
    }
    
    private func searchCardNumber(_ numbers : [StringRecognition]) {
        guard foundNumber == nil else { return }
            
        numberTracker.logFrame(recognitions: numbers)
            
        if let sureNumber = numberTracker.getStableString() {
            foundNumber = sureNumber
            
            showString(string: "Card Number: "+sureNumber, in: cardNumberLabel)
            
            let cardType = CardValidator().validationType(from: sureNumber)
            let brand = cardType?.group.rawValue ?? ""
            foundType = brand
            showString(string: "Card Type: "+brand, in: brandLabel)
            
            if let box = numberTracker.getStableBox() {
                highlightBox(box, color: vv.accentColor, lineWidth: 2, isTemporary: false)
            }
            
            numberTracker.reset(string: sureNumber)
        }
    }
    
    private func searchCVV(_ numbers : [StringRecognition]) {
        guard foundCVV == nil else { return }
        cvvTracker.logFrame(recognitions: numbers)
        if let sureNumber = cvvTracker.getStableString() {
            foundCVV = sureNumber
            if !CVVValidator().validate(cvv: sureNumber, forCardType: CardGroup(rawValue: foundType ?? "") ?? .visa){
                    self.foundCVV = nil
                    return
                }else{
                    self.showString(string: "Card VCC: "+sureNumber, in: self.cvvLabel)
                    if let box = self.expDateTracker.getStableBox() {
                        highlightBox(box, color: vv.accentColor, lineWidth: 2, isTemporary: false)
                     }
                self.cvvTracker.reset(string: sureNumber)
            }
        }
    }
    
    private func searchExpDate(_ expDates: [StringRecognition]) {
        guard foundExpDate == nil else { return }
        
        expDateTracker.logFrame(recognitions: expDates)
        
        if let sureExpDate = expDateTracker.getStableString() {
            foundExpDate = sureExpDate
            showString(string: "Expiry Date: "+sureExpDate, in: expDateLabel)
            if let box = expDateTracker.getStableBox() {
                highlightBox(box, color: vv.accentColor, lineWidth: 2, isTemporary: false)
            }
            expDateTracker.reset(string: sureExpDate)
        }
    }
    
    private func searchCardHolder(_ text: String) {
        guard foundCardHolder == nil else { return }
        func trackFullName(_ fullName: StringRecognition) {
            fullNameTracker.logFrame(recognition: fullName)
            if let sureFullName = fullNameTracker.getStableString() {
                foundCardHolder = sureFullName
                showString(string: "Card Holder: "+sureFullName, in: cardHolderLabel)
                fullNameTracker.reset(string: sureFullName)
            }
        }
        
        if let fullName = text.extractCardHolder2() {
            trackFullName((fullName, nil))
        } else if let fullName = text.checkFullName(firstName: firstNameSuggestion, lastName: lastNameSuggestion) {
            trackFullName((fullName, nil))
        }
    }
    
    private func showString(string: String, in label: UILabel) {
        DispatchQueue.main.async {
            label.text = "\(string)"
        }
    }
    
    private func showString(string: NSAttributedString, in label: UILabel) {
        DispatchQueue.main.async {
            label.attributedText = string
        }
    }
    
    // MARK: - Scanner Stop
    var observationsCount: Int = 0
    
    private func shouldStopScanner() { 
        if !isScannedForFront{
            if foundNumber != nil && ((foundExpDate != nil && foundCardHolder != nil) || (observationsCount > 50) ) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.async {
                    self.stopLiveStream()
                    self.showScanCompleteToast(message: "Front side scan completed. Please now scan the back side of your card to capture the CVV.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showToastMessage(message: "Please scan the back side of your card to capture the CVV.")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        self.startLiveStream()
                        self.observationsCount = 0
                        self.isScannedForFront = true
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didScanCard(
                        number: strongSelf.foundNumber,
                        expDate: strongSelf.foundExpDate,
                        holder: strongSelf.foundCardHolder
                    )
                }
            }
            
        }else if !isScannedForCVV && isScannedForFront{
            if foundCVV != nil || (observationsCount > 12)  {
                self.stopLiveStream()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.async {
                    self.showScanCompleteToast(message: "Card Scanning completed.",duration:.short)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showCardDetails()
                }
            }
        }
        
        observationsCount += 1
    }
    
    public override func stopLiveStream() {
        super.stopLiveStream()
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.button.setTitle(strongSelf.vv.localizedDoneButton, for: .normal)
            strongSelf.previewView.layer.sublayers?.removeSubrange(2...)
        }
    }
    
    func showScanCompleteToast(message:String,duration:ToastDuration = .long){
        MotionToast_Customisation(header: "", message: message,
                                  headerColor: .white,
                                  messageColor: .black,
                                  primary_color: .white,
                                  secondary_color: .green,
                                  icon_image: UIImage(named: "success_icon")!, duration: .long, toastStyle: .style_vibrant,
                                  toastGravity: .centre, toastCornerRadius: 12, pulseEffect: true)
    }
    
    func showToastMessage(message:String){
        MotionToast(message: message, toastType: .success, duration: .long, toastStyle: .style_vibrant, toastGravity: .top)
    }
    
    func showCardDetails(){
       let vc = CardDetailsViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.cardDetails = CardDetails(cardNumber: foundNumber,expirationDate:foundExpDate ,cardHolderName: foundCardHolder,cvv: foundCVV,cardType: foundType)
        vc.delegate = self
        self.present(vc, animated: true)
    }
}

extension CardScannerController:CardDetailsProtocal{
    func didTapOnRescan() {
        showToastForScaning()
        self.startLiveStream()
        resetRescan()
    }
}
