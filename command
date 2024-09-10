先安装一堆乱七八糟的依赖
@(require
cd /Users/cheng.kun/Documents/GitHub/eopl3_zh
scribble --xelatex /Users/cheng.kun/Documents/GitHub/eopl3_zh/chapters/eopl.scrbl


cd /Users/cheng.kun/Documents/GitHub/eopl3_zh
scribble --latex /Users/cheng.kun/Documents/GitHub/eopl3_zh/chapters/eopl.scrbl

lualatex
cd /Users/cheng.kun/Documents/GitHub/eopl3_zh
scribble --lualatex /Users/cheng.kun/Documents/GitHub/eopl3_zh/chapters/eopl.scrbl


cd /Users/cheng.kun/Documents/GitHub/eopl3_zh
scribble --html /Users/cheng.kun/Documents/GitHub/eopl3_zh/chapters/eopl.scrbl