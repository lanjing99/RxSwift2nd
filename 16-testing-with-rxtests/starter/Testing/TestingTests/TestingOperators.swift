/*
 * Copyright (c) 2014-2017 Razeware LLC
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

import XCTest
import RxSwift
import RxTest
import RxBlocking

class TestingOperators : XCTestCase {

  var scheduler: TestScheduler!
  var subscription: Disposable!

  override func setUp() {
    super.setUp()
    scheduler = TestScheduler(initialClock: 0)
    

  }

  override func tearDown() {
    scheduler.scheduleAt(110000){
        self.subscription.dispose()
    }

    super.tearDown()
  }
    
    func testAmb(){
        let observer = scheduler.createObserver(String.self)
        let observableA = scheduler.createHotObservable([
                next(100, "a"),
                next(200, "b"),
                next(300, "c"),
            ])
        let observableB = scheduler.createHotObservable([
            next(90, "1"),
            next(200, "2"),
            next(300, "3"),
            ])
        let ambObservable = observableA.amb(observableB)
        scheduler.scheduleAt(30) {
            self.subscription = ambObservable.subscribe(observer)
        }
        
        scheduler.start()
        
        let results = observer.events.map{ event in
            event.value.element!
        }
        
        XCTAssertEqual(results, ["1", "2", "3"])
        
    }
    
    func testFilter(){
        let observer = scheduler.createObserver(Int.self)
        let observable = scheduler.createHotObservable([
            next(90, 1),
            next(100, 2),
            next(110, 3),
            ])
        
        scheduler.scheduleAt(0) {
            self.subscription = observable.filter { $0 < 3 }.subscribe(observer)
        }
        
        scheduler.start()
        let results = observer.events.map { event in
            event.value.element!
        }
        XCTAssertEqual(results, [1, 2])
    }
    
    
    func testArray(){
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
//        let observable = Observable.range(start: 1, count: 100).subscribeOn(scheduler)
//        observable.subscribe(onNext: { value in
//            print(value)
//        })
        
//        let observable =  scheduler.createHotObservable([
//            next(3000, 1),
//            next(3000, 2),
//            next(3000, 3),
//            ])
        
        let observable = Observable.of(1, 2).subscribeOn(scheduler)
        XCTAssertEqual(try! observable.toBlocking().toArray(), [1, 2])
        
//        observable.toBlocking(timeout: 10000)
//        print (try! observable.toBlocking(timeout: 10000).toArray())
        
    }
    
    
    
}
