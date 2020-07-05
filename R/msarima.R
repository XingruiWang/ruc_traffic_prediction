library(xlsx)
library(forecast)
library(smooth)
library(tseries)
library(FinTS)

#======================= MSARIMA =================================
ruc_traffic <- read.xlsx("data/ruc_traffic.xlsx",1)

#平滑处理
x.hour = ruc_traffic$Speed
x.hour = filter(x.hour, rep(1/4,4))
x.hour = x.hour[ruc_traffic$Hour%%1==0]
x.hour = ts(x.hour[-1464], frequency = 24)

#差分
x.diff.week = diff(x.hour, 24*7)
x.diff.day = diff(x.diff.week, 24)
#差分后的acf和pacf
ggPacf(ts(x.diff.week, frequency = 24), lag.max=24*7*5, col="#444444")+scale_x_continuous(breaks=c(0:(5))*24*7, labels=c(0:5)*7)
ggAacf(ts(x.diff.week, frequency = 24), lag.max=24*7*5, col="#444444")+scale_x_continuous(breaks=c(0:(5))*24*7, labels=c(0:5)*7)
ggPacf(ts(x.diff.day, frequency = 24), lag.max=24*6, col="#444444")+scale_x_continuous(breaks=c(0:(6))*24, labels=c(0:6))
ggAcf(ts(x.diff.day, frequency = 24), lag.max=24*6, col="#444444")+scale_x_continuous(breaks=c(0:(6))*24, labels=c(0:6))

#拟合msarima模型
m2 =msarima(x.hour, orders=list(ar=c(1,0,3),i=c(0,0,0),ma=c(1,1,0)),lags=c(1,24,168),h=24*7*2,holdout=TRUE,FI=F)


#Arch 模型
p.q = NULL
N = 24*7*2
for(i in 1:N){
  test = ArchTest(res2, lag=i)
  p.q[i]=test$p.value
}

plot(1:N, p.q,type="l")
abline(h=0.05, col="red", lty=2)

g = garch(res2, order=c(0,2))
pred = predict(g)
plot(pred, main="")
plot(res2)
lines(pred[,1],col=2)
lines(pred[,2],col=2)
abline(h=1.96*sd(res2),col=3, lty=2)
abline(h=-1.96*sd(res2),col=4, lty=2)






