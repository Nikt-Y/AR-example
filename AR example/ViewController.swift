//
//  ViewController.swift
//  AR example
//
//  Created by Nik Y on 09.05.2023.
//

// Импортируем необходимые библиотеки
import UIKit
import RealityKit
import ARKit

// Определяем класс ViewController, который наследуется от UIViewController
class ViewController: UIViewController {
    
    // Создаем IBOutlet для ARView
    @IBOutlet var arView: ARView!
    
    // Вызываем метод viewDidAppear после загрузки и отображения view
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Устанавливаем делегат сессии AR
        arView.session.delegate = self
        
        // Настраиваем ARView
        setupARView()
        
        // Создаем обработчик нажатий, который работает как "лазерная указка",
        // т.е. реагирует на первую попавшуюся поверхность
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Setup Methods
    // Настраиваем ARView с пользовательскими настройками
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
    // Обработка нажатия (тапа) для размещения 3D-модели на поверхности
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
    
    // Размещение объекта на якоре AR
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation, .scale], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

// Расширение класса ViewController для реализации протокола ARSessionDelegate
extension ViewController: ARSessionDelegate {
    // Обрабатываем добавление якорей AR в сессию
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "Turtle" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}

