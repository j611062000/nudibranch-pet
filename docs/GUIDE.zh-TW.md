# 使用與開發說明

[English](GUIDE.en.md) | **繁體中文**

[← 回首頁](../README.zh-TW.md)

## 安裝

需要 **macOS 13 以上**。通用版下載包含 Apple Silicon 與 Intel 執行檔；本次實機驗證使用 Apple Silicon Mac。

1. 到 [Releases](https://github.com/j611062000/nudibranch-pet/releases) 下載 `Nudi-0.2.0-macOS-universal.zip`。
2. 解壓縮，把 `Nudi.app` 拖到「應用程式」或個人的 `~/Applications` 資料夾。
3. 開啟 Nudi，海蛞蝓會出現在選單列；Dock 不會顯示圖示。首次開啟會自動顯示互動面板。

此版本使用 **ad-hoc 本機簽署，尚未經 Apple 公證**。瀏覽器下載後可能會被 Gatekeeper 阻擋；若你信任這個版本，可在嘗試開啟後，依 macOS 的「系統設定 → 隱私權與安全性 → 強制打開」流程操作。也可以依下方說明自行編譯，不需要全域關閉 Gatekeeper。

## 功能

- 胖胖的黑白模板圖示，隨選單列外觀調整顏色。
- 只在專屬區域內慢爬，碰邊停一下再轉身，也能睡覺。
- 點擊活動區域，開啟餵食、摸摸與睡眠控制。
- 餵食時停下四秒咀嚼，旁邊的小點心會被咬一口；摸摸時開心晃動三秒並出現愛心；睡覺則輕輕呼吸、浮出 Z，起床後繼續爬行。
- 互動提示也限制在選單列的專屬區域內；開啟「減少動畫」時改成靜態提示。
- **繁體中文與英文**即時切換；首次依系統語言選擇，其他語言預設使用英文。
- 在本機記住狀態、睡眠、語言與動畫設定，不需帳號、網路或額外權限，也沒有遙測。
- 提供「減少動畫」，也遵循系統的減少動態效果設定。
- 忘記照顧不會死亡，狀態數值有最低保護。

在面板按「結束 Nudi」，或面板啟用時按 ⌘Q 即可退出。再次開啟 App 會顯示面板。移除時先結束，再把 App 移到垃圾桶；設定仍保留於 `io.github.j611062000.nudi` 偏好設定範圍。

Nudi 約占用 108 點的選單列寬度。圖示過多或使用瀏海螢幕時，macOS 可能隱藏額外圖示；若看不到牠，請先騰出一些空間。App 不會覆蓋其他圖示、沿整條選單列移動，或自行加入登入項目。

## 自行編譯

需要 Swift 5.9 以上的 Xcode Command Line Tools 或 Xcode，沒有第三方套件相依。

```sh
./scripts/check.sh                 # 狀態、活動邊界、存檔與雙語檢查
./scripts/build-app.sh             # 目前 Mac 架構的 App 和 ZIP
./scripts/build-app.sh --universal # Apple Silicon 與 Intel 通用版
```

可用 `./scripts/render-demo.sh` 重新產生首頁 GIF。

產物放在 `dist/`。打包腳本會產生 App 圖示、檢查 bundle、加入 ad-hoc 簽署，並為 ZIP 產生 SHA-256 校驗檔。在 Finder 開啟 `dist/Nudi.app` 即可執行。

檢查程式不依賴 XCTest，因此只有 Command Line Tools 也能執行。編譯或校驗成功不代表通過 Apple 公證，也不代表已在所有 Mac 上驗證。

## 專案結構

- `Sources/PetCore/`：寵物狀態、活動邊界與雙語文字。
- `Sources/Nudi/`：原生選單列入口、SwiftUI 面板、存檔與向量角色。
- `Tests/PetCoreChecks/`：可直接執行的邏輯檢查。
- `scripts/`：驗證與 App 打包腳本。
- `docs/`：[設計說明](DESIGN.md)與[版本驗證紀錄](VERIFICATION.md)。
