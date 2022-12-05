//
//  SheetView.swift
//  bussiness-search-ios
//
//  Created by Zhou Xie on 12/4/22.
//

import SwiftUI

struct Toast<Presenting>: View where Presenting: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let text: Text

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                    .blur(radius: self.isShowing ? 1 : 0)

                VStack {
                    self.text
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)

            }

        }

    }

}

extension View {

    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}

struct SheetView: View {
    @State var bid = ""
    @State var bname = ""
    
    @State private var email = ""
    @State private var date = Date()
    @State private var hour = "10"
    @State private var minute = "00"
    
    @State private var validEmail = false
    @State var showToast: Bool = false
    
    var body: some View {
        Form{
            Section{
                Text("Reservation Form").bold().frame(maxWidth: .infinity, alignment: .center).font(.system(size: 30))
            }
            Section{
                Text(bname).bold().frame(maxWidth: .infinity, alignment: .center).font(.system(size: 30))
            }
            HStack{
                Text("Email:").foregroundColor(.secondary)
                TextField("", text: $email)
                .labelsHidden()
                .onChange(of: email, perform: { newValue in
                    emailValidation(emailValue: newValue)
                })
            }.padding(8)
            
            HStack{
                Text("Date/Time:").foregroundColor(.secondary)
                DatePicker(
                    "",
                    selection: $date,
                    in: Date()...,
                    displayedComponents: [.date]
                ).padding(.horizontal, 13)

                Menu(hour){
                    Picker("", selection: $hour){
                        Text("10").tag("10")
                        Text("11").tag("11")
                        Text("12").tag("12")
                        Text("13").tag("13")
                        Text("14").tag("14")
                        Text("15").tag("15")
                        Text("16").tag("16")
                        Text("17").tag("17")
                    }.labelsHidden()
                }.foregroundColor(.black)
                    
                
                Text(":")
                Menu(minute){
                    Picker("", selection: $minute){
                        Text("00").tag("00")
                        Text("15").tag("15")
                        Text("30").tag("30")
                        Text("45").tag("45")
                    }.labelsHidden()
                }.foregroundColor(.black)
                
            }
            .padding(5)
            
            HStack{
                Button(action: {
                    print("reserve")
                    submitReservation()
                }, label: {
                    Text("Submit")
                        .frame(width: 120, height: 60, alignment: .center)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(13)
                })
                .padding()
//                .onTapGesture {
//                    print("reserve")
//                    submitReservation()
//                }
                .frame(maxWidth: .infinity, alignment: .center)
                
            }
            
        
        }
        .toast(isShowing: $showToast, text: Text("Please enter a valid email"))
    }
    
    
    func emailValidation(emailValue: String){
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        validEmail = emailPred.evaluate(with: emailValue)
    }
    
    
    func submitReservation(){
        // reference https://www.zerotoappstore.com/get-year-month-day-from-date-swift.html
        
//        if let appDomain = Bundle.main.bundleIdentifier {
//       UserDefaults.standard.removePersistentDomain(forName: appDomain)
//        }
        if validEmail == false {
            print("Email is not in correct format, stop submitReservation()")
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                showToast = false
            }
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        
        if UserDefaults.standard.dictionary(forKey: "reservedBusinessKey") == nil {
            UserDefaults.standard.set(Dictionary<String, Dictionary<String, String>>(), forKey: "reservedBusinessKey")
        }
        var dict = UserDefaults.standard.dictionary(forKey: "reservedBusinessKey")!
        let arr = ["bid":bid, "bname":bname, "email":email, "hour":hour, "minute":minute, "year":year, "month":month, "day":day]
        dict[bid] = arr
        
        UserDefaults.standard.set(dict, forKey: "reservedBusinessKey")
        
//        print(UserDefaults.standard.dictionary(forKey: "reservedBusinessKey")!)
    }
    
    
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView()
    }
}
