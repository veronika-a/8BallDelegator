//
//  HistoryViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    private let viewModel: HistoryViewModel
    private var tableView = UITableView()
    private var presentableHistoryAnswers: [PresentableHistoryAnswer]?

    required init?(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        loadHistory()

    }

    override func viewWillAppear(_ animated: Bool) {
    }

    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell", for: indexPath)
                as? HistoryTableViewCell else { return UITableViewCell() }
        let obj = presentableHistoryAnswers?[indexPath.row]
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.typeLabel.text = "\(obj?.answer ?? "") \(dateFormatterGet.string(from: obj?.date ?? Date()))"
        return cell
    }

    func loadHistory() {
        self.viewModel.loadAnswerHistory { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    guard let success = success else {return}
                    self?.presentableHistoryAnswers = success
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func insertNewAnswer(index: IndexPath) {
        viewModel.getAnswer(indexPath: index) { [weak self] result in
            switch result {
            case .success(let success):
                guard let success = success else {return}
                self?.presentableHistoryAnswers?.insert(success, at: index.row)
                self?.tableView.insertRows(at: [index], with: .fade)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - TableView Delegates
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentableHistoryAnswers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell", for: indexPath)
                as? HistoryTableViewCell else { return UITableViewCell() }
        let obj = presentableHistoryAnswers?[indexPath.row]
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.typeLabel.text = "\(obj?.answer ?? "") \(dateFormatterGet.string(from: obj?.date ?? Date()))"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteAnswer(indexPath: indexPath)
        } else if editingStyle == .insert {
        }
    }
}

private extension HistoryViewController {
    func createView() {
        view.backgroundColor = Asset.Colors.mainBackground.color
        let tableView = createHistoryTableView()
        tableView.snp.makeConstraints {
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.left.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.bottom.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func createHistoryTableView() -> UITableView {
        tableView = UITableView(frame: .zero)
        tableView.backgroundColor = Asset.Colors.mainBackground.color
        self.view.addSubview(tableView)
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        return tableView
    }
}

extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
        at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertNewAnswer(index: indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                _ = configureCell(indexPath: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                presentableHistoryAnswers?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }
}
