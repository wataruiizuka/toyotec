from pathlib import Path


# 対象フォルダ
TARGET_DIR = Path("/Users/iidzukawataru/toyotec/DX道場/ddl")

# 追加する接尾辞
SUFFIX = "_ddl"

# True  の場合：変更予定だけ表示する
# False の場合：実際にリネームする
DRY_RUN = False


def make_new_name(file_path: Path) -> str:
    """
    ファイル名の末尾に _ddl を追加する。
    拡張子がある場合は、拡張子の前に _ddl を追加する。

    例:
      sample.txt -> sample_ddl.txt
      sample     -> sample_ddl
    """
    stem = file_path.stem
    suffix = file_path.suffix

    # すでに _ddl で終わっている場合は二重付与しない
    if stem.endswith(SUFFIX):
        return file_path.name

    return f"{stem}{SUFFIX}{suffix}"


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
    print("ファイル名末尾に _ddl を追加する処理")
    print(f"対象フォルダ: {TARGET_DIR}")
    print(f"DRY_RUN: {DRY_RUN}")
    print("=" * 80)

    rename_count = 0
    skip_count = 0

    for file_path in files:
        new_name = make_new_name(file_path)
        new_path = file_path.with_name(new_name)

        # 変更不要
        if file_path.name == new_name:
            print(f"[SKIP] すでに付与済み: {file_path.name}")
            skip_count += 1
            continue

        # 変更後ファイル名が既に存在する場合は上書き防止
        if new_path.exists():
            print(f"[SKIP] 変更後ファイルが既に存在: {new_path.name}")
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