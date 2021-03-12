# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
import datetime

data = pd.read_csv('owid-covid-data.csv')
elcano = pd.read_excel('Elcano_Royal_Institute-Global_Presence_Requested_Data.xlsx')
wdi = pd.read_excel('wdi.xlsx')
gov_eff = pd.read_excel('gov_eff.xlsx')
soft_30 = pd.read_excel('soft_power_30.xlsx')
G_20 = pd.read_excel('G20_members.xlsx')
gov_response = pd.read_excel('gov+response.xlsx')
exports = pd.read_excel('exports.xlsx')
rule_of_law = pd.read_excel('rule_of_law.xlsx')
nato = pd.read_excel('nato.xlsx')
vaccines = pd.read_excel('definition.xlsx', sheet_name='vaccines')
pop65 = pd.read_excel('pop65.xlsx')

data['date'] = pd.to_datetime(data['date'], format="%Y/%m/%d")

drop_list = ['nan','OWID_KOS','OWID_WRL','HKG']
data.drop(data[data['iso_code'].isin(drop_list)].index, inplace=True)

data = data[data['location']!='International']

first_dates = {}

for i in pd.unique(data['iso_code']):
  if data[data['iso_code']==i].total_vaccinations.first_valid_index() == None:
    first_dates[i] = 'NaN'
  else:
    first_dates[i] = data.loc[data[data['iso_code']==i].total_vaccinations.first_valid_index()].date

last_dates = {}

for i in pd.unique(data['iso_code']):
  if data[data['iso_code']==i].total_vaccinations.last_valid_index() == None:
    last_dates[i] = 'NaN'
  else:
    last_dates[i] = data.loc[data[data['iso_code']==i].total_vaccinations.last_valid_index()].date

first_dates_ = pd.DataFrame(first_dates.items()).rename(columns={0: "iso_code", 1: "first_date"})
last_dates_ = pd.DataFrame(last_dates.items()).rename(columns={0: "iso_code", 1: "last_date"})

first_dates_['started_vi'] = (first_dates_['first_date'] != 'NaN').astype(int)

last_dates_['ended_vi'] = (last_dates_['last_date'] != 'NaN').astype(int)

date_estimation = pd.merge(first_dates_,
                           last_dates_,
                           on='iso_code',
                           how='inner')
dates = date_estimation[date_estimation['started_vi']==1]

dates['days'] = dates.last_date - dates.first_date
dates = dates[['iso_code','days']]
dates.days = dates.days.astype('timedelta64[D]')

end_indices = []

for i in pd.unique(data['iso_code']):

  if last_dates_[last_dates_['iso_code']==i].last_date.values[0] != 'NaN':
    end_indices.append(data[(data['iso_code']==i) & 
         (data['date']==list(pd.to_datetime(last_dates_[last_dates_['iso_code']==i].last_date))[0].strftime('%Y/%m/%d'))].index[0])
  else:
    end_indices.append(data[(data['iso_code']==i) & 
         (data['date']=='2021-01-30')].index[0])

data_ = data[data.index.isin(end_indices)]

variables = ['iso_code','location','total_cases_per_million','total_deaths_per_million','total_vaccinations','total_vaccinations_per_hundred','population', 'population_density','aged_65_older',
         'gdp_per_capita','life_expectancy', 'human_development_index']
data_ = data_[variables]

data_1 = pd.merge(data_,
                  dates,
                  on='iso_code',
                  how='left')

data_2 = pd.merge(data_1,
         wdi,
         on='iso_code',
         how='left')

data_2.drop(columns=['country'], inplace=True)

data_3 = pd.merge(data_2,
                  gov_eff,
                  on='iso_code',
                  how='left')

data_3.drop(columns=['country'], inplace=True)

data_4 = pd.merge(data_3,
                  elcano,
                  left_on='location',
                  right_on='country',
                  how='left')

data_4.rename(columns={2019:'elcano_index'}, inplace=True)

data_4.drop(columns=['country'], inplace=True)

data_5 = pd.merge(data_4,
                  first_dates_,
                  on='iso_code',
                  how='left')

data_6 = pd.merge(data_5,
         soft_30,
         on='iso_code',
         how='left')

data_6.drop(columns=['value'], inplace=True)
data_6.rename(columns={'country':'soft_30'}, inplace=True)

data_6['soft_30'] = data_6['soft_30'].notnull().astype('int')

data_7 = pd.merge(data_6,
                  G_20,
                  on='iso_code',
                  how='left')

data_7.rename(columns={'country':'G_20_member'}, inplace=True)

data_7['G_20_member'] = data_7['G_20_member'].notnull().astype('int')

data_7.drop(columns=['first_date'], inplace=True)

data_8 = pd.merge(data_7,
                  exports,
                  on='iso_code',
                  how='left')

data_9 = pd.merge(data_8,
                  rule_of_law,
                  on='iso_code',
                  how='left')

data_9 = pd.merge(data_9,
                  pop65,
                  left_on='iso_code',
                  right_on='country_code',
                  how='left')

data_10 = data_9.replace('..', np.nan)

data_11 = data_10.replace('...', np.nan)

data_12 = pd.merge(data_11,
                   gov_response,
                   on='iso_code',
                   how='left')

clean1 = vaccines[['iso_code','vaccines']]

clean1[['type1','type2','type3','type4','type5']] = vaccines['vaccines'].str.split(",", expand=True)

clean1['helper'] = 'Oxford/AstraZeneca'
clean1['helper1'] = 'Pfizer/BioNTech'
clean1['helper2'] = 'Moderna'
clean1['helper3'] = 'Sputnik V'
clean1['helper4'] = 'Sinopharm/Wuhan'
clean1['helper5'] = 'Sinopharm/Beijing'
clean1['helper6'] = 'Sinovac'

clean1["Oxford/AstraZeneca"] = clean1.drop("helper", 1).isin(clean1["helper"]).any(1)
clean1["Pfizer/BioNTech"] = clean1.drop("helper1", 1).isin(clean1["helper1"]).any(1)
clean1["Moderna"] = clean1.drop("helper2", 1).isin(clean1["helper2"]).any(1)
clean1["Sputnik V"] = clean1.drop("helper3", 1).isin(clean1["helper3"]).any(1)
clean1["Sinopharm/Wuhan"] = clean1.drop("helper4", 1).isin(clean1["helper4"]).any(1)
clean1["Sinopharm/Beijing"] = clean1.drop("helper5", 1).isin(clean1["helper5"]).any(1)
clean1["Sinovac"] = clean1.drop("helper6", 1).isin(clean1["helper6"]).any(1)

type_helper = clean1[['iso_code','Oxford/AstraZeneca','Pfizer/BioNTech', 'Moderna',\
                      'Sputnik V', 'Sinopharm/Wuhan', 'Sinopharm/Beijing', 'Sinovac']]

data_13 = pd.merge(data_12,
                   type_helper,
                   on='iso_code',
                   how='left')

data_13 = data_13.applymap(lambda x: int(x) if isinstance(x, bool) else x)

data_13.to_excel('estimation_data_wtypev.xlsx')

corr_data = pd.DataFrame()

corr_data['lcases'] = np.log(data_12['total_cases_per_million'])
corr_data['ldeaths'] = np.log(data_12['total_deaths_per_million'])
corr_data['lvaccinations'] = np.log(data_12['total_vaccinations_per_hundred'])
corr_data['lpop'] = np.log(data_12['population'])
corr_data['lpop65'] = np.log(data_12['aged_65_older'])
corr_data['lgdp'] = np.log((data_12['gdp_per_capita']) * data_12['population'])
corr_data['days'] = data_12['days']
corr_data['lhealth'] = np.log(data_12['Current health expenditure (% of GDP)'])
corr_data['lgdp_ppp_pc'] = np.log(data_12['GDP per capita, PPP (current international $)'])
corr_data['lmilitary'] = np.log(data_12['Military expenditure (% of GDP)'])
corr_data['lphysicians'] = np.log(data_12['Physicians (per 1,000 people)'])
corr_data['ltrade'] = np.log(data_12['Trade (% of GDP)'])
corr_data['gov_eff'] = data_12['gov_eff']
corr_data['elcano'] = data_12['elcano_index']
corr_data['lgov_response'] = np.log(data_12['gov_response'])
corr_data['lexports'] = np.log(data_12['exports'])

# Commented out IPython magic to ensure Python compatibility.
import seaborn as sns
import matplotlib.pyplot as plt

# %matplotlib inline

f, ax = plt.subplots(figsize=(25, 15))

corr = corr_data.corr()
ax = sns.heatmap(
    corr, 
    vmin=-1, vmax=1, center=0,
    cmap=sns.diverging_palette(20, 220, n=200),
    square=True,
    annot=True,
    annot_kws={"fontsize":12}  
)
ax.set_xticklabels(
    ax.get_xticklabels(),
    rotation=45,
    horizontalalignment='right'
);

#sns.set(font_scale=2)

data_13 = pd.merge(data_12,
         nato,
         on='iso_code',
         how='left')

data_13.rename(columns={'country':'nato'}, inplace=True)
data_13['nato'] = data_13['nato'].notnull().astype('int')

data_13.to_excel('estimation_data.xlsx')

"""## summary"""

summary_data = pd.read_excel('estimation_data_wtypev.xlsx')

summary_data['gdp'] = np.log(summary_data['gdp_per_capita'] * summary_data['population'])

summary_data['cases'] = np.log(summary_data['cases'])
summary_data['gov_respose'] = np.log(summary_data['gov_response'])
summary_data['exports'] = np.log(summary_data['exports'])
summary_data['health_exp'] = np.log(summary_data['health_exp'])
summary_data['military'] = np.log(summary_data['military'])
summary_data['pop65'] = np.log(summary_data['pop65'])
summary_data['vi_per_hundred'] = np.log(summary_data['vi_per_hundred'])
summary_data['gdp_ppp_pc'] = np.log(summary_data['gdp_ppp_pc'])

pd.DataFrame(summary_data.groupby('started_vi').agg({'cases':[np.mean, np.std],
                                        'gov_response':[np.mean, np.std],
                                        'gdp':[np.mean, np.std],
                                        'exports':[np.mean, np.std],
                                        'health_exp':[np.mean, np.std],
                                        'military':[np.mean, np.std], 
                                        'gov_eff':[np.mean, np.std],
                                        'vi_per_hundred':[np.mean, np.std],
                                        'pop65':[np.mean, np.std],
                                        'days':[np.mean, np.std],
                                        'gdp_ppp_pc':[np.mean, np.std]}).T)

