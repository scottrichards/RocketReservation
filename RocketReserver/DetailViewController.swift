//
//  ViewController.swift
//  RocketReserver
//
//  Created by Scott Richards on 3/30/21.
//

import UIKit
import Apollo

class DetailViewController: UIViewController {
    @IBOutlet weak var missionNameLabel: UILabel!
    @IBOutlet weak var launchSiteLabel: UILabel!
    @IBOutlet weak var rocketNameLabel: UILabel!
    private var launch: LaunchDetailsQuery.Data.Launch? {
      didSet {
        self.configureView()
      }
    }
    var launchID: GraphQLID? {
      didSet {
        self.loadLaunchDetails()
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        guard
            let label = self.missionNameLabel,
            let id = self.launchID,
            let launch = launch else {
            return
        }
        
        label.text = "Launch \(id)"
        launchSiteLabel.text = launch.site
        rocketNameLabel.text = launch.rocket?.name
    }
    
    private func loadLaunchDetails() {
        guard
            let launchID = self.launchID,
            launchID != self.launch?.id else {
            // This is the launch we're already displaying, or the ID is nil.
            return
        }
        
        Network.shared.apollo.fetch(query: LaunchDetailsQuery(id: launchID)) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                print("NETWORK ERROR: \(error)")
            case .success(let graphQLResult):
                if let launch = graphQLResult.data?.launch {
                    self.launch = launch
                }
                
                if let errors = graphQLResult.errors {
                    print("GRAPHQL ERRORS: \(errors)")
                }
            }
        }
    }
}

