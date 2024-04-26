import UIKit
// Card Details Model
struct CardDetails {
    var cardNumber: String?
    var expirationDate: String?
    var cardHolderName: String?
    var cvv: String?
    var cardType: String?
    var cardNetwork: String?
}

protocol CardDetailsProtocal{
    func didTapOnRescan()
}

class CardDetailsViewController: UIViewController {
    
    // Define labels and text fields for each card detail
    var cardNumberLabel = UILabel()
    var cardNumberTextField = UITextField()
    var expirationDateLabel = UILabel()
    var expirationDateTextField = UITextField()
    var cvvLabel = UILabel()
    var cvvTextField = UITextField()
    var cardHolderNameLabel = UILabel()
    var cardHolderNameTextField = UITextField()
    var cardTypeLabel = UILabel()
    var cardTypeTextField = UITextField()
  
    var titleLbl = UILabel()
    var reScanBtn = UIButton()
    var cardDetails: CardDetails?
    var delegate:CardDetailsProtocal? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setUpUI()
        setUpTextFieldBorder()
        setUpLeftView()
        displayCardDetails()
        setUpUIFont()
    }
    
    func setUpTextFieldBorder(){
        cardNumberTextField.layer.borderWidth = 1
        expirationDateTextField.layer.borderWidth = 1
        cvvTextField.layer.borderWidth = 1
        cardHolderNameTextField.layer.borderWidth = 1
        cardTypeTextField.layer.borderWidth = 1
        
        cardNumberTextField.layer.cornerRadius = 8
        expirationDateTextField.layer.cornerRadius = 8
        cvvTextField.layer.cornerRadius = 8
        cardHolderNameTextField.layer.cornerRadius = 8
        cardTypeTextField.layer.cornerRadius = 8
    }
    
    func setUpUIFont(){
        cardNumberLabel.font = UIFont.boldSystemFont(ofSize: 17)
        expirationDateLabel.font = UIFont.boldSystemFont(ofSize: 17)
        cvvLabel.font = UIFont.boldSystemFont(ofSize: 17)
        cardHolderNameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        cardTypeLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        titleLbl.font = UIFont.boldSystemFont(ofSize: 22)
        
        cardNumberTextField.isUserInteractionEnabled = false
        expirationDateTextField.isUserInteractionEnabled = false
        cvvTextField.isUserInteractionEnabled = false
        cardHolderNameTextField.isUserInteractionEnabled = false
        cardTypeTextField.isUserInteractionEnabled = false

    }
    
    func setUpLeftView(){
        let leftView1 = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: cardNumberTextField.bounds.height))
        cardNumberTextField.leftView = leftView1
        cardNumberTextField.leftViewMode = .always
        
        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: expirationDateTextField.bounds.height))
        expirationDateTextField.leftView = leftView2
        expirationDateTextField.leftViewMode = .always
        
        let leftView3 = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: cvvTextField.bounds.height))
        cvvTextField.leftView = leftView3
        cvvTextField.leftViewMode = .always
        
        let leftView4 = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: cardHolderNameTextField.bounds.height))
        cardHolderNameTextField.leftView = leftView4
        cardHolderNameTextField.leftViewMode = .always
        
        let leftView5 = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: cardTypeTextField.bounds.height))
        cardTypeTextField.leftView = leftView5
        cardTypeTextField.leftViewMode = .always
    }
    
    func setUpUI() {
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 0
        view.addSubview(titleLbl)
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor,constant: 20),
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            titleLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20)
        ])
        
        titleLbl.text = "Your Card Details"
        
        setupLabelAndTextField(label: cardNumberLabel, textField: cardNumberTextField, title: "Card Number", topAnchor: titleLbl.bottomAnchor, constant: 35)
        setupLabelAndTextField(label: cardHolderNameLabel, textField: cardHolderNameTextField, title: "Cardholder Name", topAnchor: cardNumberTextField.bottomAnchor, constant: 20)
        setupHalfWidthLabelAndTextField(label: expirationDateLabel, textField: expirationDateTextField, title: "Expiration Date", topAnchor: cardHolderNameTextField.bottomAnchor, constant: 20, leadingAnchor: view.leadingAnchor)
        setupHalfWidthLabelAndTextField(label: cvvLabel, textField: cvvTextField, title: "CVV", topAnchor: cardHolderNameTextField.bottomAnchor, constant: 20, leadingAnchor: view.centerXAnchor)
        setupHalfWidthLabelAndTextField(label: cardTypeLabel, textField: cardTypeTextField, title: "Card Type", topAnchor: expirationDateTextField.bottomAnchor, constant: 20, leadingAnchor: view.leadingAnchor)
        
        reScanBtn.translatesAutoresizingMaskIntoConstraints = false
        reScanBtn.setTitle("RESCAN", for: .normal)
        reScanBtn.setTitleColor(UIColor.blue, for: .normal)
        view.addSubview(reScanBtn)
        NSLayoutConstraint.activate([
            reScanBtn.topAnchor.constraint(equalTo:  cardTypeTextField.bottomAnchor,constant: 50),
            reScanBtn.heightAnchor.constraint(equalToConstant: 45),
            reScanBtn.widthAnchor.constraint(equalToConstant: 150),
            reScanBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        reScanBtn.addTarget(self, action: #selector(tapOnReScan), for: .touchUpInside)
        reScanBtn.layer.borderWidth = 1
        reScanBtn.layer.borderColor = UIColor.blue.cgColor
        reScanBtn.layer.cornerRadius = 8
    }
    
    func setupLabelAndTextField(label: UILabel, textField: UITextField, title: String, topAnchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter \(title)"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupHalfWidthLabelAndTextField(label: UILabel, textField: UITextField, title: String, topAnchor: NSLayoutYAxisAnchor, constant: CGFloat, leadingAnchor: NSLayoutXAxisAnchor) {
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter \(title)"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -30),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -30),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func displayCardDetails() {
        cardNumberTextField.text = cardDetails?.cardNumber
        expirationDateTextField.text = cardDetails?.expirationDate
        cvvTextField.text = cardDetails?.cvv
        cardHolderNameTextField.text = cardDetails?.cardHolderName
        cardTypeTextField.text = cardDetails?.cardType
    }
    
    @objc func tapOnReScan(sender:UIButton){
        self.delegate?.didTapOnRescan()
        self.dismiss(animated: true)
    }
}
