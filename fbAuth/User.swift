//
//  User.swift
//  ecommerceApplication
//
//  Created by shankar singh on 29/03/2025.
//

import FirebaseFirestore

class User{
    var id : String!
    var name : String
    var email : String
    var phone : String
    var address : String
    var photo : String
    
    init(id : String, name : String, email : String, phone : String, address : String, photo : String){
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.photo = photo
    }
    
    convenience init(id : String, dictionary : [String: Any]){
        self.init(id: id,
                  name: dictionary["name"] as! String,
                  email: dictionary["email"] as! String,
                  phone: dictionary["phone"] as! String,
                  address: dictionary["address"] as! String,
                  photo: dictionary["photo"] as! String
        
        )
    }
    func toString() -> String{
        return "name : \(name)\n email : \(email)\n phone : \(phone)\n address : \(address)\n photo : \(photo)"
    }
    
    
}
