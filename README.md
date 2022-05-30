
https://kakurasan.blogspot.com/2019/04/glibc-strftime-reiwa-era-support.html

どうやったらライブラリ内で局所化できるだろうか？

```
#?= (sys-localeconv)
  #?= (sys-setlocale LC_TIME "ja_JP.UTF-8")
  #?= (sys-strftime "%EC %Ey 年 %B%d日 %X" (date->sys-tm (current-date)))
  #?= (sys-localeconv)
  #?= (sys-setlocale LC_TIME "C")
  #?= (sys-localeconv)
```

http://manpages.ubuntu.com/manpages/trusty/ja/man7/locale.7.html

strftime にしか影響ないらしいから、別にいいんだろうけど…
