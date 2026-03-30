import pandas as pd
import numpy as np
import sqlite3
from datetime import datetime, timedelta
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import time

source_url = 'https://gasprices.aaa.com/state-gas-price-averages/'
attr = ['data_date', 'state', 'regular_usd', 'mid_grade_usd', 'premium_usd', 'diesel_usd']
csv_file = './usa_gas_prices.csv'
log_file = './usa_gas_prices_etl_log.txt'
database_name = './usa_gas_prices.db'
table_name = 'daily_gas_prices'
conn = sqlite3.connect(database_name)

#################### Extraction Function ####################
def extract():
    options = webdriver.ChromeOptions()
    # Remove the headless line entirely - run as a real visible browser
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)
    
    driver = webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=options
    )
    
    # Tell the browser to hide that it's being controlled by automation
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    
    driver.get(source_url)
    time.sleep(10)  # Give Cloudflare more time to verify
    
    data = BeautifulSoup(driver.page_source, 'html.parser')
    driver.quit()

    data_date = data.find('div', class_='map-badges').find('div', class_='average-price').find('span').find('br').next_sibling.strip()
    table = data.find_all('tbody')
    rows = table[0].find_all('tr')
    df = pd.DataFrame(columns=attr)

    for row in rows:
        cols = row.find_all('td')
        if cols != 0:
            dic = {
                'data_date': datetime.strptime(data_date,'%m/%d/%y').date(),
                'state': cols[0].a.text.strip(),
                'regular_usd': cols[1].text.strip(),
                'mid_grade_usd': cols[2].text.strip(),
                'premium_usd': cols[3].text.strip(),
                'diesel_usd': cols[4].text.strip()
            }
            df1 = pd.DataFrame([dic])
            df = pd.concat([df, df1], ignore_index=True)

    return df

#################### Transformation Functions ####################
def t_cleanPrices(df):
    price_cols = ['regular_usd', 'mid_grade_usd', 'premium_usd', 'diesel_usd']
    for col in price_cols:
        df[col] = df[col].str.replace('$', '').astype(float)
    return df

def t_todays_price(df):
    today = datetime.today().date()

    if df['data_date'].iloc[0] == today:
        return df
    else:
        print("Data is NOT from today, re-extracting...")
        new_extraction= extract()
        new_extraction_date = new_extraction['data_date'].iloc[0]
        if new_extraction_date == today:
            return new_extraction
        else:
            print(f"Sorry, there is no data from today available, latest data is from {new_extraction_date}")
            return new_extraction

def t_priceChange1d(table_name, conn):
    today = datetime.today().date()
    yesterday = today - timedelta(days=1)
    
    query_stmnt = f"""
        SELECT t.data_date, t.state,
               t.regular_usd - y.regular_usd AS regular_usd,
               t.mid_grade_usd - y.mid_grade_usd AS mid_grade_usd,
               t.premium_usd - y.premium_usd AS premium_usd,
               t.diesel_usd - y.diesel_usd AS diesel_usd
        FROM {table_name} t
        JOIN {table_name} y ON t.state = y.state
        WHERE t.data_date = '{today}'
          AND y.data_date = '{yesterday}'
    """
    
    df = pd.read_sql(query_stmnt, conn)
    return df

def t_priceChange7d(table_name, conn):
    today = datetime.today().date()
    week_ago = today - timedelta(days=7)
    
    query_stmnt = f"""
        SELECT t.data_date, t.state,
               t.regular_usd - w.regular_usd AS regular_usd,
               t.mid_grade_usd - w.mid_grade_usd AS mid_grade_usd,
               t.premium_usd - w.premium_usd AS premium_usd,
               t.diesel_usd - w.diesel_usd AS diesel_usd
        FROM {table_name} t
        JOIN {table_name} w ON t.state = w.state
        WHERE t.data_date = '{today}'
          AND w.data_date = '{week_ago}'
    """   
    df = pd.read_sql(query_stmnt, conn)
    return df

def t_ranked(df):
    rank = df.sort_values('regular_usd', ascending=False).reset_index(drop=True)
    rank.index += 1
    return rank



#################### Load Functions ####################

def load_csv(df):
    df.to_csv(csv_file, mode='a', header=False, index=False)
    

def load_sql(df, table_name, conn):
    df.to_sql(table_name, conn, if_exists='append', index = False)

#################### Loag Function ####################

def log(message):
    '''
    This function logs the timestamp and message to the log file.
    '''
    stamp_format = '%Y-%m-%d %H:%M:%S'
    now = datetime.now()
    timestamp = now.strftime(stamp_format)

    with open (log_file, 'a') as f:
        f.write(f"{timestamp}, {message}\n")


#################### Excecution ####################

try:
    '''
    log('ETL Process Started')
    log('Extraction Process Started')
    df = extract()
    log('Extraction Process Ended')
    log('Transformation Process Started')
    log('Cleaning data')
    df = t_cleanPrices(df)
    log('Transformation Process Ended')
    log('Loading Process Started')
    log('Loading CSV File')
    load_csv(df)
    log('Loading to Database')
    load_sql(df, table_name, conn)
    log('Loading Process Ended')
    log('ETL Process Completed Successfully')
    '''

except Exception as e:
    print(f"Something went wrong, Error: {e}")
finally:
    conn.close()
