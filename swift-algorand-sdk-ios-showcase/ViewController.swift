//
//  ViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/4/21.
//

import UIKit
//import swift_algorand_sdk
import  LTHRadioButton
class ViewController: UIViewController {

    @IBOutlet weak var networkLabel: UITextField!
    @IBOutlet weak var nodeAndNetworkImage: UIImageView!
    override func viewDidLoad() {
//        var something:LTHRadioButton
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     
        
    }
    
    @IBAction func moveToNodeAndNetworkSettings(_ sender: Any) {
        performSegue(withIdentifier: "moveToNodeAndNetworkSettings", sender: nil)
    }
//    func movetToNodeAndNetworksScreen(){
//
//    }

    
    override func viewWillAppear(_ animated: Bool) {
        networkLabel.text="Network: \(Config.currentNet)"
    }
    @IBAction func moveToAccountsAndTransactionsPage(_ sender: Any) {
        performSegue(withIdentifier: "moveToAccountsAndTransactions",sender: nil)
    }
    
    @IBAction func moveToAlgorandStandardAssetsPage(_ sender: Any) {
        performSegue(withIdentifier: "moveToAlgorandAssetController",sender: nil)
    }
    
    @IBAction func moveToAtomicTransferScreen(_ sender: Any) {
        performSegue(withIdentifier: "moveToAtomicTransferScreen", sender: nil)
        
    }
    @IBAction func moveToSmartContractController(_ sender: Any) {
        performSegue(withIdentifier: "moveToSmartContractController", sender: nil)
    }
}

