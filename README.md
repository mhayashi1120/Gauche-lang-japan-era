
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

