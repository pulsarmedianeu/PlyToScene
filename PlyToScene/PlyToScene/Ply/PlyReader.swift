import Foundation
class PlyReader {

    //Properties
    var numberOfVertex : Int? = nil
    var indexOfStartValue : Int? = nil


    //Constants
    let endOfLineInHeader : UInt8 = 0x0A

                                         //"element vertex "
    let elementVertexInHeader: [UInt8] = [0x65, 0x6C, 0x65, 0x6D, 0x65, 0x6E, 0x74, 0x20, 0x76,
                                          0x65,0x72,0x74,0x65, 0x78, 0x20]

                                         //"end_header "
    let endOfMarkInHeader : [UInt8] =    [0x65, 0x6E, 0x64, 0x5F, 0x68, 0x65, 0x61,
                                          0x64, 0x65, 0x72, 0x0A]


    //Methods
    func setProperties(_ data : [UInt8]) -> Bool {

        var elementVertexRange : (first:Int,last:Int) = (0,0)
        
    //    vertexek szamanak keresese a byte array - ben max 300 byte vizsgalata!!!
        guard data.count > 300 else { return false }
        
        for index in 0...300 {
    //        lehetséges vertex elementek beolvasas byte - ban
            let possibleElementsVertexInHeader : [UInt8] = Array(data[index...index+elementVertexInHeader.count-1])
            
    //        megtaláltuk?
            if possibleElementsVertexInHeader == elementVertexInHeader {
                
    //          ha igen akkor kiszamoljuk a vertex ertek kezdo poziciojat
                elementVertexRange.first = index+elementVertexInHeader.count
                
            }
            
    //        keressuk a vertex szam utolso poziciojat
            if (elementVertexRange.first > 0 && elementVertexRange.last == 0 && index > elementVertexRange.first && data[index] == endOfLineInHeader) {
                elementVertexRange.last = index
                
    //            megvan a szam atalakitjuk Int tipsuva
                let numberOfVertexElement : Int? =
                Int(String(bytes: Array(data[elementVertexRange.first...elementVertexRange.last-1]), encoding: .utf8) ?? "0")
                
    //          feltoltjuk a property erteket 0 vagy az ertek lesz benne
                numberOfVertex = numberOfVertexElement
            }
            
            
    //        end of line indexenek keresese
            let possibleEndOfMarkInHeader : [UInt8] = Array(data[index...index+endOfMarkInHeader.count-1])
            
    //          megtaláltuk?
            if possibleEndOfMarkInHeader == endOfMarkInHeader {
                indexOfStartValue = index+endOfMarkInHeader.count
            }
            
        } //for index
        
        return true
    }

    
    
    func getPlyFileFromResource(forResource resource: String, withExtension fileExt: String?) -> [UInt8]? {
        
        guard let fileUrl: URL = Bundle.main.url(forResource: resource, withExtension: fileExt) else {
            return nil
        }

        do {
            let rawData: Data = try Data(contentsOf: fileUrl)
            return [UInt8](rawData)
        } catch {
            return nil
        }
    }
    

    
    func getPlyFileFromFile(forResource resource: String, withExtension fileExt: String?) -> [UInt8]? {
        return nil
    }

}
