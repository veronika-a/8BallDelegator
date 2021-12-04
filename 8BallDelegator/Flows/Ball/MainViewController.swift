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
    private var ball: UIView?
    private var newAnswer: Bool = false
    private var timer: Timer?
    private var timerTime: Double?

    required init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
      }

    required init(coder: NSCoder) {
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
        let settingsVC = SettingsViewController(settingsViewModel: settingsViewModel)
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    private func getAnswer() {
        animationWaitAnswer(targetView: self.ball!, withDuration: 3)
        counterLabel.text = mainViewModel.updateAndReturnCounter()
        mainViewModel.getAnswer(currentAnswer: presentableMagicAnswer?.answer, completion: { [weak self] result in
            switch result {
            case .success(let success):
                guard let presentableMagicAnswer = success else {return}
                DispatchQueue.main.async {
                    self?.presentableMagicAnswer = presentableMagicAnswer
                    self?.newAnswer = true
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

    func updateAnswer(answer: PresentableMagicAnswer) {
        answerLabel.text = answer.answer ?? ""
        answerLabel.textColor = answer.color?.color
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
    func animationWaitAnswer(targetView: UIView, withDuration: Double) {
        self.newAnswer = false
        startOtpTimer(totalTime: withDuration)
        animationBall(targetView: targetView, withDuration: withDuration)
    }

    func animationBall(targetView: UIView, withDuration: Double) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) {
            targetView.transform = targetView.transform.rotated(by: CGFloat(Float.pi))
        } completion: { _ in
            guard let time = self.timerTime else {return}
            print("time:\(time) newAnswer: \(self.newAnswer)")
            if (time <= 2 && self.newAnswer) || time == 0 {
                print("animationWhileWaitAnswer stop")
                self.stopTimer()
                if let answer = self.presentableMagicAnswer {
                    self.updateAnswer(answer: answer)
                }
            } else {
                print("animationWhileWaitAnswer continue")
                self.animationBall(targetView: targetView, withDuration: withDuration)
            }
        }
    }

    func startOtpTimer(totalTime: Double) {
        timerTime = totalTime + 2
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true)
    }

    @objc func updateTimer() {
        if timerTime ?? 0 > 0 {
            timerTime? -= 1
        } else {
            stopTimer()
        }
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

private extension MainViewController {
    func createView() {
        addCounterLabel()
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
        self.ball = ball

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
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(answerLabel).inset(48)
        }
    }

    func addCounterLabel() {
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
        ball.startColor = Asset.Colors.whiteOnly.color
        ball.endColor = Asset.Colors.ballBackground.color
        ball.cornerRadius = 125
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
