//
//  AccountsAndTransactionsController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/12/21.
//

import UIKit
import swift_algorand_sdk
class AccountsAndTransactionsController: UIViewController {

    @IBOutlet weak var infoLabelText: UIButton!
    
    @IBOutlet weak var networkInfoLabel: UILabel!
    
    @IBOutlet weak var generateAccount1Button: UIButton!
    @IBOutlet weak var transactionFromAccount1to2: UIButton!
    
    @IBOutlet weak var multisigAddressButton: UIButton!
    
    @IBOutlet weak var generateAccount3Button: UIButton!
    @IBOutlet weak var generateAccount2Button: UIButton!
    @IBOutlet weak var account3GetAccountBalanceButton: UIButton!
    @IBOutlet weak var account3FundsNeededButton: UIButton!
    @IBOutlet weak var account2GetAccountBalanceButton: UIButton!
    @IBOutlet weak var account2FundsNeededButton: UIButton!
    @IBOutlet weak var account1GetAccountBalanceButton: UIButton!
    @IBOutlet weak var account1FundsNeededButton: UIButton!
    @IBOutlet weak var sendMultisigTokensButton: UIButton!
    var multisigAddress:MultisigAddress?
    override func viewDidLoad() {
        super.viewDidLoad()
        account1FundsNeededButton.isHidden=true
        account2FundsNeededButton.isHidden=true
        account3FundsNeededButton.isHidden=true
        account1GetAccountBalanceButton.isHidden=true
        account2GetAccountBalanceButton.isHidden=true
        account3GetAccountBalanceButton.isHidden=true
        
        infoLabelText.titleLabel!.numberOfLines = 12;


      
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
    override func viewWillAppear(_ animated: Bool) {
        networkInfoLabel.text="\(Config.currentNet): \(Config.currentNode)"
    }
    @IBAction func getBlockInfo(_ sender: Any) {
        
        var algodClient=Config.algodClient
        showLoader()
        algodClient!.getStatus().execute(){nodeStatusResponse in
               if(nodeStatusResponse.isSuccessful){
                
                algodClient!.getBlock(round: nodeStatusResponse.data!.lastRound!).execute(){ blockResponse in
                    
                    self.hideLoader()
                    if(blockResponse.isSuccessful){
                        self.infoLabelText.setTitle(blockResponse.data!.toJson(), for: .normal)
                    }else{
                        
                        self.infoLabelText.setTitle(blockResponse.errorDescription!, for: .normal)
                    }
                    
                
                }
                
             
              
               }else{
                self.hideLoader()
                self.infoLabelText.setTitle(nodeStatusResponse.errorDescription, for: .normal)
               }
       
           }
    }
    
    
    @IBAction func generateAccount1(_ sender: Any) {
        
        var account =  try! Account()
        infoLabelText.setTitle("Mnemonic: \(account.toMnemonic())\n Address: \(account.address.description)", for: .normal)
        Config.account1=account
        generateAccount1Button.setTitle("Account 1", for: .normal)
        account1FundsNeededButton.isHidden=false
        account1FundsNeededButton.setTitle("Funds Needed", for: .normal)
        account1GetAccountBalanceButton.isHidden=false
        account1GetAccountBalanceButton.setTitle("Get Account1 Balance", for: .normal)
    }
    
    @IBAction func generateAccount2(_ sender: Any) {
        var account1 = try! Account()
        infoLabelText.setTitle("Mnemonic: \(account1.toMnemonic())\n Address: \(account1.address.description)", for: .normal)
        sendMultisigTokensButton.setTitleColor(UIColor.blue, for: .normal)
        transactionFromAccount1to2.setTitleColor(UIColor.blue, for: .normal)
        multisigAddressButton.setTitleColor(UIColor.blue, for: .normal)
        Config.account2=account1
        generateAccount2Button.setTitle("Account 2", for: .normal)
        account2FundsNeededButton.isHidden=false
        account2FundsNeededButton.setTitle("Funds Needed", for: .normal)
        account2GetAccountBalanceButton.isHidden=false
        account2GetAccountBalanceButton.setTitle("Get Account2 Balance", for: .normal)
    }
    
    @IBAction func generateAccount3(_ sender: Any) {
        var account3 = try! Account()
        infoLabelText.setTitle("Mnemonic: \(account3.toMnemonic())\n Address: \(account3.address.description)", for: .normal)
        Config.account3=account3
        generateAccount3Button.setTitle("Account 3", for: .normal)
        account3FundsNeededButton.isHidden=false
        account3FundsNeededButton.setTitle("Funds Needed", for: .normal)
        account3GetAccountBalanceButton.isHidden=false
        account3GetAccountBalanceButton.setTitle("Get Account3 Balance", for: .normal)
    }
    
    
    @IBAction func transferFromAccount1ToAccount2(_ sender: Any) {
        transferFunds(sender: Config.account1!, receiverAddress: Config.account2!.address)
    }
    
    @IBAction func createMultisigAddress(_ sender: Any) {
        createMultisigAddress(address1: Config.account1!.getAddress(), address2: Config.account2!.getAddress())
    }
    
    @IBAction func sendFromMultisigAddressToAccount2(_ sender: Any) {
        sendMultisigTransaction(account1: Config.account1!, account2: Config.account2!, receiverAddress: Config.account2!.address)
    }
    
    
    @IBAction func account1FundsNeededAction(_ sender: Any) {
        UIPasteboard.general.string=Config.account1?.address.description
    }
    
    @IBAction func account1GetAccountBalanceButton(_ sender: Any) {
        getAccountBalance(address: (Config.account1?.getAddress().description)!)
    }
    @IBAction func account2FundsNeededAction(_ sender: Any) {
        UIPasteboard.general.string=Config.account2?.address.description
    }
    @IBAction func account2GetAccountBalanceButton(_ sender: Any) {
        getAccountBalance(address: (Config.account2?.getAddress().description)!)
    }
    
    @IBAction func account3FundsNeededAction(_ sender: Any) {
        UIPasteboard.general.string=Config.account3?.address.description
    }
    @IBAction func account3GetAccountBalanceBAction(_ sender: Any) {
        getAccountBalance(address: (Config.account3?.getAddress().description)!)
    }
    
    
    @IBAction func copyInfoLabelTextAction(_ sender: UIButton) {
    
        if let buttonTitle = sender.title(for: .normal) {
            UIPasteboard.general.string=(buttonTitle)
         }
    }
    
    
    func getAccountBalance(address:String){
        showLoader()
        Config.algodClient!.accountInformation(address: address).execute(){accountInformationResponse in
            
            self.hideLoader()
            if(accountInformationResponse.isSuccessful){
                
                      
                self.infoLabelText.setTitle("\(accountInformationResponse.data!.amount!) micro algos", for: .normal)
                  }else{
                    self.infoLabelText.setTitle("\(accountInformationResponse.errorDescription)", for: .normal)
                     
                  }
        }
    
    }
    
    func transferFunds(sender:Account,receiverAddress:Address){
        showLoader()
        var trans =  Config.algodClient!.transactionParams().execute(){ paramResponse in
                    if(!(paramResponse.isSuccessful)){
                    print(paramResponse.errorDescription);
                        self.hideLoader()
                    return;
                }
        
        
            var tx = Transaction.paymentTransactionBuilder().setSender(sender.address)
                    .amount(1000000)
                    .receiver(receiverAddress)
                    .note("Swift Algo sdk is cool".bytes)
                    .suggestedParams(params: paramResponse.data!)
                    .build()
          
                    var signedTransaction=sender.signTransaction(tx: tx)
        
                    var encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(signedTransaction)
        
        
        
            Config.algodClient!.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                       response in
                self.hideLoader()
                        if(response.isSuccessful){
                          
                            self.infoLabelText.setTitle("\(response.data!.txId)", for: .normal)
                        }else{
                           
                            self.infoLabelText.setTitle(response.errorDescription, for: .normal)
                      
                        }
        
                    }
            }
    
    }
    
    func createMultisigAddress(address1:Address,address2:Address){
        var ed25519i = Ed25519PublicKey(bytes:address1.bytes!)
        var ed25519ii=Ed25519PublicKey(bytes:address2.bytes!)
    
        self.multisigAddress = try! MultisigAddress(version: 1, threshold: 2, publicKeys: [ed25519ii,ed25519i])
        self.infoLabelText.setTitle(multisigAddress!.toString(), for: .normal)
    }
    
    func sendMultisigTransaction(account1:Account,account2:Account,receiverAddress:Address){
        showLoader()
        Config.algodClient!.transactionParams().execute(){ paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                self.hideLoader()
                self.infoLabelText.setTitle("\(paramResponse.errorDescription)", for: .normal)
                return;
            }
    
            var tx = Transaction.paymentTransactionBuilder()
                .setSender( try! self.multisigAddress!.toAddress())
                  .amount(1000000)
                .receiver(receiverAddress)
                .suggestedParams(params: paramResponse.data!)
                          .build();
    
            var IsignedTrans = try! account1.signMultisigTransaction(from: self.multisigAddress!, tx: tx)
            var signedTrans=try!account2.appendMultisigTransaction(from: self.multisigAddress!, signedTx: IsignedTrans)
            var signedTransmsgPack=CustomEncoder.convertToUInt8Array(input: CustomEncoder.encodeToMsgPack(signedTrans))
            var int8sT:[Int8] = CustomEncoder.encodeToMsgPack(signedTrans)
            var jsonEncoder=JSONEncoder()
            var txData=try! jsonEncoder.encode(signedTrans)
            var txString=String(data: txData, encoding: .utf8)
      
            Config.algodClient!.rawTransaction().rawtxn(rawtaxn: CustomEncoder.encodeToMsgPack(signedTrans)).execute(){
               response in
                self.hideLoader()
                if(response.isSuccessful){
                
                    self.infoLabelText.setTitle("\(response.data!.txId)", for: .normal)
                }else{
                  
                    self.infoLabelText.setTitle("\(response.errorDescription)", for: .normal)
                }
    
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
        present(alert, animated: true, completion: nil)
        
    }
    
    public func hideLoader(){
        dismiss(animated: false, completion: nil)
    }
    
  
}
