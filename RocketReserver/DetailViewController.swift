//
//  ViewController.swift
//  RocketReserver
//
//  Created by Scott Richards on 3/30/21.
//

import UIKit
import Apollo

class DetailViewController: UIViewController {
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var launchID: GraphQLID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
      // Update the user interface for the detail item.
      guard
        let label = self.detailDescriptionLabel,
        let id = self.launchID else {
          return
      }

      label.text = "Launch \(id)"
    }
}

