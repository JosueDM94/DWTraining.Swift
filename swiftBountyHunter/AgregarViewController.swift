//
//  AgregarViewController.swift
//  swiftBountyHunter
//
//  Created by DW on 07/11/16.
//  Copyright © 2016 DW. All rights reserved.
//

import UIKit

class AgregarViewController: UIViewController {

    @IBOutlet weak var textFieldNombre: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        //Se coloca para obtener el foco en el UITextField
        textFieldNombre.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Evento de cambio en la caja de texto
    @IBAction func checkLength(_ sender: UITextField)
    {
        checkMaxLength(textField: sender, maxLength: 25)
    }
    
    //Método para evaluar el tamaño de la cadena
    func checkMaxLength(textField: UITextField!, maxLength: Int)
    {
        if textField.text!.count > maxLength
        {
            textField.deleteBackward()
        }
    }
    
    @IBAction func tabAgregar()
    {
        let dbFugitivos = DBProvider(crear: false)
        if !textFieldNombre.text!.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty
        {
            dbFugitivos.insertarFugitivo(nombre: textFieldNombre.text!.trimmingCharacters(in: NSCharacterSet.whitespaces))
            self.performSegue(withIdentifier: "Agregar", sender: self)
        }
        else
        {
            let alerta = UIAlertController(title: "Warning", message: "Debe agregar un fugitivo", preferredStyle: UIAlertControllerStyle.alert)
            alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {
                okPulso in print("Pulso el botón Ok")
            }))
            self.present(alerta, animated: true, completion: {
                self.textFieldNombre.text = ""
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
