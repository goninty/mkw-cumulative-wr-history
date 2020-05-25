from datetime import date
import pandas as pd
import json

days = [d.strftime('%Y-%m-%d') for d in pd.date_range("2008-04-12", date.today())]
days_dict = {}

for i in range(len(days)):
    days_dict[i] = days[i]

f = open("dates.json", "w")
f.write(json.dumps(days_dict))
f.close()