import Foundation
import SwiftUI

class PlyToSceneViewModel : ObservableObject {
    
    @Published var plys = [PlyViewModel]()
    
    init() {
        //testData(100)
        fetchDataFromResource()
    }
    
    func fetchDataFromResource() {
        
        let plyConverter = PlyConverter()

        //plys = plyConverter.FillModel(Count: 10)
        plys = plyConverter.FillModelAll()
 
    }
    
    
    func testData(_ count : Int) {
        
        for _ in 1...count {
            
        
            let point : Point3D = Point3D(x:Double.random(in: 1...100),
                                          y:Double.random(in: 1...100),
                                          z:Double.random(in: 1...100))
            
            let color : Color = Color(red:   10.0 / 255,
                                      green: 255.0 / 255,
                                      blue:  255.0  / 255)
            
            let plyViewModel = PlyViewModel(point:point, color:color)
            plys.append(plyViewModel)
        
        }
    }
    
    func fillScene() {
        
    }
}

struct PlyViewModel {
    
    init(point:Point3D, color: Color){
        plyModel = PlyModel(point: point, color: color, quality: 0)
    }
        
    private let plyModel : PlyModel
        
    var id : UUID {
        plyModel.id
    }
    
    var point : Point3D {
        plyModel.point
    }
        
    var color : Color {
        plyModel.color
    }
    
    var quality : Double {
        plyModel.quality
    }
    
    func formattedStringPoint()->(x:String,y:String,z:String) {
        
        let _x = String(format: "%.1f", point.x)
        let _y = String(format: "%.1f", point.y)
        let _z = String(format: "%.1f", point.z)
        return (_x,_y,_z)
    }
}

struct VertexViewModel {
    let vertex : Vertex
        
    var vertexCount : Int {
        vertex.vertexCount
    }
}



