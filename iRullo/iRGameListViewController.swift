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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.alwaysBounceVertical = true

        // Do any additional setup after loading the view.
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
        }
        
        if segue.identifier == "editGameSegue" {
            let detalleVC = segue.destination as! iRAddNewGameViewController
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
        
        let customCell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        
        
        
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
