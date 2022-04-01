# Dockerized versions of the CTSM, ELM and HLM-FATES models 
<br>


Docker hub: https://hub.docker.com/orgs/fasstsimulation

<br>

### Example ELM single site test run at US-Brw (Utqiagvik AK)

1) Install the Docker engine: https://www.docker.com/get-started

2) Open your host machine terminal

3) Pull down the latest version of the basic ELM Docker container, In your terminal run: <br>
```docker pull fasstsimulation/elm-builds:release-v1.2.0_ngeearctic-latest```

4) Sync the test forcing/input datasets to your host machine. e.g. 

Define your localhost:docker paths. Replace: <br>

/Users/sserbin/Data/single_point_cesm_input_datasets <br>

with a location on your local machine to store the datasets (~1Gb)

```
docker run -t -i --hostname=docker --user $(id -u):$(id -g) -v /Users/sserbin/Data/single_point_cesm_input_datasets:/inputdata \
fasstsimulation/elm-builds:release-v1.2.0_ngeearctic-latest /scripts/download_elm_singlesite_forcing_data.sh
```

5) Run the test case example.

Define your localhost:docker paths. Replace: <br>

/Users/sserbin/Data/single_point_cesm_input_datasets <br>
/Users/sserbin/scratch/elm_fates <br>

Also define your run settings below. Then past the command into your terminal to setup a case

```
docker run -t -i --hostname=docker --user $(id -u):$(id -g) -v /Users/sserbin/Data/single_point_cesm_input_datasets:/inputdata \
-v /Users/sserbin/scratch/elm_fates:/output fasstsimulation/elm-builds:release-v1.2.0_ngeearctic-latest \
/scripts/./1x1pt_US-Brw_test_case_e3sm.sh --case_root=/output \
--site_name=1x1pt_US-Brw --start_year='1985-01-01' --num_years=16 --output_vars=/scripts/output_vars.txt \
--met_start=1985 --met_end=2015 --resolution=CLM_USRDAT --compset=I1850CNPRDCTCBC
```
