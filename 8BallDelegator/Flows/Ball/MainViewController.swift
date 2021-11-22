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

    private var answerLabel = UILabel()
    private let mainViewModel: MainViewModel
    private var presentableMagicAnswer: PresentableMagicAnswer?
    private var counterLabel = UILabel()

    required init?(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
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

    private func errorMessage(error: String) {
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
        guard let settingsVC = SettingsViewController(settingsViewModel: settingsViewModel) else {return}
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    private func getAnswer() {
        counterLabel.text = mainViewModel.updateCounter()
        mainViewModel.getAnswer(currentAnswer: presentableMagicAnswer?.answer, completion: { [weak self] result in
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
    @objc func settings() {
        toSettings()
    }

    @IBAction func getAnswerWithoutShake(_ sender: Any) {
        getAnswer()
    }
}

private extension MainViewController {
    func createView() {
        view.backgroundColor = Asset.Colors.mainBackground.color
        let navigationView = NavigationView()
        navigationView.createNavigationButton(isRight: true, image: Asset.Assets.settings.image, action: settings)
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { (make) -> Void in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
        }

        let ball = createEightBall()
        let needAnswerLabel = UILabel()
        needAnswerLabel.text = "NEED SOME ANSWERS?"
        needAnswerLabel.textColor = Asset.Colors.titles.color
        needAnswerLabel.textAlignment = .center
        needAnswerLabel.font = needAnswerLabel.font.withSize(17)
        view.addSubview(needAnswerLabel)
        needAnswerLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ball.snp.bottom).offset(48)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
        }

        answerLabel = UILabel()
        answerLabel.text = ""
        answerLabel.textColor = Asset.Colors.titles.color
        answerLabel.textAlignment = .center
        answerLabel.font = answerLabel.font.withSize(24)
        view.addSubview(answerLabel)
        answerLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(needAnswerLabel.snp.bottom).offset(48)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
        }

        let shakeButton = UIButton(type: .custom)
        shakeButton.addTarget(self, action: #selector(getAnswerWithoutShake), for: .touchUpInside)
        shakeButton.setTitle("Shake", for: .normal)
        shakeButton.titleLabel?.font = needAnswerLabel.font.withSize(17)
        shakeButton.setTitleColor(Asset.Colors.titles.color, for: .normal)
        view.addSubview(shakeButton)
        shakeButton.snp.makeConstraints { (make) -> Void in
            make.bottom.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.greaterThanOrEqualTo(answerLabel.snp.bottom).offset(24)
        }

        counterLabel = UILabel()
        counterLabel.text = "0"
        counterLabel.textColor = Asset.Colors.titles.color
        counterLabel.textAlignment = .center
        counterLabel.font = counterLabel.font.withSize(24)
        view.addSubview(counterLabel)
        counterLabel.snp.makeConstraints { (make) -> Void in
            make.left.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    func createEightBall() -> UIView {
        let ball = CornerRadiusView()
        ball.cornerRadius = 125
        ball.borderColor = Asset.Colors.whiteOnly.color
        ball.borderWidth = 1
        ball.backgroundColor = Asset.Colors.ballBackground.color
        view.addSubview(ball)
        let ballHight: CGFloat = 250
        ball.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(ballHight)
            make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-100)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }

        let smallBall = CornerRadiusView()
        smallBall.cornerRadius = ball.cornerRadius / 2
        smallBall.backgroundColor = Asset.Colors.whiteOnly.color
        ball.addSubview(smallBall)
        smallBall.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(ballHight/2)
            make.center.equalTo(ball)
        }

        let eight = UILabel()
        eight.text = "8"
        eight.textColor = Asset.Colors.accentColor.color
        eight.font = eight.font.withSize(52)
        smallBall.addSubview(eight)
        eight.snp.makeConstraints { (make) -> Void in
            make.centerX.centerY.equalToSuperview()
        }
        return ball
    }
}
