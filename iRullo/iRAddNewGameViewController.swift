//
//  iRAddNewGameViewController.swift
//  iRullo
//
//  Created by jorgemoniz on 3/4/17.
//  Copyright © 2017 Jorge Moñiz. All rights reserved.
//

import UIKit
import CoreData

// Si la vista anterior dice que ha añadido un juego, hace una vista de recarga
protocol iRAddNewGameViewControllerDelegate {
    func didAddGame()
}

class iRAddNewGameViewController: UIViewController {

    //MARK: - Variables locales globales
    var manageContext : NSManagedObjectContext!
    var iRDelegate : iRAddNewGameViewControllerDelegate?
    var game : Game?
    var datePicker : UIDatePicker!
    var dateFormatter = DateFormatter()
    
    //MARK: - IBOutlets
    @IBOutlet weak var myImageGame: UIImageView!
    @IBOutlet weak var mySwitchBorrowed: UISwitch!
    @IBOutlet weak var myTituloGame: UITextField!
    @IBOutlet weak var myQuienPrestadoGame: UITextField!
    @IBOutlet weak var myCuandoPrestadoGame: UITextField!
    @IBOutlet weak var myEliminarJuegoBTN: UIButton!
    
    //MARK: - IBActions
    @IBAction func mySwitchChangedValue(_ sender: UISwitch) {
        if sender.isOn {
            myQuienPrestadoGame.isEnabled = true
            myCuandoPrestadoGame.isEnabled = true
            myCuandoPrestadoGame.text = dateFormatter.string(from: Date())
        } else {
            myQuienPrestadoGame.isEnabled = false
            myCuandoPrestadoGame.isEnabled = false
            myQuienPrestadoGame.text = ""
            myCuandoPrestadoGame.text = ""
        }
    }
    
    @IBAction func myEliminarJuegoACT(_ sender: UIButton) {
        if let context = manageContext {
            context.delete(game!)           //El que se está mostrando en pantalla
            game = nil
            iRDelegate?.didAddGame()
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - LIFE VC
    override func viewDidLoad() {
        super.viewDidLoad()

        //Formato de fecha
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        //Imagen
        myImageGame.isUserInteractionEnabled = true
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(pickerPhoto))
        myImageGame.addGestureRecognizer(tapGR)
        
        //Teclado
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        //Esconder el teclado
        let tapGRhidekeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGRhidekeyboard)
        
        //DatePicker
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 210, width: 320, height: 216))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        myCuandoPrestadoGame.inputView = datePicker
        
        
        //Dos lógicas para el mismo VC
        //      1. Add / 2. Edit
        if game == nil {
            self.title = "Añadir Videojuego"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonAction))
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonAction))
            
            myEliminarJuegoBTN.isHidden = true
            mySwitchBorrowed.isOn = false
        } else {
            self.title = "Editar Videojuego"
            myTituloGame.text = game?.title
            
            if let borrowed = game?.borrowed {
                mySwitchBorrowed.isOn = borrowed
            }
            myQuienPrestadoGame.text = game?.borrowedTo
            if let borrowedDate = game?.borrowedDate as Date? {
                myCuandoPrestadoGame.text = dateFormatter.string(from: borrowedDate)
            }
            if let imageData = game?.image as Data? {
                myImageGame.image = UIImage(data: imageData)
            }
            myEliminarJuegoBTN.isHidden = false
        }
        
        if !mySwitchBorrowed.isOn {
            myQuienPrestadoGame.isEnabled = false
            myCuandoPrestadoGame.isEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if game != nil {
            saveGame()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Utils
    func keyboardWillShow(_ notification : Notification) {
        let info = notification.userInfo!
        let keyboardFrame = (info [UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        //Animation - La vista sube tanto como el keyboard.
        UIView.animate(withDuration: keyboardTime) { 
            self.view.frame.origin.y = -(keyboardFrame.height)
        }
    }
    
    func keyboardWillHide(_ notification : Notification) {
        let info = notification.userInfo!
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: keyboardTime) {
            self.view.frame.origin.y = 0
        }
    }
    
    func hideKeyboard() {
        for c_view in self.view.subviews {
            if let textField = c_view as? UITextField {
                textField.resignFirstResponder()
                //Dimite como primer respondedor
            }
        }
    }
    
    func datePickerValueChanged(_ picker : UIDatePicker) {
        myCuandoPrestadoGame.text = dateFormatter.string(from: picker.date)
    }
    
    func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func saveButtonAction() {
        saveGame()
        dismiss(animated: true, completion: nil)
    }
    
    func saveGame() {
        //Inyectamos el contexto
        if let context = manageContext {
            //1
            var editedGame : Game?
            
            if game == nil {
                editedGame = Game(context: context)
            } else {
                editedGame = game
            }
            
            editedGame?.title = self.myTituloGame.text
            editedGame?.borrowed = self.mySwitchBorrowed.isOn
            
            let imageData = UIImageJPEGRepresentation(myImageGame.image!, 0.3)
            editedGame?.image = imageData as NSData?
            
            if (editedGame?.borrowed)! {
                editedGame?.borrowedTo = myQuienPrestadoGame.text?.uppercased()
                editedGame?.borrowedDate = dateFormatter.date(from: myCuandoPrestadoGame.text!) as NSDate?
            }
            
            if myTituloGame.text != "" && myImageGame.image != nil {
                
                do {
                    try context.save()
                    self.iRDelegate?.didAddGame()
                    //si todo se ha guardado correctamente, se añade un nuevo juego
                } catch {
                    print("Error al guardar los datos en CoreData")
                }
            } else {
                present(muestraAlertVC("Estimado usuario", messageData: "Por favor, introduzca los datos", titleActionData: "OK"), animated: true, completion: nil)
            }
        }
    }
    
    //Por si acaso
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

//SNIPPET - myPickerPhoto
extension iRAddNewGameViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func pickerPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            muestraMenu()
        }else{
            muestraLibreriaFotos()
        }
    }
    
    func muestraMenu(){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let tomaFotoAction = UIAlertAction(title: "Toma Foto", style: .default) { _ in
            self.muestraCamara()
        }
        let seleccionaLibreriaAction = UIAlertAction(title: "Selecciona de la Librería", style: .default) { _ in
            self.muestraLibreriaFotos()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(tomaFotoAction)
        alertVC.addAction(seleccionaLibreriaAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func muestraCamara(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func muestraLibreriaFotos(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageData = info[UIImagePickerControllerOriginalImage] as? UIImage{
            myImageGame.image = imageData
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
