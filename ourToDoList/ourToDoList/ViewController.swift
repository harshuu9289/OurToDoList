
import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var items = [String]()
    @IBOutlet weak var table: UITableView!
    var timer: Timer?
    var lastItemAddedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        title = "To Do list"
        view.addSubview(table)
        table.dataSource = self
        table.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        startTimer()
        
        // Check if a new note was added within 5 seconds when the app launches
        
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New item", message: "Enter new to do list", preferredStyle: .alert)
        alert.addTextField { field in field.placeholder = "Enter new item...."}
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self](_) in if let field = alert.textFields?.first {
            if let text = field.text, !text.isEmpty {
                
                DispatchQueue.main.async {
                    var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                    currentItems.append(text)
                    UserDefaults.standard.setValue(currentItems, forKey: "items")
                    self?.items.append(text)
                    self?.lastItemAddedDate = Date() // Save the date when the item was added
                    self?.table.reloadData()
                }
            }
        }}))
        
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopwTableViewCell", for:indexPath) as! ShopwTableViewCell
        
        cell.itemLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            UserDefaults.standard.setValue(items, forKey: "items")
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Handle insert here if needed
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editItem(at: indexPath.row)
    }

    private func editItem(at index: Int) {
        let alert = UIAlertController(title: "Edit Item", message: "Edit your to-do item", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.items[index]
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            if let textField = alert.textFields?.first, let newText = textField.text, !newText.isEmpty {
                self?.items[index] = newText
                UserDefaults.standard.setValue(self?.items, forKey: "items")
                self?.table.reloadData()
            }
        }))
        
        present(alert, animated: true)
    }
    
    @objc func checkForUpdates() {
        let storedItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
        if storedItems.count > items.count {
            items = storedItems
            table.reloadData()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(checkForUpdates), userInfo: nil, repeats: true)
    }
    
    // Check if a new note was added within 5 seconds when the app launches
}

