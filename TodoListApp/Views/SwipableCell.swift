//
//  ContentCell.swift
//  TodoListApp
//
//  Created by Peter G Hayes on 23/02/2023.
//

import SwiftUI
import RiveRuntime

let buttonWidth: CGFloat = 60
let baseSize : CGFloat = 75

enum CellButtons: Identifiable {
    case edit
    case delete
    case save
    case info
    
    var id: String {
        return "\(self)"
    }
}

struct CellButtonView: View {
    let data: CellButtons
    let cellHeight: CGFloat
    
    func getView(for image: String, title: String) -> some View {
        VStack {
            Image(systemName: image)
            Text(title)
        }.padding(5)
            .foregroundColor(.primary)
            .font(.subheadline)
            .frame(width: buttonWidth, height: cellHeight)
    }
    
    var body: some View {
        switch data {
        case .edit:
            getView(for: "pencil.circle", title: "Edit")
                .background(Color.pink)
        case .delete:
            getView(for: "delete.right", title: "Delete")
                .background(Color.red)
        case .save:
            getView(for: "square.and.arrow.down", title: "Save")
                .background(Color.blue)
        case .info:
            getView(for: "info.circle", title: "Info")
                .background(Color.green)
        }
    }
}

struct ContentCell: View {
    let data: String
    var body: some View {
        VStack {
            HStack {
                Text(data).font(.title3)
                Spacer()
            }.padding(.all, 24)
            Divider()
                .padding(.leading)
        }
    }
}


extension View {
    func addButtonActions(leadingButtons: [CellButtons], trailingButton: [CellButtons], onClick: @escaping (CellButtons) -> Void) -> some View {
        self.modifier(SwipeContainerCell(leadingButtons: leadingButtons, trailingButton: trailingButton, onClick: onClick))
    }
}

extension View {
    func addRiveSwipeAction(onSwipeLeft: @escaping () -> Void, onSwipeRight: @escaping () -> Void) -> some View {
        self.modifier(RiveSwipeCell(onSwipeLeft: onSwipeLeft, onSwipeRight: onSwipeRight))
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}


struct RiveSwipeCell: ViewModifier {
    enum VisibleButton {
        case none
        case left
        case right
    }
    
    @State private var offset: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    @State private var visibleButton: VisibleButton = .none
    @State private var hasTriggered: Bool = false;
    
    let maxLeadingOffset: CGFloat = baseSize*2
    let minTrailingOffset: CGFloat = -baseSize*2
    
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    var viewModel = RiveViewModel(fileName: "swipe_interaction", stateMachineName: "State Machine 1", fit: RiveFit.cover)
//    var something = viewModel.view()

    
    init( onSwipeLeft: @escaping () -> Void, onSwipeRight: @escaping () -> Void) {
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight

        setSwipePercentage(value: 0) // make sure it's set to 0 at the start
        
      
    }
    
   
    func reset() {
        visibleButton = .none
        offset = 0
        oldOffset = 0
    }
    
    
    
    
    func setSwipePercentage(value: CGFloat) {
        if hasTriggered {
            return; // Don't continue if already triggered}
        }
            
            
            if (value > baseSize - 1) {
                hasTriggered = true;
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) { ///call once hide animation done
                    onSwipeRight()
                    reset()
                }
            } else if (value < -baseSize+1) {
                hasTriggered = true;
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.00) { ///call once hide animation done
                    onSwipeLeft()
                    reset()
                }
            }
            
            viewModel.setInput("Swipe Direction", value: value)
        
    }
    
    func body(content: Content) -> some View {
        ZStack {
            viewModel.view()
//            something
            Text("Hey there")
            content
                .contentShape(Rectangle()) ///otherwise swipe won't work in vacant area
                .offset(x: offset)
                .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
                    .onChanged({ (value) in
                        let totalSlide = value.translation.width + oldOffset

                        if  (0...Int(maxLeadingOffset) ~= Int(totalSlide)) || (Int(minTrailingOffset)...0 ~= Int(totalSlide)) { //left to right slide
                            withAnimation{
                                offset = totalSlide
                            }
                        }
                    })
                        .onEnded({ value in
                            withAnimation {
                                if visibleButton == .left && value.translation.width < -baseSize { ///user dismisses left buttons
                                    reset()
                                } else if  visibleButton == .right && value.translation.width > baseSize { ///user dismisses right buttons
                                    reset()
                                } else if offset > baseSize-1 || offset < -baseSize+1 { ///scroller more then 50% show button
                                    if offset > 0 {
                                        visibleButton = .left
                                        offset = maxLeadingOffset
                                    } else {
                                        visibleButton = .right
                                        offset = minTrailingOffset
                                    }
                                    oldOffset = offset
                                    ///Bonus Handling -> set action if user swipe more then x px
                                } else {
                                    reset()
                                }
                            }
                        })
                )
                .onChange(of: offset, perform: { newValue in
                    setSwipePercentage(value: offset/2)
                })
        }

//        ZStack {
//            viewModel.view()
//
//            content
//                .contentShape(Rectangle()) ///otherwise swipe won't work in vacant area
//                .offset(x: offset)
//                .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
//                    .onChanged({ (value) in
//                        let totalSlide = value.translation.width + oldOffset
//
//                        if  (0...Int(maxLeadingOffset) ~= Int(totalSlide)) || (Int(minTrailingOffset)...0 ~= Int(totalSlide)) { //left to right slide
//                            withAnimation{
//                                offset = totalSlide
//                            }
//                        }
//                    })
//                        .onEnded({ value in
//                            withAnimation {
//                                if visibleButton == .left && value.translation.width < -baseSize { ///user dismisses left buttons
//                                    reset()
//                                } else if  visibleButton == .right && value.translation.width > baseSize { ///user dismisses right buttons
//                                    reset()
//                                } else if offset > baseSize-1 || offset < -baseSize+1 { ///scroller more then 50% show button
//                                    if offset > 0 {
//                                        visibleButton = .left
//                                        offset = maxLeadingOffset
//                                    } else {
//                                        visibleButton = .right
//                                        offset = minTrailingOffset
//                                    }
//                                    oldOffset = offset
//                                    ///Bonus Handling -> set action if user swipe more then x px
//                                } else {
//                                    reset()
//                                }
//                            }
//                        })
//                )
//                .onChange(of: offset, perform: { newValue in
//                    setSwipePercentage(value: offset/2)
//                })
//
//
//
//        }
    }
}





struct SwipeContainerCell: ViewModifier  {
    enum VisibleButton {
        case none
        case left
        case right
    }
    @State private var offset: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    @State private var visibleButton: VisibleButton = .none
    let leadingButtons: [CellButtons]
    let trailingButton: [CellButtons]
    let maxLeadingOffset: CGFloat
    let minTrailingOffset: CGFloat
    let onClick: (CellButtons) -> Void
    
    init(leadingButtons: [CellButtons], trailingButton: [CellButtons], onClick: @escaping (CellButtons) -> Void) {
        self.leadingButtons = leadingButtons
        self.trailingButton = trailingButton
        maxLeadingOffset = CGFloat(leadingButtons.count) * buttonWidth
        minTrailingOffset = CGFloat(trailingButton.count) * buttonWidth * -1
        self.onClick = onClick
    }
    
    func reset() {
        visibleButton = .none
        offset = 0
        oldOffset = 0
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .contentShape(Rectangle()) ///otherwise swipe won't work in vacant area
                .offset(x: offset)
                .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .local)
                    .onChanged({ (value) in
                        
                        let totalSlide = value.translation.width + oldOffset
                        
                        if  (0...Int(maxLeadingOffset) ~= Int(totalSlide)) || (Int(minTrailingOffset)...0 ~= Int(totalSlide)) { //left to right slide
                            withAnimation{
                                offset = totalSlide
                            }
                            print(offset)
                        }
                        ///can update this logic to set single button action with filled single button background if scrolled more then buttons width
                    })
                        .onEnded({ value in
                            withAnimation {
                                if visibleButton == .left && value.translation.width < -20 { ///user dismisses left buttons
                                    reset()
                                } else if  visibleButton == .right && value.translation.width > 20 { ///user dismisses right buttons
                                    reset()
                                } else if offset > 25 || offset < -25 { ///scroller more then 50% show button
                                    if offset > 0 {
                                        visibleButton = .left
                                        offset = maxLeadingOffset
                                    } else {
                                        visibleButton = .right
                                        offset = minTrailingOffset
                                    }
                                    oldOffset = offset
                                    ///Bonus Handling -> set action if user swipe more then x px
                                } else {
                                    reset()
                                }
                            }
                        })
                )
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(leadingButtons) { buttonsData in
                            Button(action: {
                                withAnimation {
                                    reset()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { ///call once hide animation done
                                    onClick(buttonsData)
                                }
                            }, label: {
                                CellButtonView.init(data: buttonsData, cellHeight: proxy.size.height)
                            })
                        }
                    }.offset(x: (-1 * maxLeadingOffset) + offset)
                    Spacer()
                    HStack(spacing: 0) {
                        ForEach(trailingButton) { buttonsData in
                            Button(action: {
                                withAnimation {
                                    reset()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { ///call once hide animation done
                                    onClick(buttonsData)
                                }
                            }, label: {
                                CellButtonView.init(data: buttonsData, cellHeight: proxy.size.height)
                            })
                        }
                    }.offset(x: (-1 * minTrailingOffset) + offset)
                }
            }
        }
    }
}
