import SwiftUI
import SpriteKit
import SceneKit
import QuartzCore

struct ContentView: View {
    
    @ObservedObject var plyToSceneViewModel : PlyToSceneViewModel = PlyToSceneViewModel()
    @State var message = ""
    
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
            Button{
                
                         
            } label: {
                
                Text(" Ply to Scene " + message)
    
            }
        }.onAppear(perform: fetch)
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
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
