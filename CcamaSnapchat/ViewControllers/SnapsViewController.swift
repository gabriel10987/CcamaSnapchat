//
//  SnapsViewController.swift
//  CcamaSnapchat
//
//  Created by Gabriel Anderson Ccama Apaza on 23/10/24.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseStorage

class SnapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {

    @IBOutlet weak var tablaSnaps: UITableView!
    
    var snaps:[Snap] = []
    var audioPlayer: AVAudioPlayer?
    var snapEnReproduccion: Snap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaSnaps.delegate = self
        tablaSnaps.dataSource = self
        
        let usuarioSnapsRef = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps")
        
        usuarioSnapsRef.observe(DataEventType.childAdded, with: { (snapshot) in
            let snapData = snapshot.value as! NSDictionary
            let snap = Snap()
            snap.id = snapshot.key
            snap.from = snapData["from"] as! String
            snap.tipo = snapData["tipo"] as! String
            
            if snap.tipo == "imagen" {
                snap.imagenURL = snapData["imagenURL"] as! String
                snap.descripcion = snapData["descripcion"] as! String
                snap.imagenID = snapData["imagenID"] as! String
            } else if snap.tipo == "audio" {
                snap.audioURL = snapData["audioURL"] as! String
                snap.titulo = snapData["titulo"] as! String
                snap.audioID = snapData["audioID"] as! String
            }
            
            self.snaps.append(snap)
            self.tablaSnaps.reloadData()
        })
        
        usuarioSnapsRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            var iterator = 0
            for snap in self.snaps{
                if snap.id == snapshot.key{
                    self.snaps.remove(at: iterator)
                }
                iterator += 1
            }
            self.tablaSnaps.reloadData()
        })
    }
    
    @IBAction func cerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if snaps.count == 0 {
            return 1
        } else {
            return snaps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if snaps.count == 0 {
            cell.textLabel?.text = "No tiene Snaps 😭"
        } else {
            let snap = snaps[indexPath.row]
            cell.textLabel?.text = snap.tipo == "imagen" ? "📷 \(snap.from)" : "🎶 \(snap.from)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snap = snaps[indexPath.row]
        
        if snap.tipo == "imagen" {
            performSegue(withIdentifier: "versnapsegue", sender: snap)
        } else if snap.tipo == "audio" {
            reproducirAudio(snap: snap)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reproducirAudio(snap: Snap) {
        guard let audioURL = URL(string: snap.audioURL) else {return}
        
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: audioURL) { (location, response, error) in
            if let location = location {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: location)
                    self.audioPlayer?.delegate = self
                    self.snapEnReproduccion = snap
                    self.audioPlayer?.play()
                } catch {
                    print("Error al reproducir el audio: \(error)")
                }
            } else {
                print("Error al descargar el audio")
            }
        }
        downloadTask.resume()
    }
    
    // detectar cuando el audio ha terminado
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let snap = snapEnReproduccion {
            Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
            
            Storage.storage().reference().child("audios").child("\(snap.audioID).m4a").delete { (error) in
                print("Se elimino el audio correctamente")
            }
            snapEnReproduccion = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "versnapsegue" {
            let siguienteVC = segue.destination as! VerSnapViewController
            siguienteVC.snap = sender as! Snap
        }
    }
}

