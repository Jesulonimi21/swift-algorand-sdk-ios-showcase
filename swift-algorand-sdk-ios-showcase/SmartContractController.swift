//
//  SmartContractController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/20/21.
//

import UIKit

class SmartContractController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    var program:[Int8]=[0x01, 0x20, 0x01, 0x00, 0x22]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func contractAccountAction(_ sender: Any) {
        
    }
    @IBAction func accountDelegateAction(_ sender: Any) {
    }
}
