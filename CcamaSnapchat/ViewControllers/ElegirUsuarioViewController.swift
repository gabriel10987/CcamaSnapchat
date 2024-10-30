//
//  ElegirUsuarioViewController.swift
//  CcamaSnapchat
//
//  Created by Gabriel Anderson Ccama Apaza on 24/10/24.
//

import UIKit
import Firebase

class ElegirUsuarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var listaUsuarios: UITableView!
    
    var usuarios:[Usuario] = []
    var imagenURL = ""
    var descripcion = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate = self
        listaUsuarios.dataSource = self
        
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded, with: {(snapshot) in
            print(snapshot)
            
            let usuario = Usuario()
            usuario.email = (snapshot.value as! NSDictionary)["email"] as! String
            usuario.uid = snapshot.key
            self.usuarios.append(usuario)
            self.listaUsuarios.reloadData()
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usuario = usuarios[indexPath.row]
        let snap = ["from" : usuario.email, "descripcion" : descripcion, "imagenURL" : imagenURL]
        Database.database().reference().child("usuarios").child(usuario.uid).child("snaps").childByAutoId().setValue(snap)
    }

}
