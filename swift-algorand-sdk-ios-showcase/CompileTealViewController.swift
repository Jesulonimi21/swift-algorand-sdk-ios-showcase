//
//  CompileTealViewController.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 5/15/21.
//

import UIKit
import swift_algorand_sdk

class CompileTealViewController: UIViewController {

    @IBOutlet weak var compiledTealLabel: UILabel!
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

    @IBAction func compileTeal(_ sender: Any) {
        var source:[Int8] = CompileTealViewController.loadSampleTeal()
        showLoader();
        Config.algodClient?.tealCompile().source(source: source).execute(){compileResponse in
                if(compileResponse.isSuccessful){
                    print(compileResponse.data?.hash)
                    print(compileResponse.data?.result)
                    self.hideLoader();
                    self.compiledTealLabel.text = "Result: \(compileResponse.data!.result!)\n Hash: \(compileResponse.data!.hash!)"
                
                }else{
                    print(compileResponse.errorMessage!)
                    self.hideLoader();
                    self.compiledTealLabel.text = compileResponse.errorMessage
                }
        
            }
        print(source)
    }
    
    public static func loadSampleTeal()  -> [Int8] {
        let configURL = Bundle.main.path(forResource: "sample.teal", ofType: "txt")
        let contensts = try! String(contentsOfFile: configURL!.description)
        let jsonData = contensts.data(using: .utf8)!

        var  data = CustomEncoder.convertToInt8Array(input: Array(jsonData))
        print(data)
        return data
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
