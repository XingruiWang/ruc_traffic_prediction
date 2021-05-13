library(xlsx)
library(forecast)
library(smooth)
library(tseries)

ruc_traffic <- read.xlsx("D:/Documents/文档/2_学校/时间序列/大作业/ruc_traffic_prediction/data/ruc_traffic.xlsx",1)
x <- ts(ruc_traffic$Speed,start = 193,frequency = 96)
Box.test(x)
acf(x,lag.max = 96*28)
pacf(x,lag.max = 200)

##周期性
x.diff.week <- diff(x, 672, 1)
plot(x.diff.week)
acf(x.diff.week,lag.max = 96*35) #5周的
acf(x.diff.week,lag.max = 96*5)

x.diff.day = diff(x.diff.week, 96, 1)
acf(x.diff.day,lag.max = 96*5)


load("model.RData")

## 建模
acf(x.diff.day,lag.max = 95)
pacf(x.diff.day,lag.max = 95)
x.diff.day[1:95] %>% ts() %>% auto.arima()
# arima(1,0,1)

acf(x.diff.day,lag.max = 95*6)
pacf(x.diff.day,lag.max = 95*6)
# *(0,0,1)[96]

acf(x.diff.week,lag.max = 95*35)
pacf(x.diff.week,lag.max = 95*35)
# *(0,0,1)[96*7] or *(4,0,0)[96*7]


m1 =msarima(x, orders=list(ar=c(1,0,0),i=c(0,0,0),ma=c(1,1,1)),lags=c(1,96,672),h=96,holdout=TRUE,FI=F)
m2_2 =msarima(x, orders=list(ar=c(1,0,4),i=c(0,0,0),ma=c(1,1,0)),lags=c(1,96,672),h=96*7,holdout=TRUE,FI=F)
m3 = msarima(x, orders=list(ar=c(2,3),i=c(0,0),ma=c(3,2)),lags=c(1,96),h=96,holdout=TRUE,FI=F)

m4 =msarima(x, orders=list(ar=c(4,0,4),i=c(0,0,0),ma=c(3,1,0)),lags=c(1,96,672),h=96*7,holdout=TRUE,FI=F)
# SARIMA(1,0,1)(0,0,1)[96]*(4,0,0)[96*7]

f2 = forecast(m2)
auto.msarima(x, orders=list(ar=c(4,4,4),i=c(1,1,1),ma=c(4,4,4)),lags=c(1,96,672))
auto.msarima(x)
# SARIMA(2,0,3)[1](3,0,2)[96]

for_fc = forecast(m2_2, h=96*14)
plot(for_fc)# m2预测较好

for_fc = forecast(m4, h=96*14)
plot(for_fc)# m2预测较好

####====================
m7 <- tbats(msts_x, seasonal_periods=c(96, 96*7))
fc <- forecast(m7)
plot(fc)
# TBATS 对预测较为平稳 可以发现周末的异常 但弱于arima

###===============
m8 = dshw(x, period1 = 96, period2 = 672)
fc <- forecast(m.hour.8)
plot(fc)

##==========================
## stl分解 （加法模型 不能完全分解周期项）
msts_x = msts(x, seasonal.periods = c(96, 96*7), ts.frequency = 96)
m5 = auto.arima(msts_x)
m6 = auto.msarima(msts_x,h=96*7,holdout=TRUE,FI=F)
#ARIMA(1,0,4)(0,1,0)[96] 

for_fc = forecast(m4, h=96*14)
plot(for_fc)

mstl_model <- msts_x  %>% head(96 *7 *8 ) %>% mstl()
autoplot(mstl_model,mstl_model)
x.r <- remainder(mstl_model)
x.s <- seasonal(mstl_model)
x.s.1 = ts(x.s[,1], frequency = 96)
x.s.2 = ts(x.s[,1], frequency = 96)
x.t = ts(mstl_model[,2], frequency = 96)

m.r = arima(x.r, order = c(1,0,2), seasonal=list(order=c(0,0,1), period=96))

##===============================
## 傅里叶级数回归 分解趋势项 不太会
aic_vals_temp =NULL
aic_vals = NULL
y <- c(1:length(x)) %>% ts(frequency = 96)
for(i in 1:5)
{
  for (j in 1:5)
  {
#    xreg1=fourier(y,i, 96)
#    xreg2=fourier(y, j, 96*7)
#    xtrain <- c(xreg1, xreg2)
    xtrain = fourier(data_msts, K = c(i, j))
    fitma1 <- auto.arima(x, D=0, max.P =0, max.Q=0, xreg=xtrain)
    aic_vals_temp <- cbind(i, j, fitma1$aic)
    aic_vals <- rbind(aic_vals, aic_vals_temp)
  }
}
colnames(aic_vals) <- c("FourierTerms96", "FourierTerms672", "AICValue")
aic_vals <- data.frame(aic_vals)
minAICVal=min(aic_vals$AICValue)
minvals=aic_vals[which(aic_vals$AICValue==minAICVal),]

#==============
data_msts <- msts(x, seasonal.periods = c(period, period*7))
m3 = tslm(data_msts ~ fourier(data_msts, K = c(3, 3)))
period = 96
K=3

trend_beer = ma(x, order = 4, centre = T) #计算移动平均数，期数为4
plot(as.ts(trend_beer))

for(i in 1:200){
  test = Box.test(res, lag=i)
  pvalue[i]=test$p.value
}