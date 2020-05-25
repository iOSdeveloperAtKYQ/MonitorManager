//
//  ViewController.swift
//  Monitor
//
//  Created by Mac123 on 2020/3/27.
//  Copyright © 2020 OC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        MonitorManager.manager.startMonitor()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
        cell?.textLabel?.text = String(indexPath.row)
        print("\(indexPath.row)行")
        if indexPath.row == 50 {
            //模拟卡顿1秒
            sleep(1)
        }
        return cell!
    }
    

}

