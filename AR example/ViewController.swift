//
//  ViewController.swift
//  AR example
//
//  Created by Nik Y on 09.05.2023.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 3D Model
        let sphere = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .red, roughness: 0, isMetallic: true)
        
        let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
        
        // Create Anchor
        let sphereAnchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: 0))
        sphereAnchor.addChild(sphereEntity)
        
        // Add anchor to scene
        arView.scene.addAnchor(sphereAnchor)
    }
}
