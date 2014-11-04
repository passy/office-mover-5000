//
//  LoginViewController.swift
//  OfficeMover500
//
//  Created by David on 10/31/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GPPSignInDelegate {

    let ref = Firebase(url: OfficeMoverFirebaseUrl)
    var authData: FAuthData?
    var authHandler: UInt!
    
    @IBOutlet var btLogin: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        var nav = self.navigationController?.navigationBar
        nav?.barTintColor = TopbarBlue
        nav?.barStyle = UIBarStyle.Default
        nav?.tintColor = UIColor.whiteColor()
        var font: UIFont = UIFont(name: "ProximaNova-Light", size: 20)!
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName:font]
        navigationItem.setHidesBackButton(true, animated: false)
        autoLogin()
    }
    
    func autoLogin() {
        // If we already have an auth observer, remove that one.
        if authHandler != nil {
            ref.removeAuthEventObserverWithHandle(authHandler)
        }
        
        // Automatically log in when we are auth'd
        authHandler = ref.observeAuthEventWithBlock({
            [unowned self] authData in
            if authData != nil {
                self.ref.removeAuthEventObserverWithHandle(self.authHandler)
                self.performSegueWithIdentifier("LOGGED_IN", sender: self)
            }
        })
    }
    
    func signInInstance() -> GPPSignIn {
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = "311395164163-bhjoq6cb43hh1n92l7ntb8180uplbcll.apps.googleusercontent.com"
        //signIn.clientID = "33816672509-qcgp7s8onp38fmtedli3prli3ql3j2i3.apps.googleusercontent.com" // extra
        signIn.scopes = [] // We pass an empty array to force Google login instead of Google+ login
        signIn.delegate = self
        return signIn
    }
    
    @IBAction func login(sender: AnyObject) {
        println("Logging in!")
        let signIn = signInInstance()
        // authenticate will do a callback to finishedWithAuth:error:
        signIn.authenticate()
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        autoLogin()
        if error != nil {
            // There was an error obtaining the Google+ OAuth Token
            println("There was an error logging in \(error)")
        } else {
            // We successfully obtained an OAuth token, authenticate on Firebase with it
            ref.authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        // Error authenticating with Firebase with OAuth token
                    } else {
                        // User is now logged in!
                        println("Successfully logged in! \(authData)")
                    }
            })
        }
    }
}