import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddAssetView: View {
    var onSaved: (() -> Void)?

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var settings: AppSettingsStore

    @State private var name = ""
    @State private var category: AssetCategory = .digital
    @State private var status: AssetStatus = .inService
    @State private var tagsText = ""
    @State private var priceText = ""
    @State private var currency = "CNY"
    @State private var purchaseDate = Date()
    @State private var targetDailyText = ""
    @State private var valuationText = ""
    @State private var note = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showSavedToast = false

    var body: some View {
        NavigationStack {
            Form {
                Section("图片") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            if let imageData, let ui = UIImage(data: imageData) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.title)
                                    .frame(width: 72, height: 72)
                                    .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
                            }
                            Text(imageData == nil ? "从相册选择" : "更换图片")
                        }
                    }
                    .onChange(of: photoItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                }

                Section("基本信息") {
                    TextField("名称", text: $name)
                    Picker("分类", selection: $category) {
                        ForEach(AssetCategory.allCases) { c in
                            Label(c.title, systemImage: c.systemImage).tag(c)
                        }
                    }
                    Picker("状态", selection: $status) {
                        ForEach(AssetStatus.allCases.filter { $0 != .sold }) { s in
                            Text(s.title).tag(s)
                        }
                    }
                    TextField("标签（逗号分隔）", text: $tagsText)
                }

                Section("购入") {
                    TextField("购入价", text: $priceText)
                        .keyboardType(.decimalPad)
                    Picker("币种", selection: $currency) {
                        ForEach(SupportedCurrency.allCases) { c in
                            Text(c.title).tag(c.rawValue)
                        }
                    }
                    DatePicker("购入日期", selection: $purchaseDate, displayedComponents: .date)
                }

                Section("可选") {
                    TextField("目标日耗（\(settings.baseCurrency)）", text: $targetDailyText)
                        .keyboardType(.decimalPad)
                    TextField("当前估值（原币）", text: $valuationText)
                        .keyboardType(.decimalPad)
                    TextField("备注", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("添加资产")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!canSave)
                }
            }
            .overlay(alignment: .bottom) {
                if showSavedToast {
                    Text("已保存到陈列柜")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onAppear {
                currency = settings.baseCurrency
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && Double(priceText) != nil
    }

    private func save() {
        guard let price = Double(priceText) else { return }
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let item = AssetItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            status: status,
            tags: tags,
            purchasePrice: price,
            purchaseCurrency: currency,
            purchaseDate: purchaseDate,
            targetDailyCost: Double(targetDailyText),
            currentValuation: Double(valuationText),
            valuationCurrency: Double(valuationText) == nil ? nil : currency,
            note: note,
            imageData: imageData
        )
        context.insert(item)
        try? context.save()
        resetForm()
        withAnimation { showSavedToast = true }
        onSaved?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showSavedToast = false }
        }
    }

    private func resetForm() {
        name = ""
        tagsText = ""
        priceText = ""
        targetDailyText = ""
        valuationText = ""
        note = ""
        imageData = nil
        photoItem = nil
        category = .digital
        status = .inService
        purchaseDate = Date()
    }
}
