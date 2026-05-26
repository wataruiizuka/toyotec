以下、**そのままMarkdownに貼り付けられる形式**で整理します。
Microsoft Fabricの仕様は変更される可能性があるため、重要な技術仕様はMicrosoft公式ドキュメントを根拠にしています。

---

# Microsoft Fabric 解説

## — MS社MTGで「現行課題に対してFabric構成でどう解決する想定なのか」を確認するための整理 —

## 0. 本資料の目的

本資料は、Microsoft社とのMTGで以下を具体的に確認するための事前整理である。

> 現行のCloudera基盤におけるBI表示速度・データ鮮度・運用負荷の課題に対して、Microsoft Fabricのどの機能を使い、どの構成で、どの程度改善できる想定なのか。

今回の主な論点は、単に「Fabricを使うかどうか」ではなく、以下である。

* 現行BI帳票の表示速度を改善できるか
* Clouderaとの役割分担をどうするか
* リアルタイム性、またはデータ鮮度を維持できるか
* Fabric側にどの粒度のデータを持つべきか
* Power BIとの接続方式は何を使うべきか
* PoCで何を測れば導入判断できるか

---

# 1. Fabricの概要

## 1.1 Microsoft Fabricとは

Microsoft Fabricは、Microsoftが提供するSaaS型の統合データ分析プラットフォームである。
データ取り込み、データ変換、リアルタイム処理、分析、データウェアハウス、データサイエンス、Power BIによる可視化までを、1つの統合基盤上で扱うことを目的としている。Microsoft公式ドキュメントでも、Fabricはデータ取り込み、変換、リアルタイムストリーム処理、分析、レポート作成を支えるエンドツーエンドの分析プラットフォームとして説明されている。([Microsoft Learn][1])

Fabricを簡単に表すと、以下のような製品である。

| 領域       | Fabricでの主な機能                                  |
| -------- | --------------------------------------------- |
| データ連携    | Data Factory、Dataflow Gen2、Pipeline           |
| データレイク   | OneLake                                       |
| データ加工    | Lakehouse、Notebook、Spark                      |
| SQL分析    | Data Warehouse、SQL analytics endpoint         |
| BI       | Power BI、Direct Lake                          |
| リアルタイム分析 | Real-Time Intelligence、Eventstream、Eventhouse |
| データ管理    | OneLake Catalog、Purview連携、権限管理                |
| AI支援     | Copilot、分析・開発支援                               |

今回のプロジェクトで重要なのは、Fabricが単なる「Power BIを速くするための箱」ではなく、**データ保存・加工・分析・BI表示までを含む統合データ基盤**である点である。

---

## 1.2 Fabricの中心概念：OneLake

Fabricの中心には、OneLakeという共通ストレージ層がある。
OneLakeはFabric全体で使われる論理的なデータレイクであり、Fabricの各ワークロードが同じデータを参照・利用できるようにする。Microsoft公式ドキュメントでは、OneLakeはFabricのすべてのワークロードがデータを保存・アクセスするための集中型の論理データレイクであり、Azure Data Lake Storage Gen2上に構築されていると説明されている。([Microsoft Learn][2])

```text
従来構成：
データ基盤A
データ基盤B
BI用DWH
分析用環境
機械学習用環境
それぞれにデータをコピー・加工

Fabric構成：
OneLakeにデータを集約または参照
  ↓
Data Engineering / Data Warehouse / Data Science / Power BI / Real-Time Intelligence
が同じデータを利用
```

今回のMTGで確認すべきポイントは以下である。

> Cloudera側のデータをFabricに物理コピーする想定なのか。
> それともOneLake上で外部データを参照する、または差分連携する想定なのか。

---

# 2. Fabricの基本機能

## 2.1 OneLake

OneLakeは、Fabricの共通ストレージである。
Fabric内のLakehouse、Warehouse、Power BI、Data Science、Data Engineeringなどが共通で利用するデータ保存基盤である。

| 観点    | 内容                              |
| ----- | ------------------------------- |
| 役割    | Fabric全体の共通データレイク               |
| 技術基盤  | Azure Data Lake Storage Gen2ベース |
| 特徴    | SaaS型で、ユーザーが細かいストレージ管理を意識しにくい   |
| 期待効果  | データの重複削減、共有、ガバナンス統一             |
| 今回の論点 | ClouderaからどのようにOneLakeへデータを渡すか  |

OneLakeを使うことで、Fabric内の各機能が同じデータを利用できる。
ただし、今回のように既存Cloudera基盤がある場合、**OneLakeに何を置くのか**が重要になる。

| OneLakeに置くデータ  | 意味                        |
| -------------- | ------------------------- |
| Raw / Bronze相当 | 生データに近い状態からFabricで加工する    |
| Silver相当       | ある程度整形されたデータをFabricで再利用する |
| Gold相当         | 既存帳票用テーブルをFabricへコピーする    |
| 集計済みテーブル       | Power BI高速表示だけを狙う         |

今回のPoCでは、Gold相当だけをFabricに置くのか、Silver相当からFabricで加工するのかを明確にする必要がある。

---

## 2.2 Lakehouse

FabricのLakehouseは、データレイクのスケーラビリティとデータウェアハウスのクエリ機能を組み合わせたデータ基盤である。
Microsoft公式ドキュメントでは、Fabric Lakehouseは構造化データ・非構造化データを1か所に保存し、Delta Lakeで管理し、Apache SparkとSQLの両方で分析できるものと説明されている。([Microsoft Learn][3])

| 観点         | 内容                                |
| ---------- | --------------------------------- |
| 主な利用者      | データエンジニア、データサイエンティスト、分析者          |
| 主な用途       | 大量データ加工、Silver / Gold層作成、分析用データ整備 |
| 処理方式       | Spark、Notebook、SQL                |
| データ形式      | Delta Lake                        |
| Power BI連携 | 可能                                |

Lakehouseは、今回のプロジェクトでは以下のような使い方が想定される。

```text
Clouderaまたは元データ
  ↓
Fabric Lakehouse
  ↓
Silver / Gold加工
  ↓
Power BI
```

ただし、この構成を採用する場合、Cloudera側で行っている既存ETLや加工処理の一部をFabric側へ移すことになる。
そのため、単なるBI高速化PoCではなく、**データ基盤再設計のPoC**に近くなる。

---

## 2.3 Data Warehouse

Fabric Data Warehouseは、SQL中心で利用するデータウェアハウス機能である。
Microsoft公式ドキュメントでは、Fabric Data Warehouseはデータレイク基盤上のエンタープライズ規模のリレーショナルウェアハウスであり、スター・スノーフレークスキーマ、企業データマート、BI向けのセマンティックモデルに適していると説明されている。([Microsoft Learn][4])

| 観点         | 内容                                    |
| ---------- | ------------------------------------- |
| 主な利用者      | BIエンジニア、SQL分析者、データアナリスト               |
| 主な用途       | BI向けデータマート、帳票用テーブル、SQL分析              |
| 開発言語       | T-SQL                                 |
| 向いている構成    | Star schema、Snowflake schema、企業データマート |
| Power BI連携 | 強い                                    |

LakehouseとWarehouseの違いは以下である。

| 比較項目  | Lakehouse            | Warehouse        |
| ----- | -------------------- | ---------------- |
| 主目的   | データレイク + Spark加工     | SQL中心のDWH        |
| 主な利用者 | データエンジニア、データサイエンティスト | BIエンジニア、データアナリスト |
| 処理方式  | Spark、Notebook、SQL   | T-SQL            |
| データ加工 | 大量加工に向く              | BI向け整形に向く        |
| 帳票用途  | 可能                   | より向いている          |

今回のMTGでは、以下を確認すべきである。

> Power BI向けの帳票データは、Lakehouseに置く想定なのか。
> Warehouseに置く想定なのか。
> それとも両方を組み合わせる想定なのか。

---

## 2.4 SQL analytics endpoint

Lakehouseを作成すると、SQL analytics endpointが自動的に生成される。
これはDeltaテーブルをSQLで参照するためのインターフェースである。

ただし、SQL analytics endpointはWarehouseと同じではない。
Microsoft公式ドキュメントでは、LakehouseのSQL analytics endpointではT-SQLの一部操作に制限があり、テーブル作成やINSERT / UPDATE / DELETEなどはWarehouseでサポートされると説明されている。([Microsoft Learn][5])

| 項目   | SQL analytics endpoint        | Warehouse   |
| ---- | ----------------------------- | ----------- |
| 位置づけ | Lakehouse上のDeltaテーブルをSQL参照する口 | SQL中心のDWH   |
| 更新処理 | 制限あり                          | 可能          |
| BI用途 | 参照用途に向く                       | データマート用途に向く |
| 注意点  | フル機能のDWHではない                  | DWHとして使いやすい |

今回のPoCでは、SQL analytics endpointを使う場合、**参照中心なのか、加工・更新も必要なのか**を明確にする必要がある。

---

## 2.5 Data Factory / Dataflow Gen2 / Pipeline

Fabricには、データ連携・データ変換のためのData Factoryがある。
Microsoft公式ドキュメントでは、Fabric Data Factoryはクラウドスケールのデータ移動とデータ変換サービスを提供し、複雑なETLシナリオを支援するものと説明されている。([Microsoft Learn][6])

代表的な機能は以下である。

| 機能            | 内容                      |
| ------------- | ----------------------- |
| Dataflow Gen2 | Power QueryベースのローコードETL |
| Pipeline      | 複数処理のワークフロー制御           |
| Copy activity | 外部データソースからFabricへのデータ移動 |
| スケジュール実行      | 日次・時間単位などの定期実行          |
| CDC / 差分連携    | 対応データソースでは差分連携も選択肢      |

Dataflow Gen2は、Power Queryベースのローコード変換機能であり、数百のデータソースから取り込み、300以上の変換を利用できると説明されている。([Microsoft Learn][7])

今回の確認ポイントは以下である。

| 確認事項                      | 理由                                     |
| ------------------------- | -------------------------------------- |
| ClouderaからFabricへ何で連携するのか | Gateway、ODBC、JDBC、ファイル連携、APIなどの方式確認が必要 |
| 全件連携か差分連携か                | 全件連携では大量データで現実的でない可能性                  |
| 連携頻度                      | 日次、時間単位、分単位、準リアルタイムなど                  |
| 失敗時の再実行                   | 本番運用で必須                                |
| 監視方法                      | ジョブ失敗や遅延を検知する必要がある                     |
| 既存ETLを移行するか               | 工数・リスク・責任分界点が変わる                       |

---

## 2.6 Power BI連携 / Direct Lake

FabricがPower BI高速化の文脈で重要になる理由の1つが、Direct Lakeである。

Direct Lakeは、Power BIのセマンティックモデルがOneLake上のDeltaテーブルを利用するストレージモードである。Microsoft公式ドキュメントでは、Direct LakeはOneLake上のDeltaテーブルから大量データを素早くメモリにロードし、高性能な対話分析を可能にする方式と説明されている。([Microsoft Learn][8])

Power BIの代表的な接続方式は以下である。

| 方式          | 特徴                    | 注意点                              |
| ----------- | --------------------- | -------------------------------- |
| Import      | Power BI側にデータを取り込む    | 高速だが更新タイミングに依存                   |
| DirectQuery | 元データソースへ都度クエリを投げる     | 鮮度は高いが遅くなりやすい                    |
| Direct Lake | OneLake上のDeltaテーブルを利用 | Fabric / OneLake / Delta前提の設計が必要 |

Direct Lakeは、大量データをPower BI Importに全量取り込むことが難しい場合に有効な選択肢になる。
一方で、Direct Lakeは「常に最新データをそのまま参照する」というより、セマンティックモデルの更新・framingなどの考え方が関係する。Microsoft公式ドキュメントでは、Direct LakeのframingはセマンティックモデルがDeltaテーブルの最新バージョンのメタデータを分析し、OneLake上のParquetファイルを参照する状態を更新する操作であると説明されている。([Microsoft Learn][8])

今回のMTGでは、以下を必ず確認すべきである。

> 今回のBI高速化は、Power BIのDirect Lakeを使って実現する想定なのか。
> それともWarehouseへのDirectQueryなのか。
> あるいはPower BI Importの更新設計を変えるだけなのか。

---

## 2.7 Real-Time Intelligence / Eventstream

Fabricには、リアルタイム・準リアルタイム分析向けにReal-Time Intelligenceがある。
Microsoft公式ドキュメントでは、Real-Time Intelligenceはイベント駆動、ストリーミングデータ、ログデータのシナリオ向けのエンドツーエンドソリューションと説明されている。([Microsoft Learn][9])

また、Eventstreamでは、リアルタイムイベントをFabricへ取り込み、変換し、各宛先へルーティングできる。Apache Kafkaエンドポイントも利用でき、Kafkaプロトコルでイベントを送受信できると説明されている。([Microsoft Learn][10])

| 機能                        | 内容                     |
| ------------------------- | ---------------------- |
| Eventstream               | イベントデータの取り込み・変換・ルーティング |
| Eventhouse / KQL Database | 時系列・ログ分析向けストア          |
| Real-Time Hub             | ストリーミングデータの管理          |
| Activator                 | 条件に応じたアラートやアクション       |

ただし、今回の議事録で出ている「リアルタイム性」は、以下のどれを指しているか分ける必要がある。

| 種類           | 意味                           |
| ------------ | ---------------------------- |
| 業務データの即時反映   | 元システムの更新がBIへすぐ反映される          |
| ストリーミング分析    | イベントやログを秒単位で分析する             |
| Power BI画面更新 | レポート表示が自動で最新化される             |
| データ連携遅延      | ClouderaやDBからFabricへ何分遅れで届くか |

FabricにReal-Time Intelligenceがあるからといって、既存Clouderaの帳票データが自動的にリアルタイム化されるわけではない。
どのデータを、どの方式で、どの頻度でFabricへ連携するかの設計が必要である。

---

## 2.8 Mirroring

Mirroringは、既存データソースのデータをFabric OneLakeへ継続的に複製する機能である。
Microsoft公式ドキュメントでは、Mirroringは各種システムからFabricのOneLakeへ低遅延でデータを継続複製するソリューションであり、既存データをOneLake上の分析可能な形式に同期できると説明されている。([Microsoft Learn][11])

| 観点   | 内容                                  |
| ---- | ----------------------------------- |
| 目的   | 既存DBのデータをOneLakeへ継続複製               |
| 期待効果 | 準リアルタイムに近い分析基盤を作りやすい                |
| 利用先  | Spark、Notebook、Power BI、Warehouseなど |
| 注意点  | 対応データソース・制約の確認が必要                   |

今回の確認ポイントは以下である。

> Cloudera、Kudu、Hive、Impala相当の既存データが、Fabric Mirroringの対象になるのか。
> 対象外の場合、Data FactoryやGateway経由のバッチ連携になるのか。

---

## 2.9 Gateway / オンプレミス接続

既存Clouderaがオンプレミスまたは閉域ネットワーク上にある場合、Fabricから直接アクセスできるとは限らない。

Microsoft公式ドキュメントでは、Fabric Data Factoryでオンプレミスデータソースへ接続する場合、オンプレミスデータゲートウェイを利用できると説明されている。利用可能な接続例として、ODBC、OLE DB、Oracle、PostgreSQL、SQL Server、Teradata、ファイル、フォルダなどが挙げられている。([Microsoft Learn][12])

| 確認事項            | 内容                                 |
| --------------- | ---------------------------------- |
| Clouderaへ接続できるか | Impala、Hive、Kudu、HDFS等への接続方式       |
| Gatewayが必要か     | オンプレ・閉域の場合は要確認                     |
| Gateway設置場所     | どのサーバー・ネットワークに置くか                  |
| 認証方式            | Kerberos、LDAP、AD、証明書など             |
| ネットワーク要件        | Firewall、Proxy、Private Link、VNetなど |
| 転送性能            | 大量データ連携時に十分な帯域があるか                 |

今回のPoCでは、Fabric本体の検証だけでなく、**既存環境からFabricへ安全かつ継続的にデータを運べるか**も評価対象に入れるべきである。

---

## 2.10 Capacity / ライセンス / スロットリング

FabricはCapacityというリソース単位で動作する。
Microsoft公式ドキュメントでは、Fabric CapacityにはF2、F4、F8、F16、F32、F64などのSKUがあり、Capacity Units、つまりCUで計算能力を表すと説明されている。([Microsoft Learn][13])

| SKU例 |  CU |
| ---- | --: |
| F2   |   2 |
| F4   |   4 |
| F8   |   8 |
| F16  |  16 |
| F32  |  32 |
| F64  |  64 |
| F128 | 128 |

重要なのは、同じFabric構成でもCapacityが小さいと性能が出ない可能性がある点である。
また、Microsoft公式ドキュメントでは、Capacityが過負荷になるとスロットリングが発生し、新しい操作に遅延や拒否が発生する可能性があると説明されている。([Microsoft Learn][14])

PoCでは、以下を必ず記録する必要がある。

| 記録項目        | 理由                      |
| ----------- | ----------------------- |
| 使用SKU       | 性能比較の前提になる              |
| Capacity使用率 | 設計問題かリソース不足かを判断するため     |
| 同時利用数       | 実運用に近い負荷を再現するため         |
| バックグラウンド処理  | データ更新とBI利用が競合する可能性があるため |
| スロットリング有無   | レスポンス悪化の原因になるため         |

---

# 3. Fabric利用時の注意点

## 3.1 Fabricを入れれば必ず速くなるわけではない

Fabricは、BI高速化に有効な構成を作れる可能性があるが、導入すれば必ず速くなるわけではない。

速度は以下に依存する。

| 影響要因       | 内容                             |
| ---------- | ------------------------------ |
| データ配置      | OneLakeにあるか、外部参照か、コピーか         |
| 接続方式       | Import、DirectQuery、Direct Lake |
| データモデル     | Star schemaになっているか             |
| 集計粒度       | 明細を都度集計するか、事前集計するか             |
| Power BI設計 | DAX、ビジュアル数、フィルタ数               |
| Capacity   | SKU、同時処理、スロットリング               |
| 権限制御       | RLSやアクセス制御のかけ方                 |

今回のPoCでは、Fabric単体ではなく、**Fabric上にどのようなデータモデルを置き、Power BIからどの方式で参照するか**を検証する必要がある。

---

## 3.2 リアルタイム性は方式次第

Fabricだからリアルタイム性が必ず失われる、とは言い切れない。
ただし、連携方式によってデータ鮮度は大きく変わる。

| 方式          | データ鮮度 | 注意点                |
| ----------- | ----- | ------------------ |
| 日次バッチ       | 低い    | 最も簡単だが鮮度は落ちる       |
| 時間単位バッチ     | 中     | 帳票用途では現実的な場合がある    |
| 差分連携 / CDC  | 高め    | ソース対応と設計が必要        |
| Mirroring   | 高め    | 対応データソースの確認が必要     |
| Eventstream | 高い    | イベント・ログ系に向く        |
| DirectQuery | 高い    | 元DBへの負荷・レスポンス悪化に注意 |

今回のMTGでは、以下を確認すべきである。

> Fabricで現行と同等のデータ鮮度を維持する場合、どの連携方式を使う想定なのか。

---

## 3.3 Gold層だけをFabricに持つと効果が限定的になる可能性

現行Clouderaで作成済みの帳票用GoldテーブルをFabricへコピーするだけの場合、構成は以下になる。

```text
Cloudera
  ↓
既存ETLでGoldテーブル作成
  ↓
Fabricへコピー
  ↓
Power BI
```

この構成はPoCしやすいが、以下のリスクがある。

| リスク           | 内容                          |
| ------------- | --------------------------- |
| 二重管理          | ClouderaとFabricに同じようなデータを持つ |
| 鮮度低下          | コピー処理分の遅延が発生                |
| 根本改善でない       | Cloudera側の重い加工処理は残る         |
| コスト増          | 保存・転送・運用コストが増える             |
| Fabricの強みが限定的 | Lakehouseとしての価値が出にくい        |

一方、Fabric上でSilverからGoldまで加工する場合、以下になる。

```text
元データ / Cloudera連携データ
  ↓
Fabric OneLake / Lakehouse
  ↓
Silver層
  ↓
Gold層
  ↓
Power BI
```

この場合はFabricの強みを活かしやすいが、Clouderaとの役割重複が大きくなる。

したがって、今回の最重要確認事項は以下である。

> Fabricを単なるBI高速化用の受け皿として使うのか。
> それともClouderaの一部または全部を置き換える次世代データ基盤として使うのか。

---

# 4. Fabric利用時のメリット・デメリット

## 4.1 基本的なメリット

| メリット                | 内容                                      |
| ------------------- | --------------------------------------- |
| Power BIとの親和性が高い    | Microsoft製品群と統合されている                    |
| OneLakeでデータを一元化しやすい | データサイロを減らせる                             |
| SaaS型で管理負荷を下げやすい    | インフラ管理の一部をMicrosoft側に任せられる              |
| ETL、DWH、BIを統合できる    | 個別サービス連携の複雑さを下げられる                      |
| Direct Lakeを使える     | Power BI高速化の選択肢になる                      |
| ガバナンスを統合しやすい        | Purview、Entra IDなどと連携しやすい               |
| ローコード利用も可能          | Dataflow Gen2などで非エンジニアも扱いやすい            |
| リアルタイム系機能もある        | Eventstream、Real-Time Intelligenceを利用可能 |

---

## 4.2 基本的なデメリット・注意点

| デメリット                | 内容                                           |
| -------------------- | -------------------------------------------- |
| Microsoftエコシステム依存が強い | Azure / Power BI前提の構成になりやすい                  |
| Capacity設計が必要        | SKU不足だと性能が出ない                                |
| 権限設計が複雑              | Workspace、OneLake、Warehouse、Power BIの権限整理が必要 |
| 既存基盤との接続が難所          | オンプレ、閉域、Cloudera接続は要検証                       |
| すべてがリアルタイムではない       | 連携方式次第で鮮度が変わる                                |
| 既存ETL移行コストがある        | Cloudera側の処理を移す場合は大きな作業                      |
| PoC結果が設計に依存する        | 小規模データだけでは本番性能を判断しにくい                        |

---

## 4.3 今回のプロジェクトにおけるメリット

| メリット             | 今回の意味                             |
| ---------------- | --------------------------------- |
| Power BI連携が強い    | BI帳票の高速化候補になる                     |
| Direct Lakeを試せる  | 大量データをPower BIで扱う選択肢になる           |
| OneLakeに集約できる    | 帳票用データの管理を統一できる可能性                |
| Warehouseを使える    | BI向けデータマートを作りやすい                  |
| Data Factoryを使える | Clouderaからのデータ連携をFabric内で管理できる可能性 |
| ガバナンス統合          | 権限管理・監査・データカタログの統一が期待できる          |

今回Fabricが有効になりやすい条件は以下である。

```text
Power BIが中心
かつ
帳票用データをOneLake / Warehouse / Lakehouseに最適化して配置できる
かつ
Direct Lakeまたは適切なデータモデルで表示速度を改善できる
かつ
業務上許容できるデータ鮮度に収まる
```

---

## 4.4 今回のプロジェクトにおけるデメリット・リスク

| リスク            | 内容                                     |
| -------------- | -------------------------------------- |
| Clouderaとの二重運用 | ClouderaでGold作成後、Fabricにもコピーするだけになる可能性 |
| 鮮度低下           | Fabricへの連携分、BI反映が遅れる可能性                |
| 本質改善にならない      | 現行の重い加工処理がCloudera側に残る可能性              |
| PoCデータが不十分     | DX道場データだけでは性能判断できない                    |
| ネットワーク・認証が難所   | Gateway、Kerberos、閉域接続などの確認が必要          |
| Capacity不足     | 小さいSKUでは性能が出ず、大きいSKUではコストが増える          |
| 権限制御の再設計       | 現行の部門別・店舗別アクセス制御を再現する必要                |
| MS提案に偏る可能性     | Snowflake、Databricks等との比較が必要           |

---

# 5. 完全類似の別ツール

厳密には、Microsoft Fabricと完全に同じ製品はない。
Fabricは、Power BI、OneLake、Data Factory、Lakehouse、Warehouse、Real-Time Intelligence、Purview連携をMicrosoftエコシステム内で統合しているためである。

ただし、思想や用途が近い統合データ分析基盤として、以下は比較対象になる。

---

## 5.1 Databricks Lakehouse Platform

Databricksは、Fabricと非常に近いレイクハウス型の分析基盤である。
Databricks公式ドキュメントでは、データレイクハウスはデータレイクとデータウェアハウスの利点を組み合わせ、MLやBIなど複数ワークロードのための単一基盤を提供するものと説明されている。また、DatabricksはApache Sparkをベースにし、Delta LakeとUnity Catalogを中核技術として利用する。([Databricks Documentation][15])

| 観点    | Fabric                    | Databricks                   |
| ----- | ------------------------- | ---------------------------- |
| 中心思想  | Microsoft統合分析SaaS         | Lakehouse / Data + AI        |
| ストレージ | OneLake / Delta           | Cloud storage / Delta Lake   |
| 加工    | Spark、Dataflow、SQL        | Spark、SQL、Delta Live Tables等 |
| BI連携  | Power BIに強い               | Power BI、Tableau等と連携         |
| ガバナンス | Purview / OneLake Catalog | Unity Catalog                |
| 強み    | Microsoft製品統合             | Spark、AI/ML、データエンジニアリング      |

今回の観点では、FabricをSpark / Lakehouseとして使うなら、Databricksも比較対象になる。

---

## 5.2 Snowflake

Snowflakeは、クラウド型のデータプラットフォームである。
Snowflake公式ドキュメントでは、Snowflakeはクラウド向けに設計されたアーキテクチャを持ち、データストレージ、処理、分析を統合するデータプラットフォームとして説明されている。([Snowflakeドキュメント][16])

| 観点    | Fabric                 | Snowflake                   |
| ----- | ---------------------- | --------------------------- |
| 強み    | Power BI / Microsoft統合 | SQL DWH性能、マルチクラウド、データ共有     |
| BI連携  | Power BI中心に強い          | Power BI、Tableau、Looker等と連携 |
| データ形式 | Delta中心                | Snowflake管理テーブル、外部テーブル等     |
| 運用    | Microsoft SaaS統合       | Snowflake管理のクラウドDWH         |
| 比較観点  | BI高速化 + Microsoft統合    | 高速DWH・SQL分析基盤               |

今回の議事録でもSnowflakeが候補に挙がっている通り、**Power BI統合よりもSQL DWH性能を重視する場合は、Snowflakeも比較対象として妥当**である。

---

## 5.3 Google BigQuery / BigLake

BigQuery / BigLakeは、Google Cloud上の分析基盤である。
BigLakeは、Google Cloudとオープンソースサービスを統合し、Apache Icebergを用いたオープンで管理された高性能レイクハウスを構築するためのストレージエンジンとして説明されている。([Google Cloud][17])

| 観点     | Fabric            | BigQuery / BigLake                   |
| ------ | ----------------- | ------------------------------------ |
| クラウド   | Azure / Microsoft | Google Cloud                         |
| BI     | Power BI中心        | Looker / Looker Studio中心             |
| レイクハウス | OneLake / Delta   | BigLake / Iceberg                    |
| DWH    | Fabric Warehouse  | BigQuery                             |
| 強み     | Microsoft統合       | サーバーレス分析、BigQuery SQL、Google Cloud統合 |

今回のプロジェクトがMicrosoft / Power BI中心であればFabricが自然だが、クラウドをフラットに比較する場合はBigQuery / BigLakeも候補になる。

---

## 5.4 AWS Redshift + S3 + Glue / Lake Formation

AWSでは、Amazon Redshift、S3、Glue Data Catalog、Lake Formationなどを組み合わせて、DWH + データレイク型の分析基盤を構成できる。
AWS公式ドキュメントでは、Redshiftを使ってAmazon S3上のデータをRedshiftテーブルにロードせずにクエリでき、AWS Glue Data CatalogやHive Metastoreで外部テーブル構造を管理できると説明されている。([AWS ドキュメント][18])

| 観点     | Fabric                    | AWS構成                              |
| ------ | ------------------------- | ---------------------------------- |
| 統合度    | Fabric内で統合                | 複数AWSサービスを組み合わせる                   |
| BI     | Power BI中心                | QuickSight、Tableau、Power BI等       |
| データレイク | OneLake                   | S3                                 |
| DWH    | Fabric Warehouse          | Redshift                           |
| ガバナンス  | Purview / OneLake Catalog | Lake Formation / Glue Data Catalog |
| 強み     | Microsoft統合               | AWS既存資産との親和性                       |

AWS構成はFabricのような単一SaaS体験ではなく、複数サービスを組み合わせる構成になる。

---

# 6. 一部類似の別ツール

## 6.1 Azure Synapse Analytics

Azure Synapse Analyticsは、Fabric以前から存在するMicrosoftの分析基盤である。
SQL Pool、Spark、Pipelineなどを提供しており、Fabricと一部機能が重複する。

| Fabricとの関係 | 内容                                     |
| ---------- | -------------------------------------- |
| 類似点        | SQL分析、Spark、データ連携                      |
| 違い         | Fabricの方がOneLake、Power BI、SaaS統合の思想が強い |
| 今回の位置づけ    | 既存Azure分析基盤との比較対象                      |

---

## 6.2 Azure Data Factory

Azure Data Factoryは、データ連携・ETLのサービスである。
Fabric Data Factoryと役割が近い。

| Fabricとの関係 | 内容                                 |
| ---------- | ---------------------------------- |
| 類似点        | Pipeline、データコピー、ETL                |
| 違い         | FabricはBI、Lakehouse、Warehouseまで含む  |
| 今回の位置づけ    | ClouderaからFabricへの連携部分だけを見る場合の比較対象 |

---

## 6.3 Power BI Premium / Power BI Import

Power BI PremiumやImportモードは、BI表示速度改善の選択肢である。

| Fabricとの関係 | 内容                                 |
| ---------- | ---------------------------------- |
| 類似点        | BI高速化に関係                           |
| 違い         | データ基盤そのものは置き換えない                   |
| 今回の位置づけ    | Fabric導入前にPower BI側改善で足りるか確認するため重要 |

現行の遅さがPower BIのDAX、モデル設計、ビジュアル数、Import更新設計に起因する場合、Fabric導入前にPower BI側の最適化で改善できる可能性もある。

---

## 6.4 BigQuery BI Engine

BigQuery BI Engineは、BigQuery向けのインメモリ分析サービスである。
Google Cloud公式ドキュメントでは、BI EngineはBigQueryの多くのSQLクエリを、頻繁に使われるデータのキャッシュによって高速化するサービスと説明されている。([Google Cloud Documentation][19])

| Fabricとの関係 | 内容                        |
| ---------- | ------------------------- |
| 類似点        | BI表示高速化                   |
| 違い         | Google Cloud / BigQuery前提 |
| 今回の位置づけ    | BI高速化という観点での比較参考          |

---

## 6.5 Amazon Redshift Spectrum

Amazon Redshift Spectrumは、S3上のデータをRedshiftから直接クエリする仕組みである。
AWS公式ドキュメントでは、Redshift Spectrumにより、Amazon S3上のデータをRedshiftテーブルにロードせずにクエリできると説明されている。([AWS ドキュメント][20])

| Fabricとの関係 | 内容                             |
| ---------- | ------------------------------ |
| 類似点        | データレイク上のデータをDWH/SQLで参照         |
| 違い         | AWSサービスを組み合わせて構成               |
| 今回の位置づけ    | Lakehouse / 外部データ参照という観点での比較対象 |

---

# 7. 今回のプロジェクトで想定されるFabric構成パターン

## 7.1 パターンA：ClouderaのGoldテーブルをFabricへコピー

```text
Cloudera
  ↓
既存ETLでGoldテーブル作成
  ↓
Data Factory等でFabricへコピー
  ↓
Fabric Warehouse / Lakehouse
  ↓
Power BI
```

| 評価項目    | 内容                           |
| ------- | ---------------------------- |
| メリット    | PoCしやすい、既存ロジックを活かせる          |
| デメリット   | 二重管理、鮮度低下、根本改善になりにくい         |
| 向くケース   | まずBI表示速度だけを検証したい場合           |
| MS社への確認 | この構成を推奨しているのか。データ鮮度はどう担保するのか |

---

## 7.2 パターンB：Silver相当をFabricへ連携し、FabricでGold作成

```text
Clouderaまたは元データ
  ↓
Fabric OneLake / Lakehouse
  ↓
Fabric上で加工
  ↓
Goldテーブル
  ↓
Power BI
```

| 評価項目    | 内容                        |
| ------- | ------------------------- |
| メリット    | Fabricの強みを活かせる            |
| デメリット   | 既存ETL移行が必要、Clouderaとの役割重複 |
| 向くケース   | 将来的にCloudera置き換えも視野に入れる場合 |
| MS社への確認 | Clouderaとの役割分担をどう考えるのか    |

---

## 7.3 パターンC：Mirroring / CDCで準リアルタイム連携

```text
元DB
  ↓ Mirroring / CDC
Fabric OneLake
  ↓
Direct Lake / Warehouse
  ↓
Power BI
```

| 評価項目    | 内容                         |
| ------- | -------------------------- |
| メリット    | データ鮮度を保ちやすい                |
| デメリット   | 対象ソースやデータ型に制約がある           |
| 向くケース   | 元DBがMirroringやCDCに対応している場合 |
| MS社への確認 | Clouderaや関連DBが対象になるのか      |

---

## 7.4 パターンD：Power BI側の改善に留める

```text
Cloudera
  ↓
Power BI最適化
```

| 評価項目    | 内容                              |
| ------- | ------------------------------- |
| メリット    | 基盤変更が小さい                        |
| デメリット   | 根本的な基盤刷新にはならない                  |
| 向くケース   | 遅さの原因がPower BIモデル・DAX・画面設計にある場合 |
| MS社への確認 | Fabric導入以外の改善余地はないのか            |

---

# 8. MS社MTGで確認すべき質問

## 8.1 アーキテクチャ確認

| No | 確認事項                                                             |
| -: | ---------------------------------------------------------------- |
|  1 | MS社として、今回の現行課題に対してどのFabric構成を想定しているか                             |
|  2 | OneLake、Lakehouse、Warehouse、Direct Lakeのどれを主軸にする想定か              |
|  3 | ClouderaからFabricへは、コピー、Shortcut、Gateway、Mirroring、CDCのどれを想定しているか |
|  4 | FabricはClouderaを補完する位置づけか、将来的に置き換える位置づけか                         |
|  5 | Gold層だけをFabricに置く構成を推奨しているのか、Silver層からFabricで加工する想定か             |

---

## 8.2 性能確認

| No | 確認事項                                  |
| -: | ------------------------------------- |
|  1 | Power BI高速化はDirect Lakeで実現する想定か       |
|  2 | Direct Lakeを使う場合、どのテーブル形式・データ配置が必要か   |
|  3 | 現行Clouderaと比較する場合、どの指標で比較すべきか         |
|  4 | BI初回表示、フィルタ応答、同時利用、クエリ時間のどれを評価対象にすべきか |
|  5 | PoCで利用すべきFabric Capacity SKUは何か       |
|  6 | 小規模データではなく、実運用相当データで性能評価できるか          |
|  7 | スロットリングやCapacity不足が発生した場合、どう見分けるか     |

---

## 8.3 リアルタイム性確認

| No | 確認事項                                         |
| -: | -------------------------------------------- |
|  1 | 現行と同等のデータ反映頻度をFabricで実現できるか                  |
|  2 | Fabricへのデータ連携遅延はどの程度発生する想定か                  |
|  3 | 日次、時間単位、分単位、準リアルタイムのどこまで可能か                  |
|  4 | MirroringやCDCは今回の既存データソースに使えるか               |
|  5 | Power BI側の表示更新はどのタイミングで反映されるか                |
|  6 | Direct Lake利用時、元データ更新後にレポートへ反映されるまでの流れはどうなるか |

---

## 8.4 ネットワーク・認証確認

| No | 確認事項                                           |
| -: | ---------------------------------------------- |
|  1 | オンプレまたは閉域のClouderaへFabricから接続できるか              |
|  2 | Gatewayが必要か                                    |
|  3 | Gatewayを置く場合、どこに置くべきか                          |
|  4 | Kerberos、LDAP、AD、証明書など現行認証方式に対応できるか            |
|  5 | Firewall、Proxy、Private Link、VNet Gatewayの要件は何か |
|  6 | データ転送帯域はPoC・本番で十分か                             |

---

## 8.5 権限・ガバナンス確認

| No | 確認事項                                   |
| -: | -------------------------------------- |
|  1 | 現行帳票の閲覧権限をFabric / Power BIでどう再現するか    |
|  2 | 店舗別・部門別・会社別のRLSをどこで実装するか               |
|  3 | OneLake、Warehouse、Power BIの権限はどう整合させるか |
|  4 | Purview連携やリネージはどこまで使えるか                |
|  5 | 監査ログ・アクセスログは取得できるか                     |
|  6 | 個人情報・機密データのラベルやDLP制御は可能か               |

---

## 8.6 コスト確認

| No | 確認事項                                  |
| -: | ------------------------------------- |
|  1 | PoCで必要なFabric Capacity SKUは何か         |
|  2 | 本番想定のSKUは何か                           |
|  3 | OneLakeストレージ費用はどの程度か                  |
|  4 | データ連携・更新処理のCompute費用はどう見積もるか          |
|  5 | Power BIライセンス要件はどうなるか                 |
|  6 | F64未満の場合、閲覧ユーザーのProライセンス要否はどうなるか      |
|  7 | SnowflakeやDatabricksと比較した場合のコスト優位性は何か |

---

# 9. PoCで評価すべき指標

| 分類     | 指標                            |
| ------ | ----------------------------- |
| BI性能   | 初回表示時間、フィルタ変更後の応答時間、ページ遷移時間   |
| クエリ性能  | 同等SQLの実行時間、スキャン量、同時実行時の劣化     |
| データ鮮度  | 元データ更新からBI反映までの時間             |
| データ整合性 | Cloudera結果とFabric結果の一致率       |
| 運用性    | 更新処理の失敗検知、再実行、監視              |
| 権限     | 現行RLS・アクセス制御を再現できるか           |
| コスト    | PoC時・本番時のCapacity、ストレージ、ライセンス |
| 移行性    | 既存SQL・ETL・帳票の修正量              |
| 将来性    | Cloudera置き換え可能性、他BI・AI活用の拡張性  |

---

# 10. まとめ

Microsoft Fabricは、単なるBI高速化ツールではない。
OneLakeを中心に、データ連携、データレイク、DWH、Spark加工、リアルタイム分析、Power BI、ガバナンスまでを統合するMicrosoftのデータ分析基盤である。

今回のプロジェクトで最も重要な整理は以下である。

```text
Fabricを入れることが目的ではない。
目的は、現行BI帳票の速度・鮮度・運用性・コストを改善できるかを検証することである。
```

Fabricを使う場合、主な選択肢は以下の3つである。

| 方向性         | 内容                              | 評価                 |
| ----------- | ------------------------------- | ------------------ |
| BI高速化用の受け皿  | ClouderaのGoldをFabricへコピー        | PoCしやすいが効果は限定的     |
| 次世代データ基盤    | Silver以降をFabricで加工・管理           | 本格的だが移行インパクト大      |
| 準リアルタイム分析基盤 | Mirroring / CDC / Eventstream活用 | 鮮度維持に有効だが対応可否確認が必要 |

MS社MTGでは、以下の一文を軸に確認するとよい。

```text
現行のCloudera基盤におけるBI表示速度・データ鮮度・運用負荷の課題に対して、
MicrosoftとしてはFabricのどの機能を使い、どの構成で、どの程度改善できると想定していますか。

また、その場合のデータ連携方式、Power BI接続方式、Capacity、権限設計、
リアルタイム性の前提を具体的に教えてください。
```

この確認ができれば、FabricのPoCは単なる製品検証ではなく、**現行課題に対する実効性のあるアーキテクチャ検証**として進められる。

[1]: https://learn.microsoft.com/en-us/fabric/fundamentals/microsoft-fabric-overview?utm_source=chatgpt.com "What is Microsoft Fabric - Microsoft Fabric | Microsoft Learn"
[2]: https://learn.microsoft.com/en-us/fabric/get-started/microsoft-fabric-overview?utm_source=chatgpt.com "What is Microsoft Fabric - Microsoft Fabric | Microsoft Learn"
[3]: https://learn.microsoft.com/ja-jp/fabric/data-engineering/lakehouse-overview?utm_source=chatgpt.com "レイクハウスとは - Microsoft Fabric | Microsoft Learn"
[4]: https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing?utm_source=chatgpt.com "What Is Fabric Data Warehouse? - Microsoft Fabric | Microsoft Learn"
[5]: https://learn.microsoft.com/en-us/fabric/data-warehouse/tsql-surface-area?utm_source=chatgpt.com "T-SQL Surface Area in Fabric Data Warehouse - Microsoft Fabric | Microsoft Learn"
[6]: https://learn.microsoft.com/en-us/fabric/data-factory/?utm_source=chatgpt.com "Fabric Data Factory documentation - Microsoft Fabric | Microsoft Learn"
[7]: https://learn.microsoft.com/en-us/fabric/data-factory/dataflows-gen2-overview?utm_source=chatgpt.com "Differences between Dataflow Gen1 and Dataflow Gen2 - Microsoft Fabric | Microsoft Learn"
[8]: https://learn.microsoft.com/en-us/power-bi/enterprise/directlake-overview?utm_source=chatgpt.com "Direct Lake overview - Microsoft Fabric | Microsoft Learn"
[9]: https://learn.microsoft.com/en-us/fabric/real-time-intelligence/?utm_source=chatgpt.com "Fabric Real-Time Intelligence documentation - Microsoft Fabric | Microsoft Learn"
[10]: https://learn.microsoft.com/en-us/fabric/real-time-intelligence/event-streams/overview?utm_source=chatgpt.com "Microsoft Fabric Eventstreams Overview - Microsoft Fabric | Microsoft Learn"
[11]: https://learn.microsoft.com/en-us/fabric/mirroring/overview?utm_source=chatgpt.com "Mirroring - Microsoft Fabric | Microsoft Learn"
[12]: https://learn.microsoft.com/en-us/fabric/data-factory/how-to-access-on-premises-data?utm_source=chatgpt.com "How to access on-premises data sources in Data Factory - Microsoft Fabric | Microsoft Learn"
[13]: https://learn.microsoft.com/en-us/fabric/enterprise/licenses?utm_source=chatgpt.com "Understand Microsoft Fabric Licenses - Microsoft Fabric | Microsoft Learn"
[14]: https://learn.microsoft.com/en-us/fabric/enterprise/throttling?utm_source=chatgpt.com "Understand your Fabric capacity throttling - Microsoft Fabric | Microsoft Learn"
[15]: https://docs.databricks.com/aws/en/lakehouse/?utm_source=chatgpt.com "What is a data lakehouse? | Databricks on AWS"
[16]: https://docs.snowflake.com/en/user-guide/intro-key-concepts?utm_source=chatgpt.com "Snowflake key concepts and architecture | Snowflake Documentation"
[17]: https://cloud.google.com/biglake/docs/introduction?utm_source=chatgpt.com "BigLake overview  |  Google Cloud"
[18]: https://docs.aws.amazon.com/redshift/latest/gsg/data-lake.html?utm_source=chatgpt.com "Querying your data lake - Amazon Redshift"
[19]: https://docs.cloud.google.com/bigquery/docs/bi-engine-query?utm_source=chatgpt.com "What is BI Engine?  |  BigQuery  |  Google Cloud Documentation"
[20]: https://docs.aws.amazon.com/redshift/latest/dg/c-spectrum-overview.html?utm_source=chatgpt.com "Amazon Redshift Spectrum overview - Amazon Redshift"

