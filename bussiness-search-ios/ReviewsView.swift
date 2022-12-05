//
//  ReviewsView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 12/3/22.
//

import SwiftUI
import SwiftyJSON

struct Review: Identifiable {
    var id: String
    let userName: String
    let rating: String
    let comment: String
    let timeCreated: String
}

struct ReviewsView: View {
    var bid: String
    
    @State private var reviews_json: JSON = JSON()
//    @State private var reviews_array = [Review]()
    @State private var reviews_array = [
        Review(id: "1", userName: "Dora L.", rating: "5", comment: "sadhsadhaskdhakjdha sadahkdhasjdh sada jsdhs ak dhajs dhahsd ajsdhka jdska", timeCreated: "2009-08-10"),
        Review(id: "2", userName: "zx", rating: "5", comment: "sadhsadhaskdhakjdha sadahkdhasjdh sada jsdhs ak dhajs dhahsd ajsdhka jdska", timeCreated: "2009-08-10"),
        Review(id: "3", userName: "zx", rating: "5", comment: "sadhsadhaskdhakjdha sadahkdhasjdh sada jsdhs ak dhajs dhahsd ajsdhka jdska", timeCreated: "2009-08-10")
    ]
    
    init(bid: String){
        self.bid = bid
    }
    
    var body: some View{
        List{
            ForEach(reviews_array) { review in
                VStack{
                    HStack{
                        Text(review.userName).bold().frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 20))
                        Text("\(review.rating)/5").bold().frame(maxWidth: .infinity, alignment: .trailing).font(.system(size: 20))
                    }
                    HStack{
                        Text(review.comment).foregroundColor(.gray).font(.system(size: 20))
                    }.padding(.vertical, 2)
                    HStack{
                        Text(review.timeCreated).font(.system(size: 20))
                    }
                }.padding()
            }
        }
        .onAppear(perform: {
            getReviews()
        })
    }
    
    func getReviews(){
        guard let url = URL(string: "https://business-search-project-zxryan.uw.r.appspot.com/review?id=\(bid)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){ data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            let response = JSON(data)
            reviews_json = response
            displayReviews()
        }
        
        task.resume()
    }
    
    func displayReviews(){
        reviews_array = [Review]()
        for review in reviews_json["reviews"].arrayValue{
            let id = review["id"].stringValue
            let name = review["user"]["name"].stringValue
            let comment = review["text"].stringValue
            let rating = review["rating"].stringValue
            
            let tmp = review["time_created"].stringValue
            let tmpArr = tmp.components(separatedBy: " ")
            let timeCreated = tmpArr[0]
            reviews_array.append(Review(id: id, userName: name, rating: rating, comment: comment, timeCreated: timeCreated))
        }
    }
}

//struct ReviewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReviewsView(bid: "bid")
//    }
//}
