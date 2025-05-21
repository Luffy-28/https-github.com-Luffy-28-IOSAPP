import UIKit
import FirebaseCore
import FirebaseAuth
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class ViewController: UIViewController {
    @IBOutlet weak var fbButton: UIButton!
    
    @IBOutlet weak var googleButton: UIButton!
    let repository = Repository()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Google Sign-In
    @IBAction func googleSignInTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing Firebase client ID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to get Google user token")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase login error: \(error.localizedDescription)")
                    return
                }

                if let firebaseUser = authResult?.user {
                    self.saveLoggedInUserToFirestore(firebaseUser)
                }
            }
        }
    }
    
    // MARK: - Facebook Sign-In

    @IBAction func facebookLoginTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print("Facebook login error: \(error.localizedDescription)")
                return
            }

            guard let result = result, !result.isCancelled,
                  let token = AccessToken.current else {
                print("Facebook login cancelled or failed")
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase login error: \(error.localizedDescription)")
                    return
                }

                if let firebaseUser = authResult?.user {
                    self.saveLoggedInUserToFirestore(firebaseUser)
                }
            }
        }
    }

    // MARK: - Save to Firestore using Repository
    func saveLoggedInUserToFirestore(_ firebaseUser: FirebaseAuth.User) {
        let uid = firebaseUser.uid

        repository.findUserInfo(for: uid) { existingUser in
            if let existingUser = existingUser {
                print("Found existing user: \(existingUser.toString())")
                
                // OPTIONAL: Update displayName/photo from FirebaseAuth if needed
                self.navigateToProfile(with: existingUser)
            } else {
                // If user does not exist, create one
                let name = firebaseUser.displayName ?? "No Name"
                let email = firebaseUser.email ?? "No Email"
                let phone = firebaseUser.phoneNumber ?? ""
                let address = ""
                let photo = firebaseUser.photoURL?.absoluteString ?? ""

                let newUser = User(id: uid, name: name, email: email, phone: phone, address: address, photo: photo)

                self.repository.addUser(withData: newUser) { success in
                    if success {
                        self.navigateToProfile(with: newUser)
                    }
                }
            }
        }
    }
    // MARK: - Navigation
    func navigateToProfile(with user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? UITabBarController {
            // Optional: pass user to Profile VC if needed
            self.view.window?.rootViewController = profileVC
            self.view.window?.makeKeyAndVisible()
        }
    }
}
