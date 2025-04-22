# VSCode拡張機能管理ツール

VSCode拡張機能の一覧出力とインストールを自動化するシェルスクリプト。

## 機能

- インストール済み拡張機能の一覧表示
- 拡張機能リストをextensions.json形式で出力
- extensions.jsonから拡張機能をインストール
- バックアップと一括インストール

## 使用方法

```bash
# 実行権限を付与
chmod +x vscode-extensions.sh

# 拡張機能の一覧を表示
./vscode-extensions.sh list

# 拡張機能リストをextensions.json形式で出力
./vscode-extensions.sh export [ファイル名(省略可)]

# extensions.jsonから拡張機能をインストール
./vscode-extensions.sh install [ファイル名(省略可)]

# バックアップしてからインストール（新環境セットアップ用）
./vscode-extensions.sh backup-install [ファイル名(省略可)]
```

※ファイル名を省略した場合は「extensions.json」が使用されます
