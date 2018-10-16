# A program that reads in a list of Street View API URLs and downloads the image produced

import pandas as pd
import numpy as np
import urllib.request
import os

def make_images(file_name):
    df  = pd.read_csv(file_name)
    url = df["API_URL"]
    url = url.tolist()
    os.mkdir("Street_View")
    file_path = os.path.join(os.getcwd(), 'Street_View')
    
    for i in range(len(url)):
        url_string = url[i]
        image_name = "image" + str(i + 1)
        urllib.request.urlretrieve(url_string, file_path + "/" + image_name + ".jpg")
    
   
# Test with the file named "Links.csv"
# Downloadable here:  https://drive.google.com/open?id=14br3ADA-h60eDFQtgIVEg17f1sEgqGD5

make_images("Links.csv")

