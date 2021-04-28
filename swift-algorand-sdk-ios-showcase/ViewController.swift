//
//  ViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/4/21.
//

import UIKit
import swift_algorand_sdk
import  LTHRadioButton
class ViewController: UIViewController {

    @IBOutlet weak var networkLabel: UITextField!
    @IBOutlet weak var nodeAndNetworkImage: UIImageView!
    override func viewDidLoad() {
//        var something:LTHRadioButton
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
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
    
    @IBAction func moveToNodeAndNetworkSettings(_ sender: Any) {
        performSegue(withIdentifier: "moveToNodeAndNetworkSettings", sender: nil)
    }
//    func movetToNodeAndNetworksScreen(){
//
//    }
    public func testPaymentTrans(){
   
        var PURESTAKE_API_KEY="ADRySlL0NK5trzqZGAE3q1xxIqlQdSfk1nbHxTNe";
        var PURESTAKE_API_PORT="443";
        var PURESTAKE_ALGOD_API_TESTNET_ADDRESS="https://testnet-algorand.api.purestake.io/ps2";
        var algodClient=AlgodClient(host: PURESTAKE_ALGOD_API_TESTNET_ADDRESS, port: PURESTAKE_API_PORT, token: PURESTAKE_API_KEY)
        algodClient.set(key: "X-API-KEY")
        var sender = try! Account("skill state margin token trip clerk view task velvet aspect amused rose glance educate zebra tunnel island odor ranch polar interest ethics lecture ability network")
        print(sender.address.description)
        print(sender.toMnemonic())
        
        var receiver = try! Account("title frame buddy stumble orbit buddy gossip finger fabric refuse toward surface shop unique coffee theory decline canal amateur hole lonely nice fault above dragon")
        print(receiver.address.description)
        print(receiver.toMnemonic())
        
        algodClient.transactionParams().execute(){ paramResponse in
            if(!(paramResponse.isSuccessful)){
            print(paramResponse.errorDescription);
            return;
        }
        
            let tx = try! Transaction.paymentTransactionBuilder().setSender(sender.getAddress())
            .amount(1)
                .receiver(receiver.address)
            .note("Swift Algo sdk is cool".bytes)
            .suggestedParams(params: paramResponse.data!)
            .build()
            
            
           let signedTransaction=sender.signTransaction(tx: tx)
           
           let encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                                response in
                                if(response.isSuccessful){
                                    print(response.data!.txId)
                                    print("Sucesso")
            //
//                                    transactionIsShowing = true
            //
                                }else{
                                    print(response.errorDescription!)
                                    print("Failed")
                                }
                                
                            }
        
    }
      
    }
        
    
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
    @IBAction func moveToRekeyController(_ sender: Any) {
        performSegue(withIdentifier: "moveToRekeyScreen", sender: nil)
    }
}

