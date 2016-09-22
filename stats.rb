#
#  Get Flickr photo stats for analysis
#        jssmk @ Helsinki Hacklab
#
# Start with editing your locals.rb file, use locals_default.rb as a template
require_relative 'locals' 
require 'flickraw' 
require 'open-uri' 
require 'date'

W_file = File.open(CSV_path, 'w')
FlickRaw.api_key = MY_api_key
FlickRaw.shared_secret = MY_shared_secret
if(MY_proxy != "")
  FlickRaw.proxy = MY_proxy
end




### use when you have your token
flickr.access_token = MY_access_token
flickr.access_secret = MY_access_secret





begin
  login = flickr.test.login
rescue  TypeError, NameError => e
  print 'error login'
end
print "login ok\n"

MY_user_profile = flickr.urls.lookupUser api_key: MY_api_key, url: MY_user_name_url

W_file.write("date_taken;weekday;hours;freq\n")


now = DateTime.now
aika_stop = DateTime.new(now.year, now.month, now.day, 3, 0, 0)
aika_start = DateTime.new(2015,02,01,03,00,00)

def datetime_sequence(start, stop, step_h)
  dates = [start]
  h = start.hour
  d = 0
  while dates.last < stop
    h = h + step_h
    d = (h / 24).floor
    new_date = DateTime.new(start.year, start.month, start.day, h % 24, 0, 0) + d
    dates << new_date
  end
  return dates
end



aika_start = aika_stop - 56 # 8 weeks
print "start "
print aika_start
print "     stop "
print aika_stop
print "\n"

date_seq = datetime_sequence(aika_start, aika_stop, 6)
prev_d = date_seq[1]

unixtime_seq = date_seq.collect {|d| d.strftime("%s")}
lkm_lista = flickr.photos.getCounts api_key: MY_api_key, taken_dates: unixtime_seq.join(',')


for x in 0..(date_seq.length-2)
  print date_seq[x]
  print "  "
  print lkm_lista.photocount[x].count
  print "\n"
  
W_file.write(date_seq[x].to_date.to_s+";"+date_seq[x].strftime("%A;")+date_seq[x].hour.to_s+";"+lkm_lista.photocount[x].count.to_s+"\n")
end
