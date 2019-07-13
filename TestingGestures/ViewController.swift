//
//  ViewController.swift
//  TestingGestures
//
//POC to determine how to limit the rotation of a spherical object as well as ignore pinch gestures
//Source https://stackoverflow.com/questions/33967838/scncamera-limit-arcball-rotation

import UIKit
import SceneKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: SCNView!
    var blenderSphereNode = SCNNode()
    var scene = SCNScene()
    let spherePinchGesture = UIPinchGestureRecognizer()
    let sphereTapGesture = UITapGestureRecognizer()
    let spherePanGesture = UIPanGestureRecognizer()
//    let constraint = SCNIKConstraint()
//    let extraCamera = SCNCamera()
    var cameraNode = SCNNode()
    let cameraOrbit = SCNNode()
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.0 //0.2
    var widthRatio: Float = 0
    var heightRatio: Float = 0.0 //0.2
    var fingersNeededToPan = 1
    var maxWidthRatioRight: Float = 1 //0.2
    var maxWidthRatioLeft: Float = -1 //-0.2
    var maxHeightRatioXDown: Float = -0.3 //0.02
    var maxHeightRatioXUp: Float = 0.3 //0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 20.0  //1.0: very fast ---- 100.0 very slow
    var lastFingersNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScene()
        setUpCameraNode()
    }


    
    fileprivate func setUpScene() {
        // Create a spherical geometry and add a material to its surface
        let sphere = SCNSphere(radius: 5.0)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: "bluemarket copy.jpg")
    
        createSphericalNode(sphere)
        
        //Set up properties of the scene view
        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = false //default camera set with true
//        sceneView.autoenablesDefaultLighting = true //default light
        
        //Create a scene in the scene view to hold our nodes
        sceneView.scene = scene
        
        //Add our nodes to the scene
        scene.rootNode.addChildNode(blenderSphereNode)
        sceneView.addGestureRecognizer(sphereTapGesture) //If not added to the scene, taps occur with the default camera
        sceneView.addGestureRecognizer(spherePinchGesture) //if not added to the scene, zooming occurs with the default camera
        sceneView.addGestureRecognizer(spherePanGesture)
        
        sphereTapGesture.addTarget(self, action: #selector(sphereTapAction))
        spherePinchGesture.addTarget(self, action: #selector(spherePinchAction))
        spherePanGesture.addTarget(self, action: #selector(spherePanAction))
        
    }
    
    func setUpCameraNode() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 9
        camera.zNear = 0
        camera.zFar = 100
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 10)
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
        
        //initial camera setup
        self.cameraOrbit.eulerAngles.y = Float(-2 * Float.pi) * lastWidthRatio
        self.cameraOrbit.eulerAngles.x = Float(-Float.pi) * lastHeightRatio
    }
    
    fileprivate func createSphericalNode(_ sphere: SCNSphere) {
        //Create a SCNNode from the geometry property of the sphere
        blenderSphereNode = SCNNode(geometry: sphere)
        
        //Rotate the node
        let action = SCNAction.rotate(by: .pi, around: SCNVector3.init(0, 1, 0), duration: 10.0)
        let rotationLoop = SCNAction.repeatForever(action)
        blenderSphereNode.runAction(rotationLoop)
//        blenderSphereNode.eulerAngles.x == Float(CGFloat(CGFloat.pi)) //Sets the node upside down

    }
    
    @objc func sphereTapAction(_ gestureRecognize: UIGestureRecognizer) {
        print("Sphere was tapped")
        
        print(cameraNode.position)
    }
    

    @objc func spherePanAction(gestureRecognize: UIPanGestureRecognizer) {
        print("I'm in the pan action")
        let numberOfTouches = gestureRecognize.numberOfTouches
        
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        
        if (numberOfTouches==fingersNeededToPan) {
            
            //Unlimited (360 degree) left-right rotation with the width
            widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width)  //+ lastWidthRatio
            
            //Limited (180 degree) up-down rotation with the height
            heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) // + lastHeightRatio
            
            //  HEIGHT constraints
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            
//              WIDTH constraints (rotation around hemisphere)
            if(widthRatio >= maxWidthRatioRight) {
                widthRatio = maxWidthRatioRight
            }
            if(widthRatio <= maxWidthRatioLeft) {
                widthRatio = maxWidthRatioLeft
            }
            
            self.cameraOrbit.eulerAngles.y = Float(-2 * Float.pi) * widthRatio
            self.cameraOrbit.eulerAngles.x = Float(-Float.pi) * heightRatio
            
            print("Height: \(round(heightRatio*100))")
            print("Width: \(round(widthRatio*100))")
            
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
    }
    
    @objc func spherePinchAction(_ gestureRecognize: UIGestureRecognizer) {
        print("Sphere was pinched")
        
        print(cameraNode.position)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("I was touched")
        
        print(cameraNode.position)
    }
}

