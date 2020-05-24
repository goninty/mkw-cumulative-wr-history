import requests
from bs4 import BeautifulSoup
import re
import json
import time as t


main_url = 'https://mkwrs.com/'
game = 'mkwii/'

res = requests.get(main_url + game)

if res.status_code == 200:
    soup = BeautifulSoup(res.content, 'html.parser')

    # grab links from all tables
    wr_table = soup.find("table", class_="wr")
    wr_tags = wr_table.find_all("a", href=re.compile("display.php"))
    
    track_urls = []
    for tag in wr_tags:
            track_urls.append(tag.get("href"))

    # dict to hold all tracks data
    all_dict = {}
    
    # go through all tracks
    for track_url in track_urls:
        track_name = track_url.replace("display.php?track=", "").replace("+", " ").replace("&nsc=1", " (Non-SC)").replace("%27", "'")
        print("Scraping " + track_name + " data...")
        
        res = requests.get(main_url + game + track_url)
        soup = BeautifulSoup(res.content, 'html.parser')

        # get the history table for this track
        history = soup.find("h2", string="History").next_sibling.next_sibling
        
        # create dictionary to hold indiv track data
        track_dict = {}
        
        # rows
        trs = history.find_all("tr")[1::]
        for tr in trs:
            # columns
            tds = tr.find_all("td", limit=2)

            # making sure to not care about "Shortcut/Glitch Introduced" rows
            if len(tds) > 1:
                date = tds[0].text
                time  = tds[1].text

                # multiple times may be set on the same day
                if date in track_dict.keys():
                    track_dict[date].append(time)
                else:
                    track_dict[date] = [time]
        
        all_dict[track_name] = track_dict
        t.sleep(2) # just so i dont get blacklisted lol

    # write json to file
    f = open("history.txt", "w")
    f.write(json.dumps(all_dict))
    f.close()

else:
    print('HTTP response ' + str(res.status_code))