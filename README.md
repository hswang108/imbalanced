#評估預測即將違約貸款的模式(imbalanced data不平衡資料的判讀)


###命令
```R
Rscript Evalute.R --target bad/good -- badthre <threshold> --input meth1 meth2 ... methx --output result.csv

```

* 讀入多個文件
* 由“--target”選項定義的正例
* 閾值由“--badthree ”選項定義
* 執行Evalute.R


### 輸入格式
* 最後一列pred.score是“不良貸款”的預測概率。

#### 示例：`examples/method1.csv`

persons	reference	pred.score
person1	bad	      0.807018548483029
person2	bad	      0.740809247596189
person3	bad	      0.0944965328089893
person4	good	    0.148418645840138

＃＃＃ 輸出格式
* 編寫函數來計算指標。
* 找出哪種方法在指標方面表現最好。
* pseudo R*R = 1 - deviance(model)/deviance(null model) for S=0.

#### 示例：`examples/output1.csv`

method	sensitivity	specificity	F1	logLikelihood	pseudoR2
method1	0.91	      0.96	      0.85	-132	      0.79
method2	0.99	      0.98	      0.86	-112	      0.70
best	  method2	    method2	 method2	method2	    method1


### Null model
*作為“明顯的猜測”：無論輸入如何，總是輸出一個常數
*始終返回“不良”貸款的比例

### 測試命令示例

```R
Rscript Evalute.R --target bad -- badthre 0.5 --input examples/method1.csv examples/method2.csv --output examples/output1.csv
Rscript Evalute.R --target bad -- badthre 0.4 --input examples/method1.csv examples/method3.csv examples/method5.csv --output examples/output2.csv 
Rscript Evalute.R --target good -- badthre 0.6 --input examples/method2.csv examples/method4.csv examples/method6.csv --output examples/output3.csv 
```
### 網路安全數據集
https://github.com/jivoi/awesome-ml-for-cybersecurity
可導入家用或公司防火牆封包檢測資料，去判斷異常封包流量。
### 程式碼參考下列改寫
Practical Data Science with R 2nd edition (Nina Zumel and John Mount)
https://github.com/WinVector/PDSwR2/tree/master

