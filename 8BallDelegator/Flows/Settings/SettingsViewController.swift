//
//  SettingsViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit

class SettingsViewController: UIViewController {

    private let settingsViewModel: SettingsViewModel
    private var cells: [SettingsCell] = []
    private var tableView = UITableView()

    required init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        loadCells()
    }

    private func loadCells() {
        cells.append(SettingsCell(cellType: .appearance, img: UIImage(named: "Appearance"), labelText: L10n.appearance))
    }

    private func selectRow(index: Int) {
        guard index < cells.count else { return }
        let cell = cells[index]
        switch cell.cellType {
        case .appearance:
            changeAppearance()
        default:
            break
        }
    }

    private func changeAppearance() {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if #available(iOS 13.0, *) {
                    if window.overrideUserInterfaceStyle != .dark {
                        window.overrideUserInterfaceStyle = .dark
                        UserDefaults.standard.set(false, forKey: "appearance")
                    } else {
                        window.overrideUserInterfaceStyle = .light
                        UserDefaults.standard.set(true, forKey: "appearance")
                    }
                } else {
                    // Fallback on earlier versions
                }
            }, completion: nil)
        }
    }

    private func toMain() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - IBAction
    @objc func back() {
        toMain()
    }
}

// MARK: - TableView Delegates
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cells[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingsTableViewCell", for: indexPath)
                as? SettingsTableViewCell else { return UITableViewCell() }
        cell.typeLabel.text = cellType.labelText
        cell.iconImageView.image = cellType.img
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectRow(index: indexPath.row)
    }
}

private extension SettingsViewController {
    func createView() {
        view.backgroundColor = Asset.Colors.mainBackground.color
        let navigationView = NavigationView()
        navigationView.createNavigationButton(isRight: false, image: Asset.Assets.backArrow.image, action: back)
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { (make) -> Void in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
        }

        let tableView = createSettingsTableView()
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.left.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func createSettingsTableView() -> UITableView {
        tableView = UITableView(frame: .zero)
        tableView.backgroundColor = Asset.Colors.mainBackground.color
        self.view.addSubview(tableView)
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        return tableView
    }
}
