# Gauche-lang-japan-era

[![CI](https://github.com/mhayashi1120/Gauche-lang-japan-era/actions/workflows/build.yml/badge.svg)](https://github.com/mhayashi1120/Gauche-lang-japan-era/actions/workflows/build.yml)

日本の元号への localization (l10n) です。令和(平成)から明治までの範囲 (誕生日) で永らく使っていたのを南北朝時代以降 (1394 年) まで拡張して公開しておきます。

> # locale -a

を実行して ja_JP.utf8 が含まれていない場合は OS の設定が必要かもしれません。各 OS の設定を参照してください。

# API (一部)

\<date> の timezone part が日本 (+32400) でない場合の挙動は今のところ考慮されていません。

## date->era (Procedure)

日付を \<date> でとり、できうる限り元号への変換を試みます。元号 (string) と 年 (integer) を返します。OS から最新の元号が取得できない場合の元号は、このモジュールで対応している最新の元号 (令和) となります。変換できない場合の戻り値は #f と #f です。

## date->era! (Procedure)

date->era と同じですが、 OS から最新の元号を取得できない場合はエラーになります。

## source-locale-ja (Parameter)

`sys-setlocale` した後、正確に切り戻す方法が見当たらないため用意した parameter です。`sys-strftime` を別の場所でも使っている場合は使用を検討してください。

## その他

省略

