ori_data <- read.csv('data/output.csv')

#平滑处理
x.speed.15 <- ori_data$speed
x.step <- ori_data$step
x.hour <- filter(x.speed.15, rep(1/4,4))
x.hour <- x.hour[x.step%%4==1]
x.hour <- ts(x.hour[-1464], frequency = 24)

save(x.hour, file="data/traffic_speed.Rdata")
