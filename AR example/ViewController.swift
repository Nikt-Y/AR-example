//
//  ViewController.swift
//  AR example
//
//  Created by Nik Y on 09.05.2023.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        // Создаем обработчик нажатий, который работает как "лазерная указка"
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Setup Methods
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        // А бывают еще конфигурации отслеживания лица, изображений и пр.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        // IOS 12 и выше
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    // MARK: Object Placement
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        // Смотрим только на горизонтальные поверхности
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "Turtle", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Не удается найти поверхность")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "Turtle" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}

//// 3D Model
//let sphere = MeshResource.generateSphere(radius: 0.05)
//let material = SimpleMaterial(color: .red, roughness: 0, isMetallic: true)
//
//let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
//
//// Create Anchor
//let sphereAnchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: 0))
//sphereAnchor.addChild(sphereEntity)
//
//// Add anchor to scene
//arView.scene.addAnchor(sphereAnchor)
