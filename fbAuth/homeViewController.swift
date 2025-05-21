//
//  homeViewController.swift
//  fbAuth
//
//  Created by shankar singh on 19/05/2025.
//

import UIKit
import FirebaseAuth
import FacebookLogin // for logout

class homeViewController: UIViewController {
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var LogOutButton: UIButton!
    @IBOutlet weak var phonenumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirebaseUserInfo()
    }
    
    func loadFirebaseUserInfo() {
        guard let user = Auth.auth().currentUser else {
            nameLabel.text = "Not Logged In"
            emailLabel.text = ""
            phonenumberLabel.text = ""
            print("No user is logged in.")
            return
        }
        
        // Set labels
        nameLabel.text = user.displayName ?? "No Name"
        emailLabel.text = user.email ?? "No Email"
        phonenumberLabel.text = user.phoneNumber ?? "No Phone"
        
        // Print user info to console
        print("Firebase User Info:")
        print("- UID: \(user.uid)")
        print("- Name: \(user.displayName ?? "N/A")")
        print("- Email: \(user.email ?? "N/A")")
        print("- Phone: \(user.phoneNumber ?? "N/A")")
        print("- Photo URL: \(user.photoURL?.absoluteString ?? "N/A")")
        
        // Load profile image from URL and round it
        if let photoURL = user.photoURL {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: photoURL) {
                    DispatchQueue.main.async {
                        self.ProfileImageView.image = UIImage(data: data)
                        self.ProfileImageView.layer.cornerRadius = self.ProfileImageView.frame.size.width / 2
                        self.ProfileImageView.clipsToBounds = true
                        self.ProfileImageView.layer.borderWidth = 1
                        self.ProfileImageView.layer.borderColor = UIColor.gray.cgColor
                    }
                }
            }
        } else {
            ProfileImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
    @IBAction func logOutButtonDidPress(_ sender: Any) {
        // Shake animation for the button
        UIView.animate(withDuration: 0.1, animations: {
            self.LogOutButton.transform = CGAffineTransform(translationX: 5, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.LogOutButton.transform = CGAffineTransform(translationX: -5, y: 0)
            }) { _ in
                self.LogOutButton.transform = .identity
                
                // Show logout confirmation alert
                let alert = UIAlertController(title: "Logout",
                                              message: "Are you sure you want to log out?",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
                    do {
                        try Auth.auth().signOut()
                        LoginManager().logOut()
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController,
                           let window = self.view.window {
                            
                            // Animate transition with a flip effect
                            UIView.transition(with: window,
                                              duration: 0.5,
                                              options: .transitionFlipFromLeft,
                                              animations: {
                                window.rootViewController = loginVC
                            }, completion: nil)
                        }
                        
                    } catch let error {
                        print("Logout failed: \(error.localizedDescription)")
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
