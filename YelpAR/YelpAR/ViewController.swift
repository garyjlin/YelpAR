//
//  ViewController.swift
//  YelpAR
//
//  Created by Gary Lin on 7/26/18.
//  Copyright © 2018 Gary Lin. All rights reserved.
//

import UIKit
import ARKit
import CDYelpFusionKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let yelpAPIClient = CDYelpAPIClient(apiKey: "whL7UaIen8TNl5V_EkEqcDmNzgFsFOBZyn8eDdZpyLQpiMQ9rEv986VNgMtaDy5N6zShdIQHQ8yXdOVnCE5myyBgaw1T4wpcRZg_rclPFvOLoddvd3SaA4WFnKFaW3Yx")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addBox()
        addTapGestureToSceneView()
        searchBusinesses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                addBox(x: translation.x, y: translation.y, z: translation.z)
            }
            return
        }
        node.removeFromParentNode()
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func searchBusinesses() {
        yelpAPIClient.searchBusinesses(byTerm: "Food",
                                       location: "San Francisco",
                                       latitude: nil,
                                       longitude: nil,
                                       radius: 10000,
                                       categories: [.activeLife, .food],
                                       locale: .english_unitedStates,
                                       limit: 5,
                                       offset: 0,
                                       sortBy: .rating,
                                       priceTiers: [.oneDollarSign, .twoDollarSigns],
                                       openNow: true,
                                       openAt: nil,
                                       attributes: nil) { (response) in
                                        
                                        if let response = response,
                                            let businesses = response.businesses,
                                            businesses.count > 0 {
                                            print(businesses)
                                            let name = businesses[0].name
                                            print(name)
                                        }
        }
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

