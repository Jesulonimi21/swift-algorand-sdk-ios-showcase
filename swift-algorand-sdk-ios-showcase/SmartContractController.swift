//
//  SmartContractController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/20/21.
//

import UIKit
import swift_algorand_sdk
class SmartContractController: UIViewController {
    
    @IBOutlet weak var infoLabel: UITextView!
    var split:ContractTemplate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
  
    


    @IBAction func generateSplitContractAddress(_ sender: Any) {
        var owner =  Config.account1!.getAddress()
        var receiver1 =  Config.account2!.getAddress()
        var receiver2 =  Config.account3!.getAddress()
                   // Addition Inputs to the Template
            var expiryRound = 5000000;
            var maxFee = 2000;
            var minPay = 3000;
            var ratn = 3;
            var ratd = 7;
           
    
        
             split=try! Split.MakeSplit(owner: owner, receiver1: receiver1, receiver2: receiver2, rat1: ratn, rat2: ratd, expiryRound: expiryRound, minPay: minPay, maxFee: maxFee)
        print(split!.address.description)
        infoLabel.text="Contract Address: \(split!.address.description)"
    }
   
    @IBAction func fundSplitContactAddress(_ sender: Any) {
      if  let split=self.split{
            UIPasteboard.general.string=split.address.description
            var urlString=""
            if(Config.currentNet==Config.TESTNET){
               urlString="https://bank.testnet.algorand.network/"
            }else if(Config.currentNet==Config.BETANET){
                urlString="https://bank.betanet.algodev.network/"
            }
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func runSplitProgram(_ sender: Any) {
        if let algodClient=Config.algodClient{
            try!  runSplitProgram(algodClient: Config.algodClient!)
        }
   
    }
    
    
    
    func runSplitProgram(algodClient:AlgodClient) throws{
        showLoader()
        if let split=self.split{
        var contractProgram=split.program
    
            algodClient.transactionParams().execute(){ paramResponse in
                if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                    self.hideLoader()
                return;
                }
                var loadedContract =  ContractTemplate(prog: contractProgram);
                      var transactions = try! Split.GetSplitTransactions(
                        contract: loadedContract,
                        amount: 50000,
                        firstValid:paramResponse.data!.lastRound!,
                        lastValid: paramResponse.data!.lastRound!+500,
                        feePerByte: 1,
                        genesisHash: Digest(paramResponse.data!.genesisHash));
                algodClient.rawTransaction().rawtxn(rawtaxn: transactions).execute(){
                   response in
                    if(response.isSuccessful){
                        print(response.data!.txId)
                        self.infoLabel.text="Transaction Id: \(response.data!.txId)"
                        UIPasteboard.general.string=response.data!.txId
                        self.waitForTransaction(algodClient: algodClient, txId: response.data!.txId){confirmedRound in
                            self.infoLabel.text="Transaction Id: \(response.data!.txId) \nConfirmed Round: \(confirmedRound!)  "
                            self.hideLoader()
                        }
                    }else{
                        print(response.errorDescription)
                        self.infoLabel.text=response.errorDescription!
                        self.hideLoader()
                        
                    }
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
