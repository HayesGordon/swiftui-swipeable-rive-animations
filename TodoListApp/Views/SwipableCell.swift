//
//  ContentCell.swift
//  TodoListApp
//
//  Created by Peter G Hayes on 23/02/2023.
//

import SwiftUI
import RiveRuntime

let animationTriggerValue : CGFloat = 75 // This is the trigger value for the Rive animation. As configured in the Rive animation.

struct ContentCell: View {
    let data: String
    var body: some View {
        VStack {
            HStack {
                Text(data).font(.title3).foregroundColor(.white)
                Spacer()
            }.padding(.all, 24)
            Divider()
                .padding(.leading)
        }
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


extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

struct RiveSwipeCell: ViewModifier {
    @State private var offset: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    @State private var hasTriggeredFinalAnimation: Bool = false;
    @State private var isEnded: Bool = false;
    
    let maxLeadingOffset: CGFloat = animationTriggerValue*2
    let minTrailingOffset: CGFloat = -animationTriggerValue*2
    
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    @State private var viewModel = RiveViewModel(fileName: "swipe_interaction", stateMachineName: "State Machine 1", fit: RiveFit.cover)
    
    init( onSwipeLeft: @escaping () -> Void, onSwipeRight: @escaping () -> Void) {
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        
        setSwipePercentage(value: 0) // make sure it's set to 0 at the start
    }
    
    func reset() {
        withAnimation {
            offset = 0
            oldOffset = 0
        }
    }
    
    func setSwipePercentage(value: CGFloat) {
        if hasTriggeredFinalAnimation {
            return; // Don't continue if already triggered}
        }
        
        var clampedValue = value
        
        if (!isEnded) {
            clampedValue = value.clamped(to: (-animationTriggerValue + 1)...(animationTriggerValue - 1))
        }
        
        viewModel.setInput("Swipe Direction", value: clampedValue)
        
        
        if (isEnded) {
            hasTriggeredFinalAnimation = true;
            
            if (value >= (animationTriggerValue)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) { ///call once hide animation is done. Time dependent on animation length
                    onSwipeRight()
                    reset()
                }
            } else if (value <= -(animationTriggerValue)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { ///call once hide animation is done.  Time dependent on animation length
                    onSwipeLeft()
                    reset()
                }
            }
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            viewModel.view().cornerRadius(15).shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3)
            content
                .contentShape(Rectangle()) ///otherwise swipe won't work in vacant area
                .offset(x: offset)
                .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
                    .onChanged({ (value) in
                        if (isEnded) {
                            return;
                        }
                        let totalSlide = value.translation.width + oldOffset
                        
                        if  (0...Int(maxLeadingOffset) ~= Int(totalSlide)) || (Int(minTrailingOffset)...0 ~= Int(totalSlide)) { //left to right slide
                            withAnimation{
                                offset = totalSlide
                            }
                        }
                    })
                        .onEnded({ value in
                            withAnimation {
                                if offset > animationTriggerValue * 1.5 || offset < -animationTriggerValue * 1.5 { ///scroller more then 50% show button
                                    isEnded = true
                                    if offset > 0 {
                                        offset = maxLeadingOffset
                                    } else {
                                        offset = minTrailingOffset
                                    }
                                    oldOffset = offset
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
        
    }
}
