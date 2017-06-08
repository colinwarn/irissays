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

class ViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {

    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var removeAds: UIButton!
    
    @IBOutlet weak var addVoices: UIButton!
    
    @IBOutlet var urlTextField: UITextField!
    
    @IBOutlet weak var botVoice: UISegmentedControl!
    
    @IBOutlet weak var bannerViewAd: GADBannerView!
    
    @IBOutlet var siriButton: UIButton!
    var myURlString: String? = ""
    
    var siriSound: AVAudioPlayer!
    
    var botVoiceMultiplier: Float = 1.0
    
    var textToSpeech = AVSpeechUtterance()
    
    
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    
    
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
        
        
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            siriSound = sound
            
        } catch {
            // couldn't load file :(
        }
        
        self.urlTextField.delegate = self
        
     
        
    }
    
    @IBAction func modeChanged(_ sender: Any) {
        
        if botVoice.selectedSegmentIndex == 0 {
            botVoiceMultiplier = 0.5
        } else {
            botVoiceMultiplier = 1.5
        }
    }
    
    @IBAction func addVoices(_ sender: Any) {
    }
    
    
    @IBAction func removeAds(_ sender: Any) {
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

