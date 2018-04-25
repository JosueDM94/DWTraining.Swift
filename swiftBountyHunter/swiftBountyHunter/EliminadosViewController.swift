//
//  EliminadosViewController.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/24/18.
//  Copyright © 2018 DW. All rights reserved.
//

import UIKit

class EliminadosViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    //CellIdentifier
    let textCellIdentifier = "TextCell"
    //Matriz de fugitivos
    var swiftFugitivos: Array<Array<String>> = []
    //Variable de base de datos
    var dbFugitivos: DBProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dbFugitivos = DBProvider(crear: false)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        //Carga del listado de fugitivos
        cargarListadoEliminados()
        tableView.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(swiftFugitivos.count)
        return swiftFugitivos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier)! as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = swiftFugitivos[row][0]
        cell.detailTextLabel?.text = swiftFugitivos[row][1] == "0" ? "Fugitivo" : "Capturado"
        
        return cell
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //Método para cargar los datos de los fugitivos de la base de datos
    func cargarListadoEliminados()
    {
        swiftFugitivos.removeAll()
        swiftFugitivos = dbFugitivos!.obtenerEliminados()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
