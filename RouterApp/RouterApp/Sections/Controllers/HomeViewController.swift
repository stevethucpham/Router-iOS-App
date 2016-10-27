//
//  HomeViewController.swift
//  RouterApp
//
//  Created by Phu Nguyen on 10/24/16.
//
//

import UIKit

class HomeViewController: UIViewController {
  
  @IBOutlet weak var currentSSID: UILabel!
  @IBOutlet weak var tableView: UITableView!
  private var scanLAN: ScanLAN?
  private var connectedDevices = [CPXDevice]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    currentSSID.text = NetworkingUtil.fetchSSIDInfo()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    title = "Home Mesh"
    startScanning()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    scanLAN = nil
  }
  
  private func startScanning() {
    startLoadingIndicator()
    if scanLAN == nil {
      scanLAN = ScanLAN.init(delegate: self)
      connectedDevices.removeAll()
    }
    scanLAN?.stopScan()
    scanLAN?.startScan()
  }
  
  @IBAction func showInfo(sender: AnyObject) {
    print("Show info")
  }
  
  @IBAction func reScan(sender: AnyObject) {
    scanLAN = nil
    startScanning()
  }
  
  // MARK: - Helper methods
  private func didSelectErrorDevice(device: CPXDevice) {
    let alerview = UIAlertController(title: "Error", message: "We cannot access this device\nPlease do a factory reset and try to configure it again", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    let showHowAction = UIAlertAction(title: "Show me how", style: .Default) { (action) in
      let howToConfigureVC = HowToConfigureViewController.instantiateFromStoryboard("Main")
      self.dismissViewControllerAnimated(true, completion: nil)
      self.presentViewController(howToConfigureVC, animated: true, completion: nil)
    }
    alerview.addAction(okAction)
    alerview.addAction(showHowAction)
    presentViewController(alerview, animated: true, completion: nil)
  }
  
  // MARK: - Prepare segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.SegueIdentifer.showCPXDetailSegueIdentifier {
      if let detailVC = segue.destinationViewController as? CPXDetailViewController {
        title = "Home"
        let device = sender as! CPXDevice
        detailVC.device = device
      }
    }
  }
  
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return connectedDevices.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("HomeTableViewCell", forIndexPath: indexPath) as! HomeTableViewCell
    let device = connectedDevices[indexPath.row]
    cell.device = device
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let device = connectedDevices[indexPath.row]
    if !device.status {
      didSelectErrorDevice(device)
    }
    else {
      self.performSegueWithIdentifier(Constants.SegueIdentifer.showCPXDetailSegueIdentifier, sender: device)
    }
  }
}

extension HomeViewController: ScanLANDelegate {
  func scanLANDidFindNewAdrress(address: String!, macAddress: String!, havingHostName hostName: String!) {
    // TODO: hard code for device contains prefix MAC Address 04:F0:21:1A:04:88
    if macAddress != nil {
      if macAddress.containsString("04:F0") {
        // Authenticate router
        APIManager.authenticateRouter(withIP: address, completion: { (result, error) in
          if result != nil {
            // Call API to get CPX detail
            APIManager.getCPXDetail(withIP: address, token: result!, completion: { (token, error) in
              print(result)
            })
          }
        })
        
        
        let device = CPXDevice(name: hostName, ip: address, mac: macAddress)
        connectedDevices.append(device)
      }
    }
  }
  
  func scanLANDidFinishScanning() {
    stopLoadingIndicator()
    print("Scan completely")
  }
  
}


