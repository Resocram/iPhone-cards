//
//  ViewController.swift
//  CardGameBluetooth
//
//  Created by Marco Ser/Cloud Services /SRCA/Associate/Samsung Electronics on 2020-07-11.
//  Copyright © 2020 Marco Ser. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController,MCSessionDelegate,MCBrowserViewControllerDelegate {


    @IBOutlet weak var textShouldChange: UITextView!
    

    var hosting:Bool!
    var msg: String!
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer:peerID,securityIdentity: nil,encryptionPreference: MCEncryptionPreference.none)
        mcSession.delegate = self
        hosting = false
    }
    
    func sendMessage(){
        let message = Data("secret message".utf8)
        if mcSession.connectedPeers.count > 0{
            do{
                try mcSession.send(message,
                                   toPeers: mcSession.connectedPeers,
                                   with: .reliable)
            }catch let error as NSError{
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title:"OK",style: .default))
                present(ac,animated:true)
                
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected :\(peerID.displayName)")
        
        case MCSessionState.connecting:
            print("Connecting :\(peerID.displayName)")
        
        case MCSessionState.notConnected:
            print("Not Connected: :\(peerID.displayName)")
        @unknown default:
            print("no way")
        }
    }

    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        _ = String(decoding:data,as: UTF8.self)
            DispatchQueue.main.async{
                self.msg = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                self.textShouldChange.text = self.textShouldChange.text + self.msg
            }
        
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated:true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated:true)
    }

    func startHosting(action: UIAlertAction!){
        mcAdvertiserAssistant =
            MCAdvertiserAssistant(serviceType:"hws-kb",discoveryInfo:nil,session:mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction!){
        let mcBrowser = MCBrowserViewController(serviceType:"hws-kb",session:mcSession)
        mcBrowser.delegate = self
        present(mcBrowser,animated:true)
    }

    @IBAction func connectionButtonTapped(_ sender: Any) {
        if mcSession.connectedPeers.count == 0 && !hosting{
            let connectActionSheet = UIAlertController(title:"Our A", message:"B",preferredStyle: .actionSheet)
            connectActionSheet.addAction(UIAlertAction(title:"Host C",style:.default,handler:{
                (action:UIAlertAction) in
                self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType:"D",discoveryInfo:nil,
                                                                 session:self.mcSession)
                self.mcAdvertiserAssistant.start()
                self.hosting = true
            }))
            
            connectActionSheet.addAction(UIAlertAction(title:"Join E",style:.default,handler:{
                (action:UIAlertAction) in
                let mcBrowser = MCBrowserViewController(serviceType:"D",session:self.mcSession)
                mcBrowser.delegate = self
                self.present(mcBrowser,animated:true,completion:nil)
            }))
            
            connectActionSheet.addAction(UIAlertAction(title:"Cancel F", style:.cancel,handler:nil))
            self.present(connectActionSheet,animated:true,completion:nil)
        }else if mcSession.connectedPeers.count == 0 && hosting{
            let waitActionSheet = UIAlertController(title: "Waiting... G",message:"Waiting for others to join H",
                                                    preferredStyle: .actionSheet)
            
            waitActionSheet.addAction(UIAlertAction(title:"Disconnect H",style:.destructive, handler:{
                (action) in
                self.mcSession.disconnect()
                self.hosting = false
            }))
            
            waitActionSheet.addAction(UIAlertAction(title:"Cancel I", style: .cancel, handler:nil))
            self.present(waitActionSheet,animated:true,completion:nil)
        }else{
            let disconnectActionSheet = UIAlertController(title:"J You want to d/c?",message:nil,preferredStyle:.actionSheet)
            disconnectActionSheet.addAction(UIAlertAction(title:"Disconnect K",style:.destructive,handler:{
                (action:UIAlertAction) in
                self.mcSession.disconnect()
            }))
            disconnectActionSheet.addAction(UIAlertAction(title:"Cancel L", style: .cancel,handler:nil))
            self.present(disconnectActionSheet,animated:true,completion:nil)
        }
    }
    
    @IBAction func hostTapped(_ sender: Any) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType:"pls",discoveryInfo:nil,
                                                      session:mcSession)
        mcAdvertiserAssistant.start()
        print("hosting")
    }
    @IBAction func joinTapped(_ sender: Any) {
        let mcBrowser = MCBrowserViewController(serviceType:"pls",session:mcSession)
        mcBrowser.delegate = self
        present(mcBrowser,animated:true)
        print("joining")
    }
    
    
}

