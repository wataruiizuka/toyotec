# 次期J Salesforce → NiFi → Kudu 疎通PoC 実施結果

## 1. 今回のPoCの目的

今回のPoCでは、次期Jで利用するSalesforceの検証環境からデータを取得し、Cloudera上のNiFiを経由してKuduへ格納できることを確認しました。

最終的に確認したかったデータの流れは以下です。

```text
Salesforce
    ↓
Salesforce API
    ↓
NiFi
    ↓
Kudu
```

単にSalesforceへ接続できるかだけではなく、

- Salesforceへ認証できること
- Salesforce APIを利用できること
- NiFiからSalesforceのデータを取得できること
- 取得したデータをNiFi内で処理できること
- NiFiからKuduへ書き込めること
- Kudu側で実際にデータが格納されたこと

までを一連の流れとして確認しています。

---

## 2. 今回利用した環境

### Salesforce

次期Jの検証用Salesforce環境として、dojo Full Sandboxを利用しました。

接続先は次期J用のSalesforce Sandboxで、NiFiからSalesforce APIを利用して接続しています。

認証方式は、

```text
OAuth 2.0
Client Credentials Flow
```

を利用しています。

これは、利用者がブラウザでログインして認証する方式ではなく、システム同士が認証情報を利用して接続する方式です。

今回のような、

```text
NiFi → Salesforce
```

というシステム間連携に適した方式として利用しています。

### NiFi

Clouderaの検証環境にあるNiFiを使用しました。

既存の処理に影響を与えないよう、今回の確認用として専用のProcess Groupを用意しています。

Process Group：

```text
NextJ_Salesforce_dojo_ConnectTest
```

既存のSalesforce連携処理は変更せず、今回の検証用領域の中だけで作業しています。

### Kudu

Kuduについても既存業務用テーブルは使用せず、PoC専用領域を利用しました。

Database：

```text
nextj_ve_poc_kudu
```

今回新たに作成したTable：

```text
salesforce_kojinmokuhyo_poc_test
```

フルネームでは、

```text
nextj_ve_poc_kudu.salesforce_kojinmokuhyo_poc_test
```

です。

---

## 3. Salesforce側で今回使用したデータ

今回の目的は業務データの本格連携ではなく、まずSalesforce → NiFi → Kuduの経路が正常に通るかを確認することでした。

そのため、Salesforce側で疎通確認用として利用可能なObjectを確認し、以下を使用しました。

表示名：

```text
個人目標
```

Object API参照名：

```text
tcrm__T_T_TJ_KojinMokuhyo__c
```

今回は大量のデータを取得せず、最小限の1件だけを取得しています。

使用したSOQLは以下です。

```sql
SELECT Id
FROM tcrm__T_T_TJ_KojinMokuhyo__c
LIMIT 1
```

つまり、

- 取得対象は1Objectのみ
- 取得項目は`Id`のみ
- 最大取得件数は1件

という、疎通確認に必要な最小構成です。

---

## 4. ネットワーク接続の確認

NiFiからSalesforceへ接続するため、Salesforceの接続先に対するネットワーク設定を確認しました。

NiFiから利用するSalesforceのAPI接続先として、次期J dojo環境の、

```text
03601-toyota-crm--dojo.sandbox.my.salesforce.com
```

を利用しています。

OAuth認証についても、同じdojo環境のToken Endpointを利用しています。

最終的にNiFiからSalesforceへOAuth認証を行い、Salesforce APIからデータを取得できているため、今回利用したネットワーク経路については疎通できることを確認できました。

---

## 5. NiFiで作成した接続設定

今回のPoCでは、接続先や認証情報をProcessorへ直接書き込まず、NiFiのParameter Contextで管理しました。

作成したParameter Context：

```text
NextJ_Salesforce_dojo_ConnectTest_Param
```

主に以下の情報を管理しています。

```text
salesforce_url
salesforce_authorization_url
salesforce_client_id
salesforce_client_secret
kudu_masters
```

役割としては、

- `salesforce_url`
  - Salesforce APIの接続先
- `salesforce_authorization_url`
  - OAuth認証の接続先
- `salesforce_client_id`
  - OAuth Client ID
- `salesforce_client_secret`
  - OAuth Client Secret
- `kudu_masters`
  - Kudu Masterの接続先

となります。

Client SecretについてはSensitive情報として管理しています。

---

## 6. OAuth認証設定

Salesforceとの認証には、NiFiのOAuth2 Controller Serviceを利用しました。

作成したController Service：

```text
NextJ_Salesforce_dojo_ConnectTest_OAuth2
```

主な設定は以下です。

```text
Authorization Server URL
→ Salesforce dojoのToken Endpoint

Client Authentication Strategy
→ REQUEST_BODY

Grant Type
→ Client Credentials

Client ID
→ Parameterから参照

Client Secret
→ Sensitive情報として設定
```

最終的にこのController Serviceを利用した認証が成功し、Salesforce APIからデータを取得できています。

そのため、

**NiFi → SalesforceのOAuth2 Client Credentials認証が成立することを確認できた**

と整理できます。

---

## 7. Salesforceデータ取得用Processor

Salesforceからデータを取得するため、以下のProcessorを作成しました。

```text
QuerySalesforceObject_NextJ_dojo_ConnectTest
```

主な設定は以下です。

```text
Salesforce Instance URL
→ dojo用Salesforce URL

API Version
→ 64.0

Query Type
→ Custom Query

Read Timeout
→ 120 sec

OAuth2 Access Token Provider
→ NextJ_Salesforce_dojo_ConnectTest_OAuth2
```

SOQLは前述のとおり、

```sql
SELECT Id
FROM tcrm__T_T_TJ_KojinMokuhyo__c
LIMIT 1
```

としています。

また、NiFiは複数ノードで構成されているため、同じSalesforce Queryを複数ノードから重複実行しないよう、

```text
Execution
→ Primary node
```

としています。

---

## 8. Salesforceからのデータ取得結果

`QuerySalesforceObject`を実行した結果、Salesforceからのデータ取得に成功しました。

NiFi上では、Salesforce取得成功時のConnectionとして、

```text
Salesforce_success_to_Kudu
```

を作成しています。

実行後、このConnectionのQueueに、

```text
FlowFile：1件
File Size：168 bytes
```

が生成されました。

これは、

```text
Salesforce
↓
OAuth認証
↓
Salesforce API
↓
SOQL実行
↓
NiFi
```

まで正常に処理されたことを示しています。

---

## 9. JSONデータをKuduで扱うための設定

Salesforceから取得したデータはJSON形式でNiFiへ渡されるため、Kuduへ書き込む前にNiFi側でJSONをレコードとして読み取る必要があります。

そのため、以下のController Serviceを作成しました。

```text
JsonTreeReader_NextJ_dojo_ConnectTest
```

主な設定は、

```text
Schema Access Strategy
→ Infer Schema

Starting Field Strategy
→ Root Node
```

です。

今回のPoCでは、JSONからNiFi側でSchemaを推測させる構成にしています。

正式なデータ連携で同じ方式を採用するかについては、今後の対象Fieldやデータ型が確定した段階で改めて検討が必要です。

---

## 10. Kudu側のテーブル作成

Salesforceから取得した`Id`を格納するため、今回専用のKuduテーブルを作成しました。

作成したテーブルは、

```text
nextj_ve_poc_kudu.salesforce_kojinmokuhyo_poc_test
```

です。

今回のPoCでは`Id`だけを取得するため、Kudu側も最小構成にしています。

```sql
id STRING NOT NULL
PRIMARY KEY (id)
```

Partitionは、

```text
HASH(id) PARTITIONS 2
```

としました。

今回のPoCではSalesforceの`Id`をKuduのPrimary Keyとして利用しています。

これは今回の疎通確認用の設計であり、正式なデータ連携で使用するPrimary Keyを確定したものではありません。

---

## 11. NiFiからKuduへの書込み設定

Kuduへの書込みには以下のProcessorを作成しました。

```text
PutKudu_NextJ_dojo_ConnectTest
```

主な設定は以下です。

```text
Kudu Masters
→ Parameterから参照

Table
→ nextj_ve_poc_kudu.salesforce_kojinmokuhyo_poc_test

Record Reader
→ JsonTreeReader_NextJ_dojo_ConnectTest

Kudu Operation Type
→ UPSERT

Lowercase Field Names
→ true

Handle Schema Drift
→ false

Failure Strategy
→ Route to Failure
```

Salesforce側ではField名が、

```text
Id
```

ですが、Kudu側では、

```text
id
```

としているため、

```text
Lowercase Field Names = true
```

を利用しています。

これにより、

```text
Salesforce：Id
       ↓
NiFi
       ↓
Kudu：id
```

として格納できています。

---

## 12. NiFiの最終フロー

今回作成した処理の全体像は以下です。

```text
Salesforce dojo Full Sandbox
        │
        │ OAuth2 Client Credentials
        ▼
QuerySalesforceObject_NextJ_dojo_ConnectTest
        │
        │ success
        ▼
Salesforce_success_to_Kudu
        │
        ▼
PutKudu_NextJ_dojo_ConnectTest
        │
        │ JsonTreeReaderでJSONを解析
        ▼
Kudu
nextj_ve_poc_kudu.salesforce_kojinmokuhyo_poc_test
```

Salesforceの取得処理とKuduへの書込み処理を分けているため、途中のQueueでSalesforceから取得したデータがNiFiまで届いていることも確認できました。

---

## 13. Kuduへの格納結果

今回のPoCでは、NiFiからデータを流す前にKuduの件数を確認しています。

実行前：

```sql
SELECT COUNT(*)
FROM nextj_ve_poc_kudu.salesforce_kojinmokuhyo_poc_test;
```

結果：

```text
0
```

その後、

```text
Salesforce → NiFi → Kudu
```

の処理を実行しました。

実行後に同じSQLを確認した結果、

```text
COUNT(*) = 1
```

となりました。

さらに、

```sql
SELECT *
FROM nextj_ve_poc_kudu.salesforce_kojinmokuhyo_poc_test;
```

を実行し、`id`カラムにSalesforceから取得したレコードのIdが1件格納されていることも確認しました。

したがって、

```text
実行前
Kudu：0件

↓

Salesforce → NiFi → Kudu

↓

実行後
Kudu：1件
```

という前後比較ができています。

---

## 14. 今回の成功判定

今回の疎通PoCは、**成功と判断します。**

確認できた内容は以下です。

- 次期J dojoのSalesforceへNiFiから接続できた
- OAuth2 Client Credentialsによる認証が成功した
- Salesforce APIを利用できた
- 「個人目標」ObjectへQueryを実行できた
- Salesforceから1件のデータを取得できた
- 取得したデータがNiFiのsuccess経路へ正常に流れた
- JSONをNiFiでレコードとして読み取れた
- NiFiからKuduへ書き込めた
- Kuduのレコード件数が0件から1件へ増えた
- Salesforceから取得したIdがKuduの`id`カラムへ格納された

つまり、今回確認したかった、

```text
Salesforce
↓
NiFi
↓
Kudu
```

という一連のデータ連携経路が正常に動作することを、実データ1件で確認できました。

---

## 15. 今回確認できたことと、まだ確認していないこと

今回の結果から、

> 次期J SalesforceからNiFiを経由してKuduへデータを連携できる

という技術的な疎通は確認できました。

一方で、今回実施したのはあくまで**最小1件での疎通PoC**です。

そのため、以下については今回の成功結果だけではまだ判断できません。

- 本番連携で使用する正式なSalesforce Object
- 正式な取得Field
- SalesforceとKuduの正式な項目マッピング
- Fieldごとの正式なデータ型
- 正式なPrimary Key
- NULLの扱い
- 全件取得
- 差分取得
- 更新データの連携
- Deleteの扱い
- 大量データの処理
- 性能・処理時間
- Salesforce API利用量
- リトライ
- エラー時の再処理
- 重複データ防止
- Sandbox Refresh後の再接続確認
- 本番運用時の監視・通知

ここは「疎通成功」と「正式連携設計完了」を分けて考える必要があります。

---

## 16. 今回の結果まとめ

今回のPoCでは、**次期JのSalesforce dojo Full SandboxからNiFiを経由してKuduへ1件のデータを正常に格納できることを確認しました。**

Salesforce側ではOAuth2 Client Credentialsで認証し、「個人目標」Objectから`Id`を1件取得しています。

NiFiでは取得したデータを`QuerySalesforceObject`から`PutKudu`へ連携し、最終的にKuduのPoC専用テーブルへ格納しました。

Kudu側では、

```text
連携前：0件
連携後：1件
```

となり、実際にSalesforceのIdが格納されていることまで確認できています。

そのため、**Salesforce → NiFi → Kuduの基本的な連携経路については疎通確認完了**として整理できます。

---

## 17. 次のステップ

今回のPoC結果をベースに、正式な次期J連携へ進むために決める必要がある内容を整理します。

特に、

- 対象Object
- 対象Field
- データ型
- Kuduスキーマ
- 差分取得方法
- 更新データの扱い
- Deleteの扱い
- リトライ
- エラー処理
- 監視
- 性能確認

などを、今回の疎通PoCとは分けて整理していく必要があります。
