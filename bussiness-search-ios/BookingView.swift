//
//  BookingView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 12/4/22.
//

import SwiftUI

struct Reservation: Identifiable {
    var id: String
    let bname: String
    let email: String
    let hour: String
    let minute: String
    let year: String
    let month: String
    let day: String
}

struct BookingView: View {
    
    @State private var reviews_array = [Reservation]()
    
    var body: some View {
        List{
            ForEach(reviews_array) { reservation in
                HStack{
                    Text(reservation.bname).frame(width: 80)
                    Spacer()
                    Text("\(reservation.year)-\(reservation.month)-\(reservation.day)")
                    Spacer()
                    Text("\(reservation.hour):\(reservation.minute)")
                    Spacer()
                    Text(reservation.email)
                }
            }
        }.onAppear(perform: {
            getReservations()
        })
        .navigationTitle("Your Reservations")
        Spacer()
        
    }
    
    func getReservations(){
        let dict = UserDefaults.standard.dictionary(forKey: "reservedBusinessKey")!

        for i in dict.keys{
//            print(dict[i]!)
//            print(type(of: dict[i]!))
            
            let tmp = (dict[i]! as! [String:String])
//            print(type(of: tmp))
            
            let id = tmp["bid"]!
            let bname = tmp["bname"]!
            let email = tmp["email"]!
            let hour = tmp["hour"]!
            let minute = tmp["minute"]!
            let year = tmp["year"]!
            let month = tmp["month"]!
            let day = tmp["day"]!
            var reservation = Reservation(id: id, bname: bname, email: email, hour: hour, minute: minute, year: year, month: month, day: day)
            reviews_array.append(reservation)
        }
    }
}

//struct BookingView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookingView()
//    }
//}
