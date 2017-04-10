//
//  iRGameListViewController.swift
//  iRullo
//
//  Created by jorgemoniz on 3/4/17.
//  Copyright © 2017 Jorge Moñiz. All rights reserved.
//

import UIKit
import CoreData

class iRGameListViewController: UIViewController {
    
    //MARK: - Variables locales
    var manageContext : NSManagedObjectContext!
    var listGame = [Game]()
    
    //MARK: - IBOutlets
    @IBOutlet weak var myFilterSegmentCon: UISegmentedControl!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    //MARK: - IBActions
    @IBAction func myShowFilterACTION(_ sender: Any) {
        performGamesQuery()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.alwaysBounceVertical = true

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performGamesQuery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGameSegue" {
            let navVC = segue.destination as! UINavigationController
            let detalleVC = navVC.topViewController as! iRAddNewGameViewController
            detalleVC.manageContext = manageContext
            detalleVC.iRDelegate = self
        }
        
        if segue.identifier == "editGameSegue" {
            let detalleVC = segue.destination as! iRAddNewGameViewController
            
            //Tengo que poder hacer un push cuando toco
            let selectIndex = myCollectionView.indexPathsForSelectedItems?.first?.row
            let gameInd = listGame[selectIndex!]
            detalleVC.game = gameInd
            detalleVC.iRDelegate = self
        }

    }
    
    //MARK: - Utils
    func formatColors(_ myString : String, myColor : UIColor) -> NSMutableAttributedString {
        //1 -> longitud del String
        let length = myString.characters.count
        //2 -> posición de los ':'
        let colonPosition = myString.indexOf(":")!
        //3 -> creamos la instancia de NSMutableAttributedString
        let myMutableString = NSMutableAttributedString(string: myString, attributes: nil)
        
        myMutableString.addAttribute(NSForegroundColorAttributeName,
                                     value: myColor,
                                     range: NSRange(location: 0,
                                                    length: length))
        
        //lo mismo más un carácter, para que sea después de los puntos
        myMutableString.addAttribute(NSForegroundColorAttributeName,
                                     value: UIColor.black,
                                     range: NSRange(location: 0,
                                                    length: colonPosition + 1))
        return myMutableString
    }
 
    //MARK: - Consulta a CoreData
    func performGamesQuery() {
        
        //1 -> request
        let customRequest : NSFetchRequest<Game> = Game.fetchRequest()
        
        //2 -> sortBy
        let sortByDate = NSSortDescriptor(key: "dateCreated", ascending: false)
        
        //3
        customRequest.sortDescriptors = [sortByDate]
        
        //4
        if myFilterSegmentCon.selectedSegmentIndex == 0 {
            let customPredicate = NSPredicate(format: "borrowed = true")
            customRequest.predicate = customPredicate
        }
        
        //5
        do {
            let fetchGames = try manageContext.fetch(customRequest)
            listGame = fetchGames
            self.myCollectionView.reloadData()
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }

} //TODO: - fin de de la clase

extension iRGameListViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if listGame.count == 0 {
            let imageBackgroundList = UIImageView(image: #imageLiteral(resourceName: "img_empty_list"))
            imageBackgroundList.contentMode = .scaleAspectFit
            myCollectionView.backgroundView = imageBackgroundList
            
        } else {
            myCollectionView.backgroundView = UIView()
        }
        return listGame.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let customCell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! iRCustomCell
        
        let gameModel = listGame[indexPath.row]
        customCell.myTituloGame.text = gameModel.title
        
        //Definimos los colores
        var myColorPrestado = CONSTANTES.COLORES.GAME_NO_PRESTADO
        
        if !gameModel.borrowed {
            myColorPrestado = CONSTANTES.COLORES.GAME_PRESTADO
        }
        
        //operador ternario, si la condición se cumple pinta un SI, si no NO
        customCell.myBorrowedGame.attributedText = formatColors("PRESTADO: \(gameModel.borrowed ? "SI": "NO")", myColor: myColorPrestado)
        
        if let borrowedTo = gameModel.borrowedTo {
            customCell.myBorrowedToGame.attributedText = formatColors("A: \(borrowedTo)", myColor: myColorPrestado)
        } else {
            customCell.myBorrowedToGame.attributedText = formatColors("A: --", myColor: myColorPrestado)
        }
        
        //Casteamos la fecha
        if let borrowedDate = gameModel.borrowedDate as Date? {
           let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "dd/MM/yyyy"
            myDateFormatter.string(from: borrowedDate)
            customCell.myBorrowedDateGame.attributedText = formatColors("FECHA: \(myDateFormatter.string(from: borrowedDate))", myColor: myColorPrestado)
        } else {
            customCell.myBorrowedDateGame.attributedText = formatColors("FECHA: --", myColor: myColorPrestado)
        }
        
        customCell.myImageGame.image = UIImage(data: (gameModel.image as Data?)!)
        
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editGameSegue", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        if (offsetY < -120) {
            performSegue(withIdentifier: "addGameSegue", sender: self)
        }
    }
    
}

extension String {
    func indexOf(_ myTarget : String) -> Int? {
        if let myRange = self.range(of: myTarget) {
            return distance(from: self.startIndex, to: myRange.lowerBound)
        }
        return nil
    }
}

//Collection View Delegate de la segunda lista - Recarga tabla
extension iRGameListViewController : iRAddNewGameViewControllerDelegate {
    func didAddGame() {
        myCollectionView.reloadData()
    }
}
