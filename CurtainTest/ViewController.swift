//
//  ViewController.swift
//  CurtainTest
//
//  Created by Mikhail Plotnikov on 31.03.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func sliderValueChanged(_ sender: Any) {

    }
    
    @IBOutlet weak var slider: UISlider!
    var bottomCurtainViewController: BottomCurtainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomCurtainViewController = BottomCurtainViewController(heightCurtain: 700)
        bottomCurtainViewController.delegate = self
        
        bottomCurtainViewController.registerCell(nib: UINib(nibName: "CustomTableViewCell", bundle: nil), identifier: "Cell")
        
        self.addChild(bottomCurtainViewController)
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
    
    
}
