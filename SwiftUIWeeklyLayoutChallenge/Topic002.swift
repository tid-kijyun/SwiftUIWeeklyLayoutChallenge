//
//  Topic002View.swift
//  SwiftUIWeeklyLayoutChallenge
//
//  Created by treastrain on 2022/07/20.
//

import SwiftUI

// MARK: - Entities
fileprivate struct Vital: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let value: Value
    let date: Date
    let iconSystemName: String
    let color: Color
    
    enum Value {
        case number(value: Double, style: NumberFormatter.Style, customUnit: String? = nil)
        case dateComponents(_ dateComponents: DateComponents)
        case measurement(value: Double, unit: Dimension, formattedUnit: Dimension? = nil)
    }
}

// MARK: - Sample Data
fileprivate let vitalData: [Vital] = [
    .init(title: "取り込まれた酸素のレベル", value: .number(value: 0.99, style: .percent), date: Date(timeIntervalSinceNow: -300), iconSystemName: "o.circle.fill", color: .blue),
    .init(title: "心拍数", value: .number(value: 61, style: .decimal, customUnit: "拍/分"), date: Date(timeIntervalSinceNow: -5400), iconSystemName: "heart.fill", color: .red),
    .init(title: "睡眠", value: .dateComponents(.init(minute: 451)), date: Date(timeIntervalSinceNow: -87000), iconSystemName: "bed.double.fill", color: .green),
    .init(title: "体温", value: .measurement(value: 36.4, unit: UnitTemperature.celsius), date: Date(timeIntervalSinceNow: -172800), iconSystemName: "thermometer", color: .red),
]

// MARK: - Views
/// <doc:Topic002>
public struct Topic002View: View {
    public init() {
    }

    public var body: some View {
        VitalView()
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}

struct VitalView: View {
    @Environment(\.locale) private var locale

    public init() {
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(vitalData) { vital in
                    vitalCell(vital: vital)
                }
            }
            .navigationTitle("バイタルデータ")
        }
        .navigationViewStyle(.stack)
    }

    private func vitalCell(vital: Vital) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationLink {

            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Label {
                            Text(vital.title)
                                .font(.subheadline.bold())
                        } icon: {
                            Image(systemName: vital.iconSystemName)
                        }
                        .foregroundStyle(vital.color)

                        Spacer()

                        relativeDateText(date: vital.date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
#if os(watchOS)
                    vitalValueView(vitalValue: vital.value)
#elseif os(tvOS)
                    vitalValueView(vitalValue: vital.value)
                        .padding(.top, 16)
#endif
                }
            }
#if os(iOS)
            vitalValueView(vitalValue: vital.value)
#endif
        }
        .padding(.vertical, 5)
    }

    private func relativeDateText(date: Date) -> some View {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.locale = locale
        return Text(formatter.string(for: date)!)
    }

    private func vitalValueView(vitalValue: Vital.Value) -> some View {
        let str: String
        switch vitalValue {
        case .number(let value, let style, let customUnit):
            let formatter = NumberFormatter()
            formatter.locale = locale
            formatter.numberStyle = style
            formatter.positiveSuffix = customUnit
            str = formatter.string(from: value as NSNumber) ?? ""
        case .dateComponents(let dateComponents):
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = locale
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .brief
            formatter.allowedUnits = [.hour, .minute]
            formatter.calendar = calendar
            str = formatter.string(from: dateComponents) ?? ""
        case .measurement(let value, let unit, _):
            let formatter = MeasurementFormatter()
            formatter.locale = locale
            let temp = Measurement(value: value, unit: unit)
            str = formatter.string(from: temp)
        }

        let primaryAttributes = AttributeContainer()
            .foregroundColor(.primary)
            .font(.system(.title, design: .rounded).weight(.medium))
        let secondaryAttributes = AttributeContainer()
            .foregroundColor(.secondary)
            .font(.subheadline.weight(.medium))
        var attributedString = AttributedString()
        for c in str {
            var part = AttributedString("\(c)")
            if c.isNumber || c == "." {
                part.setAttributes(primaryAttributes)
            } else {
                part.setAttributes(secondaryAttributes)
            }
            attributedString.append(part)
        }
        return Text(attributedString)
    }
}

struct Topic002View_Previews: PreviewProvider {
    static var previews: some View {
        Topic002View()
    }
}
