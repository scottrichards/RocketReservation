//
//  MainViewController.swift
//  RocketReserver
//
//  Created by Scott Richards on 3/30/21.
//

import Foundation
import UIKit
import Apollo

class MainViewController: UITableViewController {
    var launches = [LaunchListQuery.Data.Launch.Launch]()
    private var lastConnection: LaunchListQuery.Data.Launch?
    private var activeRequest: Cancellable?
    
    enum ListSection: Int, CaseIterable {
        case launches
        case loading
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMoreLaunchesIfTheyExist()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ListSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let listSection = ListSection(rawValue: section) else {
            assertionFailure("Invalid section")
            return 0
        }
        
        switch listSection {
        case .launches:
            return self.launches.count
        case .loading:
            if self.lastConnection?.hasMore == false {
                return 0
            } else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let listSection = ListSection(rawValue: indexPath.section) else {
            assertionFailure("Invalid section")
            return cell
        }
        
        switch listSection {
        case .launches:
            let launch = self.launches[indexPath.row]
            cell.textLabel?.text = launch.mission?.name
            cell.detailTextLabel?.text = launch.site
        case .loading:
            if self.activeRequest == nil {
                cell.textLabel?.text = "Tap to load more"
            } else {
                cell.textLabel?.text = "Loading..."
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let launch = self.launches[indexPath.row]
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let listSection = ListSection(rawValue: indexPath.section) else {
            assertionFailure("Invalid section")
            return
          }
        
        switch listSection {
        case .launches:
            if let detailviewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailviewController.launchID = launch.id
            self.navigationController?.pushViewController(detailviewController, animated: true)
        
            }
        case .loading:
            self.tableView.deselectRow(at: indexPath, animated: true)

                if self.activeRequest == nil {
                  self.loadMoreLaunchesIfTheyExist()
                } // else, let the active request finish loading

                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                // In either case, don't perform the segue
        }
        
    }
    
    private func loadMoreLaunches(from cursor: String?) {
        self.activeRequest = Network.shared.apollo.fetch(query: LaunchListQuery(cursor: cursor)) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.activeRequest = nil
            defer {
                self.tableView.reloadData()
            }
            
            switch result {
            case .success(let graphQLResult):
                if let launchConnection = graphQLResult.data?.launches {
                    self.lastConnection = launchConnection
                    self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
                }
                
                if let errors = graphQLResult.errors {
                    let message = errors
                        .map { $0.localizedDescription }
                        .joined(separator: "\n")
                    self.showErrorAlert(title: "GraphQL Error(s)",
                                        message: message)
                }
            case .failure(let error):
                self.showErrorAlert(title: "Network Error",
                                    message: error.localizedDescription)
            }
        }
    }
    
    private func loadMoreLaunchesIfTheyExist() {
        guard let connection = self.lastConnection else {
            // We don't have stored launch details, load from scratch
            self.loadMoreLaunches(from: nil)
            return
        }
        
        guard connection.hasMore else {
            // No more launches to fetch
            return
        }
        
        self.loadMoreLaunches(from: connection.cursor)
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
