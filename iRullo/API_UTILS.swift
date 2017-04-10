//
//  API_UTILS.swift
//  iRullo
//
//  Created by jorgemoniz on 3/4/17.
//  Copyright © 2017 Jorge Moñiz. All rights reserved.
//

import Foundation
import UIKit

let CONSTANTES = Constantes()

struct Constantes {
    let COLORES = Colores()
}

struct Colores {
    let GRIS_BARRA_NAV = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    let BLANCO_TEXTO_BARRA_NAV = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let GAME_NO_PRESTADO = #colorLiteral(red: 0.5215686275, green: 0.1098039216, blue: 0.05098039216, alpha: 1)
    let GAME_PRESTADO = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
}

func muestraAlertVC (_ titleData : String, messageData : String, titleActionData : String) -> UIAlertController {
    let alertVC = UIAlertController(title: titleData, message: messageData, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: titleActionData, style: .cancel, handler: nil))
    
    return alertVC
}
