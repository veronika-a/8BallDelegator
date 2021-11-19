//
//  SettingsViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit

class SettingsViewController: UIViewController {

    var settingsViewModel: SettingsViewModel?
    var cells: [SettingsCell] = []
    lazy var tableView = UITableView()

    required init?(settingsViewModel: SettingsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.settingsViewModel = settingsViewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        loadCells()
    }

    func loadCells() {
        cells.append(SettingsCell(cellType: .appearance, img: UIImage(named: "Appearance"), labelText: L10n.appearance))
    }

    func selectRow(index: Int) {
        guard index < cells.count else { return }
        let cell = cells[index]
        switch cell.cellType {
        case .appearance:
            changeAppearance()
        default:
            break
        }
    }

    func changeAppearance() {
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

    func toMain() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - IBAction
    @IBAction func back(_ sender: Any) {
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

extension SettingsViewController {
    func createView() {
        view.backgroundColor = Asset.Colors.mainBackground.color
        let backButton = createNavigationButton(isRight: false, image: Asset.Assets.backArrow.image)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        let tableView = createSettingsTableView()
        tableView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(12)
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.left.bottom.equalTo(view.safeAreaLayoutGuide)
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

class SettingsTableViewCell: UITableViewCell {
    var iconImageView: UIImageView!
    var typeLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }

    func configure() {
        self.backgroundColor = Asset.Colors.mainBackground.color
        self.selectionStyle = .none
        iconImageView = UIImageView()
        self.contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.height.width.equalTo(24)
            $0.centerY.equalToSuperview()
        }

        typeLabel = UILabel(frame: .zero)
        typeLabel.font = typeLabel.font.withSize(15)
        self.contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(12)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
