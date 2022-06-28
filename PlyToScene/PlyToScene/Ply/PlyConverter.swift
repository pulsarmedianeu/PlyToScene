import Foundation
import SwiftUI

class PlyConverter {
    
    // Model data
    var plyViewModels     : [PlyViewModel] = []
    
    var startIndexInBytes : Int = 0
    var bytes             : [UInt8] = []
    var vertexCount       : Int = 0
    
    var plyReader = PlyReader()
    
    init() {}
        
    
    func FillModel(Count:Int)->[PlyViewModel] {
        
        PlyToMemoryBytes()
        
        for index in 0...Count {
            
            ConvertToPlyModelElementProcessing(vertexIndex:index)
            
        }
        return plyViewModels
    }
    
    func FillModelAll()->[PlyViewModel] {
        
        PlyToMemoryBytes()
        
        for index in 0...vertexCount-1 {
            
            ConvertToPlyModelElementProcessing(vertexIndex:index)
            
        }
        return plyViewModels
    }
    
    func PlyToMemoryBytes() {
        
        bytes = plyReader.getPlyFileFromResource(forResource: "korhaz1", withExtension: "ply") ?? []
        
        if bytes.count > 0  {
            var _ = plyReader.setProperties(bytes)
            vertexCount = plyReader.numberOfVertex ?? 0
            startIndexInBytes = plyReader.indexOfStartValue ?? 0
        }
    }
    
    func ConvertToPlyModelElementProcessing(vertexIndex : Int) {
                 
        var byteIndex = startIndexInBytes + vertexIndex * 36
        
        var  x,y,z,q : Double
        var  r,g,b,a : UInt8

        
        x = Double(Array(bytes[0+byteIndex...7+byteIndex]))!
        byteIndex = byteIndex + 8

        y = Double(Array(bytes[0+byteIndex...7+byteIndex]))!
        byteIndex = byteIndex + 8

        z = Double(Array(bytes[0+byteIndex...7+byteIndex]))!
        byteIndex = byteIndex + 8
  
        r = bytes[byteIndex]
        byteIndex = byteIndex + 1
        g = bytes[byteIndex]
        byteIndex = byteIndex + 1
        b = bytes[byteIndex]
        byteIndex = byteIndex + 1
        a = bytes[byteIndex]
        byteIndex = byteIndex + 1
            
        q = Double(Array(bytes[0+byteIndex...7+byteIndex]))!
        byteIndex = byteIndex + 8
            
        let color : Color = Color(red:Double(r/255), green:Double(g/255), blue:Double(b/255))
        
        let point : Point3D = Point3D(x:x,
                                      y:y,
                                      z:z)
        
       
        let plyViewModel = PlyViewModel(point:point, color:color)
        
        plyViewModels.append(plyViewModel)

    }
}


