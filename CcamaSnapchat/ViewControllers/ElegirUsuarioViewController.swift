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
    
    var tipoSnap = ""
    
    var imagenURL = ""
    var descripcion = ""
    var imagenID = ""
    
    // para el audio
    var audioURL = ""
    var titulo = ""
    var audioID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate = self
        listaUsuarios.dataSource = self
        
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded, with: {(snapshot) in
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
        var snap = ["from" : Auth.auth().currentUser?.email]
        
        if tipoSnap == "imagen" {
            snap["descripcion"] = descripcion
            snap["imagenURL"] = imagenURL
            snap["imagenID"] = imagenID
            snap["tipo"] = "imagen"
        } else if tipoSnap == "audio" {
            snap["audioURL"] = audioURL
            snap["titulo"] = titulo
            snap["audioID"] = audioID
            snap["tipo"] = "audio"
        }
        
        Database.database().reference().child("usuarios").child(usuario.uid).child("snaps").childByAutoId().setValue(snap)
        navigationController?.popViewController(animated: true)
    }

}

