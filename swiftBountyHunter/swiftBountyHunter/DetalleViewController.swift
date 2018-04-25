//
//  DetalleViewController.swift
//  swiftBountyHunter
//
//  Created by DW on 07/11/16.
//  Copyright © 2016 DW. All rights reserved.
//

import UIKit

class DetalleViewController: UIViewController{
    
    var NombreFugitivo: String!
    var Estatus: String!
    var id:String!
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var labelMensaje: UILabel!
    @IBOutlet weak var btnCapturar: UIButton!
    @IBOutlet weak var btnEliminar: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Se colocará el titulo con el nombre
        NavigationBar.topItem!.title = "\(NombreFugitivo!) - [\(id!)]"
        //Se validará el estatus para colocar su respectivo mensaje dentro del label
        if Estatus == "0"
        {
            labelMensaje.text = "El fugitivo sigue suelto..."
        }
        else
        {
            btnCapturar.isHidden = true
            labelMensaje.text = "Atrapado!!!"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Acción de captura del fugitivo
    @IBAction func tabCapturar()
    {
        let dbFugitivos = DBProvider(crear: false)
        dbFugitivos.actualizarFugitivo(pID: id!, pEstatus: "1")
        
        let funcion = {
            (error:Int, mensaje:String?) in
            if error != 1
            {
                //Si no existe error se mostrará el mensaje proveniente del WebService
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Información", message: "\(mensaje!)", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler:
                        {okPulso in
                            self.performSegue(withIdentifier: "Capturar", sender: nil)
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
            else
            {
                //Si existe error se mostrará una alerta de error
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Error", message: "Error al consumir el WebService verbo POST", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler:
                        {okPulso in
                            self.performSegue(withIdentifier: "Capturar", sender: nil)
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
        }
        //Se realiza el consumo del servicio y se extrae el UUID del dispositivo.
        let ws:NetServices = NetServices()
        let udid = UIDevice.current.identifierForVendor?.uuidString
        ws.connectPOST(udid: udid!, completado: funcion)
        //Se ocultan los botones para evitar que se presionen varias ocasiones.
        btnCapturar.isHidden = true
        btnEliminar.isHidden = true
    }
    
    //Acción de eliminación del fugitivo
    @IBAction func tabEliminar()
    {
        let dbFugitivos = DBProvider(crear: false)
        dbFugitivos.eliminarFugitivo(pID: id!)
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
