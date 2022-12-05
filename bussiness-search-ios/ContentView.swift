//
//  ContentView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 11/25/22.
//

import SwiftUI
import SwiftyJSON
import MapKit



var lat = ""
var lon = ""


struct Business: Identifiable {
    var id: String
    let num: Int
    let imgUrl: String
    let name: String
    let rating: String
    let distance: String
    let blat: String
    let blon: String
}



struct ContentView: View {
    @State private var keyword = ""
    @State private var distance = "10"
    @State private var category = "Default"
    @State private var location = ""
    @State private var checkbox = false
    @State private var valid = false
    
    @State private var options = ["Default", "Arts and Entertainment", "Health and Medical", "Hotels and Travel", "Food", "Professional Services"]
    
//    @State private var business_array = [
//        Business(id: "id1", num: 1, imgUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/WYXrERXt5jxn5qim1xn30A/o.jpg", name: "Sushi bar", rating: "4", distance: "3"),
//        Business(id: "id2", num: 2, imgUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/WYXrERXt5jxn5qim1xn30A/o.jpg", name: "Sushi bar sahsasdjasd", rating: "4.5", distance: "3"),
//        Business(id: "id3", num: 3, imgUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/WYXrERXt5jxn5qim1xn30A/o.jpg", name: "Sushi bar sahsasdjasdasdhsakdhas", rating: "4.5", distance: "3.5")
//    ]
    
    @State private var business_array = [Business]()
    
    @State private var business_json: JSON = JSON()
    
    
    init(){
        getIpinfo()
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    HStack{
                        Text("Keyword:").foregroundColor(.secondary)
                        TextField("Required", text: $keyword).onChange(of: keyword, perform: { newValue in
                            formValidation()
                        })
                    }
                    
                    HStack{
                        Text("Distance:").foregroundColor(.secondary)
                        TextField("10", text: $distance)
                            .labelsHidden()
                    }
                    
                    HStack{
                        Text("Category:").foregroundColor(.secondary)
                        Picker("Default", selection: $category) {
                            ForEach(options, id: \.self) { item in
                                Text(item)
                            }
                        }
                        .labelsHidden()
                        .padding(.horizontal, -14)
                    }
                    
                    if !checkbox {
                        HStack{
                            Text("Location:").foregroundColor(.secondary)
                            TextField("Required", text: $location).onChange(of: location, perform: { newValue in
                                formValidation()
                            })
                        }
                    }
                    
                    Toggle("Auto-Detect my location", isOn: $checkbox).onChange(of: checkbox, perform: { newValue in
                        formValidation()
                    })
                    
                    HStack {
                        Button(action: {
                        }, label: {
                            Text("Submit")
                                .frame(width: 120, height: 60, alignment: .center)
                                .background(valid ? .red : .gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        })
                        
                        .padding()
                        .onTapGesture {
                            print("submit")
                            submitForm(keyword: keyword, distance: distance, category: category, location: location, checkBox: checkbox)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                        }, label: {
                            Text("Clear")
                                .frame(width: 120, height: 60, alignment: .center)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        })
                        .padding()
                        .onTapGesture {
                            print("clear")
                            clearForm()
                        }
                    }
                    
                }
                
                Section{
                    Text("Results").bold().font(.system(size: 30))
                    
                    ForEach(business_array) { business in
                        HStack(spacing: 20){
                            Text("\(business.num)").frame(width: 10)

                            AsyncImage(url: URL(string: business.imgUrl)){
                                image in image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 70, height: 70)
                            

                            Text(business.name).frame(width: 60)

                            
                            Text(business.rating).frame(width: 30)

                            Text(business.distance).frame(width: 30)
//                            Button(action: {
//                            }, label: {
//                                Image(systemName: "calendar.badge.clock")
//                            }).frame(width: 30)
                            
                            NavigationLink(destination: DetailView(bid: business.id, blat: business.blat, blon: business.blon)){
                                
                            }
                            
                        }
                }
            }
            }
                .accentColor(.blue)
                .navigationTitle("Business Search")
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink{
                            BookingView()
                        } label: {
                            Image(systemName: "calendar.badge.clock")
                        }
                    }
                }


//            NavigationLink("1", value: Color.mint)
        }
        
    }
    
    func clearForm(){
        business_array = [Business]()
        keyword = ""
        distance = "10"
        category = "Default"
        location = ""
        checkbox = false
        valid = false
    }
    
    func formValidation(){
        if keyword.isEmpty{
            valid = false
        } else if !checkbox && location.isEmpty{
            valid = false
        } else {
            valid = true
        }
    }
    
    
    func submitForm(keyword: String, distance: String, category: String, location: String, checkBox: Bool){
        
//        if keyword.isEmpty{
//            valid = false
//            return
//        } else if !checkbox && location.isEmpty{
//            valid = false
//            return
//        } else {
//            valid = true
//        }
        if valid == false {
            return
        }
        
        var cat = ""
        if(category == "Default") {
            cat = "all"
        } else if(category == "Arts and Entertainment") {
            cat = "art"
        } else if(category == "Health and Medical"){
            cat = "health"
        } else if(category == "Hotels and Travel"){
            cat = "hotel"
        } else if(category == "Food") {
            cat = "food"
        } else {
            cat = "professional"
        }
        
        let checkB = String(checkBox)
        
        getQuery(keyword: keyword, latitude: lat, longitude: lon, category: cat, distance: distance, location: location, checkbox: checkB)
    }


    func getIpinfo(){
        print("get ipinfo")
        guard let url = URL(string: "https://ipinfo.io/?token=311443a0910a19") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){ data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            let response = JSON(data)
            let tmp = response["loc"].string
            let arr = tmp!.components(separatedBy: ",")
            lat = arr[0]
            lon = arr[1]
        }
        
        task.resume()
    }

    func getQuery(keyword: String, latitude: String, longitude: String, category: String, distance: String, location: String, checkbox: String){
        print("get query")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "business-search-project-zxryan.uw.r.appspot.com"
        components.path = "/query"
        components.queryItems = [
            URLQueryItem(name: "term", value: keyword),
            URLQueryItem(name: "latitude", value: latitude),
            URLQueryItem(name: "longitude", value: longitude),
            URLQueryItem(name: "categories", value: category),
            URLQueryItem(name: "radius", value: distance),
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "checkbox", value: checkbox)
        ]

        print(components.string!)
        let tmp = components.string!

        guard let url = URL(string: tmp) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){ data, _, error in
            guard let data = data, error == nil else {
                return
            }

            let response = JSON(data)


            business_json = response
            displayTable()
        }

        task.resume()
    }

    func displayTable(){
        business_array = [Business]()
        var i = 1
        for business in business_json["businesses"].arrayValue {
            let id = business["id"].stringValue
            let imgUrl = business["image_url"].stringValue
            let name = business["name"].stringValue
            let rating = business["rating"].stringValue
            let tmp = business["distance"].doubleValue
            let distance: String = String(Int(tmp / 1609))
            
            let blat = String(business["coordinates"]["latitude"].doubleValue)
            let blon = String(business["coordinates"]["longitude"].doubleValue)
            
            business_array.append(Business(id: id, num: i, imgUrl: imgUrl, name: name, rating: rating, distance: distance, blat: blat, blon: blon))
            i += 1
            if(i > 10){
                break
            }
        }
        print(business_array)
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//struct DetailView: View {
//    var bid: String
//
//    var body: some View{
//        TabView{
//            BusinessDetailView(bid: bid)
//                .tabItem{
//                    Label("Business Detail", systemImage: "text.bubble.fill")
//                }
//            MapLocationView()
//                .tabItem{
//                    Label("Map Location", systemImage: "location.fill")
//                }
//
//            ReviewsView(bid: bid)
//                .tabItem{
//                    Label("Reviews", systemImage: "message.fill")
//                }
//        }.navigationBarTitleDisplayMode(.inline)
//
//    }
//}
//
//
//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(bid: "bid")
//    }
//}


//struct BusinessDetailView: View {
//    var bid: String
//    @State private var business_detail_json: JSON = JSON()
//    @State private var business_detail = BusinessDetail(id: "tmpid", name: "Sushi Bar", address: "1426 W 38th St", category: "Fish", phone: "(888)888-8888", price: "$", status: "Open Now", link: "https://www.google.com", imgUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/WYXrERXt5jxn5qim1xn30A/o.jpg")
////    @State private var business_detail: BusinessDetail?
//    var body: some View{
//        
//        VStack{
//            let _ = getDetail(bid: bid)
//            Text(business_detail.name).bold().font(.system(size: 30))
//            
//            HStack{
//                VStack{
//                    Text("Address").bold().frame(maxWidth: .infinity, alignment: .leading)
//                    Text(business_detail.address).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.gray)
//                }.frame(maxWidth: .infinity, alignment: .leading)
//                
//                VStack{
//                    Text("Category").bold().frame(maxWidth: .infinity, alignment: .trailing)
//                    Text(business_detail.category).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.gray)
//                }.frame(maxWidth: .infinity, alignment: .trailing)
//            }.padding()
//            
//            HStack{
//                VStack{
//                    Text("Phone").bold().frame(maxWidth: .infinity, alignment: .leading)
//                    Text(business_detail.phone).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.gray)
//                }.frame(maxWidth: .infinity, alignment: .leading)
//                
//                VStack{
//                    Text("Price Range").bold().frame(maxWidth: .infinity, alignment: .trailing)
//                    Text(business_detail.price).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.gray)
//                }.frame(maxWidth: .infinity, alignment: .trailing)
//            }.padding()
//            
//            HStack{
//                VStack{
//                    Text("Status").bold().frame(maxWidth: .infinity, alignment: .leading)
//                    Text(business_detail.status).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.green)
//                }.frame(maxWidth: .infinity, alignment: .leading)
//                
//                VStack{
//                    Text("Visit Yelp for more").bold().frame(maxWidth: .infinity, alignment: .trailing)
//                    Link("Business Link", destination: URL(string: business_detail.link)!).frame(maxWidth: .infinity, alignment: .trailing)
//                }.frame(maxWidth: .infinity, alignment: .trailing)
//            }.padding()
//            
//            HStack{
//                Button(action: {
//                }, label: {
//                    Text("Reserve Now")
//                        .frame(width: 150, height: 60, alignment: .center)
//                        .background(.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(13)
//                })
//                .padding()
//                .onTapGesture {
//                    print("reserve")
//                }
//            }
//            
//            HStack{
//                Text("Share on:")
////                Link(destination: URL(string: "https://www.facebook.com/sharer.php?u=\(business_detail.link)&quote=yelp")!) {
////                    Image("facebook").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
////                }
////                Link(destination: URL(string: "https://www.twitter.com/share?url=\(business_detail.link)")!) {
////                    Image("twitter").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
////                }
//                
//                Link(destination: URL(string: "https://www.facebook.com/sharer.php?u=\(business_detail.link)&quote=yelp")!) {
//                    Image("facebook").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
//                }
//                Link(destination: URL(string: "https://www.twitter.com/share?url=\(business_detail.link)")!) {
//                    Image("twitter").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
//                }
//            }
//            
//            HStack{
//                AsyncImage(url: URL(string: business_detail.imgUrl)){
//                    image in image.resizable()
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(width: 300, height: 250)
//            }
//            
//            Spacer()
//        }.padding()
//
//    }
//    
//    func getDetail(bid: String){
//        print("\(bid)")
//        guard let url = URL(string: "https://business-search-project-zxryan.uw.r.appspot.com/detail?id=\(bid)") else {
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let task = URLSession.shared.dataTask(with: request){ data, _, error in
//            guard let data = data, error == nil else {
//                return
//            }
//            
//            let response = JSON(data)
//            business_detail_json = response
//            displayDetail()
//        }
//        
//        task.resume()
//    }
//    
//    func displayDetail(){
//        let id = business_detail_json["id"].stringValue
//        let name = business_detail_json["name"].stringValue
//        
//        var address = ""
//        for addr in business_detail_json["location"]["display_address"].arrayValue{
//            address += addr.stringValue
//        }
//        
//        var category = ""
//        var i = 0;
//        let cat_arr = business_detail_json["categories"].arrayValue
//        for cat in cat_arr{
//            category += cat["title"].stringValue
//            if i != cat_arr.count - 1{
//                category += " | "
//            }
//            i += 1
//        }
//        let phone = business_detail_json["display_phone"].stringValue
//        let price = business_detail_json["price"].stringValue
//        var status = ""
//        if !business_detail_json["hours"].exists() || !business_detail_json["hours"].arrayValue[0]["is_open_now"].boolValue {
//            status = "Closed"
//        } else {
//            status = "Open Now"
//        }
//        
//        let link = business_detail_json["url"].stringValue
//        let imgUrl = business_detail_json["image_url"].stringValue
//        
//        business_detail = BusinessDetail(id: id, name: name, address: address, category: category, phone: phone, price: price, status: status, link: link, imgUrl: imgUrl)
//    }
//    
//}







