//
//  ViewController.swift
//  CinnamonButterSampler
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

import UIKit

class ViewController: UITableViewController {
    
    struct TestCase {
        let title: String
        
        init(title: String) {
            self.title = title
        }
        
        var storyboardName: String {
            return "\(title)Test"
        }
    }
    
    let testSuites: [TestCase] = [
        TestCase.init(title: "CBBarrierView"),
        TestCase.init(title: "CBDialogController"),
        TestCase.init(title: "CBNetworkInterface")
    ]
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTestCase = testSuites[indexPath.row]
        let storyboard = UIStoryboard.init(name: selectedTestCase.storyboardName, bundle: Bundle.main)
        let vc = storyboard.instantiateInitialViewController()!
        vc.title = selectedTestCase.title
        navigationController!.pushViewController(vc, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testSuites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = testSuites[indexPath.row].title
        return cell
    }

}
