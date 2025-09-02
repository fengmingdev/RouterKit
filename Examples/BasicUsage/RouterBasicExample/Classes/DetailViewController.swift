import UIKit

class DetailViewController: UIViewController {

    var itemId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        // 显示ID
        let idLabel = UILabel(frame: CGRect(x: 50, y: 200, width: 300, height: 44))
        idLabel.text = "Item ID: \(itemId ?? "Unknown")"
        idLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(idLabel)

        // 返回按钮
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.frame = CGRect(x: 100, y: 260, width: 200, height: 44)
        view.addSubview(backButton)
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
