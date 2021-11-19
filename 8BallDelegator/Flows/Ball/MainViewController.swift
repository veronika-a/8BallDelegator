//
//  MainViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit
import Foundation
import OSLog
import SnapKit

class MainViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    var mainViewModel: MainViewModel?
    var presentableMagicAnswer: PresentableMagicAnswer?

    required init?(mainViewModel: MainViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.mainViewModel = mainViewModel
      }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        changeAppearance()
        createView()
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
        let settingsModel = SettingsModel()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        guard let settingsVC = storyboard?.instantiateViewController(identifier: "Settings", creator: { coder in
            return SettingsViewController(coder: coder, settingsViewModel: settingsViewModel)
        }) else {return}
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

extension MainViewController {
    func createView() {
        view.backgroundColor = Asset.Colors.mainBackground.color

        let ball = CornerRadiusView()
        ball.cornerRadius = 125
        ball.borderColor = Asset.Colors.whiteOnly.color
        ball.borderWidth = 1
        ball.backgroundColor = Asset.Colors.ballBackground.color
        self.view.addSubview(ball)
        let ballHight: CGFloat = 250
        ball.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(ballHight)
            make.center.equalTo(self.view)
        }
        let smallBall = CornerRadiusView()
        smallBall.cornerRadius = ball.cornerRadius / 2
        smallBall.backgroundColor = Asset.Colors.whiteOnly.color
        ball.addSubview(smallBall)
        smallBall.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(ballHight/2)
            make.center.equalTo(ball)
        }
//        let eight = UILabel()
//        eight.textColor = Asset.Colors.accentColor.color
//        eight.font = eight.font.withSize(52)
//        eight.snp.makeConstraints { (make) -> Void in
//            make.center.equalTo(smallBall)
//        }
    }
}
