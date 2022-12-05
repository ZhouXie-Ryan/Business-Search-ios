//
//  DetailView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 12/4/22.
//

import SwiftUI
import MapKit

struct DetailView: View {
    @State var bid: String
    @State var blat: String
    @State var blon: String
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    @State private var markers = [
        Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020), tint: .red))]
    
    
    var body: some View{
        TabView{
            BusinessDetailView(bid: bid)
                .tabItem{
                    Label("Business Detail", systemImage: "text.bubble.fill")
                }
            MapLocationView(region: $region, markers: $markers)
                .tabItem{
                    Label("Map Location", systemImage: "location.fill")
                        .onAppear(perform: {
                            region = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: Double(blat)!,
                                                               longitude: Double(blon)!),
                                latitudinalMeters: 750,
                                longitudinalMeters: 750
                            )
                            markers = [
                                Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: Double(blat)!, longitude: Double(blon)!), tint: .red))]
                        })
                }
                

            ReviewsView(bid: bid)
                .tabItem{
                    Label("Reviews", systemImage: "message.fill")
                }
        }.navigationBarTitleDisplayMode(.inline)
        
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(bid: "bid", blat: "34", blon: "-118")
    }
}
