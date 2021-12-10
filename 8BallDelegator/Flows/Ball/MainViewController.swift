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
import SceneKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    private var answerLabel = UILabel()
    private var shakeButton = UIButton()
    private let mainViewModel: MainViewModel
    private var presentableMagicAnswer = BehaviorRelay<PresentableMagicAnswer>(value: PresentableMagicAnswer())
    private var counterLabel = UILabel()
    private var ball3D: SCNNode?
    private var newAnswer: Bool = false
    private var timer: Timer?
    private var timerTime: Double?
    private let value = BehaviorRelay<Int>(value: 0)
    private let disposeBag = DisposeBag()

    required init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
        mainViewModel
            .magicAnswer.map {$0.toPresentableMagicAnswer()}
            .bind(to: presentableMagicAnswer)
            .disposed(by: disposeBag)
        mainViewModel
            .magicAnswer
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.newAnswer = true
            })
            .disposed(by: disposeBag)
        presentableMagicAnswer
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.updateAnswer(answer: self.presentableMagicAnswer.value)
            }
            .disposed(by: disposeBag)
      }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        changeAppearance()
        create3D()
        createView()
        setupBindings()
    }

    private func setupBindings() {
        value
            .filter { $0 > 0 }
            .map(String.init)
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)

        shakeButton.rx.tap
            .withLatestFrom(value)
            .map { $0 + 1 }
            .bind(to: value)
            .disposed(by: disposeBag)
        shakeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.getAnswer()
            })
            .disposed(by: disposeBag)
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
        changeAppearance()
        animationWaitAnswer(withDuration: 3)
        mainViewModel.updateAndReturnCounter()
        mainViewModel.getAnswer(currentAnswer: presentableMagicAnswer.value.answer)
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
}

private extension MainViewController {
    func animationWaitAnswer(withDuration: Double) {
        self.newAnswer = false
        startOtpTimer(totalTime: withDuration)
        animationBall(withDuration: withDuration)
    }

    // MARK: - 2d animation
    func animationBall(targetView: UIView, withDuration: Double) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) {
            targetView.transform = targetView.transform.rotated(by: CGFloat(Float.pi))
        } completion: { _ in
            guard let time = self.timerTime else {return}
            print("time:\(time) newAnswer: \(self.newAnswer)")
            if (time <= 2 && self.newAnswer) || time == 0 {
                print("animationWhileWaitAnswer stop")
                self.stopTimer()
                self.updateAnswer(answer: self.presentableMagicAnswer.value)
            } else {
                print("animationWhileWaitAnswer continue")
                self.animationBall(targetView: targetView, withDuration: withDuration)
            }
        }
    }

    func animationBall(withDuration: Double) {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 2 * Float.pi))
        spin.duration = 1
        spin.repeatCount = 1
        self.ball3D?.addAnimation(spin, forKey: "spin around")
        UIView.transition(with: answerLabel, duration: 1, options: .transitionCrossDissolve, animations: {
            self.answerLabel.frame = self.answerLabel.frame.offsetBy(dx: -100, dy: -100)
            self.answerLabel.transform = self.answerLabel.transform.rotated(by: .pi)
            self.answerLabel.alpha -=  0.25
        }, completion: { _ in
            guard let time = self.timerTime else {return}
            print("time:\(time) newAnswer: \(self.newAnswer)")
            if (time <= 2 && self.newAnswer) || time == 0 {
                print("animationWhileWaitAnswer stop")
                self.stopTimer()
                self.updateAnswer(answer: self.presentableMagicAnswer.value)
                UIView.transition(
                    with: self.answerLabel,
                    duration: 1,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.answerLabel.frame = self.answerLabel.frame.offsetBy(dx: 100, dy: 100)
                        self.answerLabel.transform = self.answerLabel.transform.rotated(by: .pi)
                        self.answerLabel.alpha = 1
                    }, completion: nil)
            } else {
                print("animationWhileWaitAnswer continue")
                self.animationBall(withDuration: withDuration)
            }
        })
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

        let needAnswerLabel = UILabel()
        needAnswerLabel.text = "NEED SOME ANSWERS?"
        needAnswerLabel.textColor = Asset.Colors.titles.color
        needAnswerLabel.textAlignment = .center
        needAnswerLabel.font = needAnswerLabel.font.withSize(17)
        view.addSubview(needAnswerLabel)
        needAnswerLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(48)
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
        shakeButton.setTitle("Shake", for: .normal)
        shakeButton.titleLabel?.font = needAnswerLabel.font.withSize(17)
        shakeButton.setTitleColor(Asset.Colors.titles.color, for: .normal)
        view.addSubview(shakeButton)
        shakeButton.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(answerLabel).inset(48)
        }
        self.shakeButton = shakeButton
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

    func create3D() {
        let sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        let scene = SCNScene()
        sceneView.backgroundColor = Asset.Colors.mainBackground.color
        sceneView.scene = scene

        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 3.0)

        let light = SCNLight()
        light.type = SCNLight.LightType.directional
        light.spotInnerAngle = 30.0
        light.spotOuterAngle = 80.0
        light.castsShadow = true
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0.1, y: 0.5, z: 1.0)

        let sphereGeometry = SCNSphere(radius: 0.5)
        let sphereNode = SCNNode(geometry: sphereGeometry)

        let planeGeometry = SCNPlane(width: 50.0, height: 50.0)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = SCNVector3(x: 0, y: -1, z: 0)

        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = Asset.Assets.ball8Material.image
        sphereGeometry.materials = [sphereMaterial]

        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = Asset.Colors.ballBackground.color
        planeGeometry.materials = [planeMaterial]

        let constraint = SCNLookAtConstraint(target: sphereNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        lightNode.constraints = [constraint]

        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(sphereNode)
        scene.rootNode.addChildNode(planeNode)
        ball3D = sphereNode
    }

    // MARK: - 2d ball
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
        smallBall.cornerRadius = ballHight / 4
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
