# 次期J Salesforceデータ連携｜NiFi権限確認・作業内容まとめ

## 1. 目的

次期JのSalesforceデータ連携POCに向けて、現在付与されている権限でNiFiをどこまで確認・操作できるかを整理しました。

今回の確認では、単に「NiFiへログインできるか」だけではなく、以下の観点まで確認しています。

- NiFiへアクセスできるか
- 既存のProcess Groupやフローを閲覧できるか
- Processorの設定内容を確認できるか
- Controller Serviceの内容を確認できるか
- Connectionの構成を確認できるか
- 実行状態やValidation、エラー情報を確認できるか
- Processorの起動・停止に関する権限情報を確認できるか
- ProcessorやController Service、ConnectionのWrite権限情報を確認できるか
- 新規Processor、Connection、Process Groupを作成できそうか
- 現状の権限でPOCの事前調査を進められるか

当初はGUIを中心に確認していましたが、レビューで「CLIでも確認した方がよい」「GUIとCLIの両方の確認方法を記載した方がよい」「CLI利用に必要なツールや導入方法も整理した方がよい」という指摘があったため、最終的には以下の4つの観点で確認しています。

- Cloudera / NiFi GUI
- CDP CLI
- NiFi Toolkit
- NiFi REST API

---

## 2. 現時点の結論

現時点では、POCの事前調査や既存NiFi構成の解析に必要な権限は確認できています。

特に、今回確認対象としたNiFi環境では、Process Group、Processor、Controller Service、Connection、実行状態、Validation等をGUIだけでなくCLI/APIからも確認できました。

また、対象ProcessorについてはRead / Write / Operate、Controller ServiceについてはRead / Write / Operate、ConnectionについてはRead / Writeの権限情報を取得できています。

一方で、既存業務への影響を避けるため、以下のような実変更・実操作は行っていません。

- ProcessorのStart / Stop
- Run Once
- Processor設定の変更・保存
- Controller ServiceのEnable / Disable
- Connectionの変更
- Queue削除
- Processorの新規作成
- Connectionの新規作成
- Process Groupの新規作成

そのため、現在の状態は次のように整理しています。

| 項目 | 状態 |
|---|---|
| NiFi GUIアクセス | 確認済み |
| NiFi CLI/APIアクセス | 確認済み |
| Process Group閲覧 | 確認済み |
| Processor詳細閲覧 | 確認済み |
| Controller Service詳細閲覧 | 確認済み |
| Connection詳細閲覧 | 確認済み |
| 実行状態・Validation確認 | 確認済み |
| Processor Read権限 | 確認済み |
| Processor Write権限情報 | 確認済み |
| Processor Operate権限情報 | 確認済み |
| Controller Service Write / Operate権限情報 | 確認済み |
| Connection Write権限情報 | 確認済み |
| Processor Start / Stop実操作 | 未実施 |
| 設定変更・保存の実操作 | 未実施 |
| 新規Processor作成 | 未実施 |
| 新規Connection作成 | 未実施 |
| 新規Process Group作成 | 未実施 |
| Salesforce POC正式対象NiFiクラスタ | 未確定 |

---

## 3. 権限情報と実操作は分けて考える

今回の確認で特に重要なのは、「権限情報上は許可されていること」と「実際に変更操作まで成功したこと」を分けて扱っている点です。

例えば、ProcessorについてはAPIから以下の権限情報を取得できています。

```text
CanRead      = True
CanWrite     = True
OperateRead  = True
OperateWrite = True
```

これは、NiFiが対象ユーザーに対してRead / Write / Operate権限を返していることを意味します。

ただし、実際にStartボタンを押してProcessorを起動したり、設定値を変更して保存したりしたわけではありません。

今回の目的は権限確認であり、既存フローへ変更を加えることではないため、実操作が既存処理へ影響する可能性があるものについては、意図的に実行していません。

レビューや報告では、以下のように表現するのが適切です。

> 権限情報上、Write / Operate権限を確認済み。既存処理への影響を避けるため、実変更・実起動停止は未実施。

---

## 4. 確認したCloudera / NiFi環境

Cloudera Data Hub上では、主に以下のNiFiクラスタを確認しました。

| クラスタ | 状態 | 補足 |
|---|---|---|
| `cdp-toyotecdap-nifi1-dev-je` | AVAILABLE | NiFi UIは今回開けなかった |
| `cdp-toyotecdap-nifi-ve-je` | NODE_FAILURE | 今回のGUI / CLI / API確認を実施 |
| `cdp-toyotecdap-nifi-pr-je` | AVAILABLE | 本番相当のため今回の確認対象外 |

実際にNiFi GUI、NiFi Toolkit、REST APIまで確認できたのは`cdp-toyotecdap-nifi-ve-je`です。

ただし、このクラスタが次期J Salesforceデータ連携POCで正式に利用するNiFiクラスタであることは、まだ確認できていません。

今後の最優先確認事項は以下です。

> Salesforceデータ連携POCで正式に使用するNiFiクラスタはどれか。

---

## 5. `ve`クラスタの状態

CDP CLIで`cdp-toyotecdap-nifi-ve-je`を確認したところ、クラスタステータスは`NODE_FAILURE`でした。

詳細では、NiFi用の3ノードのうち1ノードでHealth異常が確認されています。

一方、NiFiサービス自体は`STARTED`ですが、Cloudera側のHealth Summaryは`BAD`です。

さらに、NiFi Toolkitの`cluster-summary`では以下を確認しています。

```text
connectedNodes      : 3 / 3
connectedNodeCount  : 3
totalNodeCount      : 3
clustered           : true
connectedToCluster  : true
```

この2つは矛盾ではありません。

NiFiクラスタのメンバーとしては3ノードすべてが接続している一方で、ClouderaのサービスHealth Checkでは1ノードに問題が検知されている状態です。

そのため、「3 / 3接続なので全ノード正常」とは判断していません。

また、今回の作業では原因調査や修復、再起動等は行っていません。

---

## 6. NiFiバージョン

NiFi GUIのAbout画面で以下を確認しました。

```text
CFM          : 2.2.9.500
Apache NiFi  : 1.28.1
Build        : 1.28.1.2.2.9.500-269
```

そのため、ローカルのCLI環境もNiFi本体と合わせて`NiFi Toolkit 1.28.1`を利用しています。

---

## 7. GUIで確認した内容

### 7.1 NiFi Canvas

`cdp-toyotecdap-nifi-ve-je`のNiFi UIへアクセスし、Canvasが正常に表示されることを確認しました。

既存のProcess Group、Processor、Connection / Queue等も閲覧できています。

### 7.2 確認対象としたProcess Group

GUIでは以下の順に確認しました。

```text
Ops4USlim_nifi_group
  └─ S3-_Kudu_UPASS
```

CLIで確認したIDは以下です。

```text
Ops4USlim_nifi_group
ID: f2613412-e31d-1ff9-0000-0000526547ae
```

```text
S3-_Kudu_UPASS
ID: 161738d5-e892-1713-ae84-c17687bda86e
```

なお、似た名称の`USlim_nifi_group`も存在しますが、別のProcess Groupです。

今後CLIで対象を指定する場合は、名称だけではなくIDも合わせて確認した方が安全です。

### 7.3 Processor

GUIでは代表的に`ListS3`や`RouteOnAttribute`を確認しました。

ProcessorのConfigure画面から、SETTINGS、SCHEDULING、PROPERTIES、RELATIONSHIPS、COMMENTS等を閲覧できています。

`ListS3`ではBucket、Region、認証関連設定、Controller Service参照等も確認できました。

Sensitiveな設定値はマスク表示でした。

### 7.4 Controller Service

Process Group ConfigurationのController Servicesから、Name、Type、Bundle、State、Scope等を確認しました。

さらに、`CSVReader_UPASS`等のController Service詳細を開き、PropertiesやReferencing Componentsまで確認できています。

### 7.5 Connection

既存ConnectionのConfigure画面から、Source、Destination、Relationship、FlowFile Expiration、Back Pressure、Load Balance、Prioritizer等を確認できました。

ただし、Connection設定の変更やAPPLY、Empty Queue、Delete等は実施していません。

### 7.6 操作系UI

Processorの右クリックメニューではStart、Run Once、Disable、Configure等の操作項目が表示されました。

Controller Serviceでも`DISABLE & CONFIGURE`が表示されました。

Add Processor画面ではProcessor候補一覧とADDボタン、Add Process Group画面ではProcess Group Name、Parameter Context、ADDボタン等を確認しています。

ただし、いずれも実作成・実起動・実停止は行っていません。

---

## 8. CLI環境の準備

レビュー指摘に対応するため、Windows端末上にCDP CLI、NiFi Toolkit、REST API確認用の環境を構築しました。

### 8.1 Python

```text
Python 3.13.15
```

確認コマンド：

```powershell
python --version
```

### 8.2 pip

```text
pip 26.2.1
```

確認コマンド：

```powershell
python -m pip --version
```

### 8.3 CDP CLI

インストール：

```powershell
python -m pip install cdpcli
```

確認結果：

```text
cdpcli 0.9.163
```

確認コマンド：

```powershell
cdp --version
```

### 8.4 CDP CLI認証

ClouderaでAccess Keyを生成し、ダウンロードした`credentials`ファイルを以下へ配置しました。

```text
$HOME\.cdp\credentials
```

確認：

```powershell
cdp configure list
```

Access Key等はマスクされた状態で認識されています。

以下の情報は資料やチャットへ貼り付けないようにしています。

- Access Key
- Private Key
- Workload Password
- credentialsファイルの中身

---

## 9. CDP CLIで確認した内容

### 9.1 認証ユーザー

```powershell
cdp iam get-user
```

正常に取得できています。

### 9.2 Data Hub一覧

```powershell
cdp datahub list-clusters
```

NiFiのdev / ve / pr等のクラスタを確認しました。

### 9.3 クラスタ詳細

```powershell
cdp datahub describe-cluster --cluster-name cdp-toyotecdap-nifi-ve-je
```

ここで`NODE_FAILURE`と、NiFi 1ノードのHealth異常を確認しています。

### 9.4 サービス状態

```powershell
cdp datahub get-cluster-service-status --cluster-name cdp-toyotecdap-nifi-ve-je
```

NiFiサービスは`STARTED`、Cloudera側Healthは`BAD`であることを確認しています。

---

## 10. Java / NiFi Toolkit

NiFi Toolkit利用のため、Azul Zulu OpenJDK 11を導入しました。

```text
Java 11.0.32.1
```

確認：

```powershell
java -version
javac -version
```

NiFi Toolkitは、NiFi本体と合わせて以下を使用しています。

```text
nifi-toolkit-1.28.1
```

配置先：

```text
$HOME\Tools\NiFi\nifi-toolkit-1.28.1
```

CLI：

```text
$HOME\Tools\NiFi\nifi-toolkit-1.28.1\bin\cli.bat
```

ダウンロード後はSHA512も公式Archiveの値と照合し、一致することを確認しています。

---

## 11. NiFiへのネットワーク接続

ローカルPCからNiFiのREST APIへ直接接続した場合、NiFiホストはPrivate IPへ名前解決され、443/TCPへ直接接続できませんでした。

そのため、既存のAzure Bastion経由のSSH接続を利用し、ローカルPCにSOCKS Proxyを作成しています。

構成イメージは以下です。

```text
ローカルPC
  ↓
Azure Bastion
  ↓
Maintenance VM
  ↓
Cloudera Private Network
  ↓
NiFi
```

ローカルSOCKS Proxy：

```text
127.0.0.1:1080
```

NiFi ToolkitからSOCKS Proxyを利用するため、以下を設定しています。

```powershell
$env:JAVA_TOOL_OPTIONS="-DsocksProxyHost=127.0.0.1 -DsocksProxyPort=1080"
```

---

## 12. NiFi ToolkitのHTTPS接続

NiFi ToolkitからHTTPS接続する際はTruststoreが必要だったため、JDK標準のcacertsを使用しました。

```text
$env:JAVA_HOME\lib\security\cacerts
```

Truststore TypeはJKSです。

Workload Passwordについては、PowerShellのSecureStringまたは`curl.exe`のパスワードプロンプトから入力し、コマンド本文には直接書かないようにしています。

---

## 13. NiFi Toolkitで確認した内容

### 13.1 Current User

`current-user`を実行し、Workloadユーザーとして正常に認証できました。

```text
anonymous = false
```

また、Controller、Policies、System、Parameter Context、Restricted Components、Provenance、Counters、Tenants等を含む多数のグローバル権限で`canRead=true`、`canWrite=true`が返っています。

さらに以下も確認しています。

```text
canVersionFlows = true
```

ただし、グローバル権限だけでは個別ProcessorやConnectionの権限まで断定せず、後続のAPI確認で個別権限も確認しています。

### 13.2 Cluster Summary

```text
connectedNodes     : 3 / 3
clustered          : true
connectedToCluster : true
```

を確認しました。

### 13.3 Root Process Group

`get-root-id`でRoot Process Group IDを取得しました。

```text
a67044a0-0194-1000-ee58-1daef9525473
```

初回は取得エラーがありましたが、再実行で正常に取得できたため、権限不足とは判断していません。

### 13.4 Root直下Process Group

`pg-list`でRoot直下のProcess Group一覧を取得し、`Ops4USlim_nifi_group`がCLIからも確認できました。

### 13.5 `Ops4USlim_nifi_group`配下

以下の7つのProcess Groupを取得しました。

1. `DataLib`
2. `DataLib_ops`
3. `S3-_Iceberg_UPASS_ops`
4. `S3-_Kudu_Gazoo_ops`
5. `S3-_Kudu_UPASS`
6. `S3-_Kudu_UPASS_ops`
7. `test_putsql`

今回の詳細確認対象は`S3-_Kudu_UPASS`です。

---

## 14. Parameter Context

`S3-_Kudu_UPASS`では以下のParameter Contextを確認しました。

```text
S3ToKudoParam_Upass
```

権限情報は以下です。

```text
canRead  = true
canWrite = true
```

---

## 15. Controller ServiceのCLI確認

NiFi Toolkitの`pg-get-services`を使用し、対象Process GroupのController Service詳細を取得しました。

確認できた内容は以下です。

- Controller Service名
- Type
- State
- Properties
- Descriptor
- Referencing Components
- permissions
- operatePermissions

取得したController Serviceでは以下を確認しています。

```text
permissions.canRead  = true
permissions.canWrite = true
```

```text
operatePermissions.canRead  = true
operatePermissions.canWrite = true
```

Controller ServiceについてはGUIだけではなくCLIからも詳細を確認できることが分かりました。

ただし、Enable / Disableや設定変更は行っていません。

---

## 16. ProcessorのREST API確認

対象Process Group`S3-_Kudu_UPASS`に対して、NiFi REST APIでProcessor一覧を取得しました。

利用したAPIは以下です。

```text
GET /process-groups/{processGroupId}/processors
```

### PowerShell 5.1でのJSON変換

最初は`curl.exe`の出力を直接`ConvertFrom-Json`へ渡しましたが、JSON変換エラーになりました。

レスポンス自体はNiFiから取得できていたため、UTF-8の扱いを考慮し、一度ファイルへ保存してから読み込む方式へ変更しました。

```text
curl.exe
  ↓
UTF-8 JSONファイルへ保存
  ↓
Get-Content -Raw -Encoding UTF8
  ↓
ConvertFrom-Json
```

この方法では正常に処理できました。

今後もWindows PowerShell 5.1ではこの方式を使うのが安全です。

---

## 17. Processor確認結果

対象Process Group直下から22件のProcessorを取得しました。

### State

| State | 件数 |
|---|---:|
| STOPPED | 11 |
| DISABLED | 11 |
| 合計 | 22 |

### Validation

| Validation | 件数 |
|---|---:|
| VALID | 11 |
| VALIDATING | 9 |
| INVALID | 2 |
| 合計 | 22 |

`INVALID`だったProcessorは以下です。

- `RouteOnAttribute CSV`
- `PutKudu_poc`

`RouteOnAttribute CSV`では、`csv`および`unmatched`のRelationshipが未接続かつAuto Terminateされていないことを確認しました。

`PutKudu_poc`では、存在しないController Service参照やUpstream Connectionが存在しないこと等を確認しました。

これらは既存フロー側の状態であり、今回の権限確認で変更したものではありません。

---

## 18. Processor権限

取得した22件すべてのProcessorで以下を確認しました。

```text
CanRead      = True
CanWrite     = True
OperateRead  = True
OperateWrite = True
```

そのため、対象Process Group直下の既存Processorについては、Read / Write / Operateの権限情報を確認済みです。

ただし、Start / Stop、設定変更、保存等の実操作は行っていません。

---

## 19. 日本語文字化けへの対応

REST APIレスポンスを直接PowerShellへ渡した際には、日本語のProcessor名やScript Bodyで文字化けが見られました。

UTF-8ファイル経由へ変更したところ、以下のような日本語名も正常に表示されました。

```text
必要な項目を抽出
対象販社だけ取得
```

今回確認した範囲では、NiFi上の名称自体が壊れているのではなく、PowerShell側の文字コード処理が主要因と判断できる結果になっています。

---

## 20. ConnectionのREST API確認

対象Process Groupに対して以下のAPIを使用しました。

```text
GET /process-groups/{processGroupId}/connections
```

Processorと同様に、UTF-8ファイル経由でJSONを読み込みました。

結果として35件のConnectionを取得できました。

各Connectionについて以下を確認しています。

- Source
- Source Type
- Destination
- Destination Type
- Relationship
- Connection ID
- CanRead
- CanWrite

代表的な接続例は以下です。

```text
ListS3
  ↓ success
RouteOnAttribute
```

```text
FetchS3Object
  ↓ success
UpdateAttribute
```

```text
UpdateAttribute
  ↓ success
必要な項目を抽出
```

```text
必要な項目を抽出
  ↓ selected
UpdateRecord
```

```text
UpdateRecord
  ↓ success
PutKudu
```

GUIでは線として見えていたNiFiフローを、CLI/APIでは`Source → Relationship → Destination`の構造として確認できています。

---

## 21. Connection権限

取得した35件すべてのConnectionで以下を確認しました。

```text
CanRead  = True
CanWrite = True
```

そのため、既存ConnectionのRead / Write権限情報は確認済みです。

ただし、Connection変更、新規Connection作成、Empty Queue、Deleteは未実施です。

---

## 22. GUIとCLI/APIの対応

| 確認項目 | GUI | CLI / API |
|---|---|---|
| NiFiアクセス | 確認済み | 確認済み |
| Process Group | 確認済み | 確認済み |
| Processor | 確認済み | 確認済み |
| Controller Service | 確認済み | 確認済み |
| Connection | 確認済み | 確認済み |
| 実行状態 | 確認済み | 確認済み |
| Validation | 一部確認 | 確認済み |
| Processor Write権限 | 編集UI確認 | 権限情報確認 |
| Processor Operate権限 | 操作UI確認 | 権限情報確認 |
| Controller Service Operate | 操作UI確認 | 権限情報確認 |
| Connection Write | 設定UI確認 | 権限情報確認 |
| 新規Processor作成 | 作成UI確認 | 実作成未実施 |
| 新規Connection作成 | 設定UI確認 | 実作成未実施 |
| 新規Process Group作成 | 作成UI確認 | 実作成未実施 |

---

## 23. 現在のチェックリスト状況

全14項目について確認自体は完了しています。

```text
総項目数 : 14
確認済   : 14
未確認   : 0

可能     : 9
一部可能 : 5
不可     : 0
対象外   : 0
```

「一部可能」としている主な項目は以下です。

- Salesforce POC正式対象クラスタの特定
- 新規Processor作成
- 新規Connection作成
- 新規Process Group作成
- POC全体としての最終判断

---

## 24. 現在の権限で確認できること

現時点で、少なくとも以下の調査は可能です。

### 既存構成の確認

- Process Group確認
- Processor確認
- Processor Properties確認
- Controller Service確認
- Controller Service参照関係確認
- Connection確認
- State確認
- Validation確認
- Validation Error確認

### 権限情報の確認

- Processor Read
- Processor Write
- Processor Operate
- Controller Service Read
- Controller Service Write
- Controller Service Operate
- Connection Read
- Connection Write

---

## 25. 今回実施していない操作

既存フローへの影響を防ぐため、以下は実施していません。

- Processor Start
- Processor Stop
- Run Once
- Disable
- Processor設定変更
- APPLYによる保存
- Controller Service Enable
- Controller Service Disable
- Controller Service設定変更
- Connection変更
- Queue削除
- Connection削除
- Processor新規作成
- Connection新規作成
- Process Group新規作成

今後実施する場合も、正式な対象環境と検証領域を確認し、担当者の承認を得てから行う前提です。

---

## 26. Salesforce / CDC関連で確認できた既存情報

Root Process Group一覧では、`Ops4NEO_nifi_group`に関連して以下のParameter Context名も確認しました。

```text
NEO_salesforce_sync_bk
```

ただし、これが今回の次期J Salesforce POC用設定であることは確認できていません。

「Salesforce」という名称だけを根拠に今回の対象と判断しないようにしています。

また、Rootには以下のようなCDC / OGG関連と見られる名称のProcess Groupも存在しています。

- `cdc_to_kudu_1219`
- `Neo cdc_to_kudu_1219`
- `Dump_OGG-to-IceBerg`
- `Dump_OGG-to-Parquet`

ただし、これらをSalesforce CDCのPOCへそのまま流用できるとは確認していません。

---

## 27. Salesforce連携方式について

NiFiの権限確認とは別に、Salesforce連携方式そのものはまだ確定していません。

会議では以下のような案が出ています。

```text
Salesforce CDC
  ↓
Kafka Connector
  ↓
Kafka
```

一方で、以下は引き続き検討事項です。

- Kafka Connectorの実装実績
- サンプルコードの有無
- イベント駆動と常時Streamingの考え方
- コスト
- NiFiを使うかどうか
- 別方式を採用するかどうか

そのため、今回のNiFi権限確認が完了したことと、NiFiの採用決定は別の話として扱う必要があります。

---

## 28. 今後の確認事項

### 1. Salesforce POC正式対象NiFiクラスタの確定

今回確認した`cdp-toyotecdap-nifi-ve-je`が正式なPOC対象クラスタかどうかを確認します。

### 2. 正式対象環境でのRead確認

正式な対象クラスタが確定した後は、必要に応じて同じRead系確認を実施します。

```text
対象クラスタ確認
  ↓
GUIアクセス
  ↓
CLI認証
  ↓
Process Group確認
  ↓
Processor確認
  ↓
Controller Service確認
  ↓
Connection確認
```

### 3. 実操作確認が本当に必要かを判断

Write / Operateの権限情報自体は確認できています。

そのため、実際にProcessor作成、設定保存、Start / Stop等まで確認する必要があるかは、レビュー結果を踏まえて判断します。

実操作を行う場合は、少なくとも以下を満たす必要があります。

1. Salesforce POC正式環境が確定している
2. 既存処理へ影響しない検証用領域が確定している
3. 担当者から実操作の承認を得ている

---

## 29. セキュリティ面の注意

今回の確認では、以下の情報は資料やチャットへ直接記載しないようにしています。

- Access Key
- Private Key
- Workload Password
- credentialsファイルの中身
- SSH Private Key
- 不要な内部FQDN
- Private IP
- Subscription ID
- Resource ID
- CRN

レビュー資料へ掲載する場合も、必要に応じてマスクする前提です。

---

## 30. 作成済みのレビュー用Excel

今回のGUI / CLI確認結果は、以下のExcelへ整理済みです。

```text
次期J_NiFi権限確認チェックリスト_GUI_CLIレビュー提出版.xlsx
```

シート構成は以下です。

| シート | 内容 |
|---|---|
| `01_権限確認チェックリスト` | 14項目の確認結果 |
| `02_使い方・判定基準` | 判定方法・記載ルール |
| `03_確認結果サマリー` | 全体サマリー |
| `04_GUI確認手順` | GUIでの確認方法 |
| `05_CLI環境準備` | CLI利用に必要なツール・設定 |
| `06_CLI確認手順` | CDP CLI / NiFi Toolkit / REST APIの確認方法 |
| `07_GUI_CLI対応表` | GUIとCLI/APIの対応 |
| `08_CLI確認結果` | 実際のCLI/API確認結果 |

内容を確認する場合は、まず`03_確認結果サマリー`と`01_権限確認チェックリスト`を見れば全体像を把握できます。

その後、再現手順を確認する場合は`04`〜`08`を見る流れが分かりやすいです。

---

## 31. 現時点の整理

ここまでの確認によって、NiFiについてはGUIだけでなく、CDP CLI、NiFi Toolkit、NiFi REST APIを使って既存構成と権限情報を確認できる状態まで整理できました。

特に`S3-_Kudu_UPASS`では、以下まで確認できています。

- Processor：22件
- Connection：35件
- Controller Service詳細
- Processor State
- Validation
- Validation Error
- Processor Read / Write / Operate権限情報
- Controller Service Read / Write / Operate権限情報
- Connection Read / Write権限情報

一方で、現在残っているのは「権限が見えるかどうか」ではなく、実際のPOC環境や運用方針に関する確認です。

主な残事項は以下です。

- Salesforce POCで正式に使用するNiFiクラスタの確定
- NiFiを実際の連携方式として採用するかの判断
- 新規Processor / Connection / Process Group作成の実確認が必要かの判断
- Start / Stopや設定保存等の実操作確認が必要かの判断
- `ve`クラスタのNODE_FAILUREがPOCへ影響するかの確認
