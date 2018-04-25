//
//  DBProvider.swift
//  swiftBountyHunter
//
//  Created by DW on 09/11/16.
//  Copyright © 2016 DW. All rights reserved.
//

import Foundation

class DBProvider{
    
    //Apuntador de la base de datos
    var db:OpaquePointer? = nil
    //Variable para capturar los errores provenientes de la base de datos
    var error:String? = nil
    
    //Definición de constantes para el manejo y gestión de la base de datos
    let DATA_BASE_NAME = "swiftBH.sqlite"
    let DATA_TABLE_NAME = "Fugitivos"
    let DATA_TABLE_LOG = "LogFugitivos"
    let COLUMN_NAME_ID = "id"
    let COLUMN_NAME_NAME = "nombre"
    let COLUMN_NAME_STATUS = "estatus"
    
    init(crear: Bool)
    {
        //Se evaluará si se creará la base de datos si es false retornará sin crear la base de datos
        if !crear
        {
            return
        }
        //Se inicializa la base de datos esperando que no ocurra un error
        if dbCreate()
        {
            //Se ejecuta la sentencia DDL de creación de la tabla
            if !createDDL()
            {
                print("DBProvider:init() --> Error devuelto por el método createDDL()")
            }
            
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:init() --> Error devuelto por el método dbClose()")
            }
        }
    }

    //método para la creación o apertura de la base de datos
    func dbCreate() -> Bool
    {
        //Se obtiene el path del sandbox de la apliación (carpeta de  documentos)
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        //Se adjunta al path el nombre del archivo de la base de datos
        let fileURI = documents.appendingPathComponent("\(DATA_BASE_NAME)")
        
        //Se imprime la ruta en la que se guardará la base de datos.
        print(fileURI)
        
        //Se crea la base de datos y si ya existe solamente la abre
        if sqlite3_open(fileURI.path, &db) != SQLITE_OK
        {
            print("DBProvider:dbInitial() --> Error al tratar de crear/abrir la base de datos")
            return false
        }
        return true
    }
    
    
    //Método para cerrar la base de datos
    func dbClose() -> Bool
    {
        //Se cierra la base de datos
        if sqlite3_close(db) != SQLITE_OK
        {
            print("DBProvider:dbClose() --> Error al cerrar la base de datos")
            return false
        }
        return true
    }
    
    //Método para la creación de la tabla Fugitivos
    func createDDL() -> Bool
    {
        //Se ejecuta la sentencia de creación de la tabla
        if sqlite3_exec(db, "create table if not exists \(DATA_TABLE_NAME) (\(COLUMN_NAME_ID) integer primary key autoincrement, \(COLUMN_NAME_NAME) text, \(COLUMN_NAME_STATUS) integer)", nil, nil, nil) != SQLITE_OK
        {
            error = String(cString: sqlite3_errmsg(db))
            print("DBProvider:createDDL() --> Error creando la tabla fugitivos: \(error!)")
            error = nil
            return false
        }
        //Se ejecuta la sentencia de creación de la tabla
        if sqlite3_exec(db, "create table if not exists \(DATA_TABLE_LOG) (\(COLUMN_NAME_ID) integer primary key autoincrement, \(COLUMN_NAME_NAME) text, \(COLUMN_NAME_STATUS) integer)", nil, nil, nil) != SQLITE_OK
        {
            error = String(cString: sqlite3_errmsg(db))
            print("DBProvider:createDDL() --> Error creando la tabla LogFugitivos: \(error!)")
            error = nil
            return false
        }
        return true
    }
    
    //Método para insertar los fugitivos
    func insertarFugitivo(nombre: String)
    {
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia insert
            if sqlite3_prepare_v2(db, "insert into \(DATA_TABLE_NAME) (\(COLUMN_NAME_NAME), \(COLUMN_NAME_STATUS)) values (?, 0)", -1, &sentencia, nil) == SQLITE_OK
            {
                //Se adjunta la variable nombre a la sentencia insert
                if sqlite3_bind_text(sentencia, 1, "\(nombre)", -1, nil) == SQLITE_OK
                {
                    //Se ejecuta la sentencia insert
                    if sqlite3_step(sentencia) != SQLITE_DONE
                    {
                        error = String(cString: sqlite3_errmsg(db))
                    }
                }
                else
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:insertarFugitivos() --> Error en la creación/ejecución de la sentencia insert: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:insertarFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    //Método para insertar el log de los fugitivos eliminados
    func insertarLogFugitivo(pNombre: String,pStatus:String)
    {
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            
            //Se crea la sentencia insert
            if sqlite3_prepare_v2(db, "insert into \(DATA_TABLE_LOG) (\(COLUMN_NAME_NAME), \(COLUMN_NAME_STATUS)) values (?, \(pStatus))", -1, &sentencia, nil) == SQLITE_OK
            {
                //Se adjunta la variable nombre a la sentencia insert
                if sqlite3_bind_text(sentencia, 1, "\(pNombre)", -1, nil) == SQLITE_OK
                {
                    //Se ejecuta la sentencia insert
                    if sqlite3_step(sentencia) != SQLITE_DONE
                    {
                        error = String(cString: sqlite3_errmsg(db))
                    }
                }
                else
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:insertarLogFugitivos() --> Error en la creación/ejecución de la sentencia insert: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:insertarLogFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    //Método para actualizar el estatus del fugitivo
    func actualizarFugitivo(pID:String, pEstatus: String)
    {
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia update
            if sqlite3_prepare_v2(db, "update \(DATA_TABLE_NAME) set \(COLUMN_NAME_STATUS) = ? where \(COLUMN_NAME_ID) = ?", -1, &sentencia, nil) == SQLITE_OK
            {
                //Se adjunta la variable estatus para colocarlo como capturado
                if sqlite3_bind_int(sentencia, 1, Int32(pEstatus)!) == SQLITE_OK
                {
                    //Se adjunta la variable id para colocarlo en el where como filtro
                    if sqlite3_bind_int(sentencia, 2, Int32(pID)!) == SQLITE_OK
                    {
                        if sqlite3_step(sentencia) != SQLITE_DONE
                        {
                            error = String(cString: sqlite3_errmsg(db))
                        }
                    }
                    else{
                        error = String(cString: sqlite3_errmsg(db))
                    }
                }
                else
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:actualizarFugitivos() --> Error en la creación/ejecución de la sentencia update: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:actualizarFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    //Método para eliminar el fugitivo
    func eliminarFugitivo(pID:String)
    {
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia delete
            if sqlite3_prepare_v2(db, "delete from \(DATA_TABLE_NAME) where \(COLUMN_NAME_ID) = ?", -1, &sentencia, nil) == SQLITE_OK
            {
                //Se adjunta la variable id para colocarlo en el where como filtro
                if sqlite3_bind_int(sentencia, 1, Int32(pID)!) == SQLITE_OK
                {
                    if sqlite3_step(sentencia) != SQLITE_DONE
                    {
                        error = String(cString: sqlite3_errmsg(db))
                    }
                }
                else
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:eliminarFugitivos() --> Error en la creación/ejecución de la sentencia delete: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:eliminarFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    //Método para obtener un fugitivo
    func obtenerFugitivo(pID:String) -> Array<Array<String>>
    {
        var datosFugitivos = Array<Array<String>>()
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia select
            if sqlite3_prepare_v2(db, "select * from \(DATA_TABLE_NAME) where \(COLUMN_NAME_ID) = ?", -1, &sentencia, nil) == SQLITE_OK
            {
                //Se adjunta la variable estatus para colocarlo en el where como filtro
                if sqlite3_bind_int(sentencia, 1, Int32(pID)!) == SQLITE_OK
                {
                    //Ejecución de la sentencia por row y obtención de la información
                    while sqlite3_step(sentencia) == SQLITE_ROW
                    {
                        let nombre = String(cString: sqlite3_column_text(sentencia, 1))
                        let status = String(sqlite3_column_int(sentencia, 2))
                        datosFugitivos.append(Array(arrayLiteral: nombre, status))
                    }
                }
                else
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:obtenerFugitivo() --> Error en la creación/ejecución de la sentencia select: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:obtenerFugitivo() --> Error devuelto por el método dbClose()")
            }
        }
        return datosFugitivos
    }

    //Método para obtener los fugitivos
    func obtenerFugitivos(pEstatus:String) -> Array<Array<String>>
    {
        var datosFugitivos = Array<Array<String>>()
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia select
            if sqlite3_prepare_v2(db, "select * from \(DATA_TABLE_NAME) where \(COLUMN_NAME_STATUS) = ?", -1, &sentencia, nil) == SQLITE_OK
            {
                //Se adjunta la variable estatus para colocarlo en el where como filtro
                if sqlite3_bind_int(sentencia, 1, Int32(pEstatus)!) == SQLITE_OK
                {
                    //Ejecución de la sentencia por row y obtención de la información
                    while sqlite3_step(sentencia) == SQLITE_ROW
                    {
                        let id = String(sqlite3_column_int(sentencia, 0))
                        let nombre = String(cString: sqlite3_column_text(sentencia, 1))
                        datosFugitivos.append(Array(arrayLiteral: id, nombre))
                    }
                }
                else
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:obtenerFugitivos() --> Error en la creación/ejecución de la sentencia select: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:obtenerFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
        return datosFugitivos
    }
    
    //Método para obtener los eliminados
    func obtenerEliminados() -> Array<Array<String>>
    {
        var datosFugitivos = Array<Array<String>>()
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia select
            if sqlite3_prepare_v2(db, "select * from \(DATA_TABLE_LOG)", -1, &sentencia, nil) == SQLITE_OK
            {
                    //Ejecución de la sentencia por row y obtención de la información
                    while sqlite3_step(sentencia) == SQLITE_ROW
                    {
                        let nombre = String(cString: sqlite3_column_text(sentencia, 1))
                        let status = String(sqlite3_column_int(sentencia, 2))
                        datosFugitivos.append(Array(arrayLiteral: nombre, status))
                    }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:obtenerFugitivos() --> Error en la creación/ejecución de la sentencia select: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvider:obtenerFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
        return datosFugitivos
    }
    
    //Método para obtener la cantidad de fugitivos en la base de datos
    func contarFugitivos() -> Int
    {
        var dato:Int?
        //Se realiza la apertura de la base de datos
        if dbCreate()
        {
            //Se crea el apuntador para la sentencia
            var sentencia:OpaquePointer? = nil
            //Se crea la sentencia select
            if sqlite3_prepare_v2(db, "select count(*) from \(DATA_TABLE_NAME)", -1, &sentencia, nil) == SQLITE_OK
            {
                //Ejecución de la sentencia y se obtiene el row
                if sqlite3_step(sentencia) == SQLITE_ROW
                {
                    let id = sqlite3_column_int(sentencia, 0)
                    dato = Int(id)
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK
                {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else
            {
                error = String(cString: sqlite3_errmsg(db))
            }
            //Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory"
            {
                print("DBProvider:contarFugitivos() --> Error en la creación/ejecución de la sentencia select: \(error!)")
                error = nil
            }
            //Se cierra la base de datos
            if !dbClose()
            {
                print("DBProvicer:contarFugitivos() --> Error devuelto por el método dbClsoe()")
            }
        }
        return dato!
    }

    
}


