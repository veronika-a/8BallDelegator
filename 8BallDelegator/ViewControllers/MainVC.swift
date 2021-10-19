//
//  MainVC.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit

class MainVC: UIViewController {
    let networkService = NetworkService()
    
    @IBOutlet weak var answer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeAppearance()
    }
    
    func changeAppearance(){
        let appearance = UserDefaults.standard.bool(forKey: "appearance")
        
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            UIView.transition (with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = appearance ? .light : .dark
                } else {
                    // Fallback on earlier versions
                }
            }, completion: nil)
        }
    }
    
    public func errorMessage(error: String){
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func toSettings(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Settings") as? SettingsVC else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getAnswer(){
        networkService.getAnswer(question: "How do I know this is real magic?") { [weak self] result in
            switch result {
            case .success(let success):
                guard let success = success, let value = success.magic else {return}
                print(success)
                DispatchQueue.main.async {
                    self?.answer.text = value.answer ?? ""
                }
            case .failure(let error):
                switch error {
                case .networkError(let error):
                    self?.errorMessage(error: error)
                default:
                    self?.errorMessage(error: "\(error.localizedDescription)")
                    print(error)
                }
            }
        }
    }
    
    @IBAction func shake(_ sender: Any) {
        getAnswer()
    }
    
    //MARK: - IBAction
    @IBAction func settings(_ sender: Any) {
        toSettings()
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            getAnswer()
        }
    }
}

