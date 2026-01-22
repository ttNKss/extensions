# VSCode/Cursor 拡張機能管理ツール

VSCode/Cursorの拡張機能の一覧出力とインストールを自動化するシェルスクリプト。

## 機能

- インストール済み拡張機能の一覧表示
- 拡張機能リストをextensions.json形式で出力
- extensions.jsonから拡張機能をインストール
- バックアップと一括インストール
- **VSCode / Cursor 両対応**

## 使用方法

```bash
# 実行権限を付与
chmod +x vscode-extensions.sh

# === VSCode（デフォルト） ===

# 拡張機能の一覧を表示
./vscode-extensions.sh list

# 拡張機能リストをextensions.json形式で出力
./vscode-extensions.sh export [ファイル名(省略可)]

# extensions.jsonから拡張機能をインストール
./vscode-extensions.sh install [ファイル名(省略可)]

# バックアップしてからインストール（新環境セットアップ用）
./vscode-extensions.sh backup-install [ファイル名(省略可)]

# === Cursor ===

# --cursor または -c オプションを追加するとCursorを対象にします
./vscode-extensions.sh --cursor list
./vscode-extensions.sh -c export
./vscode-extensions.sh --cursor install
./vscode-extensions.sh -c backup-install
```

## オプション

| オプション | 説明 |
|-----------|------|
| `--cursor`, `-c` | Cursorエディタを対象にする（デフォルトはVSCode） |

※ファイル名を省略した場合は `.vscode/extensions.json` が使用されます
