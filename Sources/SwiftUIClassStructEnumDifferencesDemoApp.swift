import SwiftUI // 导入 SwiftUI。

@main // 声明应用入口。
struct SwiftUIClassStructEnumDifferencesDemoApp: App { // 定义 demo app。
    var body: some Scene { // 定义主场景。
        Window("Class / Struct / Enum", id: "main") { // 创建主窗口。
            ContentView() // 把主视图放进窗口。
        } // 结束窗口内容。
        .defaultSize(width: 1180, height: 880) // 设定默认窗口尺寸。
    } // 结束场景定义。
} // 结束 app 定义。
