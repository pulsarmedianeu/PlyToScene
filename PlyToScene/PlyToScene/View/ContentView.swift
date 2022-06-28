import SwiftUI
import SpriteKit
import SceneKit
import QuartzCore

struct ContentView: View {
    
    @ObservedObject var plyToSceneViewModel : PlyToSceneViewModel = PlyToSceneViewModel()
    @State var message = ""
    @State var pointSize : Float = 2
    @State var countOfPoint : Int = 0
    @State var cameraStart : SCNVector3? = nil
    
    
    
    
    // SceneKit
    static func makeScene() -> SCNScene? {
      let scene = SCNScene(named: "PlyScene.scn")
      return scene
    }
    
    var scene = makeScene()
    //
    
    var body: some View {

        VStack {
            
            SceneView(scene: scene, options: [.allowsCameraControl])
                .background(Color.yellow)
                .edgesIgnoringSafeArea(.all)
                    
/*
            List (plyToSceneViewModel.plys, id: \ PlyViewModel.id) { ply in
                HStack {
                    
                    Text("x:\(ply.formattedStringPoint().x)")
                    Text("y:\(ply.formattedStringPoint().y)")
                    Text("z:\(ply.formattedStringPoint().z)")
                    Spacer()
                    Image(systemName:"seal.fill").renderingMode(.original).foregroundColor(ply.color)
                }
            }
            
 */
            HStack{
                
                Spacer()
                
                    ButtonView(action: {
                        downPointSize()
                        changeThePointSize(size: pointSize)
                    }, icon: "minus.circle", isActive: true)
                
                    ButtonView(action: {
                        upPointSize()
                        changeThePointSize(size: pointSize)
                    }, icon: "plus.circle", isActive: true)
                    
                Spacer()
                
                
                ButtonView(action: {

                    var camera = scene?.rootNode.childNode(withName: "camera", recursively: true)
                    camera?.position = SCNVector3(x: 0 , y: 10, z: 0.1)
                    
                    
                }, icon: "square.and.arrow.down", isActive: true)
                
                
                ButtonView(action: {

                    var camera = scene?.rootNode.childNode(withName: "camera", recursively: true)
                    camera?.position = cameraStart ?? SCNVector3(x: 0, y: 0, z: 0)
                    
                }, icon: "rectangle.portrait.and.arrow.right", isActive: true)
                
                Spacer()
                
                ButtonView(action: {
                    
                    var camera = scene?.rootNode.childNode(withName: "camera", recursively: true)
                    
                    camera?.position.y = camera!.position.x + 10

                    /*
                    var camera = scene?.rootNode.childNode(withName: "camera", recursively: true)
                    var cameraEuler : SCNVector3? = camera?.eulerAngles
                    cameraEuler?.y += 0.1
                    camera?.eulerAngles = cameraEuler!
                    */
                    
                }, icon: "arrowshape.turn.up.right.circle", isActive: true)

                
                    
                Text("Point count : \(countOfPoint)").foregroundColor(SwiftUI.Color.blue)
                
                Spacer()
                    
            }
        }.onAppear(perform: fetch)
    }
    
    
    
    struct ButtonView: View {
        let action: () -> Void
        var icon: String = "square"
        @State var isActive: Bool = true

        var body: some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title)
            }
            .frame(width: 35, height: 35)
        }
    }
     
    

    
    func changeThePointSize(size : Float){
        scene?.rootNode.childNode(withName: "cloud", recursively: false).map({ node in
            
            node.geometry?.elements.map({ element in
                element.minimumPointScreenSpaceRadius = CGFloat(size)
                element.maximumPointScreenSpaceRadius = CGFloat(size)
                element.pointSize = CGFloat(size)
            })
        })
    }
    
    func upPointSize() {
        pointSize = pointSize + 2
    }
    
    func downPointSize() {
        if  pointSize>2 {
            pointSize = pointSize - 2
        }
    }
    
    func originalPointSize() {
        pointSize = 2
    }
    
   func fetch() {
        
        print("loading cloud...")
        
        DispatchQueue.global(qos: .background).async {
            let pointcloud = PointCloud()

            pointcloud.progressEvent.addHandler { progress in
                 DispatchQueue.main.async {
                     self.message = "Converting... \(progress * 100)%"
                 }
             }

            
            pointcloud.loadFromPlyViewModels(models: plyToSceneViewModel.plys)
            
            let cloud = pointcloud.getNode(useColor: true)
            cloud.name = "cloud"
            scene?.rootNode.addChildNode(cloud)
            

            
            print("done!")
            print(pointcloud.pointCloud.count)
            
            countOfPoint = pointcloud.pointCloud.count
            cameraStart = scene?.rootNode.childNode(withName: "camera", recursively: true)?.position
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
