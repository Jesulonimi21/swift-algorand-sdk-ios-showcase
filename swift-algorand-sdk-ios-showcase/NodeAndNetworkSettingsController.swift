//
//  NodeAndNetworkSettingsController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/11/21.
//

import UIKit
import  swift_algorand_sdk
import DLRadioButton
class NodeAndNetworkSettingsController:
    UIViewController {

    @IBOutlet weak var netSelector: UISegmentedControl!
    
    
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

    @IBAction func netSelectionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0 :connectToTestnet()
        case 1 :connectToBetanet()
        default:print("None of the above")

    }
    }
    
    func connectToTestnet(){
        Config.currentNet=Config.TESTNET
    }
    func connectToBetanet(){
        Config.currentNet=Config.BETANET
    }
    
    
    @IBAction func selectPurestakeNode(_ sender: DLRadioButton) {
        Config.currentNode="Purestake"
        if(Config.currentNet==Config.TESTNET){
            var algodClient:AlgodClient=AlgodClient(host: Config.PURESTAKE_ALGOD_API_TESTNET_ADDRESS, port: Config.PURESTAKE_API_PORT, token: Config.PURESTAKE_API_KEY)
            algodClient.set(key: "X-API-Key")
            Config.algodClient=algodClient
        }else{
            var algodClient:AlgodClient=AlgodClient(host: Config.PURESTAKE_ALGOD_API_BETANET_ADDRESS, port: Config.PURESTAKE_API_PORT, token: Config.PURESTAKE_API_KEY)
            algodClient.set(key: "X-API-Key")
            Config.algodClient=algodClient
        }
  
    }
    
    @IBAction func selectHackathonNode(_ sender: DLRadioButton) {
        Config.currentNode="Hackathon"
        var algodClient:AlgodClient=AlgodClient(host: Config.HACKATHON_API_ADDRESS  , port: Config.HACKATHON_API_PORT, token: Config.HACKATHON_API_TOKEN)
            Config.algodClient=algodClient
       
    }
    
    @IBAction func selectCustomNode(_ sender: DLRadioButton) {
        Config.currentNode="CustomNode"
        Config.currentNet="Unknown"
        var algodClient:AlgodClient=AlgodClient(host:"http://localhost",port:"4001",token:"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        Config.algodClient=algodClient
    }
    
    
    
}
