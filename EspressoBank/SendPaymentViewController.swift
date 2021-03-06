//
//  SendPaymentViewController.swift
//  EspressoBank
//
//  Created by Samuël Maljaars on 21/08/16.
//  Copyright © 2016 Samuël Maljaars. All rights reserved.
//

import UIKit

protocol FlowPaymentDataDelegate: class {
    func validatePaymentData()
}

class SendPaymentViewController: BaseViewController, FlowPaymentDataDelegate {
        
    let orchestrator = PaymentFlowOrchestrator.sharedInstance
    
    func validatePaymentData(){
        
        var payment: Payment!
        
        if let name = name.text, let iban = iban.text, let amount = amount.text, let amountDouble = Double(amount), name != "" && iban != "" {
            if let paymentDescription = paymentDescription.text {
                payment = Payment(name: name, iban: iban, amount: amountDouble, paymentDescription: paymentDescription)
            } else {
                payment = Payment(name: name, iban: iban, amount: amountDouble, paymentDescription: nil)
            }
            PaymentFlowOrchestrator.sharedInstance.paymentToConfirm = payment
        }
    }
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var iban: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var paymentDescription: UITextField!
    
    let numberToolbar: UIToolbar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        name.delegate = self
        iban.delegate = self
        amount.delegate = self
        paymentDescription.delegate = self
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelKeyboard)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
        ]
        
        numberToolbar.sizeToFit()
        
        amount.inputAccessoryView = numberToolbar
    }
    
    func dismissKeyboard () {
        amount.resignFirstResponder()
    }
    
    func cancelKeyboard () {
        amount.text=""
        amount.resignFirstResponder()
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            print("send payment will move nil parent")
            orchestrator.state = .transactions
            delegate.backButtonTapped()
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            print("send payment did move nil parent")
            orchestrator.state = .transactions
            delegate.backButtonTapped()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y >= 0 && (paymentDescription.isEditing || amount.isEditing) {
                self.view.frame.origin.y -= 0.3*keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += 0.3*keyboardSize.height
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension SendPaymentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
