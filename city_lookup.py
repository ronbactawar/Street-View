import pandas as pd
import numpy as np
import reverse_geocoder as rg

# Accepts a .csv file with "Latitude" and "Longitude" as fields

# Return a DataFrame with and additional "City" field.  Output .csv is "r_geocoded_table.csv"

def r_geocode(file):
    df = pd.read_csv("Master3.csv")
    df['Lat_Long'] = df[['Latitude', 'Longitude']].apply(tuple, axis=1)
    coordinates = df['Lat_Long']
    coordinates = pd.Series.tolist(coordinates)
    results = rg.search(coordinates)
    arr = []
    for i in results:
        name = i['name']
        arr.append(name)   
    df['City'] = arr
    df2 = df[['Latitude', 'Longitude', 'City']]
    df2.to_csv("r_geocoded_table.csv")
    
# Example of usage

# Data available at https://drive.google.com/open?id=1J6ozSQQ45u9go01UFH9604R-lwhAK_AY

r_geocode("Master3.csv")
