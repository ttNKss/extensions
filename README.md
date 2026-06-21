# VSCode/Cursor/Antigravity 拡張機能管理ツール

VSCode/Cursor/Antigravityの拡張機能の一覧出力とインストールを自動化するシェルスクリプト。

## 機能

- インストール済み拡張機能の一覧表示
- 拡張機能リストをextensions.json形式で出力
- extensions.jsonから拡張機能をインストール
- バックアップと一括インストール
- **VSCode / Cursor / Antigravity 対応**

## 前提条件（CLIコマンドのインストール）

本スクリプトを実行するには、対象とするエディタのCLIコマンドがシステムにインストールされ、環境変数 `PATH` に追加されている必要があります。

### VSCode (`code` コマンド)
1. **VSCode** を起動します。
2. コマンドパレット（`Cmd+Shift+P` または `Ctrl+Shift+P`）を開きます。
3. `Shell Command: Install 'code' command in PATH` と入力して選択し、実行します。

### Cursor (`cursor` コマンド)
1. **Cursor** を起動します。
2. コマンドパレット（`Cmd+Shift+P` または `Ctrl+Shift+P`）を開きます。
3. `Shell Command: Install 'cursor' command in PATH` と入力して選択し、実行します。

### Antigravity (`antigravity` または `antigravity-ide` コマンド)
1. **Antigravity** を起動します。
2. コマンドパレット（`Cmd+Shift+P` または `Ctrl+Shift+P`）を開きます。
3. `Shell Command: Install 'antigravity' command in PATH` 
   （環境によっては `Install 'antigravity-ide' command in PATH`）と入力して選択し、実行します。

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

# === Antigravity ===

# --antigravity または -a オプションを追加するとAntigravityを対象にします
./vscode-extensions.sh --antigravity list
./vscode-extensions.sh -a export
./vscode-extensions.sh --antigravity install
./vscode-extensions.sh -a backup-install
```

## オプション

| オプション | 説明 |
|-----------|------|
| `--cursor`, `-c` | Cursorエディタを対象にする（デフォルトはVSCode） |
| `--antigravity`, `-a` | Antigravityエディタを対象にする |

※ファイル名を省略した場合は `.vscode/extensions.json` が使用されます

## 除外設定（.extensionsignore）

特定の拡張機能をエクスポート対象から除外したい場合は、スクリプトと同じディレクトリに `.extensionsignore` ファイルを作成します。

### 形式

```
# コメント行（#で始まる行は無視されます）
# 空行も無視されます

# 部分一致で除外されます
mycompany.           # mycompany.で始まる拡張機能を除外
internal-            # internal-を含む拡張機能を除外
ms-vscode-remote.    # 特定のパブリッシャーを除外
```

### 動作例

```bash
$ ./vscode-extensions.sh export
Cursor拡張機能リストを .vscode/extensions.json に出力しています...
除外設定ファイル: /path/to/.extensionsignore を使用
  除外: mycompany.internal-tools
  除外: mycompany.private-snippets

完了！
  合計: 50 個
  除外: 2 個
  出力: 48 個の拡張機能が .vscode/extensions.json に保存されました
```
