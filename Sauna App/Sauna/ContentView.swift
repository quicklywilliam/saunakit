//
//  ContentView.swift
//  Sauna Watch WatchKit Extension
//
//  Created by William Henderson on 2/8/20.
//  Copyright © 2020 Knock Software, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var saunaManager: SaunaManager = SaunaManager()
    @State private var animate = false
    
    let targetTemperature = Double(180)
    let lowTemperature = Double(70)
    
    private var isSaunaOn: Bool {
        saunaManager.isOn ?? false
    }
    private var temperatureDouble: Double? {
        if let temp = saunaManager.temperatureFareinheit {
            return Double(temp)
        }
        
        return nil
    }
    private var relativeTempt: Double {
        if let temperatureDouble = self.temperatureDouble {
            if temperatureDouble < lowTemperature {
                return Double(0)
            }
            return (temperatureDouble-lowTemperature)/(targetTemperature - lowTemperature)
        }
        
        return Double(0)
    }
    var color1: Color {
        if self.isSaunaOn {
            return Color(red: 0.9 - 0.1*(1-self.relativeTempt), green: 0.7, blue: 0.69*(1-self.relativeTempt))
        }
        
        return self.disabledColor
    }
    var color2: Color {
        if self.isSaunaOn {
            return Color(red: 1.0 - 0.3*(1-self.relativeTempt), green: 0.5*(1-self.relativeTempt), blue: 0.5*(1-self.relativeTempt))
        }
        
        return self.disabledColor
    }
    var disabledColor: Color {
        Color.gray
    }
    
    var body: some View {
        let spectrum = Gradient(colors: [self.color1, self.color2])
        let percentage = 1.0
        let angle = Angle.radians(2*Double.pi*percentage - Double.pi/2)
        
            if self.temperatureDouble != nil {
                return AnyView(ZStack {
                    AngularGradient(gradient: spectrum, center: .center, angle: angle)
                    .drawingGroup().onAppear {
                        withAnimation(Animation.linear(duration: 4.0).repeatForever()) {
                                self.animate = true
                        }
                    }
                    Text(String(format: "%.0fºF", self.temperatureDouble!))
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                    }.edgesIgnoringSafeArea(.all))
        }
        
        return AnyView(VStack {
            Text("🙅‍♀️").font(.largeTitle)
            Text("Can't connect to sauna")
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
