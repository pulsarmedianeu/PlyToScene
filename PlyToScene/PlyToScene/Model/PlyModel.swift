import Foundation
import SwiftUI

struct PlyModel : Identifiable {
    let id :UUID = UUID()
    let point : Point3D
    let color : Color
    let quality : Double
}

struct Point3D {
    let x : Double
    let y : Double
    let z : Double
}

struct Vertex {
    let vertexCount : Int
}

