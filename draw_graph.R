#!/usr/bin/Rscript
"Usage: draw_graph.R --csv_file <csv_file_path> --dest_dir <dest_dir_path>
Options:
draw_graph.R --csv_file
draw_graph.R --dest_dir" -> doc


require("ggplot2")
require("data.table")


require("docopt")
opts <- docopt(doc)


# Cairo is optional
#require("Cairo")
#Cairo()

csv_path = opts[["csv_file_path"]]
dest_dir = opts[["dest_dir_path"]]

if(!file.exists(csv_path)) {
  print("no such csv file!")
  quit()
}
if(!dir.exists(dest_dir)) {
  print("no such output path!")
  quit()
}

data = fread(csv_path)
for (x in 0:(nrow(data)-1)) {data$hours_end[x+1] = data$hours[(x+1)%%nrow(data)+1] }

weekdays_en <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

data <- data[order(factor(weekday, levels = weekdays_en),hours),]

data$timeline <- paste0(data$hours, " - ",  data$hours_end, " ", data$weekday)


freq_table <- data[, list(median(freq), quantile(freq, .25), quantile(freq, .75)), by="timeline"]

setnames(freq_table, c("timeline", "median", "p25", "p75"))

freq_table$timeline <- factor(freq_table$timeline, levels=freq_table$timeline) # preserve order


max_y <- max(freq_table$p75)

polar_plot <- ggplot(freq_table) + theme_bw() + geom_blank() +
  coord_polar(start=pi/28, direction=1) +
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
  annotate("text",label = weekdays_en, x = c(2,6,10,14,18,22,26), y=rep(max_y*.9,7)) +
  scale_y_sqrt(limits=c(0,max_y)) +
  ggtitle(paste0("Helsinki Hacklab flickr upload activity\n",min(data$date_taken), " — ", max(data$date_taken)))

image_filename <- paste0(dest_dir, min(data$date_taken),"_",max(data$date_taken),"_stats.png")

ggsave(file=image_filename)
#ggsave(file=image_filename, type="cairo-png")

