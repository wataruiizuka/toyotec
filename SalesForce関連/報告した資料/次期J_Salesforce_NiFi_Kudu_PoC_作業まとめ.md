# 次期J Salesforce → NiFi → Kudu データ連携PoC 作業まとめ

## 1. 今回の作業概要

今回の作業では、次期JにおけるSalesforceデータ連携の実現性を確認するため、**SalesforceのデータをNiFiのSalesforceコネクタで取得し、Cloudera環境上のKuduへ格納できるかをPoCとして検証**しました。

現時点では、業務側で正式に使用するSalesforceのObjectやField、取得条件などは確定していません。

そのため今回は、本番仕様を完成させることではなく、

```text
Salesforce
  ↓
NiFi
  ↓
Kudu
```

という基本的なデータ連携経路が技術的に成立することを確認することを目的としています。

検証の結果、**Salesforceから10件のデータを取得し、NiFiを経由してKuduへ10件格納できることを確認しました。さらに、Salesforce側とKudu側で主要Fieldの値やNULLが一致していることまで確認できています。**

---

## 2. 今回のPoCで確認したかったこと

大きく以下を確認しました。

- NiFiからSalesforce Sandboxへ接続できるか
- Salesforce OAuth2認証が利用できるか
- NiFiの`QuerySalesforceObject`でSalesforceデータを取得できるか
- SOQLをParameter化して実行できるか
- Salesforceから取得したJSONをNiFiで読み取れるか
- NiFiからKuduへデータを書き込めるか
- Salesforce側とKudu側で件数が一致するか
- Salesforce側とKudu側でFieldの値が一致するか
- NULL値や全角文字列などが保持されるか

今回の検証では、上記の基本的な連携についてすべて確認できました。

---

## 3. NiFiのPoC専用領域

既存のNiFiフローへ影響を与えないように、PoC専用のProcess Groupを作成しました。

```text
NextJ_Salesforce_PoC
```

今回作成したSalesforce取得ProcessorやKudu書込みProcessor、Controller Serviceは、基本的にこのProcess Group内へ配置しています。

これにより、既存のSalesforce連携処理とは分離した状態で検証を進めています。

---

## 4. Parameter Context

PoC専用のParameter Contextとして、以下を作成しました。

```text
NextJ_Salesforce_PoC_Param
```

このParameter Contextでは、Salesforce接続先、認証情報、SOQL、Kudu接続先などを管理しています。

ProcessorやController Serviceへ値を直接書くのではなく、

```text
#{salesforce_url}
#{salesforce_soql}
#{kudu_masters}
```

のようにParameterを参照する構成としました。

この構成にしておくことで、後から正式なSalesforce Objectや接続環境が決まった場合でも、Processor自体を大きく作り直さず、Parameterを差し替えて対応しやすくなります。

---

## 5. Salesforce接続先

今回のPoCでは、既存の検証用Salesforce Sandboxを使用しました。

Salesforce Instance URLは、

```text
https://tmt-crm--dev0.sandbox.my.salesforce.com
```

です。

OAuth2のAuthorization Server URLは、

```text
https://test.salesforce.com/services/oauth2/token
```

を使用しています。

これらは既存のSalesforce連携設定をRead Onlyで確認し、PoC用の接続先として採用しました。

---

## 6. Salesforce認証情報の管理

今回のPoCでは、PasswordやClient SecretなどのSensitive情報を画面上で直接コピーする方法は使用していません。

既存のParameter Context、

```text
NEO_salesforce_sync_bk
```

を、

```text
NextJ_Salesforce_PoC_Param
```

からInheritanceする構成にしました。

これによって、

- Salesforce Password
- Client ID
- Client Secret

については、既存の設定値を安全に継承しています。

最終的には以下のような構成になっています。

```text
NEO_salesforce_sync_bk
  ├─ salesforce_authorization_password
  ├─ salesforce_client_id
  └─ salesforce_client_secret
          ↓
      Inheritance
          ↓
NextJ_Salesforce_PoC_Param
```

PasswordとClient Secretは、

```text
Sensitive value set
```

の状態で保持されており、実値を画面上へ表示したり、チャット等へ転記したりしていません。

---

## 7. Salesforce OAuth2 Controller Service

PoC専用のOAuth2 Controller Serviceとして、

```text
NextJ_Salesforce_PoC_OAuth2
```

を作成しました。

使用したController Serviceのタイプは、

```text
StandardOauth2AccessTokenProvider
```

です。

主な設定は以下です。

```text
Authorization Server URL
= #{salesforce_authorization_url}

Client Authentication Strategy
= REQUEST_BODY

Grant Type
= User Password

Username
= #{salesforce_authorization_username}

Password
= Sensitive Parameter参照

Client ID
= #{salesforce_client_id}

Client secret
= #{salesforce_client_secret}

Refresh Window
= 0 s
```

最初は必要なParameterが不足していたため`Invalid`でした。

認証情報を正しく設定・継承したことで、

```text
Invalid
↓
Disabled
↓
Enabled
```

へ正常に状態が変化しました。

この結果から、NiFi上ではOAuth2 Controller Serviceとして利用可能な状態になったことを確認しています。

---

## 8. Salesforceからデータを取得するProcessor

Salesforceからデータを取得するために、

```text
QuerySalesforceObject
```

を使用しました。

設定は以下です。

```text
Salesforce Instance URL
= #{salesforce_url}

API Version
= 64.0

Query Type
= Custom Query

Custom SOQL Query
= #{salesforce_soql}

Read Timeout
= 120 s

OAuth2 Access Token Provider
= NextJ_Salesforce_PoC_OAuth2
```

既存の稼働中Salesforce連携を参考にし、API VersionとRead Timeoutについても既存実績に合わせています。

---

## 9. PoCで使用したSalesforce Object

正式な業務対象Objectはまだ決まっていないため、今回のPoCでは仮の対象として、

```text
Order__c
```

を使用しました。

既存のSalesforce連携で利用実績があり、FieldやSchemaの参考情報も確認できたため、PoC対象として採用しています。

今回の検証はあくまでPoCのため、`Order__c`を今後も正式に使用することが決まったわけではありません。

---

## 10. PoC用のSOQL

今回のSOQLは以下です。

```sql
SELECT
    Id,
    OrderNo__c,
    LeaseCompanyVehicleContractNO__c,
    Mj_LeaseKaishaSyaryoKeiyakuNoYobi__c,
    EntryDate__c
FROM
    Order__c
LIMIT 10
```

今回は疎通確認が目的なので、取得件数を10件に制限しました。

また、既存業務固有のWHERE条件などは入れず、できるだけ単純なQueryにしています。

SOQLはProcessorへ直接記載せず、

```text
salesforce_soql
```

というParameterに格納しています。

これによって、今後正式なObjectやFieldが決定した場合も、SOQLを差し替えやすい構成になっています。

---

## 11. QuerySalesforceObjectの実行ノード

初期状態では、

```text
Execution = All nodes
```

になっていました。

NiFiクラスタは3ノード構成だったため、`Run Once`を実行すると、

```text
3 Tasks
3 FlowFiles
```

が生成されました。

1つのFlowFileには10レコード入っていたため、3ノードそれぞれが同じSalesforce Queryを実行したことが分かりました。

今回のPoCではSalesforceへのQueryを1回だけ実行すれば十分なので、

```text
Execution = Primary node
```

へ変更しました。

変更後は、

```text
Tasks = 1
Out = 1 FlowFile
Queue = 1 FlowFile
```

となり、Primary Nodeから1回だけSalesforce Queryが実行される状態になりました。

この設定は、今回のような外部システムからデータを取得する処理では重要です。

---

## 12. Salesforceから取得したデータ

実際にSalesforceから取得したFlowFileのContentも確認しました。

1 FlowFileの中には、SOQLの`LIMIT 10`どおり10レコードが格納されていました。

データはJSON配列として出力されており、1レコードは概ね以下の形です。

```json
{
  "attributes": {
    "type": "Order__c",
    "url": "..."
  },
  "Id": "a0qfc000001X2P4AAK",
  "OrderNo__c": "T_DR11815202_20220117",
  "LeaseCompanyVehicleContractNO__c": null,
  "Mj_LeaseKaishaSyaryoKeiyakuNoYobi__c": null,
  "EntryDate__c": "2022-02-10"
}
```

取得対象として指定した5Fieldがすべて含まれていることを確認できました。

---

## 13. Salesforce固有の`attributes`

取得結果には、

```json
"attributes": {
  "type": "Order__c",
  "url": "..."
}
```

というSalesforce固有のメタ情報も含まれていました。

今回のKuduテーブルには、この`attributes`用のColumnは作っていません。

それでも最終的にKuduへ10件正常に格納できているため、今回のPoCでは`attributes`をKudu側へ格納する必要はありませんでした。

---

## 14. JSONを読み取るController Service

Kuduへ書き込む際、`PutKudu`ではRecord Readerが必要です。

そのためPoC専用として、

```text
JsonTreeReader_NextJ_Salesforce_PoC
```

を作成しました。

当初は既存のSalesforce連携と同様に、Schema Textを手書きする方法も検討しました。

既存実装では、

```text
Schema Access Strategy
= Use 'Schema Text' Property
```

として、Avro Schemaを明示的に定義していました。

しかし今回のPoCは、

> まずSalesforceからKuduまでデータが通ることを確認する

ことが目的だったため、Schema定義を簡略化しました。

今回の設定は、

```text
Schema Access Strategy
= Infer Schema

Starting Field Strategy
= Root Node
```

です。

これにより、入力JSONからNiFi側でSchemaを推論する構成としています。

---

## 15. PoC用Kudu Database

PoC専用のDatabaseとして、

```text
nextj_ve_poc_kudu
```

を新規作成しました。

既存業務のDatabaseへ直接書き込まず、PoC用として明確に分離しています。

---

## 16. PoC用Kudu Table

PoC用のKudu Tableとして、

```text
nextj_ve_poc_kudu.salesforce_poc_test
```

を作成しました。

当初はSalesforce Object名に合わせて`order__c`とする案もありましたが、今回の用途はあくまでPoCのため、

```text
salesforce_poc_test
```

という目的が分かる名称に変更しています。

今後、Salesforceの対象Objectが変更された場合でも、PoC用途であることが分かりやすい名称になっています。


---

## 17. Kudu TableのSchema

今回のKudu Tableは以下の5Columnです。

```text
id
orderno__c
leasecompanyvehiclecontractno__c
mj_leasekaishasyaryokeiyakunoyobi__c
entrydate__c
```

定義は以下です。

```text
id
→ STRING
→ PRIMARY KEY
→ NOT NULL

orderno__c
→ STRING
→ NULL許容

leasecompanyvehiclecontractno__c
→ STRING
→ NULL許容

mj_leasekaishasyaryokeiyakunoyobi__c
→ STRING
→ NULL許容

entrydate__c
→ STRING
→ NULL許容
```

Primary KeyにはSalesforceの`Id`を使用しています。

---

## 18. KuduのPartition

Partitionは、

```text
PARTITION BY HASH (id)
PARTITIONS 2
```

としました。

既存Kuduテーブルでは12 Partitionの例も確認しましたが、今回は10件程度のPoCなので、既存のPartition数をそのまま流用する必要はありません。

PoCとして必要最低限の2 Partitionとしています。

---

## 19. なぜPoCでは全項目をSTRINGにしたのか

既存のデータ連携では、

- STRING
- TIMESTAMP
- BIGINT
- DECIMAL

などを使い分けている実績が確認できました。

一方、今回のPoCの目的はデータ型設計を完成させることではありません。

特に`EntryDate__c`は実際のSalesforce JSON上では、

```text
"2022-02-10"
```

のような文字列として取得されています。

そのため今回のPoCでは、

```text
EntryDate__c
→ STRING
```

として、そのままKuduへ格納しました。

これは、

> 本番でも日付をSTRINGにする

という意味ではありません。

正式化時にはSalesforceのDate / DateTime / Number等を確認した上で、Kudu側の型を改めて設計する必要があります。

---

## 20. PutKudu Processor

Kuduへ書き込むため、PoC専用のProcessorとして、

```text
PutKudu_NextJ_Salesforce_PoC
```

を作成しました。

主な設定は以下です。

```text
Kudu Masters
= #{kudu_masters}

Table Name
= nextj_ve_poc_kudu.salesforce_poc_test

Failure Strategy
= Route to Failure

Kerberos User Service
= Default KerberosPasswordUserService-Datahub

Lowercase Field Names
= true

Handle Schema Drift
= false

Record Reader
= JsonTreeReader_NextJ_Salesforce_PoC

Kudu Operation Type
= UPSERT

Flush Mode
= AUTO_FLUSH_BACKGROUND

FlowFiles per Batch
= 1

Max Records per Batch
= 100

Ignore NULL
= false

Kudu Operation Timeout
= 30000ms

Kudu Keep Alive Period Timeout
= 15000ms

Kudu Client Worker Count
= 8

Kudu SASL Protocol Name
= kudu
```

既存の稼働中PutKudu設定を参考にしつつ、今回のPoC用テーブルへ書き込む構成にしています。

---

## 21. Field名の大文字・小文字対応

Salesforce側のField名は、

```text
Id
OrderNo__c
LeaseCompanyVehicleContractNO__c
Mj_LeaseKaishaSyaryoKeiyakuNoYobi__c
EntryDate__c
```

ですが、Kudu側では小文字で定義しています。

```text
id
orderno__c
leasecompanyvehiclecontractno__c
mj_leasekaishasyaryokeiyakunoyobi__c
entrydate__c
```

`PutKudu`側で、

```text
Lowercase Field Names = true
```

としているため、NiFi側でField名を小文字化してKudu Columnへ対応させています。

今回の実データでも、この対応で正常に格納できることを確認しました。

---

## 22. NiFi Connection

`QuerySalesforceObject`と`PutKudu`の間には、

```text
Salesforce_success_to_Kudu
```

というConnectionを作成しました。

データ経路は、

```text
QuerySalesforceObject
        │
        │ success
        ▼
Salesforce_success_to_Kudu
        │
        ▼
PutKudu_NextJ_Salesforce_PoC
```

です。

Salesforce Queryに成功したFlowFileだけをKuduへ送る構成になっています。

---

## 23. QuerySalesforceObjectのRelationship

確認したRelationshipは、

```text
failure
original
success
```

です。

今回のPoCでは、

```text
failure
→ terminate

original
→ terminate

success
→ PutKuduへ接続
```

としています。

PoCでは最低限の構成にしています。

---

## 24. PutKuduのRelationship

PutKuduには、

```text
success
failure
```

のRelationshipがあります。

今回のPoCでは、

```text
success
→ terminate

failure
→ terminate
```

としました。

本番では、`failure`をそのまま終了させるのではなく、

- エラーデータ保管
- ログ出力
- アラート
- 再処理
- リトライ

などの運用設計が必要です。

---

## 25. PutKuduのExecution設定

一度、`QuerySalesforceObject`と同じように、

```text
Execution = Primary node
```

へ変更しました。

しかしNiFiから、

```text
Processors with incoming connections cannot be scheduled for Primary Node Only
```

というValidation Errorが出ました。

PutKuduには入力Connectionがあるため、この構成ではPrimary Node Onlyに設定できません。

最終的には、

```text
QuerySalesforceObject
→ Primary node

PutKudu
→ All nodes
```

としています。

これが今回のPoCで正常に動作した構成です。

---

## 26. Salesforce取得試験

`QuerySalesforceObject`をPrimary Nodeで`Run Once`しました。

結果は、

```text
Tasks = 1

Out
= 1 FlowFile / 約2.75 KB

Queue
= 1 FlowFile
```

でした。

FlowFileのContentを確認したところ、**10レコードが入っていることを確認**しています。

つまり、

```text
Salesforce
↓
SOQL LIMIT 10
↓
10レコード取得
↓
1 FlowFile
```

が成功しています。

---

## 27. Kudu書き込み前の状態

Kudu Table作成後の初期状態では、レコードは存在していませんでした。

その後、Salesforceから取得した1 FlowFileを`PutKudu`へ渡しています。

---

## 28. PutKudu実行結果

PutKudu実行時には、

```text
In
= 1 FlowFile / 約2.75 KB

Tasks
= 1
```

となりました。

処理後、Connection Queueは、

```text
0 FlowFiles
```

になりました。

ただし、Queueが0になっただけではKudu成功とは断定せず、Kudu側でも確認しています。

---

## 29. Kuduの件数確認

Kudu側で、

```sql
SELECT COUNT(*) AS cnt
FROM nextj_ve_poc_kudu.salesforce_poc_test;
```

を実行しました。

結果は、

```text
cnt
10
```

でした。

Salesforce側のSOQLも`LIMIT 10`で、FlowFile内も10レコードだったため、

```text
Salesforce 10件
↓
NiFi 10件
↓
Kudu 10件
```

という件数一致を確認できました。

---

## 30. Kuduの実データ確認

さらにKudu側の実データも確認しました。

結果の一例は以下です。

```text
id
a0qfc000001X2P4AAK

orderno__c
T_DR11815202_20220117

leasecompanyvehiclecontractno__c
NULL

mj_leasekaishasyaryokeiyakunoyobi__c
NULL

entrydate__c
2022-02-10
```

Salesforce側で確認したJSONと照合したところ、10件について主要5項目の値が一致していました。

---

## 31. NULL値の確認

Salesforce側で、

```json
"LeaseCompanyVehicleContractNO__c": null
```

となっていたものは、Kudu側でも、

```text
NULL
```

として保持されています。

また、

```text
Mj_LeaseKaishaSyaryoKeiyakuNoYobi__c
```

についても、今回確認したデータではNULLがそのままKuduへ格納されています。

したがって、今回のPoCではNULL値も正常に保持できています。

---

## 32. 全角数字の確認

Salesforce側には、

```text
２１０４３５８
２１０４２１８
```

のような全角数字を含む文字列もありました。

Kudu側でも同じ内容で格納されています。

今回これらをSTRINGとして扱ったため、意図しない数値変換や文字化けが発生していないことを確認できました。

---

## 33. PoCの最終構成

最終的な構成は以下です。

```text
Salesforce Sandbox
        │
        │ OAuth2
        ▼
NextJ_Salesforce_PoC_OAuth2
        │
        ▼
QuerySalesforceObject
・Custom Query
・API Version 64.0
・Primary Node
        │
        │ success
        ▼
Salesforce_success_to_Kudu
        │
        ▼
JsonTreeReader_NextJ_Salesforce_PoC
・Infer Schema
        │
        ▼
PutKudu_NextJ_Salesforce_PoC
・UPSERT
・Lowercase Field Names = true
・All nodes
        │
        ▼
nextj_ve_poc_kudu.salesforce_poc_test
        │
        ▼
10件格納
```

---

## 34. 今回PoCで確認できたこと

今回、実際の環境で以下を確認できました。

- Salesforce Sandboxへ接続できる
- OAuth2認証が利用できる
- NiFiの`QuerySalesforceObject`が利用できる
- SOQLをParameter化して実行できる
- Salesforceから10件取得できる
- 取得結果をJSONのFlowFileとして受け取れる
- Primary Node実行によって重複Queryを防止できる
- `JsonTreeReader`のInfer SchemaでJSONを読み取れる
- NiFiからKuduへ接続できる
- `PutKudu`でUPSERTできる
- Salesforce `Id`をKuduのPrimary Keyとして利用できる
- Salesforce Field名と小文字Kudu Columnを対応させられる
- NULL値を保持できる
- 全角数字などを含むSTRINGを保持できる
- Salesforce側10件とKudu側10件が一致する
- Salesforce側とKudu側で主要Fieldの値が一致する

---

## 35. 今回のPoCでまだ決めていないこと

PoCが成功したことと、本番仕様が完成したことは分けて考える必要があります。

### 正式なSalesforce Object / Field

今回使用した`Order__c`は仮の対象です。

正式な、

- Object
- Field
- WHERE条件
- 取得範囲
- 業務上必要なデータ

は、業務要件確定後に変更する必要があります。

### データ型

今回は疎通優先でほぼSTRINGにしています。

今後は、

- String
- Boolean
- Date
- DateTime
- Integer
- Decimal

などをSalesforce側の型に合わせて、Kuduの型へ正式にマッピングする必要があります。

### 増分取得

今回は単純な10件取得です。

まだ、

- 初回全件取得
- 前回取得位置
- 更新日時による差分
- CDC
- Platform Event
- 削除データ

などは実装していません。

### エラー処理

現在のPoCでは、

```text
failure
→ terminate
```

としている箇所があります。

本番では、

- エラー内容記録
- エラーデータ退避
- Retry
- 再処理
- アラート
- 監視

などが必要です。

### 性能・負荷

今回の取得件数は10件だけです。

そのため、

- 大量データ
- Salesforce API Limit
- NiFi負荷
- Kudu負荷
- Batch Size
- 処理時間
- 同時実行

などの性能面は未検証です。

### 認証情報の正式管理

今回のPoCでは既存のSensitive ParameterをInheritanceして利用しています。

正式化時には、

- NextJ専用Salesforce接続ユーザー
- NextJ専用Connected App
- Client ID / Client Secret
- Password
- Secret管理方式

を分離するか検討した方が安全です。

---

## 36. Parameter Contextの今後の整理

今回、

```text
NEO_salesforce_sync_bk
```

全体をInheritanceしているため、NextJでは使用していない既存Parameterも見える状態です。

例えば、

```text
putsql_sql_1
putsql_sql_2
salesforce_jolt
schema_houjinhankatsu
tablename_houjinhankatsu
```

などです。

PoCの動作には影響していませんが、正式化時には、

> Salesforce認証用Parameter Contextを専用化する

など、必要なParameterだけに整理した方が分かりやすくなります。

---

## 37. 最終評価

今回のPoCについては、以下の結果となりました。

```text
Salesforce接続
→ 成功

OAuth2認証
→ 成功

SOQL実行
→ 成功

Salesforceデータ取得
→ 成功

NiFi FlowFile生成
→ 成功

NiFi → Kudu接続
→ 成功

Kudu書込み
→ 成功

Salesforce取得件数
→ 10件

Kudu格納件数
→ 10件

件数一致
→ 確認済み

主要Fieldの値
→ 一致確認済み

NULL
→ 正常保持

全角数字等の文字列
→ 正常保持
```

したがって、**今回のPoCの中心目的である「SalesforceのデータをNiFiのSalesforceコネクタで取得し、Kuduまで連携できること」は達成できた**と整理できます。

---

## 38. まとめ

今回、NextJ向けにPoC専用のNiFi Process Group、Parameter Context、OAuth2 Controller Service、Salesforce取得Processor、JsonTreeReader、PutKudu、Kudu Database / Tableを一から準備しました。

検証の途中では、

- Salesforce URL未設定
- OAuth2認証Parameter不足
- Sensitive Parameterの扱い
- Parameter ContextのInheritance
- `All nodes`によるSalesforce Queryの3重実行
- incoming connectionを持つPutKuduをPrimary Nodeにできない問題

などがありましたが、NiFiのValidation Errorや実データを確認しながら1つずつ解消しました。

最終的には、

**Salesforceから10件取得 → NiFiで1 FlowFileとして受信 → Kuduへ10件格納 → データ内容も一致**

まで確認できています。

そのため、今回の結果をもって、**Salesforce → NiFi → Kuduという基本的なデータ連携方式は技術的に実現可能であることを確認できた**と判断できます。

今後は、このPoC構成をそのまま本番化するのではなく、正式な業務要件に合わせて、対象Object / Field、型変換、増分取得、削除、エラー処理、監視、性能、認証情報管理などを具体化していく段階になります。
