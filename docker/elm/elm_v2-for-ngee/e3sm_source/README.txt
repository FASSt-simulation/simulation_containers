# ELM source
https://github.com/fmyuan/E3SM.git

Branch: elm_v2-for-ngee

git clone -b elm_v2-for-ngee --single-branch https://github.com/fmyuan/E3SM.git
git submodule update -f --init --recursive

To download an already prepared version
wget https://github.com/FASSt-simulation/simulation_containers/blob/main/docker/elm/elm_v2-for-ngee/e3sm_source/e3sm_v2.0.0_ngee.tar.gz?raw=true -O e3sm_v2.0.0_ngee.tar.gz
