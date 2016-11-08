//
//  CPXConfigureDetailViewController.swift
//  RouterApp
//
//  Created by iOS Developer on 10/28/16.
//
//

import UIKit

class CPXConfigureDetailViewController: UIViewController {
  
  @IBOutlet weak var mPasswordTextField: UITextField!
  @IBOutlet weak var mPasswordLabel: UILabel!
  @IBOutlet weak var configureButton: UIButton!
  
  var wifiInformation: AnyObject!
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Configure"
    if let ssid = wifiInformation["ssid"] as? String {
      mPasswordLabel.text = "Enter \(ssid) password"
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "showCPXConfiguring" {
//      let configuringVC = segue.destinationViewController as! CPXConfiguringViewController
//      configuringVC.wifiInfo = wifiInformation
//    }
  }
  
  @IBAction func connectButtonClicked(sender: AnyObject) {
    configureRouter()
  }
  
  private func startLoadingView() {
    mPasswordLabel.text = "We are configure your mesh router, please be patient"
    configureButton.hidden = true
    mPasswordTextField.hidden = true
  }
  
  private func stopLoadingView() {
    if let ssid = wifiInformation["ssid"] as? String {
      mPasswordLabel.text = "Enter \(ssid) password"
    }
    configureButton.hidden = false
    mPasswordTextField.hidden = false
  }
  
  private func configureRouter() {
    view.endEditing(true)
//    wifiInformation.password = mPasswordTextField.text!
    startAnimating()
    startLoadingView()
    APIManager.configureCPX(wifiInfo: wifiInformation, password: mPasswordTextField.text!) { (result, error) in
      self.stopAnimating()
      self.stopLoadingView()
      if result != nil {
        self.performSegueWithIdentifier("showConfigureSuccess", sender: nil)
      }
      else {
        self.showAlert(withMessage: "Have something wrong, please try again!")
      }
    }
  }
  
}
