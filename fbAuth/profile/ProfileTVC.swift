import UIKit
import FirebaseAuth
import UniformTypeIdentifiers

class ProfileTVC: UITableViewController {

    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtphoneNumber: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIBarButtonItem!

    let service = Repository()
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.isEnabled = false

        if let userAuthId = Auth.auth().currentUser?.uid {
            service.findUserInfo(for: userAuthId) { returnedUser in
                guard let returnedUser = returnedUser else { return }

                self.user = returnedUser
                DispatchQueue.main.async {
                    self.emailLabel.text = self.user.email
                    self.txtName.text = self.user.name
                    self.txtphoneNumber.text = self.user.phone
                    self.txtAddress.text = self.user.address
                    self.loadProfileImage(from: self.user.photo)
                    self.saveButton.isEnabled = true
                }
            }
        }
    }

    func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profilePhotoView.image = image
                    self.profilePhotoView.layer.cornerRadius = self.profilePhotoView.frame.width / 2
                    self.profilePhotoView.clipsToBounds = true
                }
            }
        }
    }

    func isDataValid() -> Bool {
        var invalidCount = 0

        if txtName.text.isBlank {
            txtName.showInvalidBorder()
            invalidCount += 1
        } else {
            txtName.removeInvalidBorder()
        }

        if txtphoneNumber.text.isBlank {
            txtphoneNumber.showInvalidBorder()
            invalidCount += 1
        } else {
            txtphoneNumber.removeInvalidBorder()
        }

        if invalidCount > 0 {
            showAlertMessage(tittle: "Validation", message: "Please input the required information")
            return false
        }
        return true
    }

    @IBAction func saveDidPressButton(_ sender: Any) {
        if isDataValid() {
            let updatedUser = User(
                id: user.id,
                name: txtName.text ?? "",
                email: emailLabel.text ?? "",
                phone: txtphoneNumber.text ?? "",
                address: txtAddress.text ?? "",
                photo: user.photo // ✅ keep the photo
            )

            service.updateUser(withData: updatedUser) { success in
                DispatchQueue.main.async {
                    let msg = success ? "Profile updated successfully." : "Failed to update profile."
                    self.showAlert(message: msg)
                }
            }
        }
    }

    @IBAction func logoutDidPressButton(_ sender: Any) {
        showConfirmationAlert(
            title: "Log Out",
            message: "Are you sure you want to logout?",
            okHandler: {
                do {
                    try Auth.auth().signOut()
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let signinVC = storyboard.instantiateViewController(withIdentifier: "ViewController")
                        sceneDelegate.window?.rootViewController = signinVC
                    }
                } catch {
                    self.showAlert(message: "Logout failed: \(error.localizedDescription)")
                }
            }
        )
    }
}
