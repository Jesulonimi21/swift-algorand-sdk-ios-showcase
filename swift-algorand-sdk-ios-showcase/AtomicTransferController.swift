//
//  AtomicTransferController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/19/21.
//

import UIKit
import swift_algorand_sdk
class AtomicTransferController: UIViewController {

    @IBOutlet weak var account1BalanceBeforeTransaction: UILabel!
    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var account1BalanceAfterTransaction: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAccountBalance(address: Config.account1!.address.description){amount in
            self.account1BalanceBeforeTransaction.text="Account1 Balance Before Transaction: \(amount)"
   
        }

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

    @IBAction func transferFromAccount1to2And3(_ sender: Any) {
        showLoader()
        createtransactions(sender: Config.account1!, receiver1: Config.account2!.address, receiver2: Config.account3!.address,algodClient: Config.algodClient!){ txId in
           
            self.transactionId.text=txId
            UIPasteboard.general.string=txId
            self.waitForTransaction(algodClient: Config.algodClient!, txId: txId){confirmedRound in
                self.hideLoader()
                self.getAccountBalance(address: Config.account1!.address.description){amount in
                    self.account1BalanceAfterTransaction.text="Account1 Balance After Transaction: \(amount)"
                }
            }
            
         
            
        }
    }
    
    func getAccountBalance(address:String, functionToCall: @escaping (String)->Void){
//        self.showLoader()
        Config.algodClient!.accountInformation(address: address).execute(){accountInformationResponse in
//            self.hideLoader()
        
            if(accountInformationResponse.isSuccessful){
                print("\(accountInformationResponse.data!.amount!)")
                functionToCall("\(accountInformationResponse.data!.amount!)")
                  }else{
                    functionToCall("\(accountInformationResponse.errorDescription)")
                     
                  }
        }
    
    }
    
    public func makeAtomicTransfer(signedTransactions:[SignedTransaction?],algodClient:AlgodClient,functionToCall: @escaping (String)->Void){
        var encodedTrans:[Int8]=Array()
        for i in 0..<signedTransactions.count{
            encodedTrans = encodedTrans+CustomEncoder.encodeToMsgPack(signedTransactions[i])
        }
              
    
                algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                   response in
                    if(response.isSuccessful){
                        functionToCall(response.data!.txId)
                    }else{
                        functionToCall(response.errorDescription!)
                    }
    
                }
        
    
    }
    
    func createtransactions(sender:Account,receiver1:Address,receiver2:Address,algodClient:AlgodClient,functionToCall: @escaping (String)->Void){
        algodClient.transactionParams().execute(){ paramResponse in
           if(!(paramResponse.isSuccessful)){
           print(paramResponse.errorDescription);
           return;
       }
            var tx1 = Transaction.paymentTransactionBuilder().setSender(sender.address)
             .amount(10000000)
             .receiver(receiver1)
             .note("Swift Algo sdk is cool".bytes)
             .suggestedParams(params: paramResponse.data!)
             .build()
 
            var tx2 = Transaction.paymentTransactionBuilder().setSender(sender.getAddress())
              .amount(11000000)
              .receiver(receiver2)
              .note("Swift Algo sdk is cool".bytes)
              .suggestedParams(params: paramResponse.data!)
              .build()
            var transactions=[tx1,tx2]
            var gid = try! TxGroup.computeGroupID(txns: transactions)
            var signedTransactions:[SignedTransaction?]=Array(repeating: nil, count: transactions.count)
            for i in 0..<transactions.count{
                transactions[i].assignGroupID(gid: gid)
                signedTransactions[i]=sender.signTransaction(tx: transactions[i])
            }
            self.makeAtomicTransfer(signedTransactions: signedTransactions, algodClient: algodClient,functionToCall: functionToCall)
            
        }
    }
    
    func waitForTransaction(algodClient:AlgodClient,txId:String, funcToCall: @escaping (Int64?)->Void) {
   
        var confirmedRound: Int64?=0
        var assetIndex:Int64?=0
        algodClient.pendingTransactionInformation(txId:txId).execute(){
            pendingTransactionResponse in
                if(pendingTransactionResponse.isSuccessful){
                    confirmedRound=pendingTransactionResponse.data!.confirmedRound
                  
                    if(confirmedRound != nil && confirmedRound! > 0){
                        
                       funcToCall(confirmedRound)
                    }else{
                        try!  self.waitForTransaction(algodClient:algodClient,txId: txId,funcToCall: funcToCall)
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
