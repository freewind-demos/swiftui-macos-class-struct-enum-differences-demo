import SwiftUI // 导入 SwiftUI。

struct ValueCounter { // 定义值类型计数器。
    var count: Int // 保存计数值。
} // 结束值类型定义。

final class ReferenceCounter: ObservableObject { // 定义引用类型计数器。
    @Published var count: Int // 保存可观察计数值。
    let idText: String // 保存对象身份标识。

    init(count: Int, idText: String = UUID().uuidString) { // 定义初始化方法。
        self.count = count // 写入初始计数。
        self.idText = idText // 写入对象身份标识。
    } // 结束初始化方法。
} // 结束引用类型定义。

enum NetworkState { // 定义有限状态集合。
    case idle // 还没开始。
    case loading(progress: Double) // 加载中，并带进度。
    case success(message: String) // 成功，并带结果。
    case failure(reason: String) // 失败，并带原因。
} // 结束 enum 定义。

struct ContentView: View { // 定义主界面。
    @State private var structOriginal = ValueCounter(count: 1) // 保存 struct 原值。
    @State private var structCopy = ValueCounter(count: 1) // 保存 struct 副本。
    @StateObject private var classShared = ReferenceCounter(count: 1) // 保存共享 class 对象。
    @StateObject private var classAlias = ReferenceCounter(count: 1) // 保存别名对象引用入口。
    @State private var enumState: NetworkState = .idle // 保存当前 enum 状态。

    init() { // 定义初始化方法。
        let shared = ReferenceCounter(count: 1) // 先创建 1 个共享对象。
        _classShared = StateObject(wrappedValue: shared) // 让第 1 个入口持有它。
        _classAlias = StateObject(wrappedValue: shared) // 让第 2 个入口也指向同 1 个对象。
    } // 结束初始化方法。

    var body: some View { // 定义主界面内容。
        ScrollView { // 外层用滚动容器承接长内容。
            VStack(alignment: .leading, spacing: 24) { // 垂直排布 3 段演示。
                header // 顶部说明区。
                structDemo // struct 演示区。
                classDemo // class 演示区。
                enumDemo // enum 演示区。
            } // 结束垂直布局。
            .padding(28) // 给整体内容增加边距。
        } // 结束滚动容器。
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 占满窗口。
        .background(Color(nsColor: .windowBackgroundColor)) // 使用系统窗口背景。
    } // 结束主界面内容。

    private var header: some View { // 定义顶部说明区。
        VStack(alignment: .leading, spacing: 12) { // 垂直排布说明内容。
            Text("Class / Struct / Enum 差异 Demo") // 显示标题。
                .font(.system(size: 32, weight: .bold, design: .rounded)) // 强调标题。
            Text("这个 Demo 不只给结论，而是让你点按钮直接看到 3 件事：struct 改副本、class 共享同一对象、enum 表达有限状态。") // 显示总说明。
                .foregroundStyle(.secondary) // 弱化辅助文字。
            HStack(spacing: 10) { // 水平排布摘要标签。
                SummaryPill(text: "struct = 值拷贝", tint: .blue) // 标签 1。
                SummaryPill(text: "class = 引用共享", tint: .green) // 标签 2。
                SummaryPill(text: "enum = 有限状态", tint: .orange) // 标签 3。
            } // 结束摘要标签。
        } // 结束顶部说明区布局。
    } // 结束顶部说明区。

    private var structDemo: some View { // 定义 struct 演示区。
        DemoCard(title: "1. Struct：改副本，不改原值", subtitle: "重点看：把 a 赋给 b 后，再改 b，a 不会变。") { // 包 1 层统一卡片。
            VStack(alignment: .leading, spacing: 16) { // 垂直排布 struct 演示内容。
                CodeLine(text: "var a = ValueCounter(count: 1)") // 显示代码行 1。
                CodeLine(text: "var b = a") // 显示代码行 2。
                CodeLine(text: "b.count += 1") // 显示代码行 3。
                HStack(spacing: 16) { // 水平排布原值和副本。
                    ValueBox(title: "a 原值", value: "\(structOriginal.count)", accent: .blue) // 展示原值。
                    ValueBox(title: "b 副本", value: "\(structCopy.count)", accent: .cyan) // 展示副本。
                } // 结束原值和副本展示。
                HStack(spacing: 12) { // 放操作按钮。
                    Button("重置 a=1, b=1") { // 定义重置按钮。
                        structOriginal = ValueCounter(count: 1) // 重置原值。
                        structCopy = ValueCounter(count: 1) // 重置副本。
                    } // 结束重置动作。
                    Button("模拟 b = a") { // 定义赋值按钮。
                        structCopy = structOriginal // 让副本重新等于原值。
                    } // 结束赋值动作。
                    Button("只改 b + 1") { // 定义只改副本按钮。
                        structCopy.count += 1 // 只修改副本。
                    } // 结束修改副本动作。
                    Button("只改 a + 1") { // 定义只改原值按钮。
                        structOriginal.count += 1 // 只修改原值。
                    } // 结束修改原值动作。
                } // 结束按钮区。
                Text("观察点：`a` 和 `b` 只是内容相同，不是同一个对象。改哪份，只影响哪份。") // 补结论说明。
                    .foregroundStyle(.secondary) // 弱化说明文字。
            } // 结束 struct 演示内容。
        } // 结束 struct 演示卡片。
    } // 结束 struct 演示区。

    private var classDemo: some View { // 定义 class 演示区。
        DemoCard(title: "2. Class：共享引用，改一处两边都变", subtitle: "重点看：shared 和 alias 指向同 1 个对象。") { // 包 1 层统一卡片。
            VStack(alignment: .leading, spacing: 16) { // 垂直排布 class 演示内容。
                CodeLine(text: "let a = ReferenceCounter(count: 1)") // 显示代码行 1。
                CodeLine(text: "let b = a") // 显示代码行 2。
                CodeLine(text: "b.count += 1") // 显示代码行 3。
                HStack(spacing: 16) { // 水平排布两个入口。
                    ReferenceBox(counter: classShared, title: "a 入口", accent: .green) // 展示第 1 个入口。
                    ReferenceBox(counter: classAlias, title: "b 入口", accent: .mint) // 展示第 2 个入口。
                } // 结束两个入口展示。
                HStack(spacing: 12) { // 放操作按钮。
                    Button("重置 count=1") { // 定义重置按钮。
                        classShared.count = 1 // 重置共享对象的值。
                    } // 结束重置动作。
                    Button("只通过 a + 1") { // 定义 a 修改按钮。
                        classShared.count += 1 // 通过 a 入口修改共享对象。
                    } // 结束 a 修改动作。
                    Button("只通过 b + 1") { // 定义 b 修改按钮。
                        classAlias.count += 1 // 通过 b 入口修改共享对象。
                    } // 结束 b 修改动作。
                } // 结束按钮区。
                Text("观察点：2 个入口显示同样 `id`，说明它们不是两份数据，而是同 1 个对象。") // 补结论说明。
                    .foregroundStyle(.secondary) // 弱化说明文字。
            } // 结束 class 演示内容。
        } // 结束 class 演示卡片。
    } // 结束 class 演示区。

    private var enumDemo: some View { // 定义 enum 演示区。
        DemoCard(title: "3. Enum：值只能是几种状态之一", subtitle: "重点看：同一时刻只能处于 1 个 case，不会又 success 又 failure。") { // 包 1 层统一卡片。
            VStack(alignment: .leading, spacing: 16) { // 垂直排布 enum 演示内容。
                CodeLine(text: "enum NetworkState {") // 显示代码行 1。
                CodeLine(text: "  case idle") // 显示代码行 2。
                CodeLine(text: "  case loading(progress: Double)") // 显示代码行 3。
                CodeLine(text: "  case success(message: String)") // 显示代码行 4。
                CodeLine(text: "  case failure(reason: String)") // 显示代码行 5。
                StatePanel(title: enumTitle, detail: enumDetail, tint: enumTint) // 展示当前状态。
                HStack(spacing: 12) { // 放状态切换按钮。
                    Button("idle") { // 定义 idle 按钮。
                        enumState = .idle // 切到 idle。
                    } // 结束 idle 动作。
                    Button("loading 30%") { // 定义 loading 按钮。
                        enumState = .loading(progress: 0.3) // 切到 loading。
                    } // 结束 loading 动作。
                    Button("success") { // 定义 success 按钮。
                        enumState = .success(message: "拿到 18 条数据") // 切到 success。
                    } // 结束 success 动作。
                    Button("failure") { // 定义 failure 按钮。
                        enumState = .failure(reason: "网络超时") // 切到 failure。
                    } // 结束 failure 动作。
                } // 结束按钮区。
                Text("观察点：enum 把“合法状态集合”写死了。比 `isLoading + data? + error?` 更稳，不易出现非法组合。") // 补结论说明。
                    .foregroundStyle(.secondary) // 弱化说明文字。
            } // 结束 enum 演示内容。
        } // 结束 enum 演示卡片。
    } // 结束 enum 演示区。

    private var enumTitle: String { // 计算当前状态标题。
        switch enumState { // 根据当前状态分支。
        case .idle: // idle 分支。
            "当前是 idle" // 返回 idle 标题。
        case .loading: // loading 分支。
            "当前是 loading" // 返回 loading 标题。
        case .success: // success 分支。
            "当前是 success" // 返回 success 标题。
        case .failure: // failure 分支。
            "当前是 failure" // 返回 failure 标题。
        } // 结束分支。
    } // 结束状态标题计算。

    private var enumDetail: String { // 计算当前状态细节。
        switch enumState { // 根据当前状态分支。
        case .idle: // idle 分支。
            "还没开始。" // 返回 idle 说明。
        case .loading(let progress): // loading 分支。
            "进度 = \(Int(progress * 100))%" // 返回 loading 说明。
        case .success(let message): // success 分支。
            message // 返回 success 消息。
        case .failure(let reason): // failure 分支。
            reason // 返回 failure 原因。
        } // 结束分支。
    } // 结束状态细节计算。

    private var enumTint: Color { // 计算当前状态颜色。
        switch enumState { // 根据当前状态分支。
        case .idle: // idle 分支。
            .gray // 返回灰色。
        case .loading: // loading 分支。
            .blue // 返回蓝色。
        case .success: // success 分支。
            .green // 返回绿色。
        case .failure: // failure 分支。
            .red // 返回红色。
        } // 结束分支。
    } // 结束状态颜色计算。
} // 结束主界面定义。

private struct DemoCard<Content: View>: View { // 定义统一卡片容器。
    let title: String // 保存卡片标题。
    let subtitle: String // 保存卡片副标题。
    @ViewBuilder let content: Content // 保存卡片主体内容。

    var body: some View { // 定义卡片外观。
        VStack(alignment: .leading, spacing: 16) { // 垂直排布卡片内容。
            Text(title) // 显示标题。
                .font(.title2.weight(.bold)) // 强调标题。
            Text(subtitle) // 显示副标题。
                .foregroundStyle(.secondary) // 弱化副标题。
            content // 注入外部内容。
        } // 结束卡片内容布局。
        .padding(20) // 给卡片加边距。
        .frame(maxWidth: .infinity, alignment: .leading) // 拉满宽度并左对齐。
        .background(Color(nsColor: .controlBackgroundColor)) // 使用系统控制背景色。
        .clipShape(RoundedRectangle(cornerRadius: 16)) // 做圆角。
        .overlay( // 增加描边。
            RoundedRectangle(cornerRadius: 16) // 创建同尺寸圆角矩形。
                .stroke(Color.black.opacity(0.06), lineWidth: 1) // 绘制淡描边。
        ) // 结束描边。
    } // 结束卡片外观。
} // 结束卡片容器。

private struct SummaryPill: View { // 定义顶部摘要标签。
    let text: String // 保存标签文字。
    let tint: Color // 保存标签颜色。

    var body: some View { // 定义标签样式。
        Text(text) // 显示标签文字。
            .font(.system(size: 12, weight: .medium, design: .rounded)) // 设置字体。
            .padding(.horizontal, 10) // 设置水平内边距。
            .padding(.vertical, 6) // 设置垂直内边距。
            .background(tint.opacity(0.14)) // 设置浅背景。
            .clipShape(Capsule()) // 做成胶囊。
    } // 结束标签样式。
} // 结束顶部摘要标签。

private struct CodeLine: View { // 定义代码行展示组件。
    let text: String // 保存代码文字。

    var body: some View { // 定义代码行外观。
        Text(text) // 显示代码文字。
            .font(.system(.body, design: .monospaced)) // 使用等宽字体。
            .padding(.horizontal, 12) // 设置水平内边距。
            .padding(.vertical, 8) // 设置垂直内边距。
            .background(Color.black.opacity(0.04)) // 设置浅灰背景。
            .clipShape(RoundedRectangle(cornerRadius: 10)) // 做圆角。
    } // 结束代码行外观。
} // 结束代码行组件。

private struct ValueBox: View { // 定义值类型展示盒子。
    let title: String // 保存标题。
    let value: String // 保存值文本。
    let accent: Color // 保存主色。

    var body: some View { // 定义盒子外观。
        VStack(alignment: .leading, spacing: 10) { // 垂直排布内容。
            Text(title) // 显示标题。
                .font(.headline) // 强调标题。
            Text(value) // 显示值。
                .font(.system(size: 32, weight: .bold, design: .rounded)) // 放大值。
        } // 结束内容布局。
        .padding(16) // 给盒子加边距。
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading) // 给盒子稳定尺寸。
        .background(accent.opacity(0.10)) // 设置浅色背景。
        .clipShape(RoundedRectangle(cornerRadius: 14)) // 做圆角。
    } // 结束盒子外观。
} // 结束值类型展示盒子。

private struct ReferenceBox: View { // 定义引用类型展示盒子。
    @ObservedObject var counter: ReferenceCounter // 观察共享对象。
    let title: String // 保存标题。
    let accent: Color // 保存主色。

    var body: some View { // 定义盒子外观。
        VStack(alignment: .leading, spacing: 10) { // 垂直排布内容。
            Text(title) // 显示标题。
                .font(.headline) // 强调标题。
            Text("count = \(counter.count)") // 显示当前计数。
                .font(.system(size: 30, weight: .bold, design: .rounded)) // 放大计数。
            Text("id = \(counter.idText)") // 显示对象身份。
                .font(.footnote.monospaced()) // 用等宽字体显示身份。
                .textSelection(.enabled) // 允许复制。
                .foregroundStyle(.secondary) // 弱化身份色。
        } // 结束内容布局。
        .padding(16) // 给盒子加边距。
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading) // 给盒子稳定尺寸。
        .background(accent.opacity(0.10)) // 设置浅色背景。
        .clipShape(RoundedRectangle(cornerRadius: 14)) // 做圆角。
    } // 结束盒子外观。
} // 结束引用类型展示盒子。

private struct StatePanel: View { // 定义状态展示面板。
    let title: String // 保存标题。
    let detail: String // 保存细节。
    let tint: Color // 保存主色。

    var body: some View { // 定义面板外观。
        VStack(alignment: .leading, spacing: 10) { // 垂直排布内容。
            Text(title) // 显示标题。
                .font(.headline) // 强调标题。
            Text(detail) // 显示细节。
                .font(.system(size: 24, weight: .bold, design: .rounded)) // 放大细节文字。
        } // 结束内容布局。
        .padding(16) // 给面板加边距。
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading) // 给面板稳定尺寸。
        .background(tint.opacity(0.10)) // 设置浅色背景。
        .clipShape(RoundedRectangle(cornerRadius: 14)) // 做圆角。
    } // 结束面板外观。
} // 结束状态展示面板。

#Preview("Main") { // 定义主预览。
    ContentView() // 预览主界面。
        .frame(width: 1180, height: 880) // 设定预览尺寸。
} // 结束主预览。
