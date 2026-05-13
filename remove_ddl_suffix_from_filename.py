from pathlib import Path


# 対象フォルダ
TARGET_DIR = Path("/Users/iidzukawataru/toyotec/DX道場/ddl")

# True  の場合：変更予定だけ表示する
# False の場合：実際にリネームする
DRY_RUN = False


def remove_ddl_suffix_from_stem(stem: str) -> str:
    """
    ファイル名本体の末尾に付いている ddl / _ddl を削除する。

    例:
      sample_ddl -> sample
      sampleddl  -> sample
      sample     -> sample
    """
    if stem.endswith("_ddl"):
        return stem[:-4]

    if stem.endswith("ddl"):
        return stem[:-3]

    return stem


def make_new_name(file_path: Path) -> str:
    """
    以下の2処理を行った新ファイル名を返す。

    1. ファイル名末尾の ddl / _ddl を削除
    2. 拡張子 .sql を .ddl に変更

    例:
      sample_ddl.sql -> sample.ddl
      sampleddl.sql  -> sample.ddl
      sample.sql     -> sample.ddl
      sample_ddl.ddl -> sample.ddl
      sample.ddl     -> sample.ddl
    """
    stem = file_path.stem
    suffix = file_path.suffix

    # 1. ファイル名本体の末尾 ddl / _ddl を削除
    new_stem = remove_ddl_suffix_from_stem(stem)

    # 空ファイル名になるのを防止
    if not new_stem:
        new_stem = stem

    # 2. 拡張子 .sql を .ddl に変更
    if suffix.lower() == ".sql":
        new_suffix = ".ddl"
    else:
        new_suffix = suffix

    return f"{new_stem}{new_suffix}"


def main() -> None:
    if not TARGET_DIR.exists():
        raise FileNotFoundError(f"対象フォルダが存在しません: {TARGET_DIR}")

    if not TARGET_DIR.is_dir():
        raise NotADirectoryError(f"対象パスがフォルダではありません: {TARGET_DIR}")

    files = sorted([p for p in TARGET_DIR.iterdir() if p.is_file()])

    if not files:
        print("対象フォルダ内にファイルがありません。")
        return

    print("=" * 80)
    print("ファイル名末尾の ddl / _ddl 削除 + .sql を .ddl に変更する処理")
    print(f"対象フォルダ: {TARGET_DIR}")
    print(f"DRY_RUN: {DRY_RUN}")
    print("=" * 80)

    rename_pairs = []
    skip_count = 0

    # 事前にリネーム予定を作成
    for file_path in files:
        new_name = make_new_name(file_path)
        new_path = file_path.with_name(new_name)

        if file_path.name == new_name:
            print(f"[SKIP] 変更不要: {file_path.name}")
            skip_count += 1
            continue

        rename_pairs.append((file_path, new_path))

    # 変更後ファイル名の重複チェック
    destination_names = [new_path.name for _, new_path in rename_pairs]
    duplicate_names = sorted(
        {name for name in destination_names if destination_names.count(name) > 1}
    )

    if duplicate_names:
        print("[ERROR] 変更後ファイル名が重複します。処理を中止します。")
        for name in duplicate_names:
            print(f"  重複ファイル名: {name}")
        return

    rename_count = 0

    for file_path, new_path in rename_pairs:
        # 変更後ファイルが既に存在し、かつ今回のリネーム元ではない場合は上書き防止
        if new_path.exists() and new_path != file_path:
            print(f"[SKIP] 変更後ファイルが既に存在: {file_path.name} -> {new_path.name}")
            skip_count += 1
            continue

        print(f"[RENAME] {file_path.name} -> {new_path.name}")

        if not DRY_RUN:
            file_path.rename(new_path)

        rename_count += 1

    print("=" * 80)

    if DRY_RUN:
        print("ドライラン完了：実際のリネームは行っていません。")
        print("内容に問題がなければ、DRY_RUN = False に変更して再実行してください。")
    else:
        print("リネーム完了：実際にファイル名を変更しました。")

    print(f"変更対象数: {rename_count}")
    print(f"スキップ数: {skip_count}")
    print("=" * 80)


if __name__ == "__main__":
    main()