//
//  AlgorandAssetsController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/17/21.
//

import UIKit
import swift_algorand_sdk
class AlgorandAssetsController: UIViewController {

  
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var assetIDLabel: UIButton!
    @IBOutlet weak var networkLabel: UILabel!
    var assetIndex:Int64?=nil
    var algodClient=Config.algodClient
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func createAssetClicked(_ sender: Any) {
        showLoader()
        createASA(algodClient: Config.algodClient!, creator: Config.account2!, assetTotal: 10000, assetDecimals: 0, assetUnitName: "kilsjssj", assetName: "ccdoddodod", url: "https://jiji.com", manager:Config.account2!.address , reserve: Config.account2!.address, freeze: Config.account2!.address, clawback: Config.account2!.address, defaultFrozen: false){assetIndex in
            self.hideLoader()
            self.assetIDLabel.setTitle("\(assetIndex!)", for: .normal)
            self.assetIndex=assetIndex
        }
    }
    
    @IBAction func configureManagerRoleClicked(_ sender: Any) {
        if let assetIndex=self.assetIndex{
            showLoader()
            changeAsaManager(algodClient: Config.algodClient!, previousManager:  Config.account2!, assetIndex: assetIndex, manager:  Config.account1!.address, reserve: Config.account2!.address, freeze: Config.account2!.address, clawback: Config.account2!.address){ txId in
                self.hideLoader()
                print(txId)
                self.infoLabel.text=txId
                UIPasteboard.general.string=txId
                
            }
        }
    
    }
    
    @IBAction func optIntoAccount3Clicked(_ sender: Any) {
        if let assetIndex=self.assetIndex{
            showLoader()
            optInToAsa(algodClient: Config.algodClient!, acceptingAccount: Config.account3!, assetIndex: assetIndex){ txId in
                self.hideLoader()
                self.infoLabel.text=txId
                UIPasteboard.general.string=txId
                
            }
        }
      
    }
    
    
    @IBAction func transferFromAccount1to3(_ sender: Any) {
        if let assetIndex=self.assetIndex{
            showLoader()
            transferAsa(algodClient: Config.algodClient!, sender: Config.account2!, receiver: Config.account2!.address, amount: 1, assetIndex: assetIndex){txId in
                self.hideLoader()
                self.infoLabel.text=txId
                UIPasteboard.general.string=txId
            }
        }
        
       
    }
    
    
    @IBAction func freezeAccount3(_ sender: Any) {
        if let assetIndex=assetIndex{
            showLoader()
            freezeASA(algodClient: algodClient!, freezeTarget: Config.account3!.address, manager: Config.account2!,assetIndex: assetIndex,freezeState: true){ txId in
                self.hideLoader()
                self.infoLabel.text=txId
                UIPasteboard.general.string=txId
            }
        }
     
    }
    
    
    @IBAction func revokeAccount3Clicked(_ sender: Any) {
        if let assetIndex=assetIndex{
            showLoader()
            revokeAsa(algodClient: Config.algodClient!, manager: Config.account2!, clawBackFromAddress: Config.account3!.address, clawBackToAddress: Config.account2!.address, assetAmount: 10, assetIndex: assetIndex){txId in
                self.hideLoader()
                self.infoLabel.text=txId
                UIPasteboard.general.string=txId
                
            }
        }
       
    }
    
    
    @IBAction func destroyAccount1Clicked(_ sender: Any) {
        if let assetIndex=assetIndex{
            showLoader()
            destroyAsa(algodClient: Config.algodClient!, creator: Config.account1!, assetIndex: assetIndex){txId in
                self.hideLoader()
                self.infoLabel.text=txId
                UIPasteboard.general.string=txId
                
        }
        }
      
    }
    
  
    func createASA( algodClient:AlgodClient,creator:Account,assetTotal:Int64,assetDecimals:Int64,assetUnitName:String,assetName:String,url:String,manager:Address,reserve:Address,freeze:Address,clawback:Address,defaultFrozen:Bool,functionToCall:@escaping (Int64?)->Void){
        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }
     var tx = Transaction.assetCreateTransactionBuilder()
        .setSender(creator.getAddress())
                          .setAssetTotal(assetTotal: assetTotal)
                          .setAssetDecimals(assetDecimals:  assetDecimals)
                          .assetUnitName(assetUnitName: assetUnitName)
                          .assetName(assetName:  assetName)
                            .url(url: url)
                            .manager(manager: manager)
                            .reserve(reserve: reserve)
                            .freeze(freeze: freeze)
                          .defaultFrozen(defaultFrozen:  defaultFrozen)
                .clawback(clawback: clawback)
        .suggestedParams(params: paramResponse.data!).build()
         
            var signedTransaction=creator.signTransaction(tx: tx)
            var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
            var dataToSend=Data(CustomEncoder.convertToUInt8Array(input: encodedTrans))
       
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
               response in
                if(response.isSuccessful){
                    print(response.data!.txId)
                    self.infoLabel.text=response.data!.txId
                    self.waitForTransaction(txId:response.data!.txId,funcToCall: functionToCall)
                  
                }else{
                    print(response.errorDescription)
                    self.infoLabel.text=response.errorDescription
                }
            }

        }

    }
    
    
    
    
    
    func waitForTransaction(txId:String, funcToCall: @escaping (Int64?)->Void) {
        var confirmedRound: Int64?=0
        var assetIndex:Int64?=0
        algodClient!.pendingTransactionInformation(txId:txId).execute(){
            pendingTransactionResponse in
                if(pendingTransactionResponse.isSuccessful){
                    confirmedRound=pendingTransactionResponse.data!.confirmedRound
                    assetIndex=pendingTransactionResponse.data!.assetIndex
                    if(confirmedRound != nil && confirmedRound! > 0){
                       funcToCall(assetIndex)
                    }else{
                        try!  self.waitForTransaction(txId: txId,funcToCall: funcToCall)
                    }
                }else{
                    print(pendingTransactionResponse.errorDescription!)
                    funcToCall(nil)
                    confirmedRound=12000;
                }
    }
}
    
    func  changeAsaManager(algodClient:AlgodClient,previousManager:Account,assetIndex:Int64,manager:Address,reserve:Address,freeze:Address,clawback:Address,functionToCall:@escaping (String?)->Void){
        
        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }
            var tx = Transaction.assetConfigureTransactionBuilder().reserve(reserve: previousManager.address).freeze(freeze: previousManager.address).clawback(clawback: previousManager.address).assetIndex(assetIndex: assetIndex).setSender(previousManager.getAddress())
            .manager(manager: manager)
                .suggestedParams(params: paramResponse.data!)
                      .build();
       
       
            var signedTransaction=previousManager.signTransaction(tx: tx)
          
            var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
            var dataToSend=Data(CustomEncoder.convertToUInt8Array(input: encodedTrans))
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
               response in
                if(response.isSuccessful){
                    functionToCall(response.data!.txId)
                    
                }else{
                    functionToCall(response.errorDescription)
                }
    
            }
    
        }
    
    }
    
    func optInToAsa(algodClient:AlgodClient,acceptingAccount:Account,assetIndex:Int64,functionToCall:@escaping (String)->Void){
    
        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }
            var tx = Transaction.assetAcceptTransactionBuilder()
                .acceptingAccount(acceptingAccount: acceptingAccount.getAddress())
                .assetIndex(assetIndex: assetIndex)
                .suggestedParams(params: paramResponse.data!)
                .build();
    
            var txMessagePack:[Int8]=CustomEncoder.encodeToMsgPack(tx)
            var signedTrans=acceptingAccount.signTransaction(tx: tx)
            var encodedTx:[Int8]=CustomEncoder.encodeToMsgPack(signedTrans)
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTx).execute(){
               response in
                if(response.isSuccessful){
                    functionToCall(response.data!.txId)
                }else{
                    functionToCall(response.errorDescription!)
                }
    
            }}
    
    }
    
    func transferAsa(algodClient:AlgodClient,sender:Account,receiver:Address,amount:Int64,assetIndex:Int64, functionToCall:@escaping (String)->Void){

        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }

            var tx = Transaction.assetTransferTransactionBuilder().setSender(sender.getAddress()).assetReceiver(assetReceiver:receiver)
                .assetAmount(assetAmount:amount).assetIndex(assetIndex:assetIndex).suggestedParams(params:paramResponse.data!).build();

            var signedTrans=sender.signTransaction(tx: tx)
            
            var encodedTx:[Int8]=CustomEncoder.encodeToMsgPack(signedTrans)
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTx).execute(){
               response in
                if(response.isSuccessful){
                    functionToCall(response.data!.txId)
                }else{
                    functionToCall(response.errorDescription!)
                }

            }
        }

    }
    
    func freezeASA(algodClient:AlgodClient,freezeTarget:Address,manager:Account,assetIndex:Int64,freezeState:Bool, functionToCall:@escaping (String)->Void){
    
        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }
    
            var tx=Transaction.assetFreezeTransactionBuilder().setSender(manager.getAddress()).freezeTarget(freezeTarget:freezeTarget)
                .freezeState(freezeState:freezeState).assetIndex(assetIndex: assetIndex).suggestedParams(params: paramResponse.data!).build();
            var signedTrans=manager.signTransaction(tx: tx)
            var encodedTx:[Int8]=CustomEncoder.encodeToMsgPack(signedTrans)
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTx).execute(){
               response in
                if(response.isSuccessful){
                    functionToCall(response.data!.txId)
                }else{
                    functionToCall(response.errorDescription!)
                }
    
            }
        }
    }
    
    func revokeAsa(algodClient:AlgodClient,manager:Account,clawBackFromAddress:Address,clawBackToAddress:Address,assetAmount:Int64,assetIndex:Int64, functionToCall:@escaping (String)->Void){
        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }

            var tx = Transaction.assetClawbackTransactionBuilder().setSender(manager.getAddress())
                .assetClawbackFrom(assetClawbackFrom:clawBackFromAddress).assetReceiver(assetReceiver: clawBackToAddress).assetAmount(assetAmount: assetAmount)
                .assetIndex(assetIndex:assetIndex).suggestedParams(params: paramResponse.data!).build()
            var signedTrans=manager.signTransaction(tx: tx)
            var encodedTx:[Int8]=CustomEncoder.encodeToMsgPack(signedTrans)
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTx).execute(){
               response in
                if(response.isSuccessful){
                    functionToCall(response.data!.txId)
                }else{
                    functionToCall(response.errorDescription!)
                }

            }
        }
    }
    func destroyAsa(algodClient:AlgodClient,creator:Account,assetIndex:Int64,functionToCall:@escaping (String)->Void){
        algodClient.transactionParams().execute(){paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                return;
            }
            var tx = Transaction.assetDestroyTransactionBuilder()
                .setSender(creator.getAddress())
                .assetIndex(assetIndex: assetIndex)
                .suggestedParams(params: paramResponse.data!)
                          .build();

            var signedTrans=creator.signTransaction(tx: tx)
            var encodedTx:[Int8]=CustomEncoder.encodeToMsgPack(signedTrans)
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTx).execute(){
               response in
                if(response.isSuccessful){
                    functionToCall(response.data!.txId)
                }else{
                    functionToCall(response.errorDescription!)
                }

            }}

    }
    override func viewWillAppear(_ animated: Bool) {
        networkLabel.text="Network: \(Config.currentNet)"
    }
    
    public func showLoader(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
    }
    
    public func hideLoader(){
        dismiss(animated: false, completion: nil)
    }
    
}

