# PowerBIテンプレ_GitHub上のPBIXをPowerAutomateで変換できるのか調査

- **調査時点**：2026年7月27日
- **調査対象**：GitHub上で管理されているPower BIのPBIXファイルを、Power Automateを利用してPBIT形式へ変換できるか
- **確認した変換先**：PBIXから、実データを含まないPower BIテンプレート形式のPBITへ変換する
- **背景・目的**：Power BIで定義されたデータモデル、リレーションシップ、DAX、Power Queryなどを確認・分析する
- **調査方法**：MicrosoftおよびGitHubの公式ドキュメントを中心とした机上調査

> [!IMPORTANT]
> 本資料は、2026年7月27日時点で公開されている公式仕様を基にした机上調査結果です。実際のPBIX、GitHubリポジトリ、ライセンス、Windows端末を使用した動作検証は行っていません。

---

## 1. 調査背景・目的

今回のチケットでは、GitHub上で管理されているPower BIのPBIXファイルを、Power Automateを利用してPBITへ変換できるかを調査する。

三ツ井さんへの確認により、次の要件が明確になった。

- 変換元はGitHub上のPBIX
- 変換先は、実データを含まないPBIT
- 話の入口は、Power BIで定義されたデータモデルやDAXを分析すること

PBITにして実データを除外した状態で、主に次の情報を確認することを想定している。

- テーブルや列などのデータモデル
- テーブル間のリレーションシップ
- DAXメジャー
- 計算列
- Power Queryのクエリ定義
- クエリパラメーター
- レポートページやビジュアルの定義

---

## 2. 結論

### 2.1 そもそもできるのか

**条件付きで可能と考えられる。**

ただし、Power Automateのクラウドフローだけで、PBIXをPBITへ直接変換する公式機能は、公開されているPower BIコネクタのアクション一覧およびPower BI REST APIの公開仕様では確認できなかった。

Microsoft公式のPBIT作成方法は、Power BI Desktop上で次の操作を行う方法である。

```text
［ファイル］
  →［エクスポート］
    →［Power BIテンプレート］
      → PBITとして保存
```

したがって、自動化する場合は、**Power Automate DesktopからPower BI Desktopの画面を操作するRPA方式**が候補となる。

### 2.2 可否判定

| 方法 | PBIXからPBITへの変換 | 判定 |
|---|---:|---|
| Power Automateクラウドフロー単体 | 不可と判断 | 公開されている変換アクションがない |
| Power BI標準コネクタ | 不可と判断 | PBIT出力アクションが確認できない |
| Power BI REST API | 不可と判断 | 公開されているExport ReportはPBIX／RDL出力であり、PBIT変換ではない |
| Power Automate Desktop＋Power BI Desktop | 条件付きで可能 | Power BI Desktopの公式操作をRPAで再現する |
| Power BI Desktopで手動変換 | 可能 | Microsoft公式のPBIT作成方法 |

### 2.3 最終的な回答

> **GitHub上のPBIXをPBITへ変換すること自体は可能である。**
>
> **ただし、Power Automateクラウドフローだけでは完結せず、Power BI Desktopの画面操作を行うPower Automate Desktop、または担当者による手動操作が必要になる。**

---

## 3. できる場合のおおよその方法

### 3.1 全体構成

```text
GitHub
  ↓
Git／Git LFSでPBIXを取得
  ↓
Windows実行端末
  ↓
Power Automate Desktop
  ↓
Power BI DesktopでPBIXを開く
  ↓
［ファイル］→［エクスポート］→［Power BIテンプレート］
  ↓
PBITを保存
  ↓
結果通知・ログ記録
```

### 3.2 各機能の役割

| 機能 | 役割 |
|---|---|
| GitHub | PBIXと変更履歴を管理する |
| Git／Git LFS | GitHubからPBIX本体を取得する |
| Windows端末 | Power BI DesktopとPower Automate Desktopの実行環境 |
| Power Automate Desktop | Git操作、Power BI Desktop操作、結果確認を行う |
| Power BI Desktop | PBIXを開き、PBITとしてエクスポートする |
| Power Automateクラウドフロー | 実行開始、スケジュール、通知、ログ連携を行う |
| SharePoint／OneDrive等 | 生成されたPBITを保管・共有する |

### 3.3 処理の流れ

1. 対象のGitHubリポジトリ、ブランチ、コミット、PBIXファイルを特定する。
2. Windows端末上で`git clone`、`git fetch`、`git pull`などを実行し、PBIXを取得する。
3. Git LFS管理の場合は、ポインターファイルではなくPBIX本体を取得できていることを確認する。
4. Power Automate DesktopからPower BI Desktopを起動し、対象PBIXを開く。
5. 読み込み完了後、［ファイル］→［エクスポート］→［Power BIテンプレート］を操作する。
6. 保存先とファイル名を指定し、PBITとして保存する。
7. PBITの存在、拡張子、ファイルサイズ、更新日時を確認する。
8. 変換元のコミットSHA、PBIXのパス、出力先、成功・失敗をログへ記録する。
9. 必要に応じて、Teamsやメールへ処理結果を通知する。

### 3.4 PBITに保持される主な内容

Microsoft公式ドキュメントによると、PBITには主に次の情報が保持される。

- レポートページ
- ビジュアルなどの表示要素
- データモデル定義
  - スキーマ
  - リレーションシップ
  - メジャー
  - その他のモデル定義
- クエリ定義
- クエリパラメーター

一方、取り込み済みの実データ本体は含まれない。

---

## 4. GitHubからPBIXを取得する方法

### 4.1 通常Gitで管理されている場合

PBIXが100MiB以下で、通常のGitファイルとして管理されている場合は、次の方法が候補となる。

- Gitコマンドによる`clone`／`pull`
- GitHub REST APIのRepository Contents API

GitHub REST APIのRepository Contents APIでは、1MB超から100MB以下のファイルはraw形式などに限定して取得できる。100MBを超えるファイルは同APIの対象外である。

### 4.2 Git LFSで管理されている場合

Git LFSでは、Gitリポジトリ内には実ファイルではなく、実ファイルを参照するポインターファイルが保存される。

そのため、Git LFSが設定されていない環境で取得すると、PBIX本体ではなく次のようなテキストを取得する可能性がある。

```text
version https://git-lfs.github.com/spec/v1
oid sha256:...
size ...
```

Power Automate Desktopの実行端末にGitとGit LFSを導入し、端末上でPBIX本体を直接取得する構成が有力である。

### 4.3 クラウドフロー内でのファイル受け渡し

Power Automateでは、コネクタを通じてファイルを送信する場合、ファイル単体ではなくペイロード全体を100MB未満にする必要がある。

PBIXは大容量になる可能性があるため、クラウドフロー内でPBIX本体を受け渡すより、Windows端末上でGit／Git LFSから直接取得する方が制限を避けやすい。

---

## 5. 現時点での推奨案

### 5.1 初期段階の推奨：半自動方式

現時点では、次の半自動方式を第一候補とする。

```text
1. GitHubからPBIXを取得する処理を自動化する
2. 対象リポジトリ、ブランチ、コミットを記録する
3. 担当者へ対象PBIXの準備完了を通知する
4. 担当者がPower BI DesktopでPBIXを開く
5. 担当者がPBITとしてエクスポートする
6. PBITを指定された保存先へ配置する
```

#### 推奨理由

- Microsoft公式の操作方法で確実にPBITを作成できる
- 警告やエラーを担当者が確認できる
- RPAによる複雑な画面制御が不要
- Power BI DesktopのUI変更による保守負荷を抑えられる
- 専用端末や無人実行ライセンスを最初から用意しなくてよい
- 変換件数や頻度を確認してから完全自動化の必要性を判断できる

### 5.2 件数・頻度が多い場合：Power Automate Desktop方式

次の条件に該当する場合は、Power Automate Desktopによる自動変換を検討する。

- PBIXの変換頻度が高い
- 複数のPBIXを定期的に変換する
- 専用Windows端末または仮想マシンを用意できる
- Power BI Desktopのバージョンを管理できる
- UI変更時にフローを修正する保守体制がある
- Power Automateの必要なライセンスを用意できる

### 5.3 単発または少数の場合：手動変換

変換が一度限り、または対象が数ファイル程度であれば、Power Automate Desktopを構築・保守するよりも、担当者が手動でPBITを作成する方が費用対効果に優れる可能性がある。

---

## 6. 現時点で阻害・課題になりそうなこと

### 6.1 公式なPBIX→PBIT変換APIが確認できない

公開されているPower BIコネクタのアクション一覧とPower BI REST APIでは、PBIXからPBITへ直接変換する処理を確認できなかった。

#### 影響

- クラウド処理だけでは完結しない
- Windows端末が必要
- UI操作への依存が発生する
- API連携より保守性・安定性が下がる可能性がある

### 6.2 Power BI DesktopのUI操作に依存する

Power Automate Desktopでは、WindowsアプリケーションのUI要素を取得して操作できる。一方で、次の画面が割り込むと処理が停止する可能性がある。

- Power BIへのサインイン要求
- Power BI Desktopの更新案内
- セキュリティ警告
- データソースの認証要求
- カスタムビジュアルに関する警告
- ファイルバージョンに関する警告
- 上書き確認
- 保存確認
- エラー画面

#### 対応候補

- UI要素に複数のセレクターを設定する
- 想定されるダイアログごとに分岐を作る
- 座標クリックではなくUI要素を優先する
- Power BI Desktopの表示言語とバージョンを管理する
- タイムアウト時に画面キャプチャやログを保存する

### 6.3 Windows実行端末が必要

Power Automate Desktop方式では、少なくとも次のソフトウェアを実行できるWindows端末が必要である。

- Power BI Desktop
- Power Automate for desktop
- Git
- 必要に応じてGit LFS

完全無人化する場合は、通常業務で使用する個人PCよりも、専用端末または仮想マシンを利用する方が安定しやすい。

### 6.4 無人実行の実行条件とライセンス

Microsoft公式ドキュメントでは、無人デスクトップフローはRDPセッション上で実行され、Power Automate Processプランが必要と案内されている。

実運用前に次を確認する必要がある。

- 現在利用できるPower Automateライセンス
- 無人実行の要否
- 専用端末または仮想マシンの有無
- 実行用アカウント
- 対象端末のセッション状態

### 6.5 PBIXのファイルサイズ

GitHubは、通常のGit管理では100MiBを超える単一ファイルを受け付けない。100MiBを超えるPBIXはGit LFSなどで管理する必要がある。

確認事項は次のとおりである。

- PBIXの平均サイズ
- PBIXの最大サイズ
- 通常GitかGit LFSか
- Git LFSの容量・通信量
- 過去バージョンの保持方針

### 6.6 GitHubの認証情報

非公開リポジトリの場合、GitHub App、Personal Access Token、SSHキーなどの認証方式を決める必要がある。

主な課題は次のとおりである。

- 認証情報の安全な保管
- 必要最小限の読み取り権限
- 有効期限
- 更新担当者
- 組織のSSO設定
- 個人アカウントへの依存回避

### 6.7 PBITにメタデータとして値が残る可能性

PBITには実データ本体は含まれない。一方、Microsoft公式ドキュメントでは、フィルター値やスライサー選択値などがレポートメタデータとして保持される場合があると説明されている。

したがって、PBITについても次の対応が必要である。

- 適切なアクセス権限を設定する
- 外部共有前に内容を確認する
- 機密情報を含む可能性のあるファイルとして扱う
- 保存先と保持期間を決める

### 6.8 PBIT化だけではDAX・モデル分析は完了しない

PBITを作成しても、DAXやデータモデルがMarkdownやCSVとして自動的に一覧出力されるわけではない。

今回の作業は次の2段階に分けて考える必要がある。

```text
第1段階
PBIXから実データを除外したPBITを作成する

第2段階
PBITまたはPBIXからDAXやモデル定義を抽出・分析する
```

第2段階まで自動化する場合は、TMDLビュー、PBIP、外部ツール、XMLAエンドポイントなどを別途検討する必要がある。

---

## 7. できない場合・適さない場合の代替手段

### 7.1 代替案一覧

| 代替案 | PBIT作成 | DAX・モデル分析 | 自動化 | 主な特徴 |
|---|---:|---:|---:|---|
| A：Power BI Desktopで手動変換 | 可能 | 可能 | 低い | 最も単純で確実 |
| B：GitHub取得だけ自動化し、変換は手動 | 可能 | 可能 | 中程度 | 安定性と自動化のバランスがよい |
| C：PBIXをTMDLビューで直接分析 | 不要 | 可能 | 低い | PBIT化せず目的へ直接到達できる |
| D：PBIP形式へ移行してGit管理 | 不要 | 適している | 中～高 | DAXやモデルをテキスト管理できる |
| E：DAX Studio／Tabular Editor等を利用 | 不要 | 適している | 用途による | 詳細なモデル分析に向く |
| F：Power BI Service／XMLAを利用 | 不要 | 可能 | 高い | 公開済みモデルを集中管理・分析できる |

### 7.2 PBIT作成が必須の場合

推奨順位は次のとおりである。

1. GitHubからの取得を自動化し、PBIT出力だけ手動で行う
2. すべて手動で行う
3. 件数・頻度が多い場合にPower Automate Desktopを検討する

### 7.3 DAX・データモデルの分析が主目的の場合

元PBIXを安全に扱える場合は、PBITへ変換せず、Power BI DesktopのTMDLビューで直接確認する方法が有力である。

TMDLビューでは、テーブル、列、メジャーなどのセマンティックモデルオブジェクトをコード形式で確認できる。Power BI Desktop上のTMDLビューは一般提供されている。

### 7.4 GitHub上で継続的に分析・レビューしたい場合

PBIP形式への移行が有力である。PBIPでは、レポートとセマンティックモデルの定義がフォルダーとテキストファイルとして保存されるため、Git上で差分を確認しやすい。

ただし、2026年7月27日時点のMicrosoft公式ドキュメントでは、Power BI DesktopでのPBIP保存はプレビュー機能として案内されている。正式採用時は、組織のプレビュー機能利用方針を確認する必要がある。

---

## 8. 今後確認が必要な事項

### 8.1 目的・対象範囲

- PBITファイルの作成自体が必須か
- DAXやデータモデルを分析できればよいか
- PBIT作成後のモデル分析も今回の範囲に含むか
- DAXやモデル定義をどの形式で出力したいか
  - Markdown
  - CSV
  - Excel
  - テキスト
  - 画面確認のみ

### 8.2 GitHub

- 対象のGitHubリポジトリ
- 公開リポジトリか非公開リポジトリか
- GitHub.comかGitHub Enterpriseか
- 対象ブランチ
- 対象ファイルのパス
- PBIXのファイルサイズ
- Git LFSを使用しているか
- 認証方式
- 対象コミットの指定方法

### 8.3 実行頻度

- 単発作業か
- 定期作業か
- GitHub更新時に毎回変換するか
- 対象となるPBIXの数
- 1回あたりの処理件数
- 変換を完了させる必要がある時間

### 8.4 実行環境

- Power BI Desktopを導入できるWindows端末があるか
- Power Automate Desktopを利用できるか
- Git／Git LFSを導入できるか
- 専用端末を用意できるか
- 有人実行でよいか
- 無人実行が必要か
- Power BI Desktopのバージョンを管理できるか

### 8.5 ライセンス

- 現在利用しているPower Automateライセンス
- Power Automate Premiumを利用できるか
- 無人実行用のPower Automate Processプランを利用できるか
- 専用端末や仮想マシンの費用を許容できるか

### 8.6 保存・セキュリティ

- PBITの保存先
- 保存期間
- アクセスできる利用者
- GitHubへPBITを書き戻す必要があるか
- SharePointやOneDriveへ保存するか
- PBITのメタデータ確認が必要か
- 元PBIXの一時保存後の削除ルール

---

## 9. 最終的な推奨方針・まとめ

### 9.1 今回のチケットに対する回答

> GitHub上のPBIXをPower AutomateクラウドフローだけでPBITへ直接変換することはできないと判断する。
>
> Power Automate DesktopでPower BI Desktopを画面操作すれば、自動化できる可能性がある。
>
> ただし、画面操作に依存するため、保守性、安定性、実行端末、ライセンスが課題になる。

### 9.2 初期運用の推奨

> 初期段階では、GitHubからPBIXを取得する部分を自動化し、PBITへの出力は担当者がPower BI Desktopで行う半自動方式を推奨する。
>
> 変換件数や頻度が多いことが判明した場合に、Power Automate Desktopによる完全自動化を追加検討する。

### 9.3 本来の分析目的に対する推奨

> DAXやデータモデルの分析が目的で、元PBIXを安全に扱える場合は、PBITへの変換を行わず、Power BI DesktopのTMDLビューで直接分析する方法を優先して検討する。

### 9.4 中長期的な推奨

> DAXやモデル定義をGitHub上で継続的に管理・比較する場合は、PBIP形式への移行を検討する。
>
> ただし、PBIP保存は現時点でプレビュー機能として案内されているため、組織の利用方針と制約を確認したうえで判断する。

### 9.5 要点

- **PBIXからPBITへの変換自体は可能**
- **Power Automateクラウドフローだけでは変換できないと判断**
- **Power Automate DesktopとPower BI Desktopを組み合わせれば自動化できる可能性がある**
- **公式な変換APIではなく、RPAによる画面操作となる**
- **初期案としては、GitHub取得だけを自動化する半自動方式が現実的**
- **単発または少数ファイルであれば、手動変換が最も簡単**
- **DAX・モデル分析だけが目的なら、TMDLビューによる直接分析が有力**
- **継続的なGit管理にはPBIPが適しているが、現時点ではプレビュー扱い**
- **主な課題は、UI操作への依存、Windows端末、ライセンス、Git LFS、認証、PBIT内のメタデータ**
- **実際の方式は、変換頻度、ファイル数、PBIXサイズ、PBIT作成の必須性を確認して決定する**

---

## 10. エビデンス・参考資料

以下は、本調査で参照した公式ドキュメントである。リンクおよび仕様は将来変更される可能性があるため、実装・運用開始時に再確認すること。

### 10.1 PBITの仕様・作成方法

1. **Microsoft Learn：Create and use report templates in Power BI Desktop**  
   https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-templates

   確認した内容：
   - PBITはPower BI Desktopの［File］→［Export］→［Power BI template］から作成する
   - PBITにはレポートページ、ビジュアル、データモデル、リレーションシップ、メジャー、クエリ定義などが保持される
   - PBITには実データ本体は含まれない
   - フィルター値やスライサー選択値などがメタデータとして残る場合がある

### 10.2 Power AutomateのPower BIコネクタ

2. **Microsoft Learn：Power BI connector reference**  
   https://learn.microsoft.com/en-us/connectors/powerbi/

   確認した内容：
   - 公開されているPower BIコネクタのアクション一覧
   - レポート出力、データセット更新、クエリ実行などはある
   - PBIXからPBITへ変換するアクションは公開一覧で確認できない

### 10.3 Power BI REST APIのレポート出力

3. **Microsoft Learn：Reports - Export Report**  
   https://learn.microsoft.com/en-us/rest/api/power-bi/reports/export-report

   確認した内容：
   - Export Report APIの出力対象はPBIXまたはRDL
   - PBITへ変換するAPIではない

4. **Microsoft Learn：Export Power BI embedded analytics reports API**  
   https://learn.microsoft.com/en-us/power-bi/developer/embedded/export-to

   確認した内容：
   - Export to File APIでサポートされる主な形式はPowerPoint、PDF、PNG
   - PBITは出力形式として案内されていない

### 10.4 Power Automate DesktopのUI操作

5. **Microsoft Learn：Automate using UI elements**  
   https://learn.microsoft.com/en-us/power-automate/desktop-flows/ui-elements

   確認した内容：
   - WindowsアプリケーションのUI要素を取得し、デスクトップフローから操作できる
   - UIA、UIA3 Raw、MSAAのセレクターを利用できる
   - UI要素に複数セレクターを設定できる

6. **Microsoft Learn：Trigger desktop flows from cloud flows**  
   https://learn.microsoft.com/en-us/power-automate/desktop-flows/trigger-desktop-flows

   確認した内容：
   - クラウドフローから登録済み端末上のデスクトップフローを実行できる
   - 有人・無人実行では適切なライセンスが必要になる

7. **Microsoft Learn：Run unattended desktop flows**  
   https://learn.microsoft.com/en-us/power-automate/desktop-flows/run-unattended-desktop-flows

   確認した内容：
   - 無人デスクトップフローはRDPセッション上で実行される
   - 無人実行にはPower Automate Processプランが必要と案内されている
   - 端末のセッション状態などに注意が必要

### 10.5 Power Automateのファイルサイズ制限

8. **Microsoft Learn：Limits of automated, scheduled, and instant flows**  
   https://learn.microsoft.com/en-us/power-automate/limits-and-config

   確認した内容：
   - メッセージサイズの上限は100MB
   - コネクタでファイルを送信する場合、ファイル単体ではなくペイロード全体を100MB未満にする必要がある

### 10.6 GitHubのファイルサイズ・Git LFS

9. **GitHub Docs：About large files on GitHub**  
   https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github

   確認した内容：
   - GitHubは100MiBを超える通常Gitファイルをブロックする
   - 100MiBを超えるファイルはGit LFSの使用が必要

10. **GitHub Docs：About Git Large File Storage**  
    https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage

    確認した内容：
    - Git LFSでは実ファイルではなくポインターファイルをリポジトリに保存する
    - clone時にポインターを基に実ファイルを取得する
    - GitHubプランごとにGit LFSの単一ファイル上限が異なる

11. **GitHub Docs：REST API endpoints for repository contents**  
    https://docs.github.com/en/rest/repos/contents

    確認した内容：
    - Repository Contents APIでファイルやディレクトリを取得できる
    - 1MB超～100MB以下ではraw形式などに制限される
    - 100MB超のファイルは同APIの対象外
    - 非公開リポジトリではContentsの読み取り権限を持つトークン等が必要

### 10.7 DAX・データモデル分析の代替手段

12. **Microsoft Learn：Use Tabular Model Definition Language (TMDL) view in Power BI**  
    https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-tmdl-view

    確認した内容：
    - Power BI Desktop上でセマンティックモデルをコード形式で確認・編集できる
    - テーブル、列、メジャーなどをTMDLとして出力できる
    - Power BI DesktopのTMDLビューは一般提供されている

13. **Microsoft Learn：Power BI Desktop projects (PBIP)**  
    https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview

    確認した内容：
    - PBIXをPower BI Projectとして保存できる
    - レポートとセマンティックモデルをフォルダーおよびテキストファイルとして管理できる
    - 2026年7月27日時点では、Power BI DesktopでのPBIP保存はプレビュー機能として案内されている

14. **Microsoft Learn：Power BI Desktop project semantic model folder**  
    https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-dataset

    確認した内容：
    - PBIPのセマンティックモデル定義ではTMDLを使用する
    - ソース管理と共同開発に適した構造である

### 10.8 調査結果を読む際の注意

- 「PBIXからPBITへの公式変換APIがない」という判断は、2026年7月27日時点で公開されているPower BIコネクタのアクション一覧とPower BI REST APIの出力仕様に、PBIT変換処理が掲載されていないことを根拠としている。
- Microsoftが「そのようなAPIは存在しない」と明示した単一のページを根拠にしているわけではない。
- Power BI、Power Automate、GitHubの仕様・ライセンスは変更される可能性があるため、実装開始前に最新の公式ドキュメントを再確認する必要がある。

