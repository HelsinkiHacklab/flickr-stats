require("ggplot2")
require("data.table")
require("Cairo")
Cairo()


data = fread("example_output.csv")
for (x in 0:(nrow(data)-1)) {data$hours_end[x+1] = data$hours[(x+1)%%nrow(data)+1] }

data <- data[order(factor(weekday, levels = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")),hours),]

data$timeline <- paste0(data$hours, " - ",  data$hours_end, " ", data$weekday)


freq_table <- data[, list(mean(freq)), by="timeline"]
colnames(freq_table) <- c("timeline", "mean")

freq_table$timeline <- factor(freq_table$timeline, levels=freq_table$timeline) # preserve order

print(freq_table)

area_plot <- ggplot(freq_table, aes(x=timeline, y=mean, group=1))+geom_area()+geom_vline(xintercept=c(4.5, 8.5, 12.5, 16.5, 20.5, 24.5))#+coord_polar()



ggsave(file="weekly.png", type="cairo-png")


