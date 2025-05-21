//
//  Repository.swift
//  fbAuth
//
//  Created by shankar singh on 21/05/2025.
//

import Foundation
import FirebaseFirestore

class Repository{
    
    var db = Firestore.firestore()
    
    func addUser(withData user: User, completion: @escaping (Bool) -> Void) {
        let dictionary: [String: Any] = [
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "address": user.address,
            "photo": user.photo
        ]

        db.collection("User").document(user.id).setData(dictionary) { error in
            if let error = error {
                print("Error adding user: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User added: \(user.email)")
                completion(true)
            }
        }
    }
    
    func updateUser(withData user: User, completion: @escaping (Bool) -> Void) {
        let dictionary: [String: Any] = [
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "address": user.address,
            "photo": user.photo
        ]
        
        db.collection("User").document(user.id).updateData(dictionary) { error in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User updated successfully")
                completion(true)
            }
        }
    }

    
    func findUserInfo(for userId: String, completion: @escaping (User?) -> ()) {
        let userRef = db.collection("User").document(userId)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user info: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("User document does not exist")
                completion(nil) //  Important
                return
            }

            let user = User(id: document.documentID, dictionary: data)
            completion(user)
        }
    }

}

