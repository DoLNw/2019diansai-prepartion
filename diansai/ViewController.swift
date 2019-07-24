//
//  ViewController.swift
//  CameraCapture1
//
//  Created by JiaCheng on 2018/10/22.
//  Copyright © 2018 JiaCheng. All rights reserved.
//

import UIKit
import AVFoundation
import CoreBluetooth
import AudioToolbox

enum ShowType: String {
    case normal
    case bigger
    
    mutating func changeShowType(type to: ShowType) {
        self = to
    }
    
    mutating func biggerToggle() {
        if self == .normal {
            self = .bigger
        } else if self == .bigger {
            self = .normal
        }
    }
}

class ViewController: UIViewController {
    var showType: ShowType = .normal
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func chooseChartistic(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        
        self.performSegue(withIdentifier: "goToChoose", sender: nil)
    }
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func chooseCharBtnAct(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        
        self.performSegue(withIdentifier: "goToChoose", sender: nil)
    }
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    let blueToothCentral = BlueToothCentral()
    
    @IBOutlet weak var receiveBigTextView: UITextView!
    
    var allStr = ""
    var receiveStr = "" {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                switch self.showType {
                case .normal:
                    break
                case .bigger:
                    self.receiveBigTextView.text = self.receiveStr
                    self.receiveBigTextView.scrollRangeToVisible(NSRange(location:self.receiveStr.lengthOfBytes(using: .utf8), length: 0))
                }
            }
        }
    }
    
    @IBOutlet weak var page1View: UIView!
    @IBOutlet weak var page1shadowView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var page2View: UIView!
    @IBOutlet weak var page2ShadowView: UIView!
    @IBOutlet weak var freqTextField: UITextField!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var setUTextFueld: UITextField!
    @IBOutlet weak var urmsLabel: UILabel!
    @IBOutlet weak var outLabel: UILabel!
    @IBOutlet weak var irmsLabel: UILabel!
    
    @IBOutlet weak var page3View: UIView!
    @IBOutlet weak var page3ShadowView: UIView!
    @IBOutlet weak var lockTextField: UITextField!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var ctrlTextField: UITextField!
    
    @IBOutlet weak var disConnectBtn: UIButton!
    @IBOutlet weak var connectBtn: UIButton!
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UnConnected"
        self.titleLabel.text = "UnConnected"
        
        BlueToothCentral.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
        self.blueDisplay()
        
        self.receiveBigTextView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)

        //双击加在self.view上后，若button也在view上，则会引起点击button响应有延迟
//        let doubleTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(doubleTapAct(_:)))
//        doubleTapGesture1.numberOfTapsRequired = 2
//        self.view.addGestureRecognizer(doubleTapGesture1)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAct(_:)))
        self.view.addGestureRecognizer(longPress)
        
        let doubleTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(doubleTapAct(_:)))
        doubleTapGesture2.numberOfTapsRequired = 1
        self.receiveBigTextView.addGestureRecognizer(doubleTapGesture2)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapAction.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapAction)
        
        page1shadowView.backgroundColor = .WWDCYellow
        page2ShadowView.backgroundColor = .WWDCGreen
        page3ShadowView.backgroundColor = .CaliforniaCondorColor
        
        self.freqTextField.delegate = self
        self.setUTextFueld.delegate = self
        self.lockTextField.delegate = self
        self.refTextField.delegate = self
        self.ctrlTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.page1View.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.page1View.layer.shadowRadius = 5
        self.page1View.layer.shadowOpacity = 0.35
        self.page1View.layer.shadowColor = UIColor.black.cgColor
        
        self.page2View.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.page2View.layer.shadowRadius = 5
        self.page2View.layer.shadowOpacity = 0.35
        self.page2View.layer.shadowColor = UIColor.black.cgColor
        
        self.page3View.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.page3View.layer.shadowRadius = 5
        self.page3View.layer.shadowOpacity = 0.35
        self.page3View.layer.shadowColor = UIColor.black.cgColor
//        self.page2ShadowView.layer.masksToBounds = true
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if BlueToothCentral.peripheral == nil {
            self.connectBtn.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }
}

//MARK: - BlueToothDelegate
extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func startBlueTooth() {
        guard BlueToothCentral.isBlueOn else { return }
        
        let scanTableController = storyboard?.instantiateViewController(withIdentifier: "ScanTableController") as! ScanTableViewController
        self.navigationController?.pushViewController(scanTableController, animated: true)
        
        connectBtn.isHidden = true

    }
    @objc func blueBtnMethod(_ sender: UIButton) {
        if sender.currentTitle == "ScanPer" {
            AudioServicesPlaySystemSound(1519)

            startBlueTooth()
        } else if sender.currentTitle == "Discont" {
            guard BlueToothCentral.peripheral != nil else { return }
            BlueToothCentral.centralManager.cancelPeripheralConnection(BlueToothCentral.peripheral)
        }
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            BlueToothCentral.isBlueOn = true
            DispatchQueue.main.sync {
                connectBtn.isHidden = false
                self.title = "UnConnected"
                self.titleLabel.text = "UnConnected"
            }
//            BlueToothCentral.centralManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            BlueToothCentral.isBlueOn = false
            DispatchQueue.main.sync {
                if (self.navigationController?.viewControllers.count)! > 1 {
                    self.navigationController?.popViewController(animated: true)
                }
                self.disConnectBtn.isHidden = true
                self.connectBtn.isHidden = true
                allBtnisHidden(true)
                self.title = ""
                self.titleLabel.text = ""
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25) { [unowned self] in
                //貌似转场没结束，直接按钮隐身是没用的，所以只能after动画结束了难受
                self.disConnectBtn.isHidden = true
                self.connectBtn.isHidden = true
            }
            if BlueToothCentral.peripheral != nil {
                centralManager(BlueToothCentral.centralManager, didDisconnectPeripheral: BlueToothCentral.peripheral, error: nil)
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else { return }
        if BlueToothCentral.isFirstPer {
            BlueToothCentral.isFirstPer = false
            BlueToothCentral.peripherals = []
            BlueToothCentral.peripheralIDs = []
            BlueToothCentral.peripherals.append(peripheral.name ?? "Unknown")
            BlueToothCentral.peripheralIDs.append(peripheral)
        } else {
            for per in BlueToothCentral.peripheralIDs {
                if per == peripheral { return }
            }
            BlueToothCentral.peripherals.append(peripheral.name ?? "Unknown")
            BlueToothCentral.peripheralIDs.append(peripheral)
        }

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //如果连接之前已经有一个连接着了，那么需要把它先disconnect？不然虽然可能可以两个连着，但也只有一个的引用呀现在。
        if BlueToothCentral.peripheral != nil {
            
        }
        
//        self.rtthreadSendTextField.text = ""
        print("didConnect: ")
        BlueToothCentral.peripheral = peripheral
        BlueToothCentral.centralManager.stopScan()
        BlueToothCentral.peripheral.delegate = self
        BlueToothCentral.peripheral.discoverServices(nil)
        
        //注意self.title这个也需要在主线程
        DispatchQueue.main.sync { [unowned self] in
            self.title = peripheral.name
            self.titleLabel.text = peripheral.name
            self.disConnectBtn.isHidden = false
            self.connectBtn.isHidden = true
            self.allBtnisHidden(false)
            //注意在手势触发蓝牙扫描转场的时候，因为在Transition这一个类里面，所以无法对我们的按钮进行操控（也就是不能像startBlueTooth方法一样对connectbtn隐藏，且使activityView动画），所以为了稍微正常一点，我把connectbtn的隐藏在这下面也写一下，activityView就没有动画了，反正也被遮住了看不到🤦‍♂️。
            self.navigationController?.popViewController(animated: true)
        }
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect: ")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral: ")
        AudioServicesPlaySystemSound(1521)
        BlueToothCentral.peripheral = nil
        BlueToothCentral.characteristic = nil
        DispatchQueue.main.async { [unowned self] in
            
            self.allBtnisHidden(true)
            if BlueToothCentral.isBlueOn {
                self.disConnectBtn.isHidden = true
                self.connectBtn.isHidden = false
                self.title = "UnConnected"
                self.titleLabel.text = "UnConnected"
            } else {
                self.disConnectBtn.isHidden = true
                self.connectBtn.isHidden = true
                self.title = ""
                self.titleLabel.text = ""
            }
        }
        
        BlueToothCentral.services.removeAll()
        BlueToothCentral.characteristics.removeAll()
        BlueToothCentral.characteristic = nil
        BlueToothCentral.readCharacteristic = nil
        BlueToothCentral.notifyCharacteristic = nil
        
        BlueToothCentral.writeServiceNum = 0
        BlueToothCentral.writeCharNum = 0
        BlueToothCentral.readServiceNum = 0
        BlueToothCentral.readCharNum = 0
        BlueToothCentral.notifyServiceNum = 0
        BlueToothCentral.notifyCharNum = 0
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard BlueToothCentral.peripheral == peripheral else { return }
        
        for service in peripheral.services! {
            if let _ = BlueToothCentral.characteristics[service] {
                continue
            } else {
                BlueToothCentral.characteristics[service] = [CBCharacteristic]()
                BlueToothCentral.services.append(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard BlueToothCentral.peripheral == peripheral else { return }
        if let _ = BlueToothCentral.characteristics[service] {
            for charactistic in service.characteristics! {
                BlueToothCentral.characteristics[service]?.append(charactistic)
            }
        }
        
        //专门针对HC-02直接取好了对应的特征
        if BlueToothCentral.characteristic == nil && BlueToothCentral.services.count >= 2 {
            if BlueToothCentral.characteristics[BlueToothCentral.services[1]]!.count >= 3 {
                BlueToothCentral.notifyServiceNum = 2
                BlueToothCentral.notifyCharNum = 3
                BlueToothCentral.notifyCharacteristic = BlueToothCentral.characteristics[BlueToothCentral.services[1]]![2]
                
                if (BlueToothCentral.notifyCharacteristic.properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0 {
                    BlueToothCentral.peripheral.setNotifyValue(true, for: BlueToothCentral.notifyCharacteristic)
                }
            }
            if BlueToothCentral.characteristics[BlueToothCentral.services[1]]!.count >= 4 {
                BlueToothCentral.writeCharNum = 4
                BlueToothCentral.writeServiceNum = 2
                BlueToothCentral.characteristic = BlueToothCentral.characteristics[BlueToothCentral.services[1]]![3]
                
                if (BlueToothCentral.characteristic.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
                    BlueToothCentral.writeType = CBCharacteristicWriteType.withoutResponse
                }
                if (BlueToothCentral.characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0 {
                    BlueToothCentral.writeType = CBCharacteristicWriteType.withResponse
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("Updated")
        if let error = error {
            print(error.localizedDescription)
        } else {
            let valueData = characteristic.value!
            let data = NSData(data: valueData)
            let valueStr = data.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
            guard valueStr.count > 0 else { return }
            var firstIndex = valueStr.startIndex
            var secondindex = valueStr.index(firstIndex, offsetBy: 1)
            var valueStrs = [String]()

            for _ in 0..<valueStr.count/2-1 {
                valueStrs.append(String(valueStr[firstIndex...secondindex]))
                firstIndex = valueStr.index(secondindex, offsetBy: 1)
                secondindex = valueStr.index(firstIndex, offsetBy: 1)
            }
            valueStrs.append(String(valueStr[firstIndex...secondindex]))
            
            var values = ""
            //收到的是16进制的String表示

            var dataInt = [String]()
            for uint8str in valueStrs {
                if let uint8 = UInt8(uint8str, radix: 16) {
                    
                    if (uint8 >= 0 && uint8 <= 8) || (uint8 >= 11 && uint8 <= 12) || (uint8 >= 14 && uint8 <= 31) || (uint8 == 127 ) {
                        dataInt.append("\\u{\(uint8)}") //让其显示十进制的
                    } else {
                        let char = Character(UnicodeScalar(uint8))
                        dataInt.append("\(char)")
                    }
                }
            }
            
            values = dataInt.joined(separator: "")
            allStr += values

            if values.hasSuffix("\n") {
                let splites = allStr.components(separatedBy: "@@")
                
                DispatchQueue.main.async { [unowned self] in
                    for splite in splites {
                        var temp = splite
                        if splite.hasPrefix("out") {
                            for _ in 0 ..< 3 { temp.removeFirst() }
                            self.outLabel.text = temp
                        }else if splite.hasPrefix("lock") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            if !self.lockTextField.isFirstResponder {
                                self.lockTextField.text = temp
                            }
                        } else if splite.hasPrefix("ref") {
                            for _ in 0 ..< 3 { temp.removeFirst() }
                            if !self.refTextField.isFirstResponder {
                                self.refTextField.text = temp
                            }
                        } else if splite.hasPrefix("irms") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            self.irmsLabel.text = temp
                        } else if splite.hasPrefix("ctrl") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            if !self.ctrlTextField.isFirstResponder {
                                self.ctrlTextField.text = temp
                            }
                        } else if splite.hasPrefix("urms") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            self.urmsLabel.text = temp
                        } else if splite.hasPrefix("calendar") {
                            for _ in 0 ..< 8 { temp.removeFirst() }
                            self.timeLabel.text = temp
                        } else if splite.hasPrefix("time") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            self.timeLabel.text = self.timeLabel.text! + "  " + temp
                        } else if splite.hasPrefix("freq") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            if !self.freqTextField.isFirstResponder {
                                self.freqTextField.text = temp
                            }
                        } else if splite.hasPrefix("average") {
                            for _ in 0 ..< 7 { temp.removeFirst() }
                            self.averageLabel.text = temp
                        } else if splite.hasPrefix("uset") {
                            for _ in 0 ..< 4 { temp.removeFirst() }
                            if !self.setUTextFueld.isFirstResponder {
                                self.setUTextFueld.text = temp
                            }
                        }
                    }
                }
                
                allStr = ""
            }
            
            if showType == .bigger {
                self.receiveStr += "\(values)"
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Notidied")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("write to peripheral withresponse")
    }
    
}


//MARK: - TextView and Gesture Delegate
extension ViewController: UITextFieldDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    //MARK: - UIGesture delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let _ = Int(string) {
            return true
        } else if string == "." || string == "" {
            return true
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.freqTextField:
            if var freqDouble = Double(self.freqTextField.text!) {
                if freqDouble >= 200 {
                    freqDouble = 200
                } else if freqDouble <= 0 {
                    freqDouble = 0
                }
                
                let freqInt = Int(freqDouble*100)
                
                if BlueToothCentral.writeType != nil {
                    BlueToothCentral.peripheral.writeValue(("freq\0" + String(freqInt)).data(using: .utf8)!, for: BlueToothCentral.characteristic, type: BlueToothCentral.writeType)
                }
            }
            
        case self.setUTextFueld:
            if var uDouble = Double(self.setUTextFueld.text!) {
                if uDouble >= 40 {
                    uDouble = 40
                } else if uDouble <= 0 {
                    uDouble = 0
                }
                
                let uInt = Int(uDouble*10)
                
                //接收到的对应的是uset
                if BlueToothCentral.writeType != nil {
                    BlueToothCentral.peripheral.writeValue(("voltage\0" + String(uInt)).data(using: .utf8)!, for: BlueToothCentral.characteristic, type: BlueToothCentral.writeType)
                }
            }
            
        case self.lockTextField:
            if let lockInt = Int(self.lockTextField.text!) {
                if BlueToothCentral.writeType != nil {
                    BlueToothCentral.peripheral.writeValue(("lock\0" + String(lockInt)).data(using: .utf8)!, for: BlueToothCentral.characteristic, type: BlueToothCentral.writeType)
                }
            }
            
        case self.refTextField:
            if var refDouble = Double(self.refTextField.text!) {
                if refDouble >= 40 {
                    refDouble = 40
                } else if refDouble <= 0 {
                    refDouble = 0
                }
                
                let refInt = Int(refDouble*1000)
                
                if BlueToothCentral.writeType != nil {
                    BlueToothCentral.peripheral.writeValue(("ref\0" + String(refInt)).data(using: .utf8)!, for: BlueToothCentral.characteristic, type: BlueToothCentral.writeType)
                }
            }
            
        case self.ctrlTextField:
            if let ctrlInt = Int(self.ctrlTextField.text!) {
                
                if BlueToothCentral.writeType != nil {
                    BlueToothCentral.peripheral.writeValue(("ctrl\0" + String(ctrlInt)).data(using: .utf8)!, for: BlueToothCentral.characteristic, type: BlueToothCentral.writeType)
                }
            }
            
        default:
            break
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    //关于手势的很好的文章https://www.cnblogs.com/6duxz/p/6952896.html
    //https://my.oschina.net/u/2340880/blog/527077
    //点击两下放大或者接收屏幕
    @objc func longPressAct(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard self.showType == .normal else {
            return
        }
        
//        print(gestureRecognizer.view)   //这个点击在button上面，也还是直接指向self.view的
//        if gestureRecognizer.view == editBtn || gestureRecognizer.view == visualEffectView {
//            return
//        }
        
        let longPressLocation = gestureRecognizer.location(in: self.view)
        guard !self.editBtn.frame.contains(longPressLocation) && !self.visualEffectView.frame.contains(longPressLocation) else {
            return
        }
        
        
        showType.biggerToggle()
        self.receiveStr = ""
        
        if (showType == .bigger) {
            AudioServicesPlaySystemSound(1519)
            
            self.receiveBigTextView.center = longPressLocation
            self.receiveBigTextView.layer.cornerRadius = 300
            self.receiveBigTextView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: { [unowned self] in
                self.receiveBigTextView.center = self.view.center
                self.receiveBigTextView.layer.cornerRadius = 0
                self.receiveBigTextView.transform = .identity
                self.receiveBigTextView.alpha = 1
                
                self.tabBarController?.tabBar.alpha = 0
            })
        }
    }
    
    @objc func doubleTapAct(_ gestureRecognizer: UITapGestureRecognizer) {
        showType.biggerToggle()
        self.receiveStr = ""
        
        let tapLocation = gestureRecognizer.location(in: self.view)
        
        if (showType == .normal) {
            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                self.receiveBigTextView.center = tapLocation
                self.receiveBigTextView.layer.cornerRadius = 300
                self.receiveBigTextView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                self.receiveBigTextView.alpha = 0
                
                self.tabBarController?.tabBar.alpha = 1
                
            })
            
        }
    }
    
    @objc func tapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        freqTextField.resignFirstResponder()
        setUTextFueld.resignFirstResponder()
        
        lockTextField.resignFirstResponder()
        refTextField.resignFirstResponder()
        ctrlTextField.resignFirstResponder()
    }
}


//MARK: - Extral Methods
extension ViewController {
    func allBtnisHidden(_ ye: Bool) {
    }
    
    func showErrorAlertWithTitle(_ title: String?, message: String?) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
    }
}


//MARK: - Extral Displays
extension ViewController {
    func blueDisplay() {
        connectBtn.addTarget(self, action: #selector(blueBtnMethod(_:)), for: .touchUpInside)

        connectBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        connectBtn.titleLabel?.textAlignment = .center
        connectBtn.isHidden = false
        connectBtn.setTitle("Not OK", for: .normal)
        connectBtn.setTitle("ScanPer", for: .highlighted)
        connectBtn.setTitleColor(UIColor.white, for: .normal)
        connectBtn.setTitleColor(UIColor.red, for: .highlighted)
        visualEffectView.contentView.addSubview(connectBtn) //必须添加到contentView
        
        disConnectBtn.addTarget(self, action: #selector(blueBtnMethod(_:)), for: .touchUpInside)
        disConnectBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        disConnectBtn.titleLabel?.textAlignment = .center
        disConnectBtn.isHidden = true
        disConnectBtn.setTitle("Conted", for: .normal)
        disConnectBtn.setTitle("Discont", for: .highlighted)
        disConnectBtn.setTitleColor(UIColor.red, for: .normal)
        disConnectBtn.setTitleColor(UIColor.red, for: .highlighted)
        visualEffectView.contentView.addSubview(disConnectBtn) //必须添加到contentView
        
    }
}


extension ViewController {
    //segue回调方法，获取返回参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChoose" {
            let _ = segue.destination as! ChooseCharViewController
        }
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        if segue.identifier == "closeChoose" {
            let _ = segue.source as! ChooseCharViewController
            
            guard BlueToothCentral.peripheral != nil else { return }
        }
        
        
    }

}

extension ViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        var keyCommands = [UIKeyCommand]()
        if BlueToothCentral.peripheral == nil && BlueToothCentral.isBlueOn {
            keyCommands.append(UIKeyCommand(input: "c", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "connect"))
        } else {
            keyCommands.append(UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "disConnect"))
        }
        
        if self.showType != .normal {
            keyCommands.append(UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "shownormal"))
        }
        if self.showType != .bigger {
            keyCommands.append(UIKeyCommand(input: "b", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "showBigger"))
        }
        keyCommands.append(UIKeyCommand(input: "e", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "edit"))
        
        return [UIKeyCommand(input: "c", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "connect"), UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "disConnect"), UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "shownormal"), UIKeyCommand(input: "b", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "showBigger"), UIKeyCommand(input: "e", modifierFlags: .command, action: #selector(shortcuts(sender:)), discoverabilityTitle: "edit"), UIKeyCommand(input: "c", modifierFlags: [.command, .alternate], action: #selector(shortcuts(sender:)), discoverabilityTitle: "clear") ]
    }
    
    @objc func shortcuts(sender: UIKeyCommand) {
        switch sender.input {
        case "c":
            if sender.modifierFlags.contains(.alternate) {
                self.receiveStr = ""
                return
            }
            if BlueToothCentral.peripheral == nil && BlueToothCentral.isBlueOn {
                AudioServicesPlaySystemSound(1519)
                let scanTableController = storyboard?.instantiateViewController(withIdentifier: "ScanTableController") as! ScanTableViewController
                self.navigationController?.pushViewController(scanTableController, animated: true)
                connectBtn.isHidden = true
            }
        case "d":
            if BlueToothCentral.peripheral != nil {
                BlueToothCentral.centralManager.cancelPeripheralConnection(BlueToothCentral.peripheral)
            }

//        case "w":
//            if self.showType != .normal {
//                if self.rtthreadSendTextView.isFirstResponder {
//                    self.rtthreadSendTextView.resignFirstResponder()
//                }
//
//                self.showType.changeShowType(type: .normal)
//                self.receiveStr += ""
//
//                UIView.animate(withDuration: 0.25, animations: { [unowned self] in
//                    self.receiveBigTextView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//                    self.receiveBigTextView.alpha = 0
//
//                    self.rtthreadVisualBackground.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//                    self.rtthreadVisualBackground.alpha = 0
//                })
//
//                UIView.animate(withDuration: 0.45, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: { [unowned self] in
//                    self.receiveTextView.transform = .identity
//                    self.receiveTextView.alpha = 1
//                    self.tabBarController?.tabBar.alpha = 1
//                }) { (_) in
//                }
//            }
//
//        case "b":
//            if self.showType != .bigger {
//                if self.sendTextView.isFirstResponder {
//                    self.sendTextView.resignFirstResponder()
//                }
//                if self.rtthreadSendTextView.isFirstResponder {
//                    self.rtthreadSendTextView.resignFirstResponder()
//                }
//
//                self.showType.changeShowType(type: .bigger)
//                self.receiveStr += ""
//
//                AudioServicesPlaySystemSound(1519)
//                UIView.animate(withDuration: 0.25, animations: { [unowned self] in
//                    self.receiveTextView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//                    self.receiveTextView.alpha = 0
//                    self.tabBarController?.tabBar.alpha = 0
//
//                    self.rtthreadVisualBackground.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//                    self.rtthreadVisualBackground.alpha = 0
//                }) { (_) in
////                    AudioServicesPlaySystemSound(1519)
//                }
//
//                UIView.animate(withDuration: 0.45, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: { [unowned self] in
//                    self.receiveBigTextView.transform = .identity
//                    self.receiveBigTextView.alpha = 1
//                })
//            }
            
        case "e":
            self.performSegue(withIdentifier: "goToChoose", sender: nil)
            
        default:
            break
        }
    }
}

extension ViewController {
    @objc func willShow(notification: NSNotification) {
        var selectedTextField: UITextField = self.ctrlTextField
        for textField in [freqTextField, setUTextFueld, lockTextField, refTextField, ctrlTextField] {
            if textField!.isFirstResponder {
                selectedTextField = textField!
            }
        }
        let textMaxY = selectedTextField.superview!.frame.origin.y + selectedTextField.frame.maxY // 取到输入框的最大的y坐标值
        
        let userinfo: NSDictionary = notification.userInfo! as NSDictionary
        let nsValue:AnyObject? = userinfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as AnyObject?
        let keyboardY = nsValue?.cgRectValue.origin.y  //取到键盘的y坐标
        
        
        let duration = 2.0
        
        UIView.animate(withDuration: duration) { () -> Void in
            if (textMaxY > keyboardY!) {
                self.view.transform = CGAffineTransform(translationX: 0, y: keyboardY! - textMaxY - 20)
            } else {
                self.view.transform = .identity
            }
        }
        
    }
    
    @objc func willHide(notification: NSNotification) {
        UIView.animate(withDuration: 2.0) { () -> Void in
            self.view.transform = .identity
        }
        
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//    }
}



