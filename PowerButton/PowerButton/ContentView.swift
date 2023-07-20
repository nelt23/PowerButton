//
//  ContentView.swift
//  PowerButton
//
//  Created by Nuno Martins on 27/04/2021.
//

// ver depois -> https://stackoverflow.com/questions/60521118/how-to-move-a-view-shape-along-a-custom-path-with-swiftui


import SwiftUI

// idea -> https://dribbble.com/shots/9514299-Power-Button
// color literal -> https://designcode.io/swiftui-handbook-color-literals
// transaction single -> https://www.hackingwithswift.com/books/ios-swiftui/animating-simple-shapes-with-animatabledata
// arc shape -> https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
// animatable pair -> https://www.hackingwithswift.com/books/ios-swiftui/animating-complex-shapes-with-animatablepair

struct Arc: Shape {
    
    var startAngle: CGFloat
    var endAngle: CGFloat
    var clockwise: Bool

    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
           AnimatablePair(startAngle, endAngle)
        }

        set {
            self.startAngle = newValue.first
            self.endAngle = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment: CGFloat = 90
        let modifiedStart = Angle.degrees(Double(startAngle - rotationAdjustment))
        let modifiedEnd = Angle.degrees(Double(endAngle - rotationAdjustment))

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
}

struct Rect: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        
        return path
    }
}


struct ContentView: View {
    
    @State private var activebutton = true

    
    @State private var clockwiseOutside = true
    @State private var startAngleOutside: CGFloat = 0
    @State private var endAngleOutside: CGFloat = 360
    @State private var percent_ON_icon: CGFloat = 0
    @State private var percent_MARK_icon_small: CGFloat = 0
    @State private var percent_MARK_icon_big: CGFloat = 1

    @State private var startAngleInside: CGFloat = 45
    @State private var endAngleInside: CGFloat = 315
    @State private var clockwiseInside = true

    
    var body: some View {
        
        ZStack {
            
            Color(#colorLiteral(red: 0.02676557377, green: 0.08899696916, blue: 0.2056943774, alpha: 1))
            .edgesIgnoringSafeArea(.all)
                        
            ZStack {
                        
                Button(action: {
                    
                    // bloquear novos clicks, evitando sobreposição de animações
                    if activebutton {
                        self.activebutton = !self.activebutton
                        
                        // "starts off slow and picks up speed over time"
                        withAnimation(.easeIn(duration: 0.3)) {
                            // desaparecer o icon ON
                            self.percent_ON_icon = 1
                        }
                        
                        // ao fim de 15 segundos começa a animação
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            
                            // 1.
                            // arco externo fecha no sentido horário
                            withAnimation(.easeOut(duration: 0.7)) {
                                self.endAngleOutside = 0
                            }
                            
                            
                            // animação 45/315
                            //semi-volta mais lenta
                            // Start 45 -> 0
                            // End 315 -> 180
                            withAnimation(.easeIn(duration: 0.25)) {
                                self.startAngleInside = 0
                                self.endAngleInside = 180
                            }
                            
                            // evitar delays colocar menos 2 segundos
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
                                // mudar Start de angulo de 0=360
                                self.startAngleInside = 360
                                
                                // Start 360->280
                                // End 180->0
                                withAnimation(.easeIn(duration: 0.3)) {
                                    self.startAngleInside = 280
                                    self.endAngleInside = 0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    // mudar End de angulo de 0=360
                                    self.endAngleInside = 360
                                    
                                    // evitar delays este tempo é bom
                                    // End 360->280
                                    withAnimation(.easeIn(duration: 0.18)) {
                                        self.endAngleInside = 280
                                    }
                                    
                                }
                                
                            }
                            
                            // assim que termina a primeira volta
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { // alterar quando terminar
                                // 2.
                                self.clockwiseOutside = !self.clockwiseOutside
                                // End 0=360
                                self.startAngleOutside =  360 // necessario ficar 360 pq se nao quando acabava nao ficava todo azul
                                // End 0=360
                                self.endAngleOutside =  360
                                // volta interna mais rápida -> MARK
                                // End 360->0
                                withAnimation(.easeIn(duration: 0.5)) {
                                    self.endAngleOutside =  0
                                }
                                
                                withAnimation(.easeIn(duration: 0.2)) {
                                    self.percent_MARK_icon_small =  1
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                    
                                    withAnimation(.easeIn(duration: 0.28)) {
                                        self.percent_MARK_icon_big = 0
                                    }
                                }
                                
                                // pausa de 0.1
                                // 3.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    
                                    // volta interna mais rápida -> MARK
                                    // End 360->0
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        self.endAngleOutside =  360
                                    }
                                    
                                    
                                    withAnimation(.easeIn(duration: 0.28)) {
                                        self.percent_MARK_icon_big =  1
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                                        
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            self.percent_MARK_icon_small = 0
                                        }
                                    }
                                    
                                    // ultima volta
                                    // 4.
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.clockwiseOutside = !self.clockwiseOutside
                                        // Start 360=0
                                        self.startAngleOutside =  0
                                        // Start 360=0
                                        self.endAngleOutside =  0
                                        
                                        // volta normal
                                        withAnimation(.easeIn(duration: 0.7)) {
                                            self.endAngleOutside =  360
                                        }
                                        
                                       
                                        // animation 315 -> 360
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            self.endAngleInside = 360
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                            // mudar End de angulo de 360=0
                                            self.endAngleInside = 0
                                            
                                            // Start 280->360
                                            // End 0->180
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                self.startAngleInside = 360
                                                self.endAngleInside = 180
                                            }
                                            
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                self.startAngleInside = 0
                                                
                                                withAnimation(.easeIn(duration: 0.23)) {
                                                    self.startAngleInside = 45
                                                    self.endAngleInside = 315
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                    self.activebutton = !self.activebutton
                                                }
                                                
                                            }
                                            
                                        }
                                    
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                self.percent_ON_icon = 0
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                }
                            }
                      }
                    }
                    
                }) {
                    // Label vazia com o background color
                    Circle()
                        .fill(Color(#colorLiteral(red: 0.02676557377, green: 0.08899696916, blue: 0.2056943774, alpha: 1)))
                        .frame(width: 200, height: 200)
                        
                }
                
                // 1 -> começar azul e desaparecer e tar no horario (true) de 0(start) / 360 -> 0(end)
                // 2 -> aparecer azul e ir tar no sentido anti-horario(false) de 360(start) / 360 -> 0(end)
                // 3 -> desaparecer azul e ir tar no sentido anti-horario(false) de 360(start) / 0 -> 360(end)
                // 4 -> aparecer azul e ir tar no horario(true) de 0(start) / 0 -> 360(end)
                
                // arco externo
                Arc(startAngle: startAngleOutside, endAngle: endAngleOutside, clockwise: clockwiseOutside)
                    .stroke(Color(#colorLiteral(red: 0.4507066011, green: 0.7801365256, blue: 0.9713473916, alpha: 1)), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                    .frame(width: 190, height: 190)
            
                // ON icon
                Rect()
                    .trim(from: percent_ON_icon, to: 1)
                    .stroke(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .frame(width: 5, height: 80)
                
                
                // startAngle até 0/360 e depois até 300
                
                // arco interno / OFF icon
                Arc(startAngle: startAngleInside, endAngle: endAngleInside, clockwise: clockwiseInside)
                    .stroke(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .frame(width: 60, height: 60)

                // MARK icon
                Group {
                    Rect()
                        .trim(from: 0, to: percent_MARK_icon_small)
                        .stroke(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .frame(width: 5, height: 70)
                        .rotationEffect(Angle(degrees: -50))
                    
                    Rect()
                        .trim(from: percent_MARK_icon_big, to: 1)
                        .stroke(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .frame(width: 5, height: 110)
                        .rotationEffect(Angle(degrees: 40))
 
                }
                .transformEffect(.init(translationX: -3, y: 18))
                
            }
        }
    }
    
}
