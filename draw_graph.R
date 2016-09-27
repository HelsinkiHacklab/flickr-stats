require("ggplot2")
require("data.table")

# Cairo is optional
#require("Cairo")
#Cairo()

dest_dir = "/home/pi/Pictures/Stats/"
csv_path = "/home/pi/Documents/stats/out.csv"

data = fread(csv_path)
for (x in 0:(nrow(data)-1)) {data$hours_end[x+1] = data$hours[(x+1)%%nrow(data)+1] }

weekdays_en <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

data <- data[order(factor(weekday, levels = weekdays_en),hours),]

data$timeline <- paste0(data$hours, " - ",  data$hours_end, " ", data$weekday)


freq_table <- data[, list(median(freq)), by="timeline"]
freq_table <- data[, list(median(freq), quantile(freq, .25), quantile(freq, .75)), by="timeline"]

setnames(freq_table, c("timeline", "median", "p25", "p75"))

freq_table$timeline <- factor(freq_table$timeline, levels=freq_table$timeline) # preserve order

# hardcoded axis limits could be changed in the future

max_y = max(freq_table$p75)

polar_plot <- ggplot(freq_table) + theme_bw() + geom_blank() +
  scale_x_discrete(expand=c(0,0)) +
  labs(x="Median ± 25 %") +
  theme(axis.title.x=element_text(family = "Georgia", color="#303030", face="italic", size=12, hjust=0),
        axis.text.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major = element_line(colour = "#0000FF50"),
        plot.title = element_text(family = "Georgia", color="#000000", size=18)) +
  geom_area(aes(x=timeline, y=p75, group=1), fill="#FF000040") +
  geom_line(aes(x=timeline, y=median, group=1), size=1, color="#FF0000FF") +
  geom_area(aes(x=timeline, y=p25, group=1), fill="#FFFFFFFF") +
  geom_vline(xintercept=c(0, 4, 8, 12, 16, 20, 24)) +
  annotate("text",label = weekdays_en, x = c(2,6,10,14,18,22,26), y=rep(max_y-5,7)) +
  coord_polar() +
  scale_y_sqrt(limits=c(0,max_y)) +
  ggtitle(paste0("Helsinki Hacklab flickr upload activity\n",min(data$date_taken), " — ", max(data$date_taken)))

ggsave(file=paste0(dest_dir, max(data$date_taken),"_stats.png"))
#ggsave(file="weekly_polar.png", type="cairo-png")

