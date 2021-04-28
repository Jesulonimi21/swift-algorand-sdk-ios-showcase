//
//  IndexerViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 4/28/21.
//

import UIKit
import swift_algorand_sdk
class IndexerViewController: UIViewController {
    var indexerClient:IndexerClient?
    @IBOutlet weak var infoText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
         indexerClient=IndexerClient(host: Config.PURESTAKE_INDEXER_API_ADDRESS, port: Config.PURESTAKE_API_PORT, token: Config.PURESTAKE_API_KEY)
        indexerClient!.set(key:"X-API-Key")
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
    @IBAction func lookUpHealthInfo(_ sender: Any) {
        showLoader()
        indexerClient!.makeHealthCheck().execute(){ response in
            self.hideLoader()
                if response.isSuccessful{
                    print(response.data!.toJson()!)
                    self.infoText.text = response.data!.toJson()!
                }else{
                    print(response.errorDescription)
                }
    }
    }
    
    @IBAction func lookUPAccountInfo(_ sender: Any) {
        showLoader()
        indexerClient!.lookUpAccountById(address: "LL2ZGXSHW7FJGOOVSV76RRZ6IGU5ZF4DPCHQ23G7ZLIWCB4WEMIATDBTLY").execute(){response in
            self.hideLoader()
                if response.isSuccessful{
                        print("success")
                    print(response.data!.toJson()!)
                    self.infoText.text = response.data!.toJson()!
                }else{
                    print(response.errorDescription)
                }
    }
    }
    
    @IBAction func lookUpAccountTransactions(_ sender: Any) {
        showLoader()
        indexerClient!.lookUpAccountTransactions(address: "LL2ZGXSHW7FJGOOVSV76RRZ6IGU5ZF4DPCHQ23G7ZLIWCB4WEMIATDBTLY").execute(){response in
                if response.isSuccessful{
                   
                    self.hideLoader()
                    print("success")
                    print(response.data!.toJson()!)
                    self.infoText.text = response.data!.toJson()!
                }else{
                    print(response.errorDescription)
                }
            }
    }
    
    @IBAction func searchForApplications(_ sender: Any) {
        showLoader()
        indexerClient!.searchForApplications().execute(){ response in
            self.hideLoader()
            if response.isSuccessful{
                    print(response.data!.toJson()!)
                    self.infoText.text = response.data!.toJson()!
                }else{
                    print(response.errorDescription)
                }
            }
    }
    
    
    @IBAction func lookupApplicationById(_ sender: Any) {
        showLoader()
        indexerClient!.lookUpApplicationsById(id:12174882).execute(){ response in
            self.hideLoader()
            if response.isSuccessful{
                   print(response.data!.toJson()!)
                self.infoText.text = response.data!.toJson()!
               }else{
                   print(response.errorDescription)
               }
           }
    }
    
    @IBAction func searchForAssets(_ sender: Any) {
        showLoader()
        indexerClient!.searchForAssets().assetId(assetId:14077815).execute(){ response in
            self.hideLoader()
                if response.isSuccessful{
                    print(response.data!.toJson()!)
                    self.infoText.text = response.data!.toJson()!
                }else{
                    print(response.errorDescription)
                    print("Error");
                }
            }
    }
    
    @IBAction func lookupAssetsById(_ sender: Any) {
        showLoader()
        indexerClient!.lookUpAssetById(id:14077815).execute(){response in
            self.hideLoader()
                if response.isSuccessful{
                        print("success")
                    print(response.data!.toJson()!)
                    self.infoText.text = response.data!.toJson()!
                }else{
                    print(response.errorDescription)
                    print("Error");

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
