//
//  ViewController.swift
//  ProjectBat
//
//  Created by prayanalog on 2017. 7. 14..
//  Copyright © 2017년 prayanalog. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginKakao(_ sender: UIButton) {
        let session = KOSession.shared()
        // 로그인 세션이 생성 되었으면
        if let s = session {
            // 이전 열린 세션은 닫고
            if s.isOpen() {
                s.close()
            }
            s.open(completionHandler: { (error) in
                // 에러가 없으면
                if error == nil {
                    print("No error")
                    // 로그인 성공
                    if s.isOpen() {
                        print("Success")
                    }
                    
                    // 로그인 실패
                    else {
                        print("Fail")
                    }
                }
                
                // 로그인 에러
                else {
                    print("Error login: \(error!)")
                }
            })
        }
        // 로그인 세션 생성 실패
        else {
            print("Something wrong")

        }
    }

}

