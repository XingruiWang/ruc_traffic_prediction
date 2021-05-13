library(ggplot2)

ruc_traffic <- read.xlsx("data/ruc_traffic.xlsx",1)
x = ruc_traffic$Speed
x = x[1:(96*7)]
x.hour = filter(x, rep(1/4,4))
df = data.frame(idx = c(1:length(x)/96)+1,x.org = x, x.filter = x.hour)

ggplot(df)+geom_line(aes(idx, x.org), col="gray")+geom_line(aes(idx,x.filter), col = "red")+scale_x_continuous(breaks=seq(1, 8, 1), labels = c("2017-04-01","2017-04-02","2017-04-03","2017-04-04","2017-04-05","2017-04-06","2017-04-07","2017-04-08"))+xlab(label = "Date")+ylab(label = "Speed")
#x.hour = x.hour[ruc_traffic$Hour%%1==0]
#x.hour = ts(x.hour[-1464], frequency = 24)
df.first.month = data.frame(idx = c(1:(length(x.hour)/2)),x= x.hour[1:(length(x.hour)/2)])
g = ggplot(df.first.month)+geom_line(aes(idx, x), col="black")+
  scale_x_continuous(breaks=c(0:30)*24, labels=c(0:30))+ylim(c(19,55))


for(i in 0:4){
  g=g+annotate("rect", xmin = i*7*24, xmax = (i*7+1)*24, ymin = 19, ymax = 55,
               alpha = .2)
}
g
g+annotate("rect", xmin = 3, xmax = 4.2, ymin = 12, ymax = 21,
           alpha = .2)
autoplot(acf(x.hour, plot = FALSE, lag.max=24*7*4), col="red", xlab=c(1:(24*7*4)),xLab="Date") + ylim(c(0.5, 1.0))


ggPacf(ts(res2, frequency = 24), lag.max=24*7*2, col="#444444")+scale_x_continuous(breaks=c(0:(7*2))*24, labels=c(0:14))
ggAcf(ts(res2, frequency = 24), lag.max=24*7*2, col="#444444")+scale_x_continuous(breaks=c(0:(7*2))*24, labels=c(0:14))
ggPacf(ts(res.ds.model, frequency = 24), lag.max=24*7*2, col="#444444")+scale_x_continuous(breaks=c(0:(7*2))*24, labels=c(0:14))
ggAcf(ts(res.ds.model, frequency = 24), lag.max=24*7*2, col="#444444")+scale_x_continuous(breaks=c(0:(7*2))*24, labels=c(0:14))
