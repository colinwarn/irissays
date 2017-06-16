//
//  ViewController.swift
//  Wait But Why Reader
//
//  Created by Colin Warn on 4/26/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import StoreKit

class ViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    @IBOutlet weak var addVoices: UIButton!
    @IBOutlet weak var restorePurchases: UIButton!
    @IBOutlet weak var removeAds: UIButton!
    
    

    @IBOutlet weak var adView: UIView!
    
    
    @IBOutlet var urlTextField: UITextField!
    
    @IBOutlet weak var botVoice: UISegmentedControl!
    
    @IBOutlet weak var bannerViewAd: GADBannerView!
    
    var itemBeingPurchased = String()
    
    
    
    @IBOutlet var siriButton: UIButton!
    var myURlString: String? = ""
    
    //In App purchase
    let bonusRobotVoicesID = "bonusrobotvoices"
    let removeAdsID = "removeadsiris"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var bonusRobotVoicesKey = UserDefaults.standard.bool(forKey: "bonusrobotvoices")
    var removeAdsKey = UserDefaults.standard.bool(forKey: "removeads")
    
    
    //Voice
    
    
    var siriSound: AVAudioPlayer!
    
    var botVoiceMultiplier: Float = 1.0
    
    var textToSpeech = AVSpeechUtterance()
    
    
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var list: [SKProduct] = []
    var p = SKProduct()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerViewAd.delegate = self
        bannerViewAd.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerViewAd.rootViewController = self
        bannerViewAd.load(request)
        
        botVoice.selectedSegmentIndex = 2
        // Do any additional setup after loading the view, typically from a nib.
        
        let path = Bundle.main.path(forResource: "siri", ofType:"wav")!
        let url = URL(fileURLWithPath: path)
        
        //Buttons enabled = false
        addVoices.isEnabled = false
        restorePurchases.isEnabled = false
        removeAds.isEnabled = false
        
        if (SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(objects: bonusRobotVoicesID, removeAdsID)
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
            
        } else {
            print("Please enable IAPS")
            displayAlertMessage(title: "In App Purchases Not Enabled", message: "Please enable In App Purchases to take full advantage of this app.")
        }
        
        
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            siriSound = sound
            
        } catch {
            // couldn't load file :(
        }
        
        self.urlTextField.delegate = self
        
     
        
    }
    
    func displayAlertMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @available(iOS 3.0, *)
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
    }
    
    @IBAction func addVoices(_ sender: Any) {
    }
    
    @IBAction func removeAds(_ sender: Any) {
        for product in list {
            let prodID = product.productIdentifier
            if prodID == removeAdsID {
                p = product
                buyProduct()
            }
        }
    }
    
    @IBAction func restorePurchases(_ sender: Any) {
    }
    
    
    
    @IBAction func modeChanged(_ sender: Any) {
        
        if botVoice.selectedSegmentIndex == 0 {
            botVoiceMultiplier = 0.5
        }
        else if botVoice.selectedSegmentIndex == 1 {
            botVoiceMultiplier = 2.0
        }
        else {
            botVoiceMultiplier = 1.5
        }
    }
    
    
    
    
    
    
    @IBAction func clearPressed(_ sender: UIButton) {
        urlTextField.text = ""
        myURlString = ""
        loadSpeech()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        playAnimationAndSound()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
   
    
    func loadSpeech() {
        if let myUrlStringReal = myURlString {
            
            textToSpeech = AVSpeechUtterance(string: myUrlStringReal)
            textToSpeech.pitchMultiplier = botVoiceMultiplier
        }
    }
    
    

    @IBAction func textEdited(_ sender: UITextField) {
        siriButton.alpha = 1
        siriButton.isEnabled = true
        myURlString = urlTextField.text
        
        loadSpeech()
    }
    
    @IBAction func editingBegan(_ sender: UITextField) {
        siriButton.isEnabled = false
        UIView.animate(withDuration: 1, animations: {
            self.siriButton.alpha = 0
        })
        
        
    }
   
    
    func playAnimationAndSound(){
        siriSound.play()
        let pulse = Pulsing(numberOfPulses: 1, radius: 200, position: siriButton.center)
        
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.red.cgColor
        
        self.view.layer.insertSublayer(pulse, below: siriButton.layer)
    }

    @IBAction func readTextPressed(_ sender: UIButton) {
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        playAnimationAndSound()
        
        loadSpeech()
        
        speechSynthesizer.speak(textToSpeech)
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

    


}

