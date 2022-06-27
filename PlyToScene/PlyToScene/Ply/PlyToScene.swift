import Foundation
import SceneKit


@objc class PointCloud: NSObject {
    
    var n : Int = 0
    var pointCloud : Array<PointCloudVertex> = []
    
    let progressEvent = Event<Float>()
    
    override init() {
        super.init()
    }
    
    
    public func loadFromPlyViewModels(models: [PlyViewModel]) {
        
        self.n = 0
        
        progressEvent.raise(data: 0.0)
        
        do {
            
            var nextProgressStep = 0
            let minProgressStep = Int(Float(n) * 0.01)
            let i = Counter()
            
            pointCloud = models.map({ (model : PlyViewModel) -> PointCloudVertex in
            
            // show progress
            i.increment()
            if(i.value >= nextProgressStep)
            {
                let progress = Float(i.value) / Float(self.n)
                self.progressEvent.raise(data: progress)
                nextProgressStep += minProgressStep
            }
            
            return PointCloudVertex(
                
                
                x: Float(model.point.y/50),
                y: Float(model.point.x/50),
                z: Float(model.point.z/50),
                r: Float(model.color.cgColor!.components?[0] ?? 1),
                g: Float(model.color.cgColor!.components?[1] ?? 1),
                b: Float(model.color.cgColor!.components?[2] ?? 1))
  
        
        })
            
            
            print("Point cloud data loaded: \(n) points")
            progressEvent.raise(data: 1.0)
        } catch {
            print(error)
        }

        
    }
    
    public func load(file : String)
    {
        self.n = 0
        
        progressEvent.raise(data: 0.0)
        
        // Open file
        do {
            let data = try String(contentsOfFile: file, encoding: .ascii)
            var lines = data.components(separatedBy: "\n")
            
            // Read header
            while !lines.isEmpty {
                let line = lines.removeFirst()
                if line.hasPrefix("element vertex ") {
                    n = Int(line.components(separatedBy: " ")[2])!
                    continue
                }
                if line.hasPrefix("end_header") {
                    break
                }
            }
            
            var nextProgressStep = 0
            let minProgressStep = Int(Float(n) * 0.01)
            let i = Counter()
            
            pointCloud = lines.filter {$0 != ""}
                .concurrentMap({ (line : String) -> PointCloudVertex in
                    let elements = line.components(separatedBy: " ")
                    
                    // show progress
                    i.increment()
                    if(i.value >= nextProgressStep)
                    {
                        let progress = Float(i.value) / Float(self.n)
                        self.progressEvent.raise(data: progress)
                        nextProgressStep += minProgressStep
                    }
                    
                    return PointCloudVertex(
                        x: Float(elements[0])!,
                        y: Float(elements[1])!,
                        z: Float(elements[2])!,
                        r: Float(elements[3])! / 255.0,
                        g: Float(elements[4])! / 255.0,
                        b: Float(elements[5])! / 255.0)
                })
            
            print("Point cloud data loaded: \(n) points")
            progressEvent.raise(data: 1.0)
        } catch {
            print(error)
        }
    }
    
    public func getNode(useColor : Bool = false) -> SCNNode {
        let vertices = pointCloud.map { (v : PointCloudVertex) -> PointCloudVertex in
            return useColor ? PointCloudVertex(x: v.x, y: v.y, z: v.z, r: v.r, g: v.g, b: v.b)
                : PointCloudVertex(x: v.x, y: v.y, z: v.z, r: 1.0, g: 1.0, b: 1.0)
        }
        
        let node = buildNode(points: vertices)
        NSLog(String(describing: node))
        return node
    }
    
    private func buildNode(points: [PointCloudVertex]) -> SCNNode {
        let vertexData = NSData(
            bytes: points,
            length: MemoryLayout<PointCloudVertex>.size * points.count
        )
        let positionSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let colorSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.color,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: MemoryLayout<Float>.size * 3,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let elements = SCNGeometryElement(
            data: nil,
            primitiveType: .point,
            primitiveCount: points.count,
            bytesPerIndex: MemoryLayout<Int>.size
        )
        
        elements.maximumPointScreenSpaceRadius = 2.0
        elements.minimumPointScreenSpaceRadius = 2.0
        elements.pointSize = 2.0
        
        let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [elements])
        return SCNNode(geometry: pointsGeometry)
    }
}

class Event<T> {
    
    typealias EventHandler = (T) -> ()
    
    private var eventHandlers = [EventHandler]()
    
    func addHandler(handler: @escaping EventHandler) {
        eventHandlers.append(handler)
    }
    
    func raise(data: T) {
        for handler in eventHandlers {
            handler(data)
        }
    }
}


struct PointCloudVertex {
    var x: Float, y: Float, z: Float
    var r: Float, g: Float, b: Float
}

