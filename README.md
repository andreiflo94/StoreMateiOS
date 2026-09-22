<div align="center">

# 📦 StoreMate

**A small-store inventory manager for iOS, iPadOS and macOS — built with SwiftUI, SwiftData and Clean Architecture.**

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%20%7C%20macOS-lightgrey.svg)](#requirements)
[![Swift](https://img.shields.io/badge/Swift-5%2B-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-9cf.svg)](https://developer.apple.com/xcode/swiftdata/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Overview

StoreMate keeps track of what a small shop has on the shelf: products and their stock levels,
the suppliers they come from, and every sale or restock that moves the numbers. It runs entirely
on-device — no accounts, no backend, no network calls — with SwiftData as the local store.

The codebase is deliberately structured as a **Clean Architecture** reference: a framework-free
Domain layer, a SwiftData-backed Data layer, and a SwiftUI Presentation layer that never touches
persistence directly.

## Features

- 🗂 **Product catalog** — name, barcode, category, price, stock quantity, per-product low-stock
  threshold, and an optional supplier link. Searchable by name, barcode or category.
- 🚚 **Supplier directory** — contact person, email, phone and address, searchable, linked to the
  products they supply.
- 🔁 **Sales & restocks** — recording a transaction validates the quantity, refuses to oversell,
  and adjusts the product's stock in the same operation.
- 📉 **Low-stock dashboard** — every product at or below its threshold, lowest stock first, next to
  the ten most recent transactions.
- 📷 **Barcode scanning** — AVFoundation camera scanner (EAN-8/13, UPC-E, QR, Code 128, Code 39,
  PDF417) that either pre-fills a new product or fills the barcode field of the form you're in.
- 🧾 **History that survives edits** — each transaction snapshots the product name and unit price,
  so the log stays readable even after the product is renamed or deleted.
- 🔍 **Filter & sort** — transactions filter by sale/restock and sort newest- or oldest-first.

## Screens

| Tab | Screen | What it does |
| --- | --- | --- |
| 📊 Dashboard | `DashboardView` | Low-stock section (with quantity vs. threshold) and the 10 most recent transactions. |
| 📦 Products | `ProductListView` → `ProductFormView` | Searchable catalog with price, stock and low-stock warnings; swipe to delete; tap to edit. Toolbar offers "scan" and "add". The form covers details, pricing/stock and supplier selection, with an inline scan button. |
| 🏢 Suppliers | `SupplierListView` → `SupplierFormView` | Searchable vendor list; tap to edit, swipe to delete. |
| ↔️ Transactions | `TransactionListView` → `TransactionFormView` | Full history with filter/sort menu. The form picks a product and type, shows a live "current stock → new stock" summary, and disables Save when the sale would oversell. |
| 📷 Scanner | `BarcodeScannerView` | Full-screen camera sheet with an instruction overlay and a retry path when the camera is unavailable. |

## Architecture

Strict dependency direction — **Presentation → Domain ← Data**. The Domain layer imports nothing
but `Foundation`: no SwiftData, no SwiftUI. Everything crossing a layer boundary is a value type.

```
┌─────────────────────── Presentation ────────────────────────┐
│  View  ──binds──▶  @Observable ViewModel                    │
│  (SwiftUI)                    │                             │
└───────────────────────────────┼─────────────────────────────┘
                                │ calls
┌─────────────────────── Domain ▼─────────────────────────────┐
│  UseCases  ──▶  Repository protocols  ──▶  Entities         │
│  (Foundation only — no framework imports)                   │
└───────────────────────────────▲─────────────────────────────┘
                                │ implements
┌─────────────────────── Data ──┴─────────────────────────────┐
│  SwiftData*Repository  ──▶  Mappers  ──▶  @Model  *Model    │
└─────────────────────────────────────────────────────────────┘
```

```
StoreMateiOS/
├── App/                       StoreMateiOSApp, AppContainer (composition root), ContentView
├── Domain/
│   ├── Entities/              Product, Supplier, StoreTransaction, TransactionType
│   ├── Repositories/          ProductRepository, SupplierRepository, TransactionRepository (protocols)
│   └── UseCases/              RecordTransactionUseCase, FetchLowStockProductsUseCase
├── Data/
│   ├── Persistence/           ProductModel, SupplierModel, StoreTransactionModel (@Model)
│   ├── Mappers/               *Model.toDomain() conversions
│   └── Repositories/          SwiftDataProductRepository, …Supplier…, …Transaction…
└── Presentation/
    ├── Dashboard/  Products/  Suppliers/  Transactions/     one ViewModel + View per screen
    ├── BarcodeScanner/        AVFoundation scanner (iOS only)
    └── Common/                ErrorAlert view modifier
```

### Domain layer

Entities are plain `Sendable` structs. Business rules live here rather than in views or predicates:

- `Product.isLowStock` — `stockQuantity <= lowStockThreshold`.
- `RecordTransactionUseCase` — rejects non-positive quantities (`.invalidQuantity`), unknown
  products (`.productNotFound`) and oversold sales (`.insufficientStock`); otherwise adjusts stock
  and records a snapshotted transaction.
- `FetchLowStockProductsUseCase` — filters by `isLowStock` and sorts lowest-stock first, keeping
  the rule in Domain instead of expressing it as a SwiftData `#Predicate`.

### Data layer

SwiftData `@Model` classes are suffixed `Model` to keep them distinct from the domain entities and
hold the relationships (`ProductModel.supplier`, `SupplierModel.products`, `StoreTransactionModel.product`,
all with `.nullify` delete rules). The `SwiftData*Repository` types take a `ModelContext`, map
to and from domain entities, resolve relationships by `id`, and `save()` on every mutating call.
Products and suppliers are fetched sorted by name, transactions newest-first.

> Adding a new model? Register it in the `Schema([...])` array in `StoreMateiOSApp.swift`.

### Presentation layer

One `@Observable` ViewModel per screen, holding domain structs and calling repositories/use cases.
**Views never use `@Query` or `@Environment(\.modelContext)`** — they read from the ViewModel and
refresh via `load()` in `.onAppear`, plus `.sheet(onDismiss:)` after a form closes. That is the
deliberate replacement for `@Query`'s automatic cross-screen refresh.

### Dependency injection

`AppContainer` is the composition root: it owns the `ModelContext`, lazily builds the concrete
repositories and use cases, and vends ViewModels through `make…ViewModel()` factories.
`StoreMateiOSApp` creates it; `ContentView` injects it with `.environment`. List views build their
own ViewModel from the injected container, and sheet-presented forms are handed a ViewModel built
inside the `.sheet { }` closure — so no view ever constructs a repository.

## Technologies

| Area | Technology |
| --- | --- |
| UI | SwiftUI (`TabView` + `Tab` API, `NavigationStack`, `Form`, `.searchable`) |
| State | Swift Observation (`@Observable`, `@Bindable`, `@State`) |
| Persistence | SwiftData (`@Model`, `ModelContainer`, `FetchDescriptor`, `#Predicate`) |
| Camera | AVFoundation (`AVCaptureSession`, `AVCaptureMetadataOutput`) via `UIViewRepresentable` |
| Concurrency | Swift strict concurrency with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` |
| Testing | Swift Testing (`@Test` / `#expect`) for units, XCTest + `XCUIApplication` for UI |
| Build | Xcode project (no SwiftPM manifest), no third-party dependencies |

### Cross-platform

The app builds for iPhone, iPad, Mac and visionOS. Camera and barcode-scanner code is guarded with
`#if os(iOS)`, so non-iOS builds simply omit the scanner and use manual barcode entry.

## Requirements

- Xcode 26
- iOS / macOS **26.5** deployment target
- No external dependencies — clone and build

## Getting Started

```bash
git clone <your-fork-url> StoreMateiOS
cd StoreMateiOS
open StoreMateiOS.xcodeproj
```

Pick an iPhone 17 (or later) simulator and run. Barcode scanning needs a physical device — the
camera usage description (`NSCameraUsageDescription`) is already configured.

### Build from the command line

```bash
xcodebuild -project StoreMateiOS.xcodeproj -scheme StoreMateiOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## Testing

Domain use cases are tested against in-memory mock repositories (`InMemoryRepositories.swift`);
the SwiftData repositories get a round-trip test backed by `ModelContainer(isStoredInMemoryOnly: true)`.

```bash
# All unit tests
xcodebuild test -project StoreMateiOS.xcodeproj -scheme StoreMateiOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:StoreMateiOSTests

# A single test
xcodebuild test -project StoreMateiOS.xcodeproj -scheme StoreMateiOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:StoreMateiOSTests/RecordTransactionUseCaseTests/restockIncreasesStock
```

| Suite | Covers |
| --- | --- |
| `RecordTransactionUseCaseTests` | Stock adjustment on sale/restock, product snapshotting, oversell rejection, invalid quantity, unknown product |
| `FetchLowStockProductsUseCaseTests` | Threshold filtering and ordering |
| `ProductEntityTests` | `isLowStock` boundary behaviour |
| `SwiftDataProductRepositoryTests` | Add/fetch round-trip including the supplier relationship, update, delete |
| `StoreMateiOSUITests` | Launch and UI automation |

> Suites that touch app types are marked `@MainActor`, because `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
> makes every declaration implicitly main-actor isolated.

## Project conventions

- Domain stays framework-free — if you need `import SwiftData` there, the logic belongs in Data.
- Persistence types end in `Model`; domain entities never do.
- Views get data from a ViewModel, never from `@Query` or the model context.
- New screens ship as a `SomethingView` + `SomethingViewModel` pair plus a factory on `AppContainer`.

## License

Released under the [MIT License](LICENSE).
