//
//  AudioViewController.swift
//  CcamaSnapchat
//
//  Created by Gabriel Anderson Ccama Apaza on 31/10/24.
//

import UIKit
import AVFoundation
import FirebaseStorage

class AudioViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var elegirContactoButton: UIButton!
    
    var grabarAudio: AVAudioRecorder?
    var audioURL:URL?
    var audioID = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        elegirContactoButton.isEnabled = false
    }
    
    func configurarGrabacion() {
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // creando dirección para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            // impresion de ruta donde se guardan los archivos
            print("*******************")
            print(audioURL!)
            print("*******************")
            
            // crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            // crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // detener la grabacion
            grabarAudio?.stop()
            // cambiar texto del boton grabar
            grabarButton.setTitle("Grabar", for: .normal)
            elegirContactoButton.isEnabled = true
        } else {
            // empezar a grabar
            grabarAudio?.record()
            // cambiar el texto del boton grabar a detener
            grabarButton.setTitle("Detener", for: .normal)
        }
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoButton.isEnabled = false
        let audiosFolder = Storage.storage().reference().child("audios")
        if let audioURL = audioURL {
            do{
                let audioData = try Data(contentsOf: audioURL)
                let cargarAudio = audiosFolder.child("\(audioID).m4a")
                    cargarAudio.putData(audioData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        print("Ocurrio un error al subir audio: \(error)")
                        return
                    } else {
                        cargarAudio.downloadURL(completion: { (url, error) in
                            guard let enlaceURL = url else {
                                print("Ocurrio un error al obtener información del audio: \(error)")
                                return
                            }
                            self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
                        })
                        
                    }
                }
            } catch {
                print("Error al obtener datos del audio: \(error.localizedDescription)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.tipoSnap = "audio"
        siguienteVC.audioURL = sender as! String
        siguienteVC.titulo = tituloTextField.text!
        siguienteVC.audioID = audioID
    }
    
}

