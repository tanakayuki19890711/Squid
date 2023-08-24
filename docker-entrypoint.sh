#!/usr/bin/env bash
if [ "$1" == "squid" ]; then
  shift
  set -- /usr/sbin/squid "$@"
elif [ "${1:0:1}" = '-' ]; then
 set -- /usr/sbin/squid "$@"
fi
exec "$@"

# コンテナが起動されたときに実行するコマンドを解釈する。
# もし引数の最初が"squid"であれば、その後の引数を取り除いて"/usr/sbin/squid"コマンドを実行します。
# もし引数の最初の文字がハイフンであれば、同様に"/usr/sbin/squid"コマンドを実行します。それ以外の場合は、引数に指定されたコマンドをそのまま実行します。