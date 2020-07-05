library(xlsx)
library(forecast)
library(smooth)
library(tseries)
library(FinTS)

ruc_traffic <- read.xlsx("data/ruc_traffic.xlsx",1)
x.hour = ruc_traffic$Speed
x.hour = filter(x.hour, rep(1/4,4))
x.hour = x.hour[ruc_traffic$Hour%%1==0]
x.hour = ts(x.hour[-1464], frequency = 24)
x.hour.train = x.hour[1:(24*7*6)] %>% ts(frequency = 24)

x.hour.ds.model.2 = dshw(x.hour.train, period1 = 24, period2 = 24*7)
