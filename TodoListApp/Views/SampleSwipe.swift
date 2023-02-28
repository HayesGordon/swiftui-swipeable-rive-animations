//import SwiftUI
//
//struct SampleView: View {
//    var body: some View {
//        NavigationView {
//        ScrollView {
//            LazyVStack.init(spacing: 0, pinnedViews: [.sectionHeaders], content: {
//                
//                Section.init(
//                    header:
//                                HStack {
//                                    Text("Section 1")
//                                    Spacer()
//                                }.padding()
//                                .background(Color.blue))
//                {
//                    ForEach(1...10, id: \.self) { count in
//                        ContentCell(data: "cell \(count)")
//                            .addButtonActions(leadingButtons: [.save, .edit, .info],
//                                              trailingButton:  [.delete, .edit], onClick: { button in
//                                                print("clicked: \(button)")
//                                              })
//                    }
//                }
//            })
//        }.navigationTitle("Demo")
//        }
//    }
//}
//
//
//struct SampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        SampleView()
//    }
//}
