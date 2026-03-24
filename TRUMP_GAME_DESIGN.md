# THE GREATEST PET: Raise TRUMP!
### *Make Your Tamagotchi Great Again*

> 以川普真實人生軌跡為骨架的電子雞養成遊戲企劃書

---

## 目錄

1. [遊戲概念](#遊戲概念)
2. [成長階段](#成長階段)
3. [核心數值](#核心數值)
4. [核心玩法機制](#核心玩法機制)
5. [重要劇情事件](#重要劇情事件)
6. [特殊系統](#特殊系統)
7. [結局系統](#結局系統)
8. [UI視覺風格](#ui視覺風格)
9. [遊戲模式](#遊戲模式)
10. [技術架構（實作現況）](#技術架構實作現況)

---

## 遊戲概念

以川普的真實人生軌跡為骨架，玩家從 1946 年養起一隻「Baby Donald」，帶著他從皇后區小孩成長為美國總統（兩次）。遊戲融合電子雞的即時養成、川普的標誌性個性元素，以及諷刺幽默的美式政治文化。

**目標玩家**：18–35 歲，喜愛政治諷刺文化、美式幽默的玩家
**平台**：手機（iOS / Android）
**類型**：養成遊戲 / 放置遊戲 / 輕度策略

---

## 成長階段

遊戲共設 **10 個人生階段**，依據川普真實生平設計：

| 階段 | 名稱 | 對應年齡 | 解鎖條件 |
|:----:|------|:--------:|---------|
| 🍼 | Baby Donald | 0–5 歲 | 開始即有 |
| 👦 | Queens Kid | 6–12 歲 | 財富 > 100 |
| 🎖️ | Military Cadet | 13–18 歲 | 紀律值 > 50 |
| 🎓 | Wharton Boy | 18–22 歲 | 學識 > 60 |
| 💼 | Daddy's Apprentice | 22–30 歲 | 完成「跟父親學交易」事件 |
| 🏙️ | Manhattan Mogul | 30–45 歲 | 財富 > 10,000 |
| 🎰 | Casino King | 45–55 歲 | 建造賭場 |
| 📺 | TV Star | 55–60 歲 | 知名度 > 50,000 |
| 🇺🇸 | Candidate | 60–70 歲 | 支持率 > 60% |
| 👑 | THE PRESIDENT | 70+ 歲 | 贏得大選 |

---

## 核心數值

遊戲共有 **6 大屬性**，每項屬性均有對應的成長機制與危機事件：

```
💰 WEALTH（財富）     核心資源，可無限增長，也可破產歸零
📺 FAME（知名度）      影響支持率與每日媒體版面數量
🍟 HUNGER（飢餓）     優先以 McDonald's / KFC / Diet Coke 補充
😤 EGO（自我膨脹）    過低會抑鬱；過高會觸發衝動發推事件
⚡ ENERGY（精力）      看 Fox News 可快速回復
🗳️ SUPPORT（支持率）  決定政治生涯走向，影響最終結局
```

### 屬性互動關係

- **EGO ↑** → 自動發推頻率 ↑，FAME ↑ 但訴訟風險 ↑
- **FAME ↑** → SUPPORT 成長速度 ↑
- **WEALTH ↓ 至 0** → 觸發破產事件，FAME 反而暴增
- **ENERGY ↓** → 所有行動效率減半，無法進行交易

---

## 核心玩法機制

### 1. 日常養護

| 動作 | 說明 | 效果 |
|------|------|------|
| 🍔 喂食 | 只接受 Big Mac、Diet Coke、KFC、披薩 | HUNGER ↑，ENERGY ↑ |
| 💇 整髮 | 每天必須梳理金色髮型（節奏點擊小遊戲） | 失敗 → EGO −20 |
| 🟧 噴古銅色 | 點擊噴霧罐替他噴橙色膚色 | EGO +10，外表值維持 |
| 📺 看 Fox News | 讓他坐在電視前看新聞 | ENERGY +30，EGO +15（危險） |
| 💤 強制睡眠 | 他不愛睡，強制睡眠需克服他的抵抗 | 全屬性緩慢回復 |

### 2. 社群媒體系統（Tweet / Post System）

玩家自行撰寫推文，系統分析「川普程度」給予評分：

**加分規則：**
- 全大寫字母 ✓
- 感嘆號數量 ✓
- 使用對手貶義綽號 ✓
- 句尾加「SAD!」或「TREMENDOUS!」 ✓
- 長度不超過 280 字 ✓

**示範高分推文：**
> "FAKE NEWS! CNN is the WORST! Sleepy Joe is a DISASTER for our country. We will MAKE AMERICA GREAT AGAIN! SAD! 😤"

**觸發機制：**
- 連發 3 推 → **「Twitter Storm」**：全面媒體關注，FAME +5000
- 提及某國 → 外交危機事件觸發
- 被平台封號（EGO 滿值時）→ 移往 Truth Social，粉絲部分流失

### 3. 交易系統（The Art of the Deal）

每日出現 1–3 個交易機會，流程如下：

```
Step 1: 拖曳滑塊設定「開口報價」（越離譜越高分）
Step 2: 選擇談判策略（強硬 / 誘導 / 虛張聲勢）
Step 3: 對方反應動畫
Step 4: 決定接受 or 繼續施壓
Step 5: 成交 → WEALTH 增加 / 破局 → 雙方損失
```

> ⚠️ EGO 值過高時，開口價強制提高，破局機率上升

### 4. MAGA 帽裝備系統

| 帽型 | 解鎖條件 | 效果 |
|------|---------|------|
| 🧢 紅帽「MAGA」 | 宣布參選後 | SUPPORT +20% |
| 🤍 白帽「Keep America Great」 | 贏得第一次大選 | SUPPORT +15%，外交值 +10 |
| 👑 金帽（限定） | 生日特殊事件掉落 | 全屬性 +10% |

### 5. 「You're Fired!」技能

- 每日可對 1 名「員工 AI」使用，動畫為川普指向螢幕
- 解雇後從人才市場重新招募，新助手屬性更好
- 過度使用（> 3 次/週）→ 觸發「管理危機」事件，SUPPORT −15%

### 6. 建設系統

玩家可投入 WEALTH 建造以下地標，每座建築提供持續性屬性加成：

| 建築 | 費用 | 加成 |
|------|------|------|
| 🏠 Queens 豪宅 | 500 | ENERGY +5/day |
| 🏨 商品飯店改建 | 5,000 | WEALTH +100/day |
| 🗼 川普大廈 | 50,000 | FAME +500/day，EGO +20 |
| 🎰 泰姬瑪哈賭場 | 200,000 | WEALTH +2,000/day（破產風險 ↑） |
| 🏌️ 高爾夫球場 | 100,000 | ENERGY 全額回復 1次/day |
| 🏛️ 白宮（終極）| 需贏得大選 | 解鎖總統結局 |

---

## 重要劇情事件

遊戲內含 **30+ 個歷史事件**，在對應成長階段觸發：

> **角色素材索引（Pencil node IDs）**
> 每個階段對應 `trump_tamagotchi.pen` 裡的角色卡片節點，可直接用 ID 取出 Q 版角色圖。
>
> | 階段 key | card nodeId | image nodeId | 說明 |
> |---------|------------|-------------|------|
> | `baby_donald` | `wtbBZ` | `zddr9` | 🍼 Baby Donald (0–5歲) |
> | `queens_kid` | `wwIEo` | `EjpCV` | 👦 Queens Kid (6–12歲) |
> | `military_cadet` | `XI7GZ` | `sa09v` | 🎖️ Military Cadet (13–18歲) |
> | `wharton_boy` | `26PEY` | `P1aLY` | 🎓 Wharton Boy (18–22歲) |
> | `daddys_apprentice` | `QBDW9` | `ZOnO5` | 💼 Daddy's Apprentice (22–30歲) |
> | `manhattan_mogul` | `MujiM` | `M3twO` | 🏙️ Manhattan Mogul (30–45歲) |
> | `casino_king` | `qgkij` | `kqU1A` | 🎰 Casino King (45–55歲) |
> | `tv_star` | `Y9kSg` | `EXtod` | 📺 TV Star (55–60歲) |
> | `candidate` | `DacMv` | `O8y1G` | 🇺🇸 Candidate (60–70歲) |
> | `the_president` | `j7eV2` | `8cc8M` | 👑 THE PRESIDENT (70+歲) |

---

### 早期成長（0–30 歲）
<!-- character_key: baby_donald → queens_kid → military_cadet → wharton_boy → daddys_apprentice -->
- 🏠 **父親的第一課** `[baby_donald]`：弗雷德教你如何與政府打交道，獲得「交易啟蒙」技能
- 🎖️ **軍事學院入學** `[military_cadet]`：強制管教，解鎖「紀律」屬性
- 🎓 **沃頓畢業** `[wharton_boy]`：「我是沃頓最頂尖的畢業生」成就解鎖（不管是不是真的）

### 商業帝國（30–55 歲）
<!-- character_key: manhattan_mogul → casino_king -->
- 🏨 **商品飯店大交易** `[manhattan_mogul]`：第一個曼哈頓大交易小遊戲
- 🗼 **川普大廈開幕（1983）** `[manhattan_mogul]`：建設完成慶祝動畫，WEALTH ×2，FAME +10,000
- 🎰 **泰姬瑪哈開業（1990）** `[casino_king]`：「世界第八大奇觀」，耗盡資金但聲望暴漲
- 💸 **破產危機（1991）** `[casino_king]`：限時談判任務，成功重組 or 宣告破產
  - *若破產*：WEALTH 歸零，FAME +5,000，解鎖「我從不真正破產」成就

### 電視時代（55–60 歲）
<!-- character_key: tv_star -->
- 📺 **The Apprentice 試播（2004）** `[tv_star]`：錄製節目小遊戲，FAME 爆炸性成長
- 🔥 **「You're Fired!」首次說出（2004）** `[tv_star]`：全服成就通知，口頭禪解鎖

### 政治時代（60+ 歲）
<!-- character_key: candidate → the_president -->
- 🛗 **搭手扶梯宣布參選（2015.06.16）** `[candidate]`：動畫重現名場面
- 🎤 **共和黨辯論** `[candidate]`：即時問答小遊戲，用川普邏輯回答政策問題
- 🌙 **選舉夜 2016** `[candidate]`：緊張倒數，選舉人票實時累積，306 vs 232
- 🔨 **第一次彈劾（2019）** `[the_president]`：找夠多參議員支持的防禦小遊戲
- 🏛️ **國會山莊事件（2021.01.06）** `[the_president]`：高風險危機，影響最終結局分支
- 🚫 **Twitter 封號（2021）** `[the_president]`：突發危機，需在 24 小時內移往 Truth Social
- ⚖️ **重罪定罪（2024）** `[the_president]`：史上首位被定罪前總統，EGO 危機與 SUPPORT 大考驗
- 🎯 **暗殺未遂（2024）** `[the_president]`：隨機觸發的緊急閃躲小遊戲
- 🏆 **2024 再度當選** `[the_president]`：隱藏結局，312 vs 226 選舉人票勝利動畫

---

### 財富顯示模式

```
一般模式：實際財富數值
「川普模式」：數值 ×3，右下角顯示小字「*自行申報」
```

### 法律訴訟系統

隨著知名度提升，訴訟案件逐漸累積在「案件檔案夾」中：

| 案件類型 | 觸發條件 | 應對方式 |
|---------|---------|---------|
| 詐欺訴訟 | WEALTH 快速成長 | 支付和解金 or 打官司 |
| 彈劾審判 | 政治爭議事件 | 防禦小遊戲 |
| 重罪起訴 | 多項訴訟累積 | 輿論戰 + 法庭辯論 |
| 民事賠償 | 隨機觸發 | 直接付款 or 上訴 |

---

## 結局系統

遊戲共有 **6 種結局**：

| 結局 | 解鎖條件 | 結局畫面描述 |
|------|---------|------------|
| 👑 **PRESIDENT（最佳）** | SUPPORT > 60% + WEALTH > 億萬 | 在白宮宣誓就職 |
| 📺 **TV LEGEND** | FAME > 100,000，未從政 | The Apprentice 永遠播出 |
| 🏌️ **Golf Life** | WEALTH > 億萬，SUPPORT < 30% | 在海湖莊園打高爾夫度過餘生 |
| 💸 **Bankrupt Hero** | 破產 3 次以上，EGO 仍存 | 「失敗是成功之母」激勵動畫 |
| 😴 **SAD!** | 所有屬性歸零 | 川普對著鏡頭說「Loser」 |
| 🏛️ **TWICE PRESIDENT（隱藏）** | 完成全部 30 個事件，贏得第二次大選 | 成為美國史上第二位非連續任期總統 |

---

### 場景背景演進
```
皇后區小屋 → 曼哈頓摩天樓 → 大西洋城賭場 → NBC 攝影棚 → 競選舞台 → 白宮 → 海湖莊園
```

---

## 遊戲模式

| 模式 | 說明 |
|------|------|
| 📖 **Story Mode** | 完整走過川普人生，30+ 劇情事件，約 20 小時流程 |
| 🆓 **Free Mode** | 自由養成，無時間限制，探索各種屬性極值 |
| ⚡ **Crisis Mode** | 每日一個突發危機，限時解決，累積積分 |
| 👥 **Multiplayer** | 與其他玩家比較財富排行榜，爭奪「Forbes No.1」稱號 |

---

## 開發備註

### 遊戲核心精神
> 以川普真實人生的高低起伏為劇本，每個玩法機制都對應他真實的個性特徵與歷史事件，讓玩家在輕鬆幽默中體驗一個真實存在的「傳奇人物」的荒誕旅程。

### 重要設計原則
1. **諷刺而非惡意**：遊戲以幽默手法呈現，避免過度政治化
2. **史實為基礎**：所有事件均基於真實歷史，提供教育性趣味
3. **玩法對應人設**：每個機制都要能讓玩家「感受到川普的個性」
4. **結局多元**：讓玩家自由選擇走向，不強迫政治立場

---

---

## 技術架構（實作現況）

> 以下為 Flutter 專案 `trump_app/` 目前的實際架構，供開發參考。

### 專案技術棧

| 項目 | 內容 |
|------|------|
| 框架 | Flutter (dart) |
| 狀態管理 | provider ^6.1.2 — `GameState` 為唯一資料源 |
| 動畫 | rive ^0.14.4（主）/ flutter_animate ^4.5.2（備援）|
| 字體 | google_fonts — Space Mono（像素風） |
| 本地儲存 | shared_preferences ^2.3.5（已宣告，尚未串接） |

---

### 檔案結構

```
trump_app/lib/
├── main.dart                          # App 入口；直向鎖定；MaterialApp + GameState provider
├── models/
│   └── game_state.dart                # 核心遊戲邏輯；6 大屬性 + 計時器 + 動作方法
├── character/
│   ├── character_state.dart           # CharacterState / CharacterStage enum + 所有 metadata extension
│   ├── trump_sprite_animation.dart    # PNG 換幀動畫（idle_a ↔ idle_b / happy / action）
│   ├── trump_animated_fallback.dart   # flutter_animate 程序動畫（各階段專屬效果）
│   └── trump_character_widget.dart    # Rive 動畫包裝器（.riv 載入失敗自動降級）
├── screens/
│   └── main_game_screen.dart          # 主畫面（唯一實作畫面）
└── widgets/
    ├── speech_bubble.dart             # 對話氣泡（金框白底 + 三角尾）
    ├── stats_bar.dart                 # 像素屬性列（備用，目前未掛入主畫面）
    └── bottom_tab_bar.dart            # 底部5分頁（備用，目前未掛入主畫面）
```

---

### 主畫面佈局（main_game_screen.dart）

```
SafeArea
├── _StageBar (h:32)        深藍底；階段名稱 + 年齡範圍
├── Expanded → _MainArea
│   └── Stack
│       ├── 背景圖（AnimatedSwitcher，600ms 漸變）
│       ├── 暗化遮罩（alpha 0.35）
│       ├── _StatsSection（頂部）  6 屬性 2欄×3列 + 像素方塊
│       ├── 升階橫幅（條件顯示）   金底，點擊呼叫 advanceStage()
│       ├── TrumpSpriteAnimation + SpeechBubble（置中）
│       └── _MoodIndicator（底部）  心情 emoji + 標籤
├── _CollapseHandle (h:22)  點擊展開/收起動作列
└── _ActSection (h:108, 可收合)
    ├── 餵食  gs.feed('BigMac')
    ├── 關稅  gs.imposeTariff()
    ├── 睡覺  gs.forceSleep()
    ├── 發推  gs.postTweet(…)
    ├── 高爾夫 gs.playGolf()
    └── 談判  gs.negotiate()
```

---

### CharacterStage 對應資源

| 階段 enum | pngName | 背景圖 | 背景色 |
|-----------|---------|--------|--------|
| `babyDonald` | `baby_donald` | `queens_house.png` | #FFB3C1 粉紅 |
| `queensKid` | `queens_kid` | `queens_house.png` | #87CEEB 天藍 |
| `militaryCadet` | `military_cadet` | `queens_house.png` | #4A5C3A 軍綠 |
| `whartonBoy` | `wharton_boy` | `manhattan_skyline.png` | #1a237e 深藍 |
| `daddysApprentice` | `daddys_apprentice` | `manhattan_skyline.png` | #3e2723 深棕 |
| `manhattanMogul` | `manhattan_mogul` | `manhattan_skyline.png` | #1a237e 深藍 |
| `casinoKing` | `casino_king` | `atlantic_city_casino.png` | #1a0033 深紫 |
| `tvStar` | `tv_star` | `nbc_studio.png` | #0d0d0d 黑 |
| `candidate` | `candidate` | `campaign_stage.png` | #8B0000 深紅 |
| `thePresident` | `the_president` | `white_house.png` | #8B6914 金棕 |

每個階段有 5 個 PNG（`assets/characters/`）：
- `{pngName}.png` — 備援底圖
- `{pngName}_idle_a.png` + `{pngName}_idle_b.png` — 每 480ms 交替
- `{pngName}_happy.png` — 開心狀態
- `{pngName}_action.png` — 動作狀態

---

### 動畫降級順序

```
1. Rive（assets/rive/{stage}.riv）  ← 目前檔案夾為空
        ↓ 載入失敗
2. TrumpSpriteAnimation（PNG 換幀）
        ↓ 圖片找不到
3. TrumpAnimatedFallback（flutter_animate 程序動畫）
```

---

### CharacterState 動畫狀態

```dart
idle / happy / eating / sleeping / angry / sad / tweeting / fired / celebrating / crisis
```

---

### 已實作 vs 規劃中功能

| 功能 | 狀態 |
|------|------|
| 6 大屬性 + 被動衰減 | ✅ 已實作 |
| 10 成長階段 + 升階判斷 | ✅ 已實作 |
| 階段背景切換（AnimatedSwitcher）| ✅ 已實作 |
| 角色 PNG 換幀動畫 | ✅ 已實作 |
| 對話氣泡 | ✅ 已實作 |
| 餵食 / 睡覺 / 發推 / 高爾夫 / 談判 | ✅ 已實作 |
| 關稅機制 | ✅ 已實作 |
| 建設系統（飯店、大廈、賭場…）| ✅ GameState 已實作，UI 待接 |
| 破產事件 | ✅ GameState 已實作，UI 待接 |
| **互動劇情事件（7 個）** | ✅ 已實作 |
| 推文評分系統 | 規劃中 |
| 暱稱生成器 | 規劃中 |
| 法律訴訟系統 | 規劃中 |
| Story / Crisis / Multiplayer 模式 | 規劃中 |
| Rive 動畫 | 規劃中（.riv 檔尚未建立） |
| Feed / Groom / Events 分頁畫面 | 已刪除（整合進主畫面）|

---

### 互動劇情事件實作清單

> 全部事件均以全螢幕 Overlay 形式呈現，由 `GameState._checkAllStoryEvents()` 在每個 tick 自動檢查觸發條件。
> 非互動式純文字彈窗已移除；保留的都具備實際玩法機制。

事件依歷史時間軸嚴格串接，必須依序解鎖：

```
【Candidate 階段】
  1. gop_debate         2015–2016  SUPPORT ≥ 40
        ↓ 完成後
  2. election_2016      2016.11    SUPPORT ≥ 80

【thePresident 階段】
  3. impeachment_1      2019.12    election_2016 ✓
        ↓ 完成後
  4. twitter_ban        2021.01    impeachment_1 ✓  + EGO ≥ 85
        ↓ 完成後
  5. conviction_2024    2024.05    twitter_ban ✓
        ↓ 完成後
  6. assassination_attempt 2024.07 conviction_2024 ✓
        ↓ 完成後
  7. election_2024      2024.11    assassination_attempt ✓ + SUPPORT ≥ 80
```

| 事件 | key | 年份 | 解鎖前置 | 玩法類型 | 玩法說明 |
|------|-----|------|---------|---------|---------|
| 🎤 共和黨辯論 | `gop_debate` | 2015–16 | SUPPORT ≥ 40 | Q&A | 3 道選擇題，選最「川普邏輯」答案；得分決定 SUPPORT 增益（+0/+8/+16/+24） |
| 🌙 選舉夜 2016 | `election_2016` | 2016.11 | gop_debate ✓ + SUPPORT ≥ 80 | 動畫 | 選舉人票從 0 非線性累積至 306 vs 232；勝利解鎖 thePresident 後續事件鏈 |
| 🔨 第一次彈劾 | `impeachment_1` | 2019.12 | election_2016 ✓ | 點擊 | 30 秒內點擊閃爍的共和黨參議員，需累積 20/60 票阻止定罪；成功 SUPPORT +15 |
| 🚫 Twitter 封號 | `twitter_ban` | 2021.01 | impeachment_1 ✓ + EGO ≥ 85 | 倒數計時 | 60 秒計時器，玩家需主動點擊「移往 Truth Social」；逾時強制封號 FAME × 0.5 |
| ⚖️ 重罪定罪 | `conviction_2024` | 2024.05 | twitter_ban ✓ | 反覆點擊 | 45 秒對抗媒體消耗（每秒 EGO −3.5），持續點擊「EGO BOOST」；EGO 歸零即失敗 |
| 🎯 暗殺未遂 | `assassination_attempt` | 2024.07 | conviction_2024 ✓ | 反應 | 3 輪×2 秒：點綠色安全區閃躲、避開紅色靶心；≥ 2 輪成功 SUPPORT +15 + FAME +30K |
| 🏆 2024 再度當選 | `election_2024` | 2024.11 | assassination_attempt ✓ + SUPPORT ≥ 80 | 動畫 | 選舉人票從 0 累積至 312 vs 226；完成解鎖隱藏結局 TWICE PRESIDENT |
| 🌍💥 第三次世界大戰？ | `ww3` | — | election_2024 ✓ | 特殊結局 | 是否發動 WW3 二選一；開戰（EGO +50 / FAME +100萬 / SUPPORT -30）or 和平（SUPPORT +25 / FAME +50萬）；動畫素材待替換 |

#### 檔案對照

| 檔案 | 對應事件 |
|------|---------|
| `lib/widgets/gop_debate_overlay.dart` | gop_debate |
| `lib/widgets/election_night_overlay.dart` | election_2016 / election_2024 |
| `lib/widgets/impeachment_overlay.dart` | impeachment_1 |
| `lib/widgets/twitter_ban_overlay.dart` | twitter_ban |
| `lib/widgets/conviction_overlay.dart` | conviction_2024 |
| `lib/widgets/assassination_overlay.dart` | assassination_attempt |

---

*企劃書版本：v1.2*
*建立日期：2026-03-23*
*最後更新：2026-03-24（實作互動劇情事件系統，移除非互動式彈窗）*
