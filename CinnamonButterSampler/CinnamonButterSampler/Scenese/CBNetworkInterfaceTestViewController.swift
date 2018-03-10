//
//  CBNetworkInterfaceTestViewController.swift
//  CinnamonButterSampler
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

import UIKit
import CinnamonButter

class CBNetworkInterfaceTestViewController: UITableViewController {
    
    var networkInterfaces: [CBNetworkInterface]!
    var dataReloader: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl.init()
        refresh.addTarget(self, action: #selector(didPullRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refresh)
        
        updateNetworkInterfaces()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            dataReloader?.cancel()
        }
    }
    
    func updateNetworkInterfaces() {
        networkInterfaces = CBNetworkInterface.list().sorted(by: { $0.name.uppercased() < $1.name.uppercased() })
        for networkInterface in networkInterfaces {
            networkInterface.addresses = networkInterface.addresses.sorted(by: { $0.interfaceType.rawValue < $1.interfaceType.rawValue })
        }
    }
    
    // MARK: -
    
    @objc func didPullRefresh(_ sender: UIRefreshControl) {
        // TEST: Wait 3 seconds
        dataReloader = DispatchWorkItem.init(block: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.updateNetworkInterfaces()
            self.tableView.reloadData()
            sender.endRefreshing()
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: dataReloader!)
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return networkInterfaces.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return networkInterfaces[section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkInterfaces[section].addresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let networkInterface = networkInterfaces[indexPath.section]
        cell.textLabel?.text = "\(networkInterface.addresses[indexPath.row].interfaceType)"
        cell.detailTextLabel?.text = networkInterface.addresses[indexPath.row].stringValue
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // HACK: Disable capitalization of section header
        (view as! UITableViewHeaderFooterView).textLabel?.text = self.tableView(tableView, titleForHeaderInSection: section)
    }

}

extension CBNetworkInterfaceType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ether:
            return "Ether"
        case .ip4:
            return "IPv4"
        case .ip6:
            return "IPv6"
        }
    }
}
