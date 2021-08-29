# covid-vaccinations-paper

Here we include the data and code used in the paper "The Impact of State Capacity on the Cross-Country Variations in COVID-19 Vaccination Rates". 
The paper is available at https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3801205

The two-stage Heckman Selection model was estimated using Stata, while the preprocessing phase was conducted in Python.

The replication data is consisted of:

*** estimation_data_0401.xlsx -- this file contains already preprocessed data and can be directly used to reproduce the main results with model_estimation.do

*** estimation_data_0401_euw.xlsx -- this file contains already preprocessed data and can be directly used to reproduce the robustness results for EU-weighted model with model_estimation.do

*** estimation_data_0501.xlsx -- this file contains already preprocessed data and can be directly used to reproduce the robustness results for over_20% vaccinated population with model_estimation.do

*** Raw data folder contains files used in the preprocessing phase.
