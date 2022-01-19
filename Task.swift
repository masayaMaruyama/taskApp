//
//  Task.swift
//  taskapp
//
//  Created by jobs steve on 2021/12/26.
//

import RealmSwift

class Task: Object {
    //管理用　ID。プライマリキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //カテゴリ(課題追加)
    @objc dynamic var category = ""
    
    // id をプライマリキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
