//
//  AcercaDeViewController.swift
//  swiftBountyHunter
//
//  Created by DW on 07/11/16.
//  Copyright © 2016 DW. All rights reserved.
//

import UIKit

class AcercaDeViewController: UIViewController {

    @IBOutlet weak var labelContador: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    //Variable para obtener el temporalmente el valor del archivo plist
    var udefault:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Se obtiene una instancia del UserDefaults
        let userdefault = UserDefaults.standard
        //Se obtiene y se evalua si existe la llave sliderValue
        if let def = userdefault.string(forKey: "sliderValue")
        {
            udefault = String(def)
            slider.setValue(Float(udefault)!, animated: true)
            labelContador.text = udefault
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider)
    {
        let currentValue = Int(sender.value)
        labelContador.text = "\(currentValue)"
        //Se obtiene una instancia del UserDefaults
        let userdefault = UserDefaults.standard
        userdefault.set(currentValue, forKey: "sliderValue")
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


