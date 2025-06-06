//
//  FaqView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/03/25.
//

import SwiftUI

struct FaqView: View {
    @State private var expandedItems: Set<Int> = []
    var navigationController:UINavigationController?
    @State private var faqs = [FAQ]()
    
    var body: some View {
        VStack{
            
            HStack{
                Button {
                    
                    navigationController?.popViewController(animated: true)
                    
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                Text("FAQ").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            
            
            ScrollView {
                HStack{Spacer()}.frame(height: 10)
                ForEach(faqs.indices, id: \.self) { index in
                    VStack(alignment: .leading,spacing: 8) {
                        // Custom Expandable Row
                        Button(action: {
                            withAnimation {
                                if expandedItems.contains(index) {
                                    expandedItems.remove(index)
                                } else {
                                    expandedItems.insert(index)
                                }
                            }
                        }) {
                            HStack {
                                Text(faqs[index].question ?? "")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(UIColor.label))
                                    .contentShape(Rectangle())
                                    .padding()

                                Spacer() // Pushes chevron to the right

                                // Custom Chevron Arrow
                                Image(systemName: "chevron.down")
                                    .rotationEffect(.degrees(expandedItems.contains(index) ? 180 : 0))
                                    .foregroundColor(expandedItems.contains(index) ? .gray : .gray)
                                    .animation(.easeInOut(duration: 0.2), value: expandedItems.contains(index)).padding()
                            }
                        }
                        .buttonStyle(PlainButtonStyle()).background(Color(UIColor.systemBackground)) // Removes button highlight

                        // Expandable Content
                        if expandedItems.contains(index) {
                            Text(faqs[index].answer ?? "")
                                .font(.body)
                                .foregroundColor(Color(UIColor.label))
                               .padding()
                        }
                    }.background(Color(UIColor.systemBackground)).cornerRadius(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(Color.white, lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding([.leading,.trailing])
                }
            }.background(Color(UIColor.systemGroupedBackground))
            
        }.onAppear{
            getfaqListApi()
        }.navigationBarHidden(true)
    }
        
    func getfaqListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.faq) { (obj:FAQParse) in
            
            if obj.data != nil {
                self.faqs = obj.data ?? []
            }
        }
    }

}


#Preview {
    FaqView()
}



