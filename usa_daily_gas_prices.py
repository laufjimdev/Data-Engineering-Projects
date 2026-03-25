import requests
import pandas as pd
import numpy as np
import sqlite3
from datetime import datetime
from bs4 import BeautifulSoup

source_url = 'https://gasprices.aaa.com/state-gas-price-averages/'
attr = ['State', 'Regular ($USD)', 'Mid-Grade ($USD)', 'Premiun ($USD)', 'Diesel ($USD)']


def extract():
    '''
    This function extracts the gas prices for every USA state in $USD for Regular, Mid-Grade, Premium and Diesel from the AAA Fuel Prices Website: https://gasprices.aaa.com/state-gas-price-averages
    '''
    headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    r = requests.get(source_url, headers=headers)
    data = BeautifulSoup(r.text, 'html.parser')
    table = data.find_all('tbody')
    rows = table[0].find_all('tr')
    df = pd.DataFrame(columns=attr)

    for row in rows:
        cols = row.find_all('td')
        if cols != 0:
            dic = {'State': cols[0].a.text.strip(), 'Regular ($USD)': cols[1].text.strip(), 'Mid-Grade ($USD)': cols[2].text.strip(), 'Premiun ($USD)': cols[3].text.strip(), 'Diesel ($USD)': cols[4].text.strip()}
            df1 = pd.DataFrame([dic])
            df = pd.concat([df, df1], ignore_index=True)
    
    return df

extract()