//
//  MainViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit
import Foundation
import OSLog

struct PresentableMagicAnswer {
    var answer: String?
    var color: ColorAsset?
    var selectionHandler: (() -> Void)?
}

class MainViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    var mainViewModel: MainViewModel?
    var presentableMagicAnswer: PresentableMagicAnswer?

    required init?(coder: NSCoder, mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        super.init(coder: coder)
      }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        changeAppearance()
    }

    private func changeAppearance() {
        let appearance = UserDefaults.standard.bool(forKey: "appearance")

        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = appearance ? .light : .dark
                } else {
                    // Fallback on earlier versions
                }
            }, completion: nil)
        }
    }

    public func errorMessage(error: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "\(error)",
            preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func toSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let settingsVC = storyboard.instantiateViewController(withIdentifier: "Settings")
                as? SettingsViewController else { return }
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    private func getAnswer() {
        mainViewModel?.getAnswer(currentAnswer: presentableMagicAnswer?.answer, completion: { [weak self] result in
            switch result {
            case .success(let success):
                guard let presentableMagicAnswer = success else {return}
                print(presentableMagicAnswer)
                DispatchQueue.main.async {
                    self?.answerLabel.text = presentableMagicAnswer.answer ?? ""
                    self?.answerLabel.textColor = presentableMagicAnswer.color?.color
                    self?.presentableMagicAnswer = presentableMagicAnswer
                }
            case .failure(let error):
                switch error {
                case .networkError(let networkError):
                    self?.errorMessage(error: networkError)
                    print(networkError)
                default:
                    print(error)
                }
            }
        })
    }

    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            getAnswer()
        }
    }

    // MARK: - IBAction
    @IBAction func settings(_ sender: Any) {
        toSettings()
    }

    @IBAction func getAnswerWithoutShake(_ sender: Any) {
        getAnswer()
    }
}
