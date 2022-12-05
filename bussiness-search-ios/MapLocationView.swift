//
//  MapLocationView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 12/4/22.
//

import SwiftUI
import MapKit

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}

struct MapLocationView: View {
//    @Binding var blat: String
//    @Binding var blon: String
    @Binding var region : MKCoordinateRegion
    @Binding var markers : [Marker]
    
    var body: some View{
        Map(coordinateRegion: $region, annotationItems: markers) { marker in
            marker.location
        }
    }
}

//struct MapLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapLocationView()
//    }
//}
