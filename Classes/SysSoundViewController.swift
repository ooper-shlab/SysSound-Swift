//
//  SysSoundViewController.swift
//  SysSound
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/5/7.
//
//
/*
    File: SysSoundViewController.h
    File: SysSoundViewController.m
Abstract: This file does the work for SysSound--defining the sound to play and then playing
it when a user taps the System Sound button. Tapping the Alert Sound button invokes an alert as
performed by the device; for example, on an iPhone, it plays the sound and also invokes
vibration. Tapping the Vibration button directly invokes vibration on devices that support it.

 Version: 1.1

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.

*/

import UIKit
import AudioToolbox
import AVFoundation

@objc protocol AudioServicesPlaySystemSoundDelegate {
    func audioServicesPlaySystemSoundCompleted(soundId: SystemSoundID)
}
func MyAudioServicesSystemSoundCompletionHandler(soundId: SystemSoundID, inClientData: UnsafeMutablePointer<Void>) {
    let delegate = unsafeBitCast(inClientData, AudioServicesPlaySystemSoundDelegate.self)
    delegate.audioServicesPlaySystemSoundCompleted(soundId)
}
@objc(SysSoundViewController)
class SysSoundViewController: UIViewController, AVAudioPlayerDelegate, AudioServicesPlaySystemSoundDelegate  {

    var soundFileURLRef: NSURL!
    var soundFileObject: SystemSoundID = 0
    
    var player: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Provide a nice background for the app user interface.
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        // Create the URL for the source audio file. The URLForResource:withExtension: method is
        //    new in iOS 4.0.
        let tapSound = NSBundle.mainBundle().URLForResource("tap", withExtension: "aif")
        
        // Store the URL as a CFURLRef instance
        self.soundFileURLRef = tapSound
        
        // Create a system sound object representing the sound file.
        AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject)
        
        do {
            player = try AVAudioPlayer(contentsOfURL: soundFileURLRef)
        } catch _ {
            player = nil
        }
        player?.delegate = self
        player?.prepareToPlay()
    }
    
    
    // Respond to a tap on the System Sound button.
    @IBAction func playSystemSound(_: AnyObject) {
        
        AudioServicesPlaySystemSound(soundFileObject)
    }
    
    
    // Respond to a tap on the Alert Sound button.
    @IBAction func playAlertSound(_: AnyObject) {
        
        AudioServicesPlayAlertSound(soundFileObject)
    }
    
    
    // Respond to a tap on the Vibrate button. In the Simulator and on devices with no
    //    vibration element, this method does nothing.
    @IBAction func vibrate(_: AnyObject) {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    
    
    @IBAction func playWithAVAudioPlayer(_: AnyObject) {
        NSLog("started playing")
        player?.play()
    }
    
    private var repeatCount: Int = 3
    @IBAction func repeatVibration(_: AnyObject) {
        let proc: AudioServicesSystemSoundCompletionProc = MyAudioServicesSystemSoundCompletionHandler
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, proc, UnsafeMutablePointer(unsafeAddressOf(self)))
        self.repeatCount = 3
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    func audioServicesPlaySystemSoundCompleted(soundId: SystemSoundID) {
        if( --repeatCount > 0 ) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        //Do something when finished playing
        NSLog("finished playing")
    }
    
    
    deinit {
        
        AudioServicesDisposeSystemSoundID(soundFileObject)
    }
    
}
