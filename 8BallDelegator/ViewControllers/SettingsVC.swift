//
//  SettingsVC.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import UIKit

class SettingsVC: UIViewController {

    var cells: [SettingsCell] = []

    struct SettingsCell {
        var cellType: CellType?
        var img: UIImage?
        var labelText: String?
    }
    enum CellType {
        case contactSupport
        case appearance
    }

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
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
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
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

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
}
