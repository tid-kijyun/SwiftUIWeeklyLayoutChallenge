//
//  Answer003.swift
//  SwiftUIWeeklyLayoutChallenge
//
import SwiftUI
import Combine

/// <doc:Topic003>
public struct Topic003View: View {
    public init() {}

    public var body: some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
#if os(macOS)
            DepartureSignal()
                .padding()
#else
            if #available(watchOS 7.0, *) {
                NavigationView {
                    DepartureSignal()
                }
#if !os(macOS)
        .navigationViewStyle(.stack)
#endif
            } else {
                DepartureSignal()
            }
#endif
        } else {
            Text("Support for this platform is not considered.")
        }
    }
}

private extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
            }
        )
    }
}

enum Signal: String, CaseIterable, Identifiable, Hashable {
    /// 上の灯火から順に 消・消・緑・消 で進行信号を現示。
    case 出発進行
    /// 上の灯火から順に 黄・消・消・緑 で減速信号を現示。
    case 出発減速
    /// 上の灯火から順に 消・消・消・黄 で注意信号を現示。
    case 出発注意
    /// 上の灯火から順に 黄・消・消・黄 で警戒信号を現示。
    case 出発警戒
    /// 上の灯火から順に 消・赤・消・消 で停止信号を現示。
    case 出発停止

    var id: String { rawValue }

    var pattern: [Light] {
        switch self {
        case .出発進行:
            return [.消, .消, .緑, .消]
        case .出発減速:
            return [.黄, .消, .消, .緑]
        case .出発注意:
            return [.消, .消, .消, .黄]
        case .出発警戒:
            return [.黄, .消, .消, .黄]
        case .出発停止:
            return [.消, .赤, .消, .消]
        }
    }

    init?(lights: [Light]) {
        self.init(rawValue: Signal.allCases.first(where: { $0.pattern.elementsEqual(lights) })?.rawValue ?? "")
    }
}

enum Light: String, Identifiable, Equatable {
    case 消, 赤, 黄, 緑
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .消:
            return .black
        case .赤:
            return .red
        case .黄:
            return .yellow
        case .緑:
            return .green
        }
    }
}

struct LightItem: Identifiable, Equatable {
    let name: String
    var light: Light
    let preset: [Light]
    var id: String { name }
}

final class LightSwitcher: ObservableObject {
    @Published var signal: Signal?
    @Published var items: [LightItem] = [
        .init(name: "灯1", light: .消, preset: [.黄, .消]),
        .init(name: "灯2", light: .消, preset: [.赤, .消]),
        .init(name: "灯3", light: .消, preset: [.緑, .消]),
        .init(name: "灯4", light: .消, preset: [.緑, .黄, .消]),
    ]

    init() {
        $items
            .map { Signal(lights: $0.map { $0.light }) }
            .assign(to: &$signal)
    }

    func apply(_ signal: Signal?) {
        withAnimation {
            for i in 0..<items.count {
                items[i].light = signal?.pattern[i] ?? .消
            }
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct DepartureSignal: View {
    @StateObject private var lightSwitcher: LightSwitcher = .init()

    var body: some View {
        Form {
            Section {
                VStack {
                    ForEach(lightSwitcher.items) { item in
                        lightImage(light: item.light)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }

            Section {
                signalPicker(signal: $lightSwitcher.signal, onChange: lightSwitcher.apply)
            }

            Section {
                lightPicker(item: $lightSwitcher.items[0])
                lightPicker(item: $lightSwitcher.items[1])
                lightPicker(item: $lightSwitcher.items[2])
                lightPicker(item: $lightSwitcher.items[3])
            }
        }
        .navigationTitle("出発信号機")
    }

    func lightImage(light: Light) -> some View {
        Image(systemName: "circle.fill")
            .font(.largeTitle)
            .foregroundColor(light.color)
    }

    func signalPicker(signal: Binding<Signal?>, onChange apply: @escaping (Signal?) -> Void) -> some View {
#if os(iOS)
        Menu {
            Picker(selection: signal.onChange(apply)) {
                Text(verbatim: "---").tag(Signal?(nil))
                ForEach(Signal.allCases) { signal in
                    Text(signal.rawValue).tag(Signal?.some(signal))
                }
            } label: {
            }
        } label: {
            HStack {
                Spacer()
                Text(lightSwitcher.signal?.rawValue ?? "---")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .animation(nil)
                Spacer()
            }
        }
#else
        Picker(selection: signal.onChange(apply)) {
            Text(verbatim: "---").tag(Signal?(nil))
            ForEach(Signal.allCases) { signal in
                Text(signal.rawValue).tag(Signal?.some(signal))
            }
        } label: {
            Text("指差呼称")
        }
#endif
    }

    func lightPicker(item: Binding<LightItem>) -> some View {
        HStack {
            Text(verbatim: item.wrappedValue.name)
            Spacer()
            Picker("", selection: item.light.animation()) {
                ForEach(item.wrappedValue.preset) { light in
                    Text(verbatim: light.rawValue).tag(light)
                }
            }
            .labelsHidden()
            .fixedSize()
#if os(iOS) || os(tvOS)
            .pickerStyle(.segmented)
#else
            .pickerStyle(.automatic)
#endif
        }
    }
}

struct Topic003View_Previews: PreviewProvider {
    static var previews: some View {
        Topic003View()
    }
}
