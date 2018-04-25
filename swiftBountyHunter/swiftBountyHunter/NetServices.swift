//
//  NetServices.swift
//  swiftBountyHunter
//
//  Created by DW on 14/11/16.
//  Copyright © 2016 DW. All rights reserved.
//

import Foundation

class NetServices
{
    //Consantes de conectividad
    let urlfugitivos = "http://201.168.207.210/Services/droidBHServices.svc/fugitivos"
    let urlatrapadosx = "http://201.168.207.210/Services/droidBHServices.svc/atrapados"
    
    //Método para la obtención de fugitivos
    func connectGET(completado:@escaping (_ error:Int)->Void)
    {
        //Configuración default para establecer sesión
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        //Definición y obtención de la tarea con un hilo secundario.
        let dataTask = session.dataTask(with: URL(string: urlfugitivos)!,
            completionHandler:
            {
                //Closure
                data, urlReponse, error in
                var dialogError:Int = 0
                if data != nil
                {
                    
                    do{
                        //Procesamiento del JSON
                        let fugitivosJSON:Any? = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let fugitivos:NSArray = fugitivosJSON as! NSArray
                        let dbFugitivos:DBProvider = DBProvider(crear: false)
                        //Recorrido e inserción de los fugitivos
                        for cnt in 0 ..< fugitivos.count
                        {
                            let fugitivo = fugitivos[cnt]
                            let nombre:Dictionary<String,String> = fugitivo as! Dictionary<String, String>
                            dbFugitivos.insertarFugitivo(nombre: nombre["name"]!)
                        }
                    }
                    catch
                    {
                        //Error de conversión (datos)
                        dialogError = 1
                    }
                    
                }
                else
                {
                    //Error de conectividad (red)
                    dialogError = 1
                }
                completado(dialogError)
        }
        )
        //Ejecución de la tarea
        dataTask.resume()
    }
    
    //Método para saber cuantos fugitivos se han capturado con el dispositivo
    func connectPOST(udid:String, completado: @escaping (_ error:Int, _ mensaje:String?)->Void)
    {
        //Parametro que se enviará al servicio
        let diccionario:NSDictionary = NSDictionary(dictionary: ["UDIDString" : "\(udid)"])
        let parametrosData = try! JSONSerialization.data(withJSONObject: diccionario, options: JSONSerialization.WritingOptions(rawValue: 0))
        let parametros = String(data: parametrosData, encoding: String.Encoding.utf8)
        //Configuración default para establecer sesión
        let configuración = URLSessionConfiguration.default
        let sesion = URLSession(configuration: configuración)
        //Configuración del request
        var request = URLRequest(url: URL(string: urlatrapadosx)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parametros!.data(using: String.Encoding.utf8)
        let dataTask = sesion.dataTask(with: request,
            completionHandler:
            {
                data, urlReponse, error in
                var msg:String?
                var dialogError:Int = 0
                if data != nil
                {
                    do{
                        //Procesamiento de la respuesta en JSON y obtención del mensaje
                        let mensajeJSON:Any? = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let mensaje:Dictionary<String, String> = mensajeJSON as! Dictionary<String, String>
                        print(mensaje["mensaje"]!)
                        msg = String(mensaje["mensaje"]!)
                    }
                    catch
                    {
                        //Error de conversión (datos)
                        dialogError = 1
                    }
                    
                }
                else
                {
                    //Error de conectividad (red)
                    dialogError = 1
                }
                completado(dialogError, msg)
            }
        )
        //Ejecución de la tarea
        dataTask.resume()
    }
}
