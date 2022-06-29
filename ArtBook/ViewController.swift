//
//  ViewController.swift
//  ArtBook
//
//  Created by busraguler on 9.06.2022.
//

import UIKit
import CoreData
class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData() //uygulama açıldığında tableview'i güncel görmek için getdatanın çağrılması
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //newdata mesajını görünce getdata metodunu çağırıcak.
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "NewData"), object: nil)
    }
    @objc func getData(){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false) // Arrayleri temizliyor.Yeni veri eklendiğinde birden fazla görünmemesi için
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //appdelegate içinde coredata kısmı var (context) ulaşmak için
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")  //paintings'den  verileri getir.
        fetchRequest.returnsObjectsAsFaults = false  //cache'den verileri okuma// false olduğunda daha hızlı ve verimlidir.
        
        do {
             let results = try context.fetch(fetchRequest) //geri döndürdüğü şey bir dizi, birden fazla değeri diziye kaydedicek // do try-catch içerisinde olmalı ve bir değişkene atanmalı.
            for result in results as! [NSManagedObject]{ //coredata model objesi olarak verileri tek tek inceleyebilmek için nsmanageobject'e cast edilmeli
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
                self.tableView.reloadData() //tableview'a yeni data geldi kendini güncelle
            }
        }catch{
            print("hata var")
        }

    }
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "ToDetailVC", sender: nil) // segue işlemi view controllerdan detailviewcontroller' a geçiş
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // tableview kaç satır olacağı
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row] //table view satır içerikleri
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "ToDetailVC", sender: nil) //detailviewcontroller'a git ve
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{ //editingstyle silme işlemi ise
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString //tıklanılan satırın idsini getiricek
            
            fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row]{ //
                                
                                context.delete(result) //result =id silme işlemi
                                nameArray.remove(at: indexPath.row) //silinen isim ve id'yi arrayden silme
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()  //tableview'deki dataları güncelle
                                
                                
                                do{
                                    try context.save() //güncellemeden sonra kaydetme işlemi
                                    
                                }catch{
                                    print("hata")
                                }
                                
                                break  //foorlooptan çıkma
                            }
                        }
                    }
                            
                }
                
            }catch{
                
            }
                
        }
        
    }
}

