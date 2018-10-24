//
//  *@项目名称:  RxCocoaCommunity
//  *@文件名称:  ViewController.swift
//  *@Date 2018/10/24
//  *@Author lanjing 
//  *@Copyright © :  2014-2018 X-Financial Inc.   All rights reserved.
//  *注意：本内容仅限于小赢科技有限责任公内部传阅，禁止外泄以及用于其他的商业目的。
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let citeis = Observable.of(["Lisbon", "Copenhagen", "London", "Madrid",
                                    "Vienna"])
//        citeis.bind(to: tableView.rx.items){ (tableView: UITableView, index: Int, element: String) in
//            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
//            cell.textLabel?.text = element
//            return cell
//
//        }.disposed(by: disposeBag)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        citeis.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
            cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by: disposeBag)
    }


}

