/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!
    
    let categories = Variable<[EOCategory]>([])
    let disposeBage = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    startDownload()
  }

  func startDownload() {
//        //获取category数据
//        let eoCategories = EONET.categories
//        eoCategories
//            .bind(to: categories)
//            .disposed(by: disposeBage)
//
        categories.asObservable().subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()                //网络出错，也是执行onNext的代码
            }
            }, onError: { error in
                print(error)
        }, onCompleted: {
            print("completed!")
        }) {
            print("Disposed!")
        }.disposed(by: disposeBage)
    
        let eoCategories = EONET.categories
        let downloadEvents = EONET.events(forLast: 360)
        //将两个Observable结合为1个，两个接口的数据结合在一起，分离逻辑和UI，后面进一步体会吧。
        //不管哪个请求先返回，处理逻辑其实是一样的。
        let updatedCategories = Observable.combineLatest(eoCategories, downloadEvents) { (categories, events) -> [EOCategory] in
            print("categorys count \(categories.count), events count \(events.count)")
            return categories.map{ category -> EOCategory in
                var cat = category
                cat.events = events.filter{ $0.categories.contains(category.id)}
                return cat
            }
        }

        eoCategories
            .concat(updatedCategories)  //为什么这里需要concat呢，先更新一次category？再更新数据？ 用whistle测试一下？保证分类的请求完成后能看到分类的结果
            .bind(to: categories)
            .disposed(by: disposeBage)
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
    let category = categories.value[indexPath.row]
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
//    cell.detailTextLabel?.text = category.description
    cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
    return cell
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = categories.value[indexPath.row]
        guard category.events.isEmpty == false else {
            return
        }
        
        let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
        eventsController.title = category.name
        eventsController.events.value = category.events
        navigationController?.pushViewController(eventsController, animated: true)
    }
  
}

