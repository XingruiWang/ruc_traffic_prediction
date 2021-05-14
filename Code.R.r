library(xlsx)
library(forecast)
library(smooth)
library(tseries)
library(FinTS)
library(ggplot2)

#======================= MSARIMA =================================
ruc_traffic <- read.csv("Documents/Courses/时间序列分析/output.csv", 1)



#平滑处理
x.hour = ruc_traffic$Speed
x.hour = filter(x.hour, rep(1/4,4))
x.hour = x.hour[ruc_traffic$Hour%%4==1]
x.hour = ts(x.hour, frequency = 24)
ggAcf(x.hour, lag.max=24*7*5, col="#444444")
#差分
x.diff.week = diff(x.hour, 24*7)
x.diff.day = diff(x.diff.week, 24)
#差分后的acf和pacf
ggPacf(ts(x.diff.week, frequency = 24*7), lag.max=24*7*5, col="#444444")+scale_x_continuous(breaks=c(0:(5))*24*7, labels = c(0:5)*7)
ggAcf(ts(x.diff.week, frequency = 24*7), lag.max=24*7*5, col="#444444")+scale_x_continuous(breaks=c(0:(5))*24*7, labels=c(0:5)*7)
ggPacf(ts(x.diff.day, frequency = 24), lag.max=24*6, col="#444444")+scale_x_continuous(breaks=c(0:(6))*24, labels=c(0:6))
ggAcf(ts(x.diff.day, frequency = 24), lag.max=24*6, col="#444444")+scale_x_continuous(breaks=c(0:(6))*24, labels=c(0:6))



#拟合msarima模型
m2 =msarima(x.hour, orders=list(ar=c(1,0,4),i=c(0,0,0),ma=c(1,6,0)),lags=c(1,24,168),h=24*7*2,holdout=TRUE,FI=F)

#DSHW
x.hour.train = x.hour[1:(24*7*6)] %>% ts(frequency = 24)

x.hour.ds.model.2 = dshw(x.hour.train, period1 = 24, period2 = 24*7)


x.hour.test = x.hour[(24*7*6+1):(24*7*8)] %>% ts(frequency = 24)

#预测
for_m2 = forecast(m2, h=24*7*2)
y_hat_2=for_m2$mean
plot(for_m2)

for_ds = forecast(x.hour.ds.model.2, h=24*7*2)
y_hat_3 = for_ds$mean
plot(for_ds)

for_m4 = forecast(m4, h=24*7*2)
y_hat_4 = for_m4$mean
plot(for_m4)

#预测图
fore_df = data.frame(idx = c(1:(length(x.hour.test))/24),test=x.hour.test, x1=x.hour.ds.model.2$mean, x2 = m2$forecast)
idx_date = seq.Date(from = as.Date("2017/05/17",format = "%Y/%m/%d"), by = "day", length.out = 15)

ggplot(fore_df)+geom_line(aes(idx, test),col="#444444")+
  geom_line(aes(idx, x1), col="#0081a7")+
  geom_line(aes(idx, x2),col="#f07167")+
  scale_x_continuous(breaks=seq(0, 14, 1), labels = idx_date)+
  xlab(label = "Date")+ylab(label = "Speed")+
  theme(axis.text.x = element_text(angle = 90))

# 准确率计算
EC_2 = 1-sqrt(sum(((c(x.hour.test)-c(y_hat_2))^2)))/(sqrt(sum(c(y_hat_2)^2))+sqrt(sum(c(x.hour.test)^2)))
EC_3 = 1-sqrt(sum(((c(x.hour.test)-c(y_hat_3))^2)))/(sqrt(sum(c(y_hat_3)^2))+sqrt(sum(c(x.hour.test)^2)))
RMSE_2 <- sqrt(sum(((c(x.hour.test)-c(y_hat_2))^2))/336)
RMSE_3 <- sqrt(sum(((c(x.hour.test)-c(y_hat_3))^2))/336)
MAPE_2 <- sum(abs((c(x.hour.test)-c(y_hat_2)))/c(x.hour.test))/(336)*100
MAPE_3 <- sum(abs((c(x.hour.test)-c(y_hat_3)))/c(x.hour.test))/(336)*100



# 残差检验
#MSARIMA
res2 = m2$residuals
acf(res2, lag.max = 24*7*2)
pvalue_2 = NULL
N = 7*2
for(i in 1:N){
  test = Box.test(res2, lag=i*24)
  pvalue_2[i]=test$p.value
}

## auto-arima
res4 = m4$residuals
pvalue_4 = NULL
N = 7*2
for(i in 1:N){
  test = Box.test(res4, lag=i*24)
  pvalue_4[i]=test$p.value
}

p.4.df = data.frame(x = c(1:N), p = pvalue_4)
ggplot(p.4.df)+geom_point(aes(x = x, y = p),alpha=0.5)+
  geom_hline(yintercept =0.05, col="red", lty=2)+
  scale_x_continuous(breaks=c(1:7)*2)


# DSHW
res.ds.model = x.hour.ds.model.2$residuals
acf(res.ds.model, lag.max = 24*7*2)

p.ds.model = NULL
N = 7*2
for(i in 1:N){
  test = Box.test(res.ds.model, lag=i*24)
  p.ds.model[i]=test$p.value
}



p.2.df = data.frame(x = c(1:N), p = pvalue_2)
ggplot(p.2.df)+geom_point(aes(x = x, y = p),alpha=0.5)+
  geom_hline(yintercept =0.05, col="red", lty=2)+
  scale_x_continuous(breaks=c(1:7)*2)

p.ds.df = data.frame(x = c(1:N), p = p.ds.model)
ggplot(p.ds.df)+geom_point(aes(x = x, y = p),alpha=0.5)+
  geom_hline(yintercept =0.05, col="red", lty=2)+
  scale_x_continuous(breaks=c(1:7)*2)

plot(1:N, pvalue_2, type="l")
abline(h=0.05, col="red", lty=2)

plot(1:N, p.ds.model,type="l")
abline(h=0.05, col="red", lty=2)




#ADF检验
p.adf = NULL
N = 7*4
for(i in 1:N){
  test = adfTest(res2, lags=i*6, type="nc")
  p.adf[i]=test@test$p.value
}
p.adf.df=data.frame(x = c(1:N), p = p.adf)
ggplot(p.adf.df)+geom_point(aes(x = x, y = p),alpha=0.5)+
  geom_hline(yintercept =0.05, col="red", lty=2)+
  scale_x_continuous(breaks=c(1:7)*4)

# ggplot残差图

res.df = data.frame(x = c(1:1008), r1 = res.ds.model, r2 = res2[1:1008])
ggplot(res.df)+geom_line(aes(x, r1), alpha=0.8)+
  scale_x_continuous(breaks=c(0:6)*168, labels = c(0:6))
ggplot(res.df)+geom_line(aes(x, r2))+
  scale_x_continuous(breaks=c(0:6)*168, labels = c(0:6))





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


