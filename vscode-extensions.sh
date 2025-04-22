#!/bin/bash

# VSCode拡張機能管理スクリプト
# 使用方法:
# ./vscode-extensions.sh list - インストール済み拡張機能の一覧を表示
# ./vscode-extensions.sh export [ファイル名] - 拡張機能リストをextensions.json形式で出力（デフォルト: extensions.json）
# ./vscode-extensions.sh install [ファイル名] - extensions.jsonから拡張機能をインストール（デフォルト: extensions.json）
# ./vscode-extensions.sh backup-install [ファイル名] - 拡張機能をエクスポートしてからインストール（新環境セットアップ用）

# デフォルトのファイル名
DEFAULT_FILE="extensions.json"

# コマンドライン引数の確認
if [ $# -eq 0 ]; then
    echo "使用方法: $0 [list|export|install|backup-install] [ファイル名(オプション)]"
    exit 1
fi

# 操作の種類
ACTION=$1
# ファイル名（指定されていない場合はデフォルト値を使用）
FILE=${2:-$DEFAULT_FILE}

# インストール済み拡張機能の一覧を表示
list_extensions() {
    echo "インストール済みVSCode拡張機能一覧:"
    code --list-extensions
    echo "合計: $(code --list-extensions | wc -l | tr -d ' ') 個の拡張機能がインストールされています"
}

# 拡張機能リストをextensions.json形式でファイルに出力
export_extensions() {
    echo "拡張機能リストを $FILE に出力しています..."
    
    # 一時ファイルに拡張機能IDのリストを取得
    TEMP_LIST=$(mktemp)
    code --list-extensions > "$TEMP_LIST"
    
    # 拡張機能の数をカウント
    EXTENSION_COUNT=$(wc -l < "$TEMP_LIST" | tr -d ' ')
    
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
    done < "$TEMP_LIST"
    
    echo "  ]," >> "$FILE"
    echo "  \"unwantedRecommendations\": []" >> "$FILE"
    echo "}" >> "$FILE"
    
    # 一時ファイルを削除
    rm "$TEMP_LIST"
    
    echo "完了！ $EXTENSION_COUNT 個の拡張機能が $FILE に保存されました"
}

# extensions.jsonから拡張機能をインストール
install_extensions() {
    if [ ! -f "$FILE" ]; then
        echo "エラー: $FILE が見つかりません"
        exit 1
    fi
    
    echo "$FILE から拡張機能をインストールしています..."
    
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
            code --install-extension "$extension"
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
        echo "使用方法: $0 [list|export|install|backup-install] [ファイル名(オプション)]"
        exit 1
        ;;
esac

exit 0
