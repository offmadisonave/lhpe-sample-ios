//
//  ProfileDetailController.swift
//  lhpe-sample
//
//  Created by Erik Madsen on 5/17/18.
//  Copyright © 2018 Erik Madsen. All rights reserved.
//

import UIKit
import LighthouseKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var lNameText: UITextField!
    @IBOutlet weak var fNameText: UITextField!
    @IBOutlet weak var idText: UITextField!
    
    @IBAction func save(_ sender: Any) {
        
        if(idText.text! == "" || fNameText.text! == "" || lNameText.text! == ""){
            let alert: UIAlertController = UIAlertController(title: "Uh-oh!", message: "All fields are required", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        if let lhUser : LHUser = LHUser.initWithExternalId(idText.text) {
            // Profile data is JSON
            let dict: [String: Any?] = [
                "foreign_id": idText.text,
                "firstName": fNameText.text,
                "lastName": lNameText.text,
                "ABoolean": true,
                "ANumber": 3.14159265359,
                "ADate": Date().description
            ]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                lhUser.profile = jsonData
                lhUser.saveInBackground({ (success, error) -> Void in
                    print("-Saved lighthouse user")
                })
            } catch {
                print(error.localizedDescription)
                return
            }
            
        }
        
    }
    
}
