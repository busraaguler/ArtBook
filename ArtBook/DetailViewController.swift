//
//  DetailViewController.swift
//  ArtBook
//
//  Created by busraguler on 9.06.2022.
//

import UIKit
import CoreData


class DetailViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString //id'yi string'e çevirme
            fetchRequest.predicate = NSPredicate(format: "id= %@",  idString!)
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameTextField.text = name
                        }
                        if let artistname = result.value(forKey: "artist") as? String{
                            artistTextField.text = artistname
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                            
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearTextField.text = String(year)
                        }
                        
                    }
                }
              }catch{
                    print("error")
                }

            
            fetchRequest.returnsObjectsAsFaults = false
        }
        else{
            saveButton.isHidden = false //save button gizli değil
            saveButton.isEnabled = false //save button tıklanılamıyor
            
        }

        // Do any additional setup after loading the view.
        imageView.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.addGestureRecognizer(imageRecognizer)
    }
    
    @objc func selectImage(){  // image in galeriden seçilmesi, zoom yapılabilir mi belirlenmesi
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {  // görsel seçldikten sonra  ne yapılacağı
        imageView.image = info[.originalImage] as? UIImage // görselin orijinal  hali
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil) //seçildikten sonra resmin kapanması için
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
   
    @IBAction func SaveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPaintings = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //NSEntity ile coredata ya , entitilere ulaşılabilir.
        //yeni bir obje oluşturuluyor
        
        //attributes
        //attributeları kaydetme
        newPaintings.setValue(nameTextField.text!, forKey: "name")
        newPaintings.setValue(artistTextField.text!, forKey: "artist")
        
        if let year = Int(yearTextField.text!){
            newPaintings.setValue(year, forKey: "year")
        }
        newPaintings.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5) //verinin ne kadarı küçültülsün
        newPaintings.setValue(data, forKey: "image")
        
        
        do{
            try context.save()  //veritabanına context'e kaydetme do try catch içeirisnde olmalı
            print("success")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
