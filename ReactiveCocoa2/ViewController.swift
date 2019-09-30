//
//  ViewController.swift
//  ReactiveCocoa2
//
//  Created by zhifu360 on 2019/9/27.
//  Copyright © 2019 ZZJ. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class ViewController: UIViewController {
    
    lazy var nameTF: UITextField = {
        let tf = UITextField(frame: CGRect(x: 100, y: 100, width: 200, height: 40))
        tf.placeholder = "请输入"
        tf.borderStyle = UITextField.BorderStyle.roundedRect
        return tf
    }()
    
    lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 100, y: self.nameTF.frame.maxY, width: 200, height: 40)
        btn.setTitle("登录按钮", for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        bindSignal2()
        bindSignal3()
        bindSignal4()
        bindSignal5()
        bindSignal6()
        bindSignal7()
        bindSignal8()
        bindSignal9()
        bindSignal10()
        bindSignal11()
        bindSignal12()
        bindSignle13()
        bindSignal14()
        bindSignal15()
    }
    
    func createUI() {
        view.addSubview(nameTF)
        view.addSubview(loginBtn)
    }
    
    //冷信号
    func bindSignal1() {
        //冷信号
        let producer = SignalProducer<String, NoError>.init { (observer, _) in
            print("新的订阅，启动操作")
            observer.send(value: "Hello")
            observer.send(value: "World")
            observer.sendCompleted()
        }
        
        //创建观察者（多个观察者观察会有副作用）
        //        let sub1 = Observer<String, NoError>(value: {
        //
        //        })
        
        
        
        
    }
    
    //热信号
    func bindSignal2() {
        //通过管道创建
        let (signalA, observerA) = Signal<String, Never>.pipe()
        let (signalB, observerB) = Signal<Int, Never>.pipe()
        
        Signal.combineLatest(signalA, signalB).observeValues { (a,b) in
            print("两个热信号接收到的值：\(a) + \(b)")
        }
        
        //订阅信号要在send之前
        signalA.observeValues { (value) in
            print("signalA: \(value)")
        }
        
        observerA.send(value: "ssssss")
        //        observerA.sendCompleted()
        
        observerB.send(value: 2)
        //        observerB.sendCompleted()
        
        observerB.send(value: 100)
        //不sendCompleted和sendError，热信号一直激活
        //        observerB.sendCompleted()
    }
    
    //监听文本框
    func bindSignal3() {
        //监听
        nameTF.reactive.continuousTextValues.observeValues { (text) in
            print("输入的文本：\(text)")
        }
        
        //监听黏贴进来的文本
        let result = nameTF.reactive.producer(forKeyPath: "text")
        result.start { (text) in
            print("黏贴进来的文本：\(text)")
        }
        
        //按钮监听
        loginBtn.reactive.controlEvents(.touchUpInside).observeValues { (button) in
            print("\(button)点击按钮")
        }
    }
    
    //信号合并
    func bindSignal4() {
        //信号合并 两个要被订阅combineLatest 才能被订阅，被订阅后，合并其中一个sendNext都会激活订阅
        let (signalA, observerA) = Signal<String, Never>.pipe()
        let (signalB, observerB) = Signal<Array<Any>, Never>.pipe()
        
        Signal.combineLatest(signalA, signalB).observeValues { (a,b) in
            print("合并的信号：\(a) + \(b)")
        }
        
        observerA.send(value: "xxx")
        observerA.sendCompleted()
        observerB.send(value: ["sssddd","ppppxfff"])
        observerB.sendCompleted()
    }
    
    //信号联合
    func bindSignal5() {
        let (signalA, observerA) = Signal<String, Never>.pipe()
        let (signalB, observerB) = Signal<String, Never>.pipe()
        
        //两个都需要订阅，才激活zip
        Signal.zip(signalA, signalB).observeValues { (a,b) in
            print("zip: \(a) + \(b)")
        }
        
        observerA.send(value: "1")
        observerB.send(value: "2")
        observerB.send(value: "ccc")
        observerA.send(value: "ddd")
    }
    
    //调度器
    func bindSignal6() {
        QueueScheduler.main.schedule(after: Date.init(timeIntervalSinceNow: 3.0)) {
            print("主线程3s过去了")
        }
        
        QueueScheduler.init().schedule(after: Date.init(timeIntervalSinceNow: 3.0)) {
            print("子线程3s过去了")
        }
    }
    
    //通知
    func bindSignal7() {
        NotificationCenter.default.reactive.notifications(forName: UIApplication.keyboardWillShowNotification, object: nil).observeValues { (notification) in
            print("键盘弹起")
        }
        
        NotificationCenter.default.reactive.notifications(forName: UIApplication.keyboardWillHideNotification, object: nil).observeValues { (notification) in
            print("键盘收起")
        }
    }
    
    //KVO
    func bindSignal8() {
        let result = nameTF.reactive.producer(forKeyPath: "text")
        result.start { text in
            print("KVO监听：\(text)")
        }
    }
    
    //迭代器
    func bindSignal9() {
        let array:[String] = ["name1","name2"]
        var arrayIterator = array.makeIterator()
        while let temp = arrayIterator.next() {
            print(temp)
        }
        
        //swift自带
        array.forEach { (value) in
            print(value)
        }
    }
    
    //on
    func bindSignal10() {
        let signal = SignalProducer<String, NoError>.init { (observe, _) in
            observe.send(value: "ddd")
            observe.sendCompleted()
        }
        
        //可以通过on来观察signal，生成一个新的信号，即使没有订阅者（sp.start()）也会被触发
        let sp = signal.on(starting: {
            print("开始")
        }, started: {
            print("结束")
        }, event: { (event) in
            print("Event: \(event)")
        }, failed: { (error) in
            print("error: \(error)")
        }, completed: {
            print("信号完成")
        }, interrupted: {
            print("信号被中断")
        }, terminated: {
            print("信号结束")
        }, disposed: {
            print("信号清理")
        }) { (value) in
            print("value: \(value)")
        }
        
        sp.start()
        
    }
    
    //Map
    func bindSignal11() {
        //Map映射用于将一个事件流的值操作后的结果产生一个新的事件流
        let (signal, observer) = Signal<String, Never>.pipe()
        signal.map { (string) -> Int in
            return string.lengthOfBytes(using: .utf8)
            }.observeValues { (length) in
                print("length: \(length)")
        }
        
        observer.send(value: "lemon")
        
        observer.send(value: "something")
    }
    
    //filter
    func bindSignal12() {
        //filter函数可以按照之前预设的条件过滤掉不满足的值
        let (signal, observer) = Signal<Int, Never>.pipe()
        signal.filter { (value) -> Bool in
            return value % 2 == 0
            }.observeValues { (value) in
                print("\(value)能被2整除")
        }
        
        observer.send(value: 3)
        observer.send(value: 4)
        observer.send(value: 6)
        observer.send(value: 7)
    }
    
    //reduce
    func bindSignle13() {
        //reduce将事件里的值聚集后组合成一个值
        let (signal, observer) = Signal<Int, Never>.pipe()
        //reduce后的是聚合的次数
        signal.reduce(3) { (a, b) -> Int in
            //a是相乘后的值，b是传入值
            print("a:\(a), b:\(b)")
            return a * b
            }.observeValues { (value) in
                print(value)
        }
        
        observer.send(value: 2)
        observer.send(value: 5)
        observer.send(value: 4)
        //注意：最后算出来的值直到输入的流完成后才会被发送出去
        observer.sendCompleted()
    }
    
    //合并
    //merge
    func bindSignal14() {
        //merge将每个流的值立刻组合输出，无论内部还是外层的流如果收到失败就终止
        let (producerA, lettersObserver) = Signal<String, Never>.pipe()
        let (producerB, numbersObserver) = Signal<String, Never>.pipe()
        let (signal, observer) = Signal<Signal<String, Never>, Never>.pipe()
        
        signal.flatten(.merge).observeValues { (value) in
            print("value: \(value)")
        }
        
        observer.send(value: producerA)
        observer.send(value: producerB)
        observer.sendCompleted()
        
        lettersObserver.send(value: "a")
        numbersObserver.send(value: "1")
        lettersObserver.send(value: "b")
        numbersObserver.send(value: "2")
        lettersObserver.send(value: "c")
        numbersObserver.send(value: "3")
    }
    
    //contact
    func bindSignal15() {
        //contact策略是将内部的SignalProducer排序，外层的producer是马上被started的，随后的producer直到前一个发送完成后才会start，一有失败立刻传到外层
        let (signalA, lettersObserver) = Signal<Any, Never>.pipe()
        let (signalB, numbersObserver) = Signal<Any, Never>.pipe()
        
        let (signal, observer) = Signal<Signal<Any, Never>, Never>.pipe()
        
        signal.flatten(.concat).observeValues { (value) in
            print("value:\(value)")
        }
        
        observer.send(value: signalA)
        observer.send(value: signalB)
        observer.sendCompleted()
        
        lettersObserver.send(value: "ddddd")
        numbersObserver.send(value: 33)//不打印,因为前一个producer没有发送完成
        
        lettersObserver.send(value: "sss")
        lettersObserver.send(value: "ffff")
        lettersObserver.sendCompleted()
        
        //要前一个信号执行完毕后，下一个信号才能被订阅
        numbersObserver.send(value: 44)
    }
}

