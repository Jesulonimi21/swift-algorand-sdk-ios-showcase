//
//  StatefulContractsViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 5/15/21.
//

import UIKit
import swift_algorand_sdk
class StatefulContractsViewController: UIViewController {
    @IBOutlet weak var infoTextView: UITextView!
    var appId:Int64?=15871086
    var algodClient:AlgodClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView.isEditable = false
        
        algodClient = Config.algodClient
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
    
    public func tealCompile(resource:String,funcToCall:@escaping(String)->Void){
        var algodClient = Config.algodClient!;
        var source:[Int8] = loadTeal(resource: resource)
        algodClient.tealCompile().source(source: source).execute(){compileResponse in
            if(compileResponse.isSuccessful){
                print(compileResponse.data?.result)
                funcToCall(compileResponse.data!.result!)
            }else{
                self.hideLoader();
                print(compileResponse.errorMessage!)
                self.infoTextView.text=compileResponse.errorDescription!
            }
    
        }
   
    }
    
    public  func loadTeal(resource:String)  -> [Int8] {
        let configURL = Bundle.main.path(forResource: resource, ofType: "txt")
        let contensts = try! String(contentsOfFile: configURL!.description)
        let jsonData = contensts.data(using: .utf8)!

        var  data = CustomEncoder.convertToInt8Array(input: Array(jsonData))
        print(data)
        return data
       }

    @IBAction func createAppClicked(_ sender: Any) {
        showLoader();
        createApplication();
        
    }
    @IBAction func optInClicked(_ sender: Any) {
        showLoader()
        applicationOptIn();
    }
    @IBAction func callAppClicked(_ sender: Any) {
        showLoader()
        applicationCallTransaction();
    }
    @IBAction func readLocalStateAction(_ sender: Any) {
    }
    @IBAction func readGlobalStateAction(_ sender: Any) {
    }
    
    
    @IBAction func updateAppClicked(_ sender: Any) {
        showLoader()
        updateApplication()
    }
    
    @IBAction func closeOutAppCLICKED(_ sender: Any) {
        showLoader();
        closeApplication();
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
    
    public func createApplication(){
        var algodClient = Config.algodClient!;
        
        var account1 = Config.account2!
        var address = account1.getAddress()
        var address2 = account1.getAddress()
        
    
        var localInts:Int64 = 1;
        var localBytes:Int64 = 1;
        var globalInts:Int64 = 1;
        var globalBytes:Int64 = 0;
    
        var approvalProgram:TEALProgram?
        var clearStateProgram:TEALProgram?
        tealCompile(resource: "stateful_clear.teal"){ clearProgResult in
            clearStateProgram = try? TEALProgram(base64String: clearProgResult);
            print(clearStateProgram)
            print("ClearProg result: \(clearProgResult)")
            
            self.tealCompile(resource: "stateful_approval_init.teal"){ approvalProgResult in
                print("Approval Prog result: \(approvalProgResult)")
                approvalProgram = try? TEALProgram(base64String:approvalProgResult)
                print(approvalProgram)
                algodClient.transactionParams().execute(){ paramResponse in
                    if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription);
                    return;
                }
    
                    var tx = try! Transaction.applicationCreateTransactionBuilder()
                        .setSender(account1.getAddress())
                        .approvalProgram(approvalProgram: approvalProgram!)
                        .clearStateProgram(clearStateProgram: clearStateProgram!)
                        .globalStateSchema(globalStateSchema: StateSchema(numUint: globalInts, numByteSlice: globalBytes))
                        .localStateSchema(localStateSchema:StateSchema(numUint: localInts, numByteSlice: localBytes))
                        .suggestedParams(params: paramResponse.data!)
                        .build()
    
                    var signedTransaction=account1.signTransaction(tx: tx)
    
                       var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
    
                       print(CustomEncoder.encodeToJson(obj: signedTransaction))
    
                       algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                          response in
                           if(response.isSuccessful){
                               print(response.data!.txId)
                            print("Success")
                            self.waitForTransaction(txId: response.data!.txId){ applicationIndex in
                                self.infoTextView.text = "\(applicationIndex)"
                                self.appId=applicationIndex!
                                self.hideLoader();
                            }
                      
                           }else{
                                self.hideLoader();
                               print(response.errorDescription)
                            self.infoTextView.text=response.errorDescription!
                               print("Faled")
                           }
    
                       }
    
    
                }
                
            }
        }
    
    }
    
    
    func waitForTransaction(txId:String, funcToCall: @escaping (Int64?)->Void) {
        var confirmedRound: Int64?=0
        var applicationIndex:Int64?=0
        algodClient!.pendingTransactionInformation(txId:txId).execute(){
            pendingTransactionResponse in
                if(pendingTransactionResponse.isSuccessful){
                    confirmedRound=pendingTransactionResponse.data!.confirmedRound
                    applicationIndex=pendingTransactionResponse.data!.applicationIndex
                    if(confirmedRound != nil && confirmedRound! > 0){
                       funcToCall(applicationIndex)
                    }else{
                        try!  self.waitForTransaction(txId: txId,funcToCall: funcToCall)
                    }
                }else{
                    print(pendingTransactionResponse.errorDescription!)
                    self.infoTextView.text=pendingTransactionResponse.errorDescription!
                    funcToCall(nil)
                    confirmedRound=12000;
                }
    }
}
    
    
    public func applicationOptIn(){
        var account1 =  Config.account1!
        var address = account1.getAddress()
    
                algodClient!.transactionParams().execute(){ paramResponse in
                    if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription);
                        self.hideLoader()
                    return;
                }
    
                    var tx = try! Transaction.applicationOptInTransactionBuilder()
                        .setSender(account1.getAddress())
                        .applicationId(applicationId: self.appId!)
                        .suggestedParams(params: paramResponse.data!)
                        .build()
    
                    var signedTransaction=account1.signTransaction(tx: tx)
    
                       var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
    
                       print(CustomEncoder.encodeToJson(obj: signedTransaction))
    
                   //    return;
    
    
                    self.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                          response in
                           if(response.isSuccessful){
                               print(response.data!.txId)
                            self.hideLoader()
                            self.infoTextView.text="Opted in account \(address.description) successfully \n transaction id: \(response.data!.txId)"
                           }else{
                               print(response.errorDescription)
                            self.hideLoader();
                            self.infoTextView.text = response.errorDescription!
                               print("Faled")
                           }
                       }
                }
    }
    
    
    public func applicationCallTransaction(){
        
        var account1 =  Config.account1!
    
                algodClient!.transactionParams().execute(){ paramResponse in
                    if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription);
                        self.infoTextView.text = paramResponse.errorDescription!
                        self.hideLoader();
                    return;
                }
    
                    var tx = try! Transaction.applicationCallTransactionBuilder()
                        .setSender(account1.getAddress())
                        .applicationId(applicationId: self.appId!)
    
                        .suggestedParams(params: paramResponse.data!)
                        .args(args: [[1,2]])
                        .build()
    
                    var signedTransaction=account1.signTransaction(tx: tx)
    
                       var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
    
                       print(CustomEncoder.encodeToJson(obj: signedTransaction))
    
                   //    return;
    
    
                    self.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                          response in
                           if(response.isSuccessful){
                               print(response.data!.txId)
                            self.hideLoader()
                            self.infoTextView.text="Call was successfull  \n transaction id: \(response.data!.txId)"
                           }else{
                               print(response.errorDescription)
                            self.hideLoader();
                            self.infoTextView.text = response.errorDescription!
                               print("Faled")
                           }
    
                       }
    
    
                }
    
    }
    
    public func updateApplication(){
        var algodClient = Config.algodClient!;
        
        var account1 = Config.account2!
        var address = account1.getAddress()
        var address2 = account1.getAddress()
        
    
        var localInts:Int64 = 1;
        var localBytes:Int64 = 1;
        var globalInts:Int64 = 1;
        var globalBytes:Int64 = 0;
    
        var approvalProgram:TEALProgram?
        var clearStateProgram:TEALProgram?
        tealCompile(resource: "stateful_clear.teal"){ clearProgResult in
            clearStateProgram = try? TEALProgram(base64String: clearProgResult);
            print(clearStateProgram)
            print("ClearProg result: \(clearProgResult)")
            
            self.tealCompile(resource: "stateful_approval_refact.teal"){ approvalProgResult in
                print("Approval Prog result: \(approvalProgResult)")
                approvalProgram = try? TEALProgram(base64String:approvalProgResult)
                print(approvalProgram)
                algodClient.transactionParams().execute(){ paramResponse in
                    if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription);
                    return;
                }
    
                    var tx = try! Transaction.applicationUpdateTransactionBuilder()
                        .setSender(account1.getAddress())
                        .approvalProgram(approvalProgram: approvalProgram!)
                        .clearStateProgram(clearStateProgram: clearStateProgram!)
                        .applicationId(applicationId: self.appId!)
                        .suggestedParams(params: paramResponse.data!)
                        .build()
    
                    var signedTransaction=account1.signTransaction(tx: tx)
    
                       var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
    
                       print(CustomEncoder.encodeToJson(obj: signedTransaction))
    
                       algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                          response in
                           if(response.isSuccessful){
                               print(response.data!.txId)
                            print("Success")
                            self.infoTextView.text = "Application update successful with transaction id: \(response.data!.txId)"
                            self.hideLoader();
                      
                           }else{
                                self.hideLoader();
                                print(response.errorDescription)
                                self.infoTextView.text=response.errorDescription!
                                print("Faled")
                           }
    
                       }
    
    
                }
                
            }
        }
    
    }
    
    public func closeApplication(){
        var account1 =  Config.account1!
    
                algodClient!.transactionParams().execute(){ paramResponse in
                    if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription);
                        self.infoTextView.text = paramResponse.errorDescription!
                        self.hideLoader();
                    return;
                }
    
                    var tx = try! Transaction.applicationCloseTransactionBuilder()
                        .setSender(account1.getAddress())
                        .applicationId(applicationId: self.appId!)
                        .suggestedParams(params: paramResponse.data!)
        
                        .build()
    
                    var signedTransaction=account1.signTransaction(tx: tx)
    
                       var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
    
                       print(CustomEncoder.encodeToJson(obj: signedTransaction))
    
                   //    return;
    
    
                    self.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                          response in
                           if(response.isSuccessful){
                               print(response.data!.txId)
                            self.hideLoader()
                            self.infoTextView.text="Close out call was successfull  \n transaction id: \(response.data!.txId)"
                           }else{
                               print(response.errorDescription)
                            self.hideLoader();
                            self.infoTextView.text = response.errorDescription!
                               print("Faled")
                           }
    
                       }
    
    
                }
    
        
    }
    
}
