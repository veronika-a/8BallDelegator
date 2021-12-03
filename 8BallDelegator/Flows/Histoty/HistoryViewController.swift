//
//  HistoryViewController.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 23.11.2021.
//

import UIKit

class HistoryViewController: UIViewController {

    private let viewModel: HistoryViewModel
    private var tableView = UITableView()
    private var presentableHistoryAnswers: [PresentableHistoryAnswer]?
    private let fetchedResultsController: FetchedResultsController<Ball>

    required init(viewModel: HistoryViewModel, fetchedResultsController: FetchedResultsController<Ball>) {
        self.viewModel = viewModel
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
        fetchedResultsController.delegate = self
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        loadHistory()
    }

    func configureCell(indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell", for: indexPath)
                as? HistoryTableViewCell else { return }
        viewModel.getAnswer(indexPath: indexPath) { [weak self] result in
            switch result {
            case .success(let success):
                guard let success = success else {return}
                self?.presentableHistoryAnswers?[indexPath.row].answer = success.answer
                self?.presentableHistoryAnswers?[indexPath.row].date = success.date
                cell.typeLabel.text = "\(success.answer ?? "") \(success.date ?? "")"
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
            case .failure(let error):
                print(error)
            }
        }
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

    private func changeAnswer(indexPath: IndexPath) {
        let alert = UIAlertController(title: "CHANGE ANSWER", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.presentableHistoryAnswers?[indexPath.row].answer
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields?.first
            self.updateAnswer(indexPath: indexPath, answer: textField?.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func createAnswer() {
        let alert = UIAlertController(title: "ADD ANSWER", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "New answer"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields?.first
            self.addAnswer(answer: textField?.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func updateAnswer(indexPath: IndexPath, answer: String) {
        viewModel.updateAnswer(indexPath: indexPath, answer: answer)
    }

    func addAnswer(answer: String) {
        viewModel.saveAnswer(answer: HistoryAnswer(answer: answer, isUserCreated: true))
    }

    @objc func clickAdd() {
        createAnswer()
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
        cell.typeLabel.text = "\(obj?.answer ?? "") \(obj?.date ?? "")"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       changeAnswer(indexPath: indexPath)
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
            $0.right.top.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.left.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        let addButton = CornerRadiusButton()
        addButton.addTarget(self, action: #selector(clickAdd), for: .touchUpInside)
        addButton.cornerRadius = 48/2
        addButton.backgroundColor = Asset.Colors.accentColor.color
        view.addSubview(addButton)
        addButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(48)
            make.top.right.equalTo(view.safeAreaLayoutGuide).inset(24)
        }

        let addText = UILabel()
        addText.text = "Add"
        addText.textColor = Asset.Colors.whiteOnly.color
        addText.font = addText.font.withSize(48/3)
        addButton.addSubview(addText)
        addText.snp.makeConstraints { (make) -> Void in
            make.centerX.centerY.equalToSuperview()
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

// MARK: - FetchedResultsControllerDelegate
extension HistoryViewController: FetchedResultsControllerDelegate {
    func delete(indexPath: IndexPath) {
        presentableHistoryAnswers?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    func insert(indexPath: IndexPath) {
        insertNewAnswer(index: indexPath)
    }
    func update(indexPath: IndexPath) {
        configureCell(indexPath: indexPath)
    }
}
