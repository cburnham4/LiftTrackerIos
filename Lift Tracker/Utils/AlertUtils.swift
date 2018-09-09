//
//  AlertUtils.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/9/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//
import UIKit

class AlertUtils {
    static func createAlert(view: UIViewController, title: String, message: String, completion: @escaping (UIAlertAction) -> () = {_ in }){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: completion))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func createAlertCallback(view: UIViewController, title: String, message: String, callback: @escaping (UIAlertAction) -> ()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: callback))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    static func createAlertTextCallback(view: UIViewController, title: String, message: String = "", placeholder: String, callback: @escaping (String) -> ()){
        //. Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: {(UIAlertAction) -> () in
            callback((alert.textFields?[0].text)!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        view.present(alert, animated: true, completion: nil)
    }
}
