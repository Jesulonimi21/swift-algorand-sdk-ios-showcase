//
//  DryRunDebugViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 5/15/21.
//

import UIKit
import swift_algorand_sdk

class DryRunDebugViewController: UIViewController {
    @IBOutlet weak var debugDryRunText: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugDryRunText.isEditable=false
        debugDryRunText.text = "";
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

    @IBAction func dryRunDebygClicked(_ sender: Any) {
        var sources:[DryrunSource] = Array()
          var stxns:[SignedTransaction] = Array()
          var source:[Int8] = CompileTealViewController.loadSampleTeal()
         var dryRunSource = DryrunSource()
          dryRunSource.fieldName =  "approv"
          dryRunSource.source =  String(data: Data(CustomEncoder.convertToUInt8Array(input:  source)),encoding: .utf8)!

        dryRunSource.txnIndex = 01
      
          sources.append(dryRunSource)
      
          var program:[Int8] = CustomEncoder.convertToInt8Array(input: CustomEncoder.convertBase64ToByteArray(data1: "ASABASI="))
      
          var lsig = try! LogicsigSignature(logicsig: program)
      
        var signedSig = try! Config.account1!.signLogicsig(lsig: lsig)
        
        showLoader();
        
        Config.algodClient!.transactionParams().execute(){ paramResponse in
                if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription);
                    self.hideLoader()
                    self.debugDryRunText.text = paramResponse.errorMessage
                return;
            }
        
            let tx = try! Transaction.paymentTransactionBuilder().setSender(Config.account1!.getAddress())
                .amount(1000000)
                    .receiver(Config.account2!.address)
                .note("tx using in dryrun".bytes)
                .suggestedParams(params: paramResponse.data!)
                .build()
        
        
                var stx = Account.signLogicsigTransaction(lsig: lsig, tx: tx)
                stxns.append(stx)
                var dryRunRequest = DryrunRequest()
                dryRunRequest.sources = sources
                dryRunRequest.txns = stxns
        
        
                var jsonString = CustomEncoder.encodeToJson(obj: dryRunRequest)
           
        
            Config.algodClient!.tealDryRun().request(request: dryRunRequest).execute(){ requestResponse in
                self.hideLoader()
                    if(requestResponse.isSuccessful){
                     
                        self.debugDryRunText.text = requestResponse.data!.toJson()!.replacingOccurrences(of: "\\", with: "")
                    }else{
                        self.hideLoader()
                        self.debugDryRunText.text = requestResponse.errorMessage
                     
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
        self.present(alert, animated: true, completion: nil)
        
    }
    
    public func hideLoader(){
        self.dismiss(animated: false, completion: nil)
    }
}
