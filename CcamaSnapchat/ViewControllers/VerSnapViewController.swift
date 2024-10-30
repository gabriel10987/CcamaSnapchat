//
//  VerSnapViewController.swift
//  CcamaSnapchat
//
//  Created by Gabriel Anderson Ccama Apaza on 30/10/24.
//

import UIKit
import SDWebImage
import Firebase

class VerSnapViewController: UIViewController {

    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje: " + snap.descripcion
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
    }

}
