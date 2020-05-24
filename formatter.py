import pandas as pd
from datetime import datetime, date, timedelta
import json

days = [d.strftime('%Y-%m-%d') for d in pd.date_range("2008-04-12", date.today())]
days_dict = dict.fromkeys([d.strftime('%Y-%m-%d') for d in pd.date_range("2008-04-12", date.today())])

f = open("history.txt", "r")
tracks = json.loads(f.read())
f.close()

def get_wrs_for_day(day_idx):
    wrs_for_day = []
    
    for t in tracks:
        for i in range(day_idx, -1, -1):
            if days[i] in tracks[t]:
                # this if accounts for the case when
                # there are multiple wrs in one day
                # and none on some subsequent days
                # to prevent subsequent days culum time from being
                # the entire list of cumuls from prev day
                if i < day_idx:
                    days_times = [tracks[t][days[i]][::-1][0]]
                else:
                    days_times = tracks[t][days[i]]
                
                days_tds = []
                for time in days_times:
                    dt = datetime.strptime(time, '%M\'%S"%f')
                    days_tds.append( timedelta(minutes=dt.minute, seconds=dt.second, microseconds=dt.microsecond) )
                wrs_for_day.append(days_tds)
                break 
    
    return wrs_for_day

# day parameter is the timedeltas of the wrs for that day (list of lists)
def cumuls_for_day(day) :
    day_cumuls = []
    cumul = timedelta(minutes=0, seconds=0, microseconds=0)
    prev_times = [] # previous wrs on same day for specific track

    # calculating first cumulative time for that day
    for latest in day:
        cumul += latest[0]
        prev_times.append(latest[0])
        latest.pop(0)
    day_cumuls.append(str(cumul))

    # this is for the subsequent cumulative times
    while any(day):
        # need to enumerate to keep track of where we are in prev_times list
        # so can replace the old previous time with a new one when we calc new cumul
        for i, (latest, prev) in enumerate(zip(day, prev_times)):
            # if there are still more wrs that have been set
            # need to take some off cumulative time to give new cumul
            if latest != []:
                cumul -= (prev - latest[0])
                prev_times[i] = latest[0]
                latest.pop(0)
        day_cumuls.append(str(cumul))
    return day_cumuls

for i in range(len(days)):
    days_dict[days[i]] = cumuls_for_day(get_wrs_for_day(i))

# write json to file
f = open("cumuls.txt", "w")
f.write(json.dumps(days_dict))
f.close()