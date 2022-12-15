//
//  CustomTextField.swift
//  Aarambh
//
//  Created by Dr.Mac on 15/11/2022.
//

import Foundation
import UIKit

protocol TextFieldDelegate: AnyObject {
    func textFieldDidBecomeActive(view: UIView, texField: UITextField)
}

enum TextFieldType {
    case number
    case text
    case picker
}

 public class CustomTextField: UIView {
    
    @IBOutlet private weak var lblTextFieldName: UILabel!
    @IBOutlet private  weak var txtCustomTextField: UITextField!
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var lblErrorMsg: UILabel!
    @IBOutlet private weak var viewHeight: NSLayoutConstraint!
    
     weak var customTextFieldDelegate: TextFieldDelegate?
    public var pickerOptions: [String]?
    
     var textFieldType: TextFieldType = .text {
        didSet {
            if textFieldType == .text {
                txtCustomTextField.keyboardType = .default
            } else if textFieldType == .number {
                txtCustomTextField.keyboardType = .numberPad
            } else if textFieldType == .picker{
                createPickerView()
            } else {
                txtCustomTextField.keyboardType = .default
            }
        }
    }
    
    public var isRequired: Bool = false {
        didSet {
            if isRequired {
                let newTitle = lblTextFieldName.text!  + "*"
                lblTextFieldName.setText(newTitle, withColorPart: "*", color: .red)
            }
            
        }
    }
    
    public var errorHidden: Bool = true {
        didSet {
            viewHeight.constant = errorHidden ? 60 : 80
            lblErrorMsg.isHidden = errorHidden
        }
    }
    
    public  var errorMessage: String = ""  {
        didSet {
            lblErrorMsg.text = errorMessage
        }
    }
    
    public var title: String = "" {
        didSet {
            lblTextFieldName.text = title
        }
    }
    
    public var text: String = ""{
        didSet {
            txtCustomTextField.text = text
        }
    }
    
    public var placeholder: String = ""{
        didSet {
            txtCustomTextField.placeholder = placeholder
        }
    }
    
    private var viewConfiguration: CustomTextFieldConfiguration = CustomTextFieldConfiguration() {
        didSet {
            setCustomViewConfiguration(configuration: viewConfiguration)
        }
    }
    
    let nibName = "CustomTextField"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        lblErrorMsg.isHidden = true
        self.addSubview(view)
        txtCustomTextField.delegate = self
    }
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
     public override func awakeFromNib() {
        
    }
    
     func setViewConfiguration(configuration: CustomTextFieldConfiguration) {
        viewConfiguration = configuration
    }
    
    private  func defaultViewConfiguration() -> CustomTextFieldConfiguration {
        return CustomTextFieldConfiguration()
    }
    
    private  func setCustomViewConfiguration(configuration: CustomTextFieldConfiguration) {
        if let viewBG = configuration.viewBackgroundColor {
            self.backgroundColor = viewBG
        }
        if let viewBW = configuration.viewBorderWidth {
            self.layer.borderWidth = viewBW
        }
        
        if let viewBC = configuration.viewBorderColor {
            self.layer.borderColor = viewBC
        }
        
        if let viewCR = configuration.viewCorner {
            self.layer.cornerRadius = viewCR
        }
        
        if let titleFont = configuration.titleFont {
            lblTextFieldName.font = titleFont
        }
        
        if let titleFC = configuration.titleFontColor {
            lblTextFieldName.textColor = titleFC
            if let title = lblTextFieldName.text {
                lblTextFieldName.setText(title, withColorPart: "*", color: .red)
            }
        }
        
        if let textFieldB = configuration.textFieldBorderStyle {
            txtCustomTextField.borderStyle = textFieldB
        }
        
        if let textFieldTF = configuration.textFieldTextFont {
            txtCustomTextField.font = textFieldTF
        }
        
        if let textFieldTC = configuration.textFieldTextColor {
            txtCustomTextField.textColor = textFieldTC
        }
        
        if let errorF = configuration.errorFont {
            lblErrorMsg.font = errorF
        }
        
    }
}

//MARK: TextField Delegate
extension CustomTextField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        lblErrorMsg.isHidden = true
        viewHeight.constant = 60
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtCustomTextField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        customTextFieldDelegate?.textFieldDidBecomeActive(view: self, texField: textField)
    }
    
    
}

//MARK: UIPickerView Delegate and DataSource
extension CustomTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    
    private func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txtCustomTextField.inputView = pickerView
        btnDoneForPicker()
    }
    
    private func btnDoneForPicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.btnAction))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        txtCustomTextField.inputAccessoryView = toolBar
    }
    @objc func btnAction() {
        view.endEditing(true)
        self.errorHidden = true
        
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions?.count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions?[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        txtCustomTextField.text = pickerOptions?[row]
        
    }
    
}

extension UILabel {
    
    func setText(_ text: String, withColorPart colorTextPart: String, color: UIColor) {
        attributedText = nil
        let result =  NSMutableAttributedString(string: text)
        result.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSString(string: text.lowercased()).range(of: colorTextPart.lowercased()))
        attributedText = result
    }
    
}
