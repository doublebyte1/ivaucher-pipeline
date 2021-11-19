#!/usr/bin/env python
# coding: utf-8

# In[1]:


#!pip install pandas
import pandas as pd 
import numpy as np
import sys

name = str(sys.argv[1])

df = pd.read_csv("Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_" + name + ".csv", sep='@', 
                 names=["Distrito", "Concelho", "Marca", "Designacao", "Morada", "Cod_Postal"]) 





df.fillna('', inplace=True)


# In[5]:


df.head()


# In[6]:


#! pip install opencage
from opencage.geocoder import OpenCageGeocode


# In[7]:


import config
key=config.key


# In[8]:


geocoder = OpenCageGeocode(key)


# In[9]:


df['Full_Address']= df.Morada + ", " + df['Cod_Postal'] + " " + df.Concelho


# In[10]:


df.head()


# In[11]:


addresses = df['Full_Address'].values.tolist()
latitudes = []
longitudes = []
for address in addresses: 
    result = geocoder.geocode(address, no_annotations="1", countrycode='pt')  
    print(address)
    
    if result and len(result):  
        #print("ok")
        longitude = result[0]["geometry"]["lng"] 
        latitude = result[0]["geometry"]["lat"] 
    else:
        #print("no")
        longitude = np.nan
        latitude = np.nan  
    
    latitudes.append(latitude) 
    longitudes.append(longitude)
    
print("completed")


# In[12]:


df["latitudes"] = latitudes
df["longitudes"] = longitudes
df.dropna(subset=["latitudes"], inplace=True)
df.dropna(subset=["longitudes"], inplace=True)
#df.head()


# In[13]:


len(df)


# In[14]:


import folium
import folium.plugins as plugins

folium_map= folium.Map(location=[0,0],zoom_start=2,tiles='Stamen Toner', height=1000)
plugins.FastMarkerCluster(df[['latitudes', 'longitudes']].values.tolist()).add_to(folium_map)    


# In[15]:


folium_map


# In[16]:


df.to_csv('out.csv',index=False)


# In[ ]:




