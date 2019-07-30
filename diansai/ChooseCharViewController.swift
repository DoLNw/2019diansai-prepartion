//
//  ChooseCharViewController.swift
//  TransparentSend
//
//  Created by JiaCheng on 2019/6/22.
//  Copyright © 2019 JiaCheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import AudioToolbox

class ChooseCharViewController: UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var selectLabel: UIButton!
    
    @IBOutlet weak var writeLayer: UIView!
    @IBOutlet weak var readLayer: UIView!
    @IBOutlet weak var notifyLayer: UIView!
    
    @IBAction func saveBtn(_ sender: UIButton) {
        switch selectLabel.title(for: UIControl.State.normal) {
        case "发送":
            self.writeService.text = "\(pickerView.selectedRow(inComponent: 0))"
            if self.writeService.text! == "0" {
                self.writeService.text = ""
            }
            self.writeChar.text = "\(pickerView.selectedRow(inComponent: 1))"
            if self.writeChar.text! == "0" {
                self.writeChar.text = ""
            }
        case "读取":
            self.readService.text = "\(pickerView.selectedRow(inComponent: 0))"
            if self.readService.text! == "0" {
                self.readService.text = ""
            }
            self.readChar.text = "\(pickerView.selectedRow(inComponent: 1))"
            if self.readChar.text == "0" {
                self.readChar.text = ""
            }
        case "通知":
            self.notifyService.text = "\(pickerView.selectedRow(inComponent: 0))"
            if self.notifyService.text! == "0" {
                self.notifyService.text = ""
            }
            self.notifyChar.text = "\(pickerView.selectedRow(inComponent: 1))"
            if self.notifyChar.text! == "0" {
                self.notifyChar.text = ""
            }
        default:
            break
        }
    }
    
    var serviceNumbers = 0
    var charactisticNumbers = 0
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.performSegue(withIdentifier: "closeChoose", sender: nil)
//        self.dismiss(animated: true, completion: nil)
    }
    
    var writeType: CBCharacteristicWriteType?
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBAction func doneAct(_ sender: UIButton) {
        guard BlueToothCentral.peripheral != nil else {
            showErrorAlertWithTitle("Error", message: "请先连接")
            return
        }
        
        var debugMessage = ""
        var newChange = 0
        if writeService.text != "" || writeChar.text != "" {
            newChange += 1
        }
        if readService.text != "" || readChar.text != "" {
            newChange += 1
        }
        if notifyService.text != "" || notifyChar.text != "" {
            newChange += 1
        }
        var allConfirmed = 0
        
        if let writeServiceText = writeService.text, let writeCharText = writeChar.text, let writeServiceNum = Int(writeServiceText), let writeCharNum = Int(writeCharText) {
            if BlueToothCentral.services.count >= writeServiceNum && writeServiceNum >= 0 {
                let service = BlueToothCentral.services[writeServiceNum-1]
                if (BlueToothCentral.characteristics[service])!.count >= writeCharNum && writeCharNum >= 0 {
                    
                    if (BlueToothCentral.characteristics[service]![writeCharNum-1].properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0 {
                        self.writeType = .withResponse
                        BlueToothCentral.characteristic = BlueToothCentral.characteristics[service]![writeCharNum-1]
                        debugMessage += "writeCharacteristic Ok!"
                        
                        BlueToothCentral.writeServiceNum = writeServiceNum
                        BlueToothCentral.writeCharNum = writeCharNum
                        BlueToothCentral.writeType = .withResponse
                        
                        allConfirmed += 1
                    } else if (BlueToothCentral.characteristics[service]![writeCharNum-1].properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
                        self.writeType = .withoutResponse
                        BlueToothCentral.characteristic = BlueToothCentral.characteristics[service]![writeCharNum-1]
                        debugMessage += "writeCharacteristic Ok!"
                        
                        BlueToothCentral.writeServiceNum = writeServiceNum
                        BlueToothCentral.writeCharNum = writeCharNum
                        BlueToothCentral.writeType = .withoutResponse
                        
                        allConfirmed += 1
                    }
                }
            }
        }
        
        if let readServiceText = readService.text, let readCharText = readChar.text, let readServiceNum = Int(readServiceText), let readCharNum = Int(readCharText) {
            if BlueToothCentral.services.count >= readServiceNum && readServiceNum >= 0 {
                let service = BlueToothCentral.services[readServiceNum-1]
                if (BlueToothCentral.characteristics[service])!.count >= readCharNum && readCharNum >= 0 && ((BlueToothCentral.characteristics[service]![readCharNum-1].properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0) {
                    
                    BlueToothCentral.readCharacteristic = BlueToothCentral.characteristics[service]![readCharNum-1]
                    debugMessage += "\nreadCharacteristic Ok!"
                    
                    BlueToothCentral.readServiceNum = readServiceNum
                    BlueToothCentral.readCharNum = readCharNum
                    
                    allConfirmed += 1
                }
            }
        }
        
        if let notifyServiceText = notifyService.text, let notifyCharText = notifyChar.text, let notifyServiceNum = Int(notifyServiceText), let notifyCharNum = Int(notifyCharText) {
            if BlueToothCentral.services.count >= notifyServiceNum && notifyServiceNum >= 0 {
                let service = BlueToothCentral.services[notifyServiceNum-1]
                if (BlueToothCentral.characteristics[service])!.count >= notifyCharNum && notifyCharNum >= 0 && ((BlueToothCentral.characteristics[service]![notifyCharNum-1].properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0) {
                    
                    if BlueToothCentral.notifyCharacteristic != nil {
                        BlueToothCentral.peripheral.setNotifyValue(false, for: BlueToothCentral.notifyCharacteristic)
                    }
                    BlueToothCentral.notifyCharacteristic = BlueToothCentral.characteristics[service]![notifyCharNum-1]
                    BlueToothCentral.peripheral.setNotifyValue(true, for: BlueToothCentral.notifyCharacteristic)
                    debugMessage += "\nnotifyCharacteristic Ok!"
                    
                    BlueToothCentral.notifyServiceNum = notifyServiceNum
                    BlueToothCentral.notifyCharNum = notifyCharNum
                    
                    allConfirmed += 1
                }
            }
        }
        
        writeService.resignFirstResponder()
        writeChar.resignFirstResponder()
        readService.resignFirstResponder()
        readChar.resignFirstResponder()
        notifyService.resignFirstResponder()
        notifyChar.resignFirstResponder()
        
        if allConfirmed == newChange {
            AudioServicesPlaySystemSound(1519)
            
            self.performSegue(withIdentifier: "closeChoose", sender: nil)
        } else {
            showErrorAlertWithTitle("以下已选择", message: debugMessage)
        }

    }
    
    @IBOutlet weak var writeService: UITextField!
    @IBOutlet weak var writeChar: UITextField!
    
    @IBOutlet weak var readService: UITextField!
    @IBOutlet weak var readChar: UITextField!
    
    @IBOutlet weak var notifyService: UITextField!
    @IBOutlet weak var notifyChar: UITextField!
    
    //MARK: - view delegate
    var counts = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.writeService.delegate = self
        self.writeChar.delegate = self
        self.readService.delegate = self
        self.readChar.delegate = self
        self.notifyService.delegate = self
        self.notifyChar.delegate = self
        
        self.writeService.becomeFirstResponder()
        
        for service in BlueToothCentral.services {
            counts += "\(BlueToothCentral.characteristics[service]!.count) "
        }
        
        self.writeService.placeholder = "\(BlueToothCentral.services.count)"
        self.writeChar.placeholder = counts
        self.readService.placeholder = "\(BlueToothCentral.services.count)"
        self.readChar.placeholder = counts
        self.notifyService.placeholder = "\(BlueToothCentral.services.count)"
        self.notifyChar.placeholder = counts
        
//        self.writeService.addTarget(self, action: #selector(showPickViewer(_:)), for: .touchDown)
//        self.writeChar.addTarget(self, action: #selector(showPickViewer(_:)), for: .touchDown)
//        self.readService.addTarget(self, action: #selector(showPickViewer(_:)), for: .touchDown)
//        self.readChar.addTarget(self, action: #selector(showPickViewer(_:)), for: .touchDown)
//        self.notifyService.addTarget(self, action: #selector(showPickViewer(_:)), for: .touchDown)
//        self.notifyChar.addTarget(self, action: #selector(showPickViewer(_:)), for: .touchDown)
        
        self.serviceNumbers = BlueToothCentral.services.count
        if self.serviceNumbers != 0 && BlueToothCentral.writeServiceNum != 0 {
            self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.writeServiceNum-1]]!.count
        }
        if self.serviceNumbers != 0 && BlueToothCentral.writeServiceNum == 0 {
            self.charactisticNumbers = 0
        }

//        self.pickerView.
//        self.pickerView.reloadAllComponents()
        self.pickerView.layer.cornerRadius = 7
        self.pickerView.layer.borderWidth = 3
        self.pickerView.layer.borderColor = UIColor.WWDCYellow.cgColor
        self.selectLabel.layer.cornerRadius = 7
        
        self.writeService.textAlignment = .center
        self.writeChar.textAlignment = .center
        self.readService.textAlignment = .center
        self.readChar.textAlignment = .center
        self.notifyService.textAlignment = .center
        self.notifyChar.textAlignment = .center
        
        self.writeLayer.layer.borderWidth = 1.5
        self.writeLayer.layer.cornerRadius = 7
        self.writeLayer.layer.borderColor = UIColor.clear.cgColor
        self.readLayer.layer.borderWidth = 1.5
        self.readLayer.layer.cornerRadius = 7
        self.readLayer.layer.borderColor = UIColor.clear.cgColor
        self.notifyLayer.layer.borderWidth = 1.5
        self.notifyLayer.layer.cornerRadius = 7
        self.notifyLayer.layer.borderColor = UIColor.clear.cgColor
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        if self.serviceNumbers != 0 {
            self.pickerView.selectRow(BlueToothCentral.writeServiceNum, inComponent: 0, animated: true)
            self.pickerView.selectRow(BlueToothCentral.writeCharNum, inComponent: 1, animated: true)
        }
        
        
        if self.serviceNumbers != 0 && BlueToothCentral.writeServiceNum != 0 {
            self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.writeServiceNum-1]]!.count
            self.writeService.text = "\(BlueToothCentral.writeServiceNum)"
            self.writeChar.text = "\(BlueToothCentral.writeCharNum)"
        } else if self.serviceNumbers != 0 && BlueToothCentral.writeServiceNum == 0 {
            self.charactisticNumbers = 0
        }

        if self.serviceNumbers != 0 && BlueToothCentral.readServiceNum != 0 {
            self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.readServiceNum-1]]!.count
            self.readService.text = "\(BlueToothCentral.readServiceNum)"
            self.readChar.text = "\(BlueToothCentral.readCharNum)"
        } else if self.serviceNumbers != 0 && BlueToothCentral.readServiceNum == 0 {
            self.charactisticNumbers = 0
        }

        if self.serviceNumbers != 0 && BlueToothCentral.notifyServiceNum != 0 {
            self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.notifyServiceNum-1]]!.count
            self.notifyService.text = "\(BlueToothCentral.notifyServiceNum)"
            self.notifyChar.text = "\(BlueToothCentral.notifyCharNum)"
        } else if self.serviceNumbers != 0 && BlueToothCentral.notifyServiceNum == 0 {
            self.charactisticNumbers = 0
        }

    }
    
    func showErrorAlertWithTitle(_ title: String?, message: String?) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        
        if segue.identifier == "closeChoose" {
            writeService.resignFirstResponder()
            writeChar.resignFirstResponder()
            readService.resignFirstResponder()
            readChar.resignFirstResponder()
            notifyService.resignFirstResponder()
            notifyChar.resignFirstResponder()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //当我执行返回的转场的时候（我是本controller指到上一个controller的exit按钮，然后选择上一个controller的返回方法，再写好这个segue的identifier，然后再本controller的返回按钮perform这个segue）。（也可以我这里的返回按钮直接指到上一个controller的exit）
        //当转场返回时，先执行这个，然后是上面的perpare，然后就是上一个controller的@IBAction func close(segue: UIStoryboardSegue) 。方法
        return true
    }
}

extension ChooseCharViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "back" || textField.text == "BACK" {
            self.performSegue(withIdentifier: "closeChoose", sender: nil)
            return false
        }
        if textField == writeService {
            writeChar.becomeFirstResponder()
        } else if textField == writeChar {
            readService.becomeFirstResponder()
        } else if textField == readService {
            readChar.becomeFirstResponder()
        } else if textField == readChar {
            notifyService.becomeFirstResponder()
        } else if textField == notifyService {
            notifyChar.becomeFirstResponder()
        } else if textField == notifyChar {
            doneAct(doneBtn)
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        AudioServicesPlaySystemSound(1519)
        showPickView(textField)
        
        switch textField {
        case writeService:
            fallthrough
        case writeChar:
            self.writeLayer.layer.borderColor = UIColor.WWDCYellow.cgColor
            self.readLayer.layer.borderColor = UIColor.clear.cgColor
            self.notifyLayer.layer.borderColor = UIColor.clear.cgColor
        case readService:
            fallthrough
        case readChar:
            self.readLayer.layer.borderColor = UIColor.WWDCYellow.cgColor
            self.writeLayer.layer.borderColor = UIColor.clear.cgColor
            self.notifyLayer.layer.borderColor = UIColor.clear.cgColor
        case notifyService:
            fallthrough
        case notifyChar:
            self.notifyLayer.layer.borderColor = UIColor.WWDCYellow.cgColor
            self.writeLayer.layer.borderColor = UIColor.clear.cgColor
            self.readLayer.layer.borderColor = UIColor.clear.cgColor
        default:
            break
        }
        
        return false
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if string == "0" {
//            return false
//        }
//        let int = Int(string)
//        if string == "" || int != nil {
//            if textField == writeService {
//                if self.writeService.text?.count == 1 && string == "" {
//                    self.writeChar.placeholder = counts
//                    return true
//                }
//
//                if let num = Int(self.writeService.text! + string), BlueToothCentral.services.count >= num {
//
//                    self.writeChar.placeholder = "\(BlueToothCentral.characteristics[BlueToothCentral.services[num-1]]!.count)"
//                    return true
//                }
//            } else if textField == writeChar {
//                if let num = Int(self.writeService.text!), BlueToothCentral.services.count >= num {
//                    if let num1 = Int(self.writeChar.text! + string), BlueToothCentral.characteristics[BlueToothCentral.services[num-1]]!.count >= num1 {
//
//                        return true
//                    }
//                }
//            } else if textField == readService {
//                if self.readService.text?.count == 1 && string == "" {
//                    self.readChar.placeholder = counts
//                    return true
//                }
//
//                if let num = Int(self.readService.text! + string), BlueToothCentral.services.count >= num {
//
//                    self.readChar.placeholder = "\(BlueToothCentral.characteristics[BlueToothCentral.services[num-1]]!.count)"
//                    return true
//                }
//            } else if textField == readChar {
//                if let num = Int(self.readService.text!), BlueToothCentral.services.count >= num {
//                    if let num1 = Int(self.readChar.text! + string), BlueToothCentral.characteristics[BlueToothCentral.services[num-1]]!.count >= num1 {
//
//                        return true
//                    }
//                }
//            } else if textField == notifyService {
//                if self.notifyService.text?.count == 1 && string == "" {
//                    self.notifyChar.placeholder = counts
//                    return true
//                }
//
//                if let num = Int(self.notifyService.text! + string), BlueToothCentral.services.count >= num {
//
//                    self.notifyChar.placeholder = "\(BlueToothCentral.characteristics[BlueToothCentral.services[num-1]]!.count)"
//                    return true
//                }
//            } else if textField == notifyChar {
//                if let num = Int(self.notifyService.text!), BlueToothCentral.services.count >= num {
//                    if let num1 = Int(self.notifyChar.text! + string), BlueToothCentral.characteristics[BlueToothCentral.services[num-1]]!.count >= num1 {
//
//                        return true
//                    }
//                }
//            }
//        }
//
//        if string == "" {
//            return true
//        }
//
//        return false
//    }
}

extension ChooseCharViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(keyCommands(sender:)), discoverabilityTitle: "close")]
    }
    
    @objc func keyCommands(sender: UIKeyCommand) {
        switch sender.input {
        case "w":
            self.performSegue(withIdentifier: "closeChoose", sender: nil)
        default:
            break
        }
    }
}

extension ChooseCharViewController: UIPickerViewDataSource, UIPickerViewDelegate {
//    @objc func showPickViewer(_ sender: UITextField) {
//        print(sender.placeholder)
//    }
    
    @objc func showPickView(_ sender: UITextField) {
//        print(String(describing: sender.placeholder))
        switch sender {
        case writeService:
            fallthrough
        case writeChar:
            self.selectLabel.setTitle("发送", for: .normal)
            if self.serviceNumbers != 0 && BlueToothCentral.writeServiceNum != 0 {
                self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.writeServiceNum-1]]!.count
                self.writeService.text = "\(BlueToothCentral.writeServiceNum)"
                self.writeChar.text = "\(BlueToothCentral.writeCharNum)"
            } else if self.serviceNumbers != 0 && BlueToothCentral.writeServiceNum == 0 {
                self.charactisticNumbers = 0
            }
            
            self.pickerView.reloadComponent(1)
            self.pickerView.selectRow(BlueToothCentral.writeServiceNum, inComponent: 0, animated: true)
            self.pickerView.selectRow(BlueToothCentral.writeCharNum, inComponent: 1, animated: true)
            
        case readService:
            fallthrough
        case readChar:
            self.selectLabel.setTitle("读取", for: .normal)
            if self.serviceNumbers != 0 && BlueToothCentral.readServiceNum != 0 {
                self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.readServiceNum-1]]!.count
                self.readService.text = "\(BlueToothCentral.readServiceNum)"
                self.readChar.text = "\(BlueToothCentral.readCharNum)"
            } else if self.serviceNumbers != 0 && BlueToothCentral.readServiceNum == 0 {
                self.charactisticNumbers = 0
            }
            self.pickerView.reloadComponent(1)
            self.pickerView.selectRow(BlueToothCentral.readServiceNum, inComponent: 0, animated: true)
            self.pickerView.selectRow(BlueToothCentral.readCharNum, inComponent: 1, animated: true)
            
        case notifyService:
            fallthrough
        case notifyChar:
            self.selectLabel.setTitle("通知", for: .normal)
            if self.serviceNumbers != 0 && BlueToothCentral.notifyServiceNum != 0 {
                self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[BlueToothCentral.notifyServiceNum-1]]!.count
                self.notifyService.text = "\(BlueToothCentral.notifyServiceNum)"
                self.notifyChar.text = "\(BlueToothCentral.notifyCharNum)"
            } else if self.serviceNumbers != 0 && BlueToothCentral.notifyServiceNum == 0 {
                self.charactisticNumbers = 0
            }
            self.pickerView.reloadComponent(1)
            self.pickerView.selectRow(BlueToothCentral.notifyServiceNum, inComponent: 0, animated: true)
            self.pickerView.selectRow(BlueToothCentral.notifyCharNum, inComponent: 1, animated: true)
            
        default:
            break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.serviceNumbers + 1
        case 1:
            return self.charactisticNumbers + 1
        default:
            break
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row)"
        case 1:
            return "\(row)"
        default:
            break
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 && row == 0 {
            self.charactisticNumbers = 0
            self.pickerView.reloadComponent(1)
            switch selectLabel.title(for: .normal) {
            case "发送":
                self.writeService.text = ""
                self.writeChar.text = ""
            case "读取":
                self.readService.text = ""
                self.readChar.text = ""
            case "通知":
                self.notifyService.text = ""
                self.notifyChar.text = ""
            default:
                break
            }
        } else if component == 1 && row == 0 {
            switch selectLabel.title(for: .normal) {
            case "发送":
                self.writeChar.text = ""
            case "读取":
                self.readChar.text = ""
            case "通知":
                self.notifyChar.text = ""
            default:
                break
            }
        } else if component == 0 && self.serviceNumbers != 0 && row != 0 {
            self.charactisticNumbers = BlueToothCentral.characteristics[BlueToothCentral.services[row-1]]!.count
            self.pickerView.reloadComponent(1)
            switch selectLabel.title(for: .normal) {
            case "发送":
                self.writeService.text = "\(row)"
                self.writeChar.text = "\(1)"
                if row == BlueToothCentral.writeServiceNum {
                    self.pickerView.selectRow(BlueToothCentral.writeCharNum, inComponent: 1, animated: true)
                    self.writeService.text = "\(BlueToothCentral.writeServiceNum)"
                    self.writeChar.text = "\(BlueToothCentral.writeCharNum)"
                    return
                }
            case "读取":
                self.readService.text = "\(row)"
                self.readChar.text = "\(1)"
                if row == BlueToothCentral.readServiceNum {
                    self.pickerView.selectRow(BlueToothCentral.readCharNum, inComponent: 1, animated: true)
                    self.readService.text = "\(BlueToothCentral.readServiceNum)"
                    self.readChar.text = "\(BlueToothCentral.readCharNum)"
                    return
                }
            case "通知":
                self.notifyService.text = "\(row)"
                self.notifyChar.text = "\(1)"
                if row == BlueToothCentral.notifyServiceNum {
                    self.pickerView.selectRow(BlueToothCentral.notifyCharNum, inComponent: 1, animated: true)
                    self.notifyService.text = "\(BlueToothCentral.notifyServiceNum)"
                    self.notifyChar.text = "\(BlueToothCentral.notifyCharNum)"
                    return
                }
            default:
                break
            }
            
            self.pickerView.selectRow(1, inComponent: 1, animated: true)
        } else if component == 1 {
            switch selectLabel.title(for: .normal) {
            case "发送":
                self.writeChar.text = "\(row)"
            case "读取":
                self.readChar.text = "\(row)"
            case "通知":
                self.notifyChar.text = "\(row)"
            default:
                break
            }
        }
    }
}
