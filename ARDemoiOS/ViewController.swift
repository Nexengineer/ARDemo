//
//  ViewController.swift
//  ARDemoiOS
//
//  Created by Mishra, Neeraj Kumar (US - Bengaluru) on 05/07/19.
//  Copyright © 2019 Mishra, Neeraj Kumar (US - Bengaluru). All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    var trackerNode: SCNNode?
    var foundSurface = false
    var tracking = true
    var car: SCNNode!
    var carSubNodes = [CarPart]()

    @IBOutlet weak var tbleViewColor: UITableView!
    @IBOutlet weak var tbleViewParts: UITableView!
    // Lifecycle method of the view
    
    let color = [UIColor.blue, UIColor.red, UIColor.black, UIColor.magenta, UIColor.cyan, UIColor.green]
    
    let parts = [UIImage(named: "body.png"), UIImage(named: "glass.png"), UIImage(named: "rim.png"), UIImage(named: "inter.png")]
    
    var selectedPart = 0
    var selectedColor = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/car.scn")!

        // Set the scene to the view
        sceneView.scene = scene
        
        // Adding lighting to the scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        tbleViewColor.isHidden = true
        tbleViewParts.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Adding sub node and setting default color
    func getAllSubNodes(){
        // Adding Values to the arry which we have declared
        for item in car.childNodes {
            if let newItem = item as? SCNNode {
                carSubNodes.append(CarPart.getNodeObj(item: newItem))
            }
        }
        changeBodyColor(to: .blue)
        changeRimColor(to: .black)
        changeGlassColor(to: .red)
    }
    
    // Taking for the horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // Code for getting the Plane in the scene
        DispatchQueue.main.async {
            guard self.tracking else { return }
            let hitTest = self.sceneView.hitTest(CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), types: .featurePoint)
            guard let result = hitTest.first else { return }
            let translation = SCNMatrix4(result.worldTransform)
            let position = SCNVector3Make(translation.m41, translation.m42, translation.m43)
            if self.trackerNode == nil {
                let plane = SCNPlane(width: 0.15, height: 0.15)
                plane.firstMaterial?.diffuse.contents = UIImage(named: "tracker.png")
                plane.firstMaterial?.isDoubleSided = true
                self.trackerNode = SCNNode(geometry: plane)
                self.trackerNode?.eulerAngles.x = -.pi * 0.5
                self.sceneView.scene.rootNode.addChildNode(self.trackerNode!)
                self.foundSurface = true
            }
            self.trackerNode?.position = position
        }
    }
    
    // Place the car on the view
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Plane tapped by the user")
        if tracking {
            //Set up the scene
            guard foundSurface else { return }
            let trackingPosition = trackerNode!.position
            trackerNode?.removeFromParentNode()
            car = sceneView.scene.rootNode.childNode(withName: "car", recursively: false)!
            car.position = trackingPosition
            car.isHidden = false
            tracking = false
            getAllSubNodes()
            
            // Configuring View
            tbleViewColor.isHidden = false
            tbleViewParts.isHidden = false
            
            tbleViewParts.dataSource = self
            tbleViewColor.dataSource = self
            tbleViewColor.delegate = self
            tbleViewParts.delegate = self
            
            tbleViewParts.reloadData()
            tbleViewColor.reloadData()
        } else {
            //Handle all other taps
        }
    }
    
    func changeColor(){
        switch selectedPart {
        case 0:
            changeBodyColor(to: color[selectedColor])
        case 1:
            changeGlassColor(to: color[selectedColor])
        case 2:
            changeRimColor(to: color[selectedColor])
        default:
            print("Interior not defined")
        }
    }

    
    // Delegate methods of ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}

// Method for changing the colors
extension ViewController {
    // Body Color
    func changeBodyColor(to color: UIColor) {
        // Setting the intial color
        let bodyPart = carSubNodes.filter{$0.type == PartType.body}
        for obj in bodyPart {
            obj.item.geometry = obj.item.geometry!.copy() as? SCNGeometry
            // Un-share the material, too
            obj.item.geometry?.firstMaterial = obj.item.geometry?.firstMaterial!.copy() as? SCNMaterial
            // Now, we can change node's material without changing parent and other childs:
            obj.item.geometry?.firstMaterial?.diffuse.contents = color
        }
    }
    
    // Rim Color
    func changeRimColor(to color: UIColor) {
        let rimPart = carSubNodes.filter{$0.type == PartType.rim}
        for obj in rimPart {
            obj.item.geometry = obj.item.geometry!.copy() as? SCNGeometry
            // Un-share the material, too
            obj.item.geometry?.firstMaterial = obj.item.geometry?.firstMaterial!.copy() as? SCNMaterial
            // Now, we can change node's material without changing parent and other childs:
            obj.item.geometry?.firstMaterial?.diffuse.contents = color
            
        }
    }
    
    // Glass color
    func changeGlassColor(to color: UIColor) {
        let glassPart = carSubNodes.filter{$0.type == PartType.glass}
        for obj in glassPart {
            obj.item.geometry = obj.item.geometry!.copy() as? SCNGeometry
            // Un-share the material, too
            obj.item.geometry?.firstMaterial = obj.item.geometry?.firstMaterial!.copy() as? SCNMaterial
            // Now, we can change node's material without changing parent and other childs:
            obj.item.geometry?.firstMaterial?.diffuse.contents = color
            obj.item.opacity = 0.2
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == tbleViewParts ? parts.count : color.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseParts = "cellPart"
        let reuseColor = "cellColor"
        
        let cell: UITableViewCell!
        
        if tableView == tbleViewColor {
            cell = tableView.dequeueReusableCell(withIdentifier: reuseColor)
            cell.backgroundColor = color[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: reuseParts)
            (cell.viewWithTag(1000) as? UIImageView)?.image = parts[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tbleViewColor {
            selectedColor = indexPath.row
        } else {
            selectedPart = indexPath.row
        }
        changeColor()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

