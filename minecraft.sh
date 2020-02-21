#!/bin/bash -eu

# 実行ディレクトリ
cd "/minecraft"

# latest指定なら最新リリースを確認
if [ "${VERSION}" = "latest" ];then
    VERSION=$(curl -fsSL "https://launchermeta.mojang.com/mc/game/version_manifest.json" | jq -r ".latest.release")
fi
echo "version: ${VERSION}"
JAR="/minecraft_${VERSION}.jar"

# サーバーのjarがないならダウンロード
# (本当はDockerfile側でやりたいけど、権利的にまずそうなので)
if [ ! -e "${JAR}" ];then
    # まずは指定バージョンの情報を確認
    echo "info: Downloading server jar."
    manifest=$(curl -fsSL "https://launchermeta.mojang.com/mc/game/version_manifest.json" | jq -r ".versions[] | select(.id == \"${VERSION}\") | .url")
    if [ -z "${manifest}" ];then
        echo "error: Unknown version."
        exit 1
    fi

    # URLを取得
    url=$(curl -fsSL "${manifest}" | jq -r ".downloads.server.url")
    echo "url: ${url}"

    # ダウンロードして444に
    curl -L -o "${JAR}" "${url}"
    chmod 444 "${JAR}"
fi

# eula.txtを作成
if [ "${EULA,,}" = "true" ] && [ ! -e "/minecraft/eula.txt" ];then
    echo "info: Generate eula.txt"
    echo "eula=true" > "/minecraft/eula.txt"
fi

# もし残ってたら消す
if [ -e "/run/minecraft" ];then
    unlink /run/minecraft
fi
# SIGTERMされたらstopを送るようにする
mkfifo -m 600 /run/minecraft
trap "echo stop > /run/minecraft" SIGTERM SIGINT

# rootならユーザー指定して実行
if [ "$(id -u)" = 0 ];then
    # パーミッション調整しないと動かない
    # (ifせずに常にchownしてもいいが、全ファイル走査が必要になり起動が遅くなるので親ディレクトリが書き込み可能かどうかだけを見て調整するか決める)
    if gosu minecraft [ ! -w "/minecraft" ];then
        echo "info: Fix directory permission."
        chown -Rv minecraft:minecraft "/minecraft"
    fi
    # gosuでユーザー切り替えて実行
    tail -f /run/minecraft | gosu minecraft java ${JVM_OPTS} -jar "${JAR}" ${SERVER_OPTS} &
else
    # ユーザーがrootではないならそのまま実行
    tail -f /run/minecraft | java ${JVM_OPTS} -jar "${JAR}" ${SERVER_OPTS} &
fi
pid=$!

# コンソールからのコマンド入力ができるようにする
while true;do
    # タイムアウト付きのreadでコマンド入力があればサーバーに渡す
    if read -t 1 -r line;then
        echo "$line" > /run/minecraft
    fi
    # 死活チェック、死んでたら後始末して終わる
    if ! kill -0 $pid 2>/dev/null;then
        unlink /run/minecraft
        exit 0
    fi
done
