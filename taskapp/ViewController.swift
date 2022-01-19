//
//  ViewController.swift
//  taskapp
//
//  Created by jobs steve on 2021/12/19.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var searchField: UISearchBar! //add1.12
       
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト。
    //日付の近い順でソート(並べ替え)：昇順
    //以降内容をアップデートするとリストは内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self//add1.12
        
        searchField.placeholder = "カテゴリーで抽出"
        
        //タイトルを取得して再設定する。
        self.title = self.title! + ""//1.19add
        
    }
    
    // データの数（＝セルの数）を返すメソッド(tableView(_:numberOfRowsInSection:)  UITableViewDataSourceプロトコルのメソッド。データの数を返す)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド(TableView(_:cellForRowAt:)  UITableViewDataSourceプロトコルのメソッド。セルの内容を返す)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //削除するtaskを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //データベースから削除する
            try! realm.write{
                self.realm.delete(task)
                //self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/----------")
                    print(request)
                    print("----------/")
                }
            }
        }
    }
    
    //segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:inputViewController = segue.destination as! inputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきた時に TableView を更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //テキスト変更時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String) {//add01.16
        view.endEditing(true)
        if(searchField.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            
        } else if(searchField.text == "'") {
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            
        } else {
            //検索文字列を含むデータを検索結果配列に追加する。
            let predicate = NSPredicate(format: "category = '\(searchField.text!)'")
            taskArray = realm.objects(Task.self).filter(predicate)
            
            //taskArray = NSPredicate(format: "category = %@, searchField.text!")
            //let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
            //tanDogs = realm.objects(Dog.self).filter(predicate)
            //taskArray = realm.objects(Task.self).filter("category = '\(searchField.text!)'")
        }
        //テーブルを再読み込みする。
        tableView.reloadData()
    }
}
