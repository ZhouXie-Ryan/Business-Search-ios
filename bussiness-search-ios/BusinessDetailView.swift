//
//  BusinessDetailView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 12/4/22.
//

import SwiftUI
import SwiftyJSON

struct BusinessDetail: Identifiable {
    var id: String
    let name: String
    let address: String
    let category: String
    let phone: String
    let price: String
    let status: String
    let link: String
    let imgUrl: String
}

struct BusinessDetailView: View {
    var bid: String
    @State private var business_detail_json: JSON = JSON()
    @State private var business_detail = BusinessDetail(id: "tmpid", name: "Sushi Bar", address: "1426 W 38th St", category: "Fish", phone: "(888)888-8888", price: "$", status: "Open Now", link: "https://www.google.com", imgUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/WYXrERXt5jxn5qim1xn30A/o.jpg")
//    @State private var business_detail: BusinessDetail?
    
    @State private var showingSheet = false
    
    var body: some View{
        
        VStack{
            let _ = getDetail(bid: bid)
            Text(business_detail.name).bold().font(.system(size: 30))
            
            HStack{
                VStack{
                    Text("Address").bold().frame(maxWidth: .infinity, alignment: .leading)
                    Text(business_detail.address).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.gray)
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                VStack{
                    Text("Category").bold().frame(maxWidth: .infinity, alignment: .trailing)
                    Text(business_detail.category).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.gray)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.padding()
            
            HStack{
                VStack{
                    Text("Phone").bold().frame(maxWidth: .infinity, alignment: .leading)
                    Text(business_detail.phone).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.gray)
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                VStack{
                    Text("Price Range").bold().frame(maxWidth: .infinity, alignment: .trailing)
                    Text(business_detail.price).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.gray)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.padding()
            
            HStack{
                VStack{
                    Text("Status").bold().frame(maxWidth: .infinity, alignment: .leading)
                    Text(business_detail.status).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.green)
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                VStack{
                    Text("Visit Yelp for more").bold().frame(maxWidth: .infinity, alignment: .trailing)
                    Link("Business Link", destination: URL(string: business_detail.link)!).frame(maxWidth: .infinity, alignment: .trailing)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.padding()
            
            HStack{
                Button(action: {
                    showingSheet.toggle()
                }, label: {
                    Text("Reserve Now")
                        .frame(width: 150, height: 60, alignment: .center)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(13)
                })
                .sheet(isPresented: $showingSheet) {
                    SheetView(bid: business_detail.id, bname: business_detail.name)
                }
                .padding()
                .onTapGesture {
                    print("reserve")
                }
            }
            
            HStack{
                Text("Share on:")
//                Link(destination: URL(string: "https://www.facebook.com/sharer.php?u=\(business_detail.link)&quote=yelp")!) {
//                    Image("facebook").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
//                }
//                Link(destination: URL(string: "https://www.twitter.com/share?url=\(business_detail.link)")!) {
//                    Image("twitter").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
//                }
                
                Link(destination: URL(string: "https://www.facebook.com/sharer.php?u=\(business_detail.link)&quote=yelp")!) {
                    Image("facebook").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                }
                Link(destination: URL(string: "https://www.twitter.com/share?url=\(business_detail.link)")!) {
                    Image("twitter").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                }
            }
            
            HStack{
                AsyncImage(url: URL(string: business_detail.imgUrl)){
                    image in image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 300, height: 200)
            }
            
            Spacer()
        }.padding()

    }
    
    func getDetail(bid: String){
        print("\(bid)")
        guard let url = URL(string: "https://business-search-project-zxryan.uw.r.appspot.com/detail?id=\(bid)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){ data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            let response = JSON(data)
            business_detail_json = response
            displayDetail()
        }
        
        task.resume()
    }
    
    func displayDetail(){
        let id = business_detail_json["id"].stringValue
        let name = business_detail_json["name"].stringValue
        
        var address = ""
        for addr in business_detail_json["location"]["display_address"].arrayValue{
            address += addr.stringValue
        }
        
        var category = ""
        var i = 0;
        let cat_arr = business_detail_json["categories"].arrayValue
        for cat in cat_arr{
            category += cat["title"].stringValue
            if i != cat_arr.count - 1{
                category += " | "
            }
            i += 1
        }
        let phone = business_detail_json["display_phone"].stringValue
        let price = business_detail_json["price"].stringValue
        var status = ""
        if !business_detail_json["hours"].exists() || !business_detail_json["hours"].arrayValue[0]["is_open_now"].boolValue {
            status = "Closed"
        } else {
            status = "Open Now"
        }
        
        let link = business_detail_json["url"].stringValue
        let imgUrl = business_detail_json["image_url"].stringValue
        
        business_detail = BusinessDetail(id: id, name: name, address: address, category: category, phone: phone, price: price, status: status, link: link, imgUrl: imgUrl)
    }
    
}

struct BusinessDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessDetailView(bid: "bid")
    }
}
