//
//  Network.swift
//  RocketReserver
//
//  Created by Scott Richards on 3/30/21.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://apollo-fullstack-tutorial.herokuapp.com")!)
}

