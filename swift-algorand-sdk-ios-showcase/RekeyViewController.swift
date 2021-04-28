//
//  RekeyViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 4/28/21.
//

import UIKit
import swift_algorand_sdk
class RekeyViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("good")
 

        
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

    @IBAction func rekeyAccount3toAccount1(_ sender: Any) {
        showLoader()
        var info = ""
        infoLabel.text = "rekeying account 3 to 1 : Confirmed Round ..."
        
        var account3Address = Config.account3?.address
        var account1Address = Config.account1?.address
        Config.algodClient!.transactionParams().execute(){ paramResponse in
            if(!(paramResponse.isSuccessful)){
            print(paramResponse.errorDescription);
                self.hideLoader()
                self.infoLabel.text = "rekeying account 3 to 1 error: \(paramResponse.errorMessage)"
            return;
        }
        
        
            var tx = try! Transaction.paymentTransactionBuilder().setSender(account3Address!)
                .receiver(account3Address!)
            .amount(0)
            .note("Swift Algo rekey transaction".bytes)
            .suggestedParams(params: paramResponse.data!)
            .rekey(rekeyTo: account1Address!)
            .build()
        
        
            var signedTransaction = Config.account3!.signTransaction(tx: tx)
        
            var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
        
          
        
            Config.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
               response in
                if(response.isSuccessful){
                    print(response.data!.txId)
                    UIPasteboard.general.string="\(response.data!.txId)"
                    self.waitForTransaction(algodClient: Config.algodClient!, txId: response.data!.txId){ confirmedRound in
                        self.hideLoader()
                        print("Confirmed Round : \(confirmedRound)")
                      
                        if let confRound = confirmedRound{
                            self.infoLabel.text = "rekeying account 3 to 1 : Confirmed Round \(confRound)"
                        }
                      
                    }
                }else{
                    self.hideLoader()
                    print(response.errorDescription)
                    self.infoLabel.text = "rekeying account 3 to 1 error: \(response.errorMessage)"
                    print("Failed")
                }
        
            }
        }
    }
    
    @IBAction func makeTransactionWithRekeyedAccount(_ sender: Any) {
        
        infoLabel.text = "Making transaction with rekeyed account : Confirmed Round ..."
        
        showLoader()
        var account3Address = Config.account3?.address
        var account1Address = Config.account1?.address
        Config.algodClient!.transactionParams().execute(){ paramResponse in
            if(!(paramResponse.isSuccessful)){
            print(paramResponse.errorDescription);
                self.hideLoader()
                self.infoLabel.text = "Making transaction with rekeyed accounterror: \(paramResponse.errorMessage)"
            return;
        }
        
        
            var tx = try! Transaction.paymentTransactionBuilder().setSender(account3Address!)
                .receiver(account1Address!)
            .amount(1000000)
            .note("Swift Algo send transaction after rekey".bytes)
            .suggestedParams(params: paramResponse.data!)
            .build()
        
        
            var signedTransaction = Config.account1!.signTransaction(tx: tx)
        
            var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
        
        
            Config.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
               response in
                if(response.isSuccessful){
                    print(response.data!.txId)
                    UIPasteboard.general.string="\(response.data!.txId)"
                    self.waitForTransaction(algodClient: Config.algodClient!, txId: response.data!.txId){ confirmedRound in
                        print("Confirmed Round : \(confirmedRound)")
                        if let confRound = confirmedRound{
                            self.infoLabel.text = "Making transaction with rekeyed account : Confirmed Round \(confRound)"
                        }
                    
                        self.hideLoader()
                    }
                }else{
                    self.hideLoader()
                    print(response.errorDescription)
                    self.infoLabel.text = "Making transaction with rekeyed accounterror: \(response.errorMessage)"
                    print("Failed")
                }
        
            }
        }
        
    }
    
    @IBAction func resetAccounts(_ sender: Any) {
        
        infoLabel.text = "Resetting rekeyed account : Confirmed Round ..."
        
        
        showLoader()
        var account3Address = Config.account3?.address
        var account1Address = Config.account1?.address
      
        print(account3Address?.description)
        Config.algodClient!.transactionParams().execute(){ paramResponse in
            if(!(paramResponse.isSuccessful)){
            print(paramResponse.errorDescription);
                self.infoLabel.text = "Resetting rekeyed account error : \(paramResponse.errorMessage)"
                self.hideLoader()
            return;
        }
        
        
            var tx = try! Transaction.paymentTransactionBuilder().setSender(account3Address!)
                .receiver(account3Address!)
                .amount(0)
                .note("Swift Algo reset rekey transaction".bytes)
                .suggestedParams(params: paramResponse.data!)
                .rekey(rekeyTo: account3Address!)
                .build()
        
        
            var signedTransaction = Config.account1!.signTransaction(tx: tx)
        
            var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
        
        
            Config.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
               response in
                if(response.isSuccessful){
                    print(response.data!.txId)
                    UIPasteboard.general.string="\(response.data!.txId)"
                    self.waitForTransaction(algodClient: Config.algodClient!, txId: response.data!.txId){ confirmedRound in
                        print("Confirmed Round : \(confirmedRound)")
                        if let confRound = confirmedRound{
                            self.infoLabel.text = "Resetting rekeyed account : Confirmed Round: \(confRound)"
                        }
                        self.hideLoader()
                    }
                }else{
                    print(response.errorDescription)
                    print("Failed")
                    self.infoLabel.text = "Resetting rekeyed account error : \(response.errorMessage)"
                    self.hideLoader()
                }
        
            }
        }
    }
    
    func waitForTransaction(algodClient:AlgodClient, txId:String, funcToCall: @escaping (Int64?)->Void) {
        
        var confirmedRound: Int64?=0
        var assetIndex:Int64?=0
        algodClient.pendingTransactionInformation(txId:txId).execute(){
            pendingTransactionResponse in
                if(pendingTransactionResponse.isSuccessful){
                    confirmedRound=pendingTransactionResponse.data!.confirmedRound
                    
                    if(confirmedRound != nil && confirmedRound! > 0){
                       funcToCall(confirmedRound)
                    }else{
                        try!  self.waitForTransaction(algodClient:algodClient, txId: txId,funcToCall: funcToCall)
                    }
                }else{
                    print(pendingTransactionResponse.errorDescription!)
                    funcToCall(nil)
                    confirmedRound=12000;
                }
    }
}
    
    public func showLoader(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    public func hideLoader(){
        self.dismiss(animated: false, completion: nil)
    }
}
