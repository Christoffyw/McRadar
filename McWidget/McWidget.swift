//
//  McWidget.swift
//  McWidget
//
//  Created by Christopher Weinhardt on 2023-10-05.
//

import WidgetKit
import SwiftUI
import Intents
import CoreLocation

class YourLocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var magneticHeading = 0.0
    var trueHeading = 0.0
    
    override init() {
        super.init()
        
        // Set up the location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request location authorization
        locationManager.startUpdatingHeading() // Start updating heading information
    }
    
    // CLLocationManagerDelegate method called when the heading is updated
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Get the heading information
        trueHeading = newHeading.trueHeading // The heading in degrees (0 to 359.9 degrees)
        magneticHeading = newHeading.magneticHeading // The magnetic heading in degrees (0 to 359.9 degrees)
        
        // Use the heading information as needed
        print("True Heading: \(trueHeading)")
        print("Magnetic Heading: \(magneticHeading)")
    }
    
    // Handle errors if heading information cannot be obtained
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting heading: \(error.localizedDescription)")
    }
    
    func getTrueHeading() -> Double {
        return trueHeading
    }
    
    func getMagneticHeading() -> Double{
        return magneticHeading
    }
}


struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), heading:20, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), heading: 20.0, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        let currentDate = Date()
        let location = YourLocationManager()
        var heading = 0.0
        for second in 0...59 {
            let entryDate = Calendar.current.date(byAdding: .second, value: second, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, heading: location.getMagneticHeading(), configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let heading: Double
    let configuration: ConfigurationIntent
}

struct McWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
                Color.clear
                    .frame(width: 128, height:100)
                    .overlay (
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 0, y: 15))
                            path.addLine(to: CGPoint(x: 40, y: 0))
                            path.addLine(to: CGPoint(x: 0, y: -15))
                            path.addLine(to: CGPoint(x: 0, y: 0))
                        }
                        .fill(.red)
                        .foregroundColor(.red)
                        .offset(x: 44, y: 50)
                    )
                    .rotationEffect(Angle(degrees: entry.heading), anchor: .center)
            
        }
    }

struct McWidget: Widget {
    let kind: String = "McWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            McWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct McWidget_Previews: PreviewProvider {
    static var previews: some View {
        McWidgetEntryView(entry: SimpleEntry(date: Date(),heading: 190.0, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
