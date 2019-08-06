//
//  EditandAddUIViewController.swift
//  diansai
//
//  Created by JiaCheng on 2019/8/2.
//  Copyright © 2019 JiaCheng. All rights reserved.
//

import UIKit
import AudioToolbox

class EditandAddUIViewController: UIViewController {
    var elements = [Element]()
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var sysTypeField: UITextField!
    @IBOutlet weak var propertyField: UITextField!
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var sendPrefix: UITextField!
    @IBOutlet weak var receivePrefixField: UITextField!
    
    var name = ""
    var number = -1
    
    var selectedTextField: UITextField!
    
    let properties: [String] = [Charactistic.read.rawValue, Charactistic.write.rawValue, Charactistic.readAndWrite.rawValue]
    let sysTypes: [String] = [SysType.system.rawValue, SysType.custom.rawValue]
    var pickerResource = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sysTypeField.delegate = self
        propertyField.delegate = self
        displayNameField.delegate = self
        sendPrefix.delegate = self
        receivePrefixField.delegate = self

        self.title = ElementsSettingTableViewController.destinationName
        // Do any additional setup after loading the view.
        
        let rightBarItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = rightBarItem
        
        let leftBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = leftBarItem
        
        pickerView.delegate = self
        self.pickerView.alpha = 0
        self.pickerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height/2)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapAct(_:)))
        self.view.addGestureRecognizer(tapgesture)
        
        self.number = ElementsSettingTableViewController.editNumber
        if self.number != -1 {
            let user = UserDefaults.standard
            
            if let propertylistmenbers = user.array(forKey: "elements") as? [[String:String]] {
                for menber in propertylistmenbers {
                    elements.append(Element(sysType: SysType(rawValue: menber["sysType"]!), property: Charactistic(rawValue: menber["property"]!), displayName: menber["displayName"], sendPrefix: menber["sendPrefix"], receivePrefix: menber["receivePrefix"]))
                }
                
            }
            
            self.title = ElementsSettingTableViewController.destinationName + ": " + elements[self.number].displayName
            self.sysTypeField.text = elements[self.number].sysType.rawValue
            self.propertyField.text = elements[self.number].property.rawValue
            self.displayNameField.text = elements[self.number].displayName
            self.sendPrefix.text = elements[self.number].sendPrefix ?? "nil"
            self.receivePrefixField.text = elements[self.number].receivePrefix
        }
    }
    
    @objc func save() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditandAddUIViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerResource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerResource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedTextField.text = self.pickerResource[row]
    }
}

extension EditandAddUIViewController: UITextFieldDelegate {
    @objc func tapAct(_ gestureRecognizer: UITapGestureRecognizer) {
//        self.sysTypeField.resignFirstResponder()
//        self.propertyField.resignFirstResponder()
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.pickerView.alpha = 0
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height/2)
        }
        self.displayNameField.resignFirstResponder()
        self.sendPrefix.resignFirstResponder()
        self.receivePrefixField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case sysTypeField:
            showPickerView()
            self.pickerResource = self.sysTypes
            self.pickerView.reloadComponent(0)
            selectedTextField = textField
        case propertyField:
            showPickerView()
            self.pickerResource = self.properties
            self.pickerView.reloadComponent(0)
            selectedTextField = textField
        default:
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.pickerView.alpha = 0
                self.pickerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height/2)
            }
            return true
        }
        return false
    }
    
    func showPickerView() {
        self.displayNameField.resignFirstResponder()
        self.sendPrefix.resignFirstResponder()
        self.receivePrefixField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.pickerView.alpha = 1
            self.pickerView.transform = .identity
        }
    }
}
