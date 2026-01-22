#!/bin/bash

# VSCode/Cursor 拡張機能管理スクリプト
# 使用方法:
# ./vscode-extensions.sh [--cursor|-c] list - インストール済み拡張機能の一覧を表示
# ./vscode-extensions.sh [--cursor|-c] export [ファイル名] - 拡張機能リストを.vscode/extensions.json形式で出力（デフォルト: .vscode/extensions.json）
# ./vscode-extensions.sh [--cursor|-c] install [ファイル名] - .vscode/extensions.jsonから拡張機能をインストール（デフォルト: .vscode/extensions.json）
# ./vscode-extensions.sh [--cursor|-c] backup-install [ファイル名] - 拡張機能をエクスポートしてからインストール（新環境セットアップ用）
#
# オプション:
#   --cursor, -c  Cursorエディタを対象にする（デフォルトはVSCode）

# デフォルトのファイル名
DEFAULT_FILE=".vscode/extensions.json"

# 除外設定ファイル（スクリプトと同じディレクトリに配置）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IGNORE_FILE="$SCRIPT_DIR/.extensionsignore"

# デフォルトのエディタコマンド
EDITOR_CMD="code"
EDITOR_NAME="VSCode"

# --cursor または -c オプションの確認
if [ "$1" = "--cursor" ] || [ "$1" = "-c" ]; then
    EDITOR_CMD="cursor"
    EDITOR_NAME="Cursor"
    shift  # オプションを消費して次の引数へ
fi

# コマンドライン引数の確認
if [ $# -eq 0 ]; then
    echo "使用方法: $0 [--cursor|-c] [list|export|install|backup-install] [ファイル名(オプション)]"
    echo ""
    echo "オプション:"
    echo "  --cursor, -c  Cursorエディタを対象にする（デフォルトはVSCode）"
    exit 1
fi

# 操作の種類
ACTION=$1
# ファイル名（指定されていない場合はデフォルト値を使用）
FILE=${2:-$DEFAULT_FILE}

# インストール済み拡張機能の一覧を表示
list_extensions() {
    echo "インストール済み${EDITOR_NAME}拡張機能一覧:"
    $EDITOR_CMD --list-extensions
    echo "合計: $($EDITOR_CMD --list-extensions | wc -l | tr -d ' ') 個の拡張機能がインストールされています"
}

# 除外パターンにマッチするかチェック（マッチしたら1を返す）
is_ignored() {
    local extension="$1"
    
    # 除外設定ファイルがなければ除外しない
    if [ ! -f "$IGNORE_FILE" ]; then
        return 1
    fi
    
    # 除外設定ファイルを1行ずつ読み込む
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        # 空行とコメント行をスキップ
        if [ -z "$pattern" ] || [[ "$pattern" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # パターンの前後の空白を削除
        pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # 部分一致でチェック
        if [[ "$extension" == *"$pattern"* ]]; then
            return 0  # マッチした（除外対象）
        fi
    done < "$IGNORE_FILE"
    
    return 1  # マッチしなかった（除外対象外）
}

# 拡張機能リストを.vscode/extensions.json形式でファイルに出力
export_extensions() {
    echo "${EDITOR_NAME}拡張機能リストを $FILE に出力しています..."
    
    # 除外設定ファイルの存在確認
    if [ -f "$IGNORE_FILE" ]; then
        echo "除外設定ファイル: $IGNORE_FILE を使用"
    fi
    
    # 一時ファイルに拡張機能IDのリストを取得
    TEMP_LIST=$(mktemp)
    FILTERED_LIST=$(mktemp)
    $EDITOR_CMD --list-extensions > "$TEMP_LIST"
    
    # 元の拡張機能数をカウント
    ORIGINAL_COUNT=$(wc -l < "$TEMP_LIST" | tr -d ' ')
    
    # 除外パターンを適用してフィルタリング
    IGNORED_COUNT=0
    while IFS= read -r extension; do
        if [ -n "$extension" ]; then
            if is_ignored "$extension"; then
                IGNORED_COUNT=$((IGNORED_COUNT + 1))
                echo "  除外: $extension"
            else
                echo "$extension" >> "$FILTERED_LIST"
            fi
        fi
    done < "$TEMP_LIST"
    
    # フィルタリング後の拡張機能の数をカウント
    EXTENSION_COUNT=$(wc -l < "$FILTERED_LIST" | tr -d ' ')
    
    # JSON形式に変換
    echo "{" > "$FILE"
    echo "  \"recommendations\": [" >> "$FILE"
    
    # 各拡張機能IDをJSON配列要素として追加
    COUNTER=0
    while IFS= read -r extension; do
        if [ -n "$extension" ]; then
            COUNTER=$((COUNTER + 1))
            if [ $COUNTER -eq $EXTENSION_COUNT ]; then
                # 最後の要素にはカンマを付けない
                echo "    \"$extension\"" >> "$FILE"
            else
                echo "    \"$extension\"," >> "$FILE"
            fi
        fi
    done < "$FILTERED_LIST"
    
    echo "  ]," >> "$FILE"
    echo "  \"unwantedRecommendations\": []" >> "$FILE"
    echo "}" >> "$FILE"
    
    # 一時ファイルを削除
    rm "$TEMP_LIST" "$FILTERED_LIST"
    
    echo ""
    echo "完了！"
    echo "  合計: $ORIGINAL_COUNT 個"
    echo "  除外: $IGNORED_COUNT 個"
    echo "  出力: $EXTENSION_COUNT 個の拡張機能が $FILE に保存されました"
}

# .vscode/extensions.jsonから拡張機能をインストール
install_extensions() {
    if [ ! -f "$FILE" ]; then
        echo "エラー: $FILE が見つかりません"
        exit 1
    fi
    
    echo "$FILE から${EDITOR_NAME}に拡張機能をインストールしています..."
    
    # jqコマンドがインストールされているか確認
    if command -v jq &> /dev/null; then
        # jqを使用してJSONからrecommendations配列を抽出
        EXTENSIONS=$(jq -r '.recommendations[]' "$FILE" 2>/dev/null)
        
        if [ $? -ne 0 ]; then
            echo "エラー: $FILE の解析に失敗しました。有効なJSON形式であることを確認してください。"
            exit 1
        fi
    else
        # jqがない場合は簡易的なgrepとsedで抽出（完全ではないが基本的な形式には対応）
        EXTENSIONS=$(grep -o '"[^"]*"' "$FILE" | grep -v "recommendations\|unwantedRecommendations" | sed 's/"//g')
    fi
    
    # 拡張機能をインストール
    total=$(echo "$EXTENSIONS" | wc -l | tr -d ' ')
    current=0
    
    echo "$EXTENSIONS" | while read -r extension; do
        if [ -n "$extension" ]; then
            current=$((current + 1))
            echo "[$current/$total] $extension をインストール中..."
            $EDITOR_CMD --install-extension "$extension"
        fi
    done
    
    echo "完了！ $total 個の拡張機能がインストールされました"
}

# バックアップしてから新環境にインストール（新しいマシンのセットアップ用）
backup_install() {
    export_extensions
    install_extensions
}

# 指定されたアクションを実行
case "$ACTION" in
    list)
        list_extensions
        ;;
    export)
        export_extensions
        ;;
    install)
        install_extensions
        ;;
    backup-install)
        backup_install
        ;;
    *)
        echo "エラー: 無効なアクション '$ACTION'"
        echo "使用方法: $0 [--cursor|-c] [list|export|install|backup-install] [ファイル名(オプション)]"
        exit 1
        ;;
esac

exit 0
