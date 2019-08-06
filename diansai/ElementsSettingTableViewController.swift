//
//  ElementsSettingTableViewController.swift
//  diansai
//
//  Created by JiaCheng on 2019/8/2.
//  Copyright © 2019 JiaCheng. All rights reserved.
//

import UIKit
import AudioToolbox

class ElementsSettingTableViewController: UITableViewController {
    var elements = [Element]()
    static var editNumber = -1
    static var destinationName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Setting"
        
        let rightBarItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addElement))
        navigationItem.rightBarButtonItem = rightBarItem

        let user = UserDefaults.standard
            
        if let propertylistmenbers = user.array(forKey: "elements") as? [[String:String]] {
            for menber in propertylistmenbers {
                elements.append(Element(sysType: SysType(rawValue: menber["sysType"]!), property: Charactistic(rawValue: menber["property"]!), displayName: menber["displayName"], sendPrefix: menber["sendPrefix"], receivePrefix: menber["receivePrefix"]))
            }
            
            print("already saved")
            return
        }
    }
    
    @objc func addElement() {
        ElementsSettingTableViewController.destinationName = "AddNew"
        ElementsSettingTableViewController.editNumber = -1
        
        self.performSegue(withIdentifier: "elementDetail", sender: nil)
        
        AudioServicesPlaySystemSound(1519)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "elementCell", for: indexPath) as! ElementDetailTableViewCell

        // Configure the cell...
        cell.receiveLabel?.text = elements[indexPath.row].receivePrefix
        cell.displayLabel?.text = elements[indexPath.row].displayName
        cell.myImageView?.image = UIImage(named: "element\(arc4random_uniform(5))")
        cell.number = indexPath.row

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ElementsSettingTableViewController {
    //segue回调方法，获取返回参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "elementDetail" {
//            let destination = segue.destination as! EditandAddUIViewController
//            destination.name = ElementsSettingTableViewController.destinationName
//            destination.number = ElementsSettingTableViewController.editNumber
        }
    }

}
