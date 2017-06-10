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

class ViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate, SKProductsRequestDelegate {
    
    
    

    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var removeAds: UIButton!
    
    @IBOutlet weak var addVoices: UIButton!
    
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
    var productIDs: Array<String> = ["bonusrobotvoices", "removeads"]
    var productsArray: Array<SKProduct> = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("BONUS ROBOT KEY: \(bonusRobotVoicesKey)")
        print("REMOVE ADS: \(removeAdsKey)")
        
        // Add/hide buttons here
        
        // Fetch IAP Products available
        fetchAvailableProducts()
        
        
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
        
        
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            siriSound = sound
            
        } catch {
            // couldn't load file :(
        }
        
        self.urlTextField.delegate = self
        
     
        
    }
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts()  {
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            bonusRobotVoicesID, removeAdsID
        )
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            
            
            // 2nd IAP Product (Non-Consumable) ------------------------------
            let secondProd = response.products[1] as SKProduct
            
            
        }
    }
    
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
            
            // IAP Purchases dsabled on the Device
        } else {
            alertController(message: "You've disabled in app purchaes")
        }
    }
    
    func alertController(message: String) {
        let alert = UIAlertController(title: "IAP Tutorial", message: message, preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        alert.show(self, sender: nil)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Set var of purchase to thing, then set key
        if itemBeingPurchased == "ads" {
            removeAdsKey = true
            UserDefaults.standard.bool(forKey: "removeads")
        } else {
            bonusRobotVoicesKey = true
            UserDefaults.standard.bool(forKey: "bonusrobotvoices")
        }
        
        alertController(message: "You've successfully restored your purchase!")
        
    }
    
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumable product (10 coins) has been purchased -> gain 10 extra coins!
                    if productID == bonusRobotVoicesID {
                        
                        // Do robot stuff
                        
                        
                        
                        // The Non-Consumable product (Premium) has been purchased!
                    } else if productID == removeAdsID {
                        
                        //Remove adds stuff
                    }
                    
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
    
    @IBAction func modeChanged(_ sender: Any) {
        
        if botVoice.selectedSegmentIndex == 0 {
            botVoiceMultiplier = 0.5
        } else {
            botVoiceMultiplier = 1.5
        }
    }
    
    @IBAction func addVoices(_ sender: Any) {
        itemBeingPurchased = "voices"
        purchaseMyProduct(product: iapProducts[1])
    }
    
    
    @IBAction func removeAds(_ sender: Any) {
        itemBeingPurchased = "ads"
        purchaseMyProduct(product: iapProducts[0])
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
    
    @IBAction func restorePurchases(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()

        
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

