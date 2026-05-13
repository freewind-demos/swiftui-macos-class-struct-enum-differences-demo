# SwiftUI macOS Class / Struct / Enum 差异 Demo

## 简介

这个 Demo 用 1 个独立 macOS SwiftUI 窗口，把 `struct`、`class`、`enum` 的核心差异直接做成交互演示。

你不用先背概念，点按钮就能看到：

1. `struct` 改副本，不改原值
2. `class` 共享同一个对象，改一处两边都变
3. `enum` 适合表达“值只能是几种状态之一”

## 快速开始

### 环境要求

- macOS 14+
- Xcode 15+
- XcodeGen

安装 `XcodeGen`：

```bash
brew install xcodegen
```

### 运行

```bash
cd /Users/peng.li/workspace/freewind-demos/swiftui-macos-class-struct-enum-differences-demo
./scripts/build.sh
open build/DerivedData/Build/Products/Debug/SwiftUIClassStructEnumDifferencesDemo.app
```

如果你想直接打开工程：

```bash
cd /Users/peng.li/workspace/freewind-demos/swiftui-macos-class-struct-enum-differences-demo
xcodegen generate
open SwiftUIClassStructEnumDifferencesDemo.xcodeproj
```

## 注意事项

- 这个 Demo 是教学用，不追求业务完整性
- `class` 演示区故意让 2 个入口指向同 1 个对象，方便看“引用共享”
- `enum` 演示区故意用“网络状态”举例，因为这是最常见场景

## 教程

### 1. 关键概念

先压缩成 3 句：

- `struct` 是值类型
- `class` 是引用类型
- `enum` 是有限状态集合

#### `struct`

当你写：

```swift
var a = ValueCounter(count: 1)
var b = a
```

`b` 是一份新值。

后面改：

```swift
b.count += 1
```

不会影响 `a`。

#### `class`

当你写：

```swift
let a = ReferenceCounter(count: 1)
let b = a
```

`a` 和 `b` 不是两份数据，而是同 1 个对象的两个入口。

所以后面改：

```swift
b.count += 1
```

`a.count` 也会变。

#### `enum`

`enum` 不是“几个常量”这么简单。

它真正的价值是：**同 1 个值，只能处于几种合法情况之一。**

比如：

```swift
enum NetworkState {
    case idle
    case loading(progress: Double)
    case success(message: String)
    case failure(reason: String)
}
```

这比同时维护：

- `isLoading`
- `message?`
- `error?`

更稳，因为不会轻易组合出非法状态。

### 2. Demo 原理

这个 Demo 分 3 块。

#### 第一块：Struct

界面里同时显示：

- `a 原值`
- `b 副本`

按钮分别做：

- 重置
- `b = a`
- 只改 `b`
- 只改 `a`

所以你可以直接看到：

- 改 `b` 不影响 `a`
- 改 `a` 也不影响 `b`

这就是值语义。

#### 第二块：Class

这里故意先创建 1 个共享对象：

```swift
let shared = ReferenceCounter(count: 1)
```

再让两个入口都指向它：

```swift
classShared = shared
classAlias = shared
```

界面里会同时显示：

- `count`
- `id`

`id` 一样，说明就是同 1 个对象。

所以你点：

- `只通过 a + 1`
- `只通过 b + 1`

两边数值都会一起变。

#### 第三块：Enum

这里用 4 个按钮切状态：

- `idle`
- `loading 30%`
- `success`
- `failure`

界面中间的状态面板会根据 `switch` 实时显示：

- 当前 case
- 这个 case 带的数据

这样你能很直观看到：

- 当前只会落在 1 个 case
- 不会同时 success 和 failure

### 3. 关键代码解读

#### Struct 的最小关键代码

```swift
struct ValueCounter {
    var count: Int
}
```

和：

```swift
structCopy = structOriginal
structCopy.count += 1
```

关键点是：赋值后拿到的是副本。

#### Class 的最小关键代码

```swift
final class ReferenceCounter: ObservableObject {
    @Published var count: Int
    let idText: String
}
```

和：

```swift
let shared = ReferenceCounter(count: 1)
_classShared = StateObject(wrappedValue: shared)
_classAlias = StateObject(wrappedValue: shared)
```

关键点是：两个入口包着同 1 个对象。

#### Enum 的最小关键代码

```swift
enum NetworkState {
    case idle
    case loading(progress: Double)
    case success(message: String)
    case failure(reason: String)
}
```

和：

```swift
switch enumState {
case .idle:
case .loading(let progress):
case .success(let message):
case .failure(let reason):
}
```

关键点是：每个状态都能带自己专属的数据。

## 操作

1. 先看第一块 `struct`
2. 点 `模拟 b = a`
3. 再点 `只改 b + 1`
4. 观察 `a` 不变，`b` 变化
5. 再看第二块 `class`
6. 点 `只通过 a + 1` 或 `只通过 b + 1`
7. 观察两边一起变化，且 `id` 相同
8. 最后看第三块 `enum`
9. 轮流点 4 个状态按钮
10. 观察状态面板一次只落在 1 个 case

## 源码入口

- `Sources/ContentView.swift`
- `Sources/SwiftUIClassStructEnumDifferencesDemoApp.swift`
