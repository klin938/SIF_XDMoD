This project builds a Singularity SIF which runs XDMoD web. The SIF can be run on any node on the cluster with access facilitated by SSH tunneling.

## BUILD  
`sudo singularity build xdmod_srv.sif ./def_xdmod_srv.def`  

overlay image is needed for storing the MySQL database (at least 100GB):  
`dd if=/dev/zero of=overlay.img bs=1M count=100000 && mkfs.ext3 overlay.img`  
`sudo singularity sif add --datatype 4 --partfs 2 --parttype 4 --partarch 2 --groupid 1 xdmod_srv.sif overlay.img`

## RUN & STOP  
Start the Singularity instance:  
`sudo singularity instance start -B /YOUE_HOME/SIF_XDMoD/init_load_data:/init_load_data --writable xdmod_srv.sif xdmod_web`  
`sudo singularity run instance://xdmod_web`   

If the service needs to be shutdown, it must be done gracefully:    
`sudo singularity instance stop xdmod_web`   

## INITIAL DATA LOAD  
The init_load_data directory contains SGE accounting data in tar.gz format for bunk loading. The directory and its data are not provided by this repository, and they need to be prepared manually. The most recent build, we use the following files:  

```
TASK [init_loader : Load data to XDMoD] *********************************************************************************************************************************************************
changed: [localhost] => (item=/init_load_data/CLUSTER60_accounting_2017_FIXED.tar.gz)
changed: [localhost] => (item=/init_load_data/CLUSTER62_accounting_ALL.tar.gz)
changed: [localhost] => (item=/init_load_data/CLUSTER60_accounting_2012-2014.tar.gz)
changed: [localhost] => (item=/init_load_data/CLUSTER60_accounting_2015.tar.gz)
changed: [localhost] => (item=/init_load_data/CLUSTER60_accounting_2016.tar.gz)
changed: [localhost] => (item=/init_load_data/CLUSTER62_accounting_ALL.tar.gz)
changed: [localhost] => (item=/init_load_data/CLUSTER70_accounting_init_load.tar.gz)
changed: [localhost] => (item=/init_load_data/Grandline70_accounting_init_load.tar.gz)
changed: [localhost] => (item=/init_load_data/Wolfpack70_accounting_init_load.tar.gz)
```

This process is implemented in Ansible:  
`cd /SIF_XDMoD`  
`ansible-playbook init_loader.yml`  

Loading data to XDMoD is slow, it will take one or a few days depends the amount of data. After it's done, it brings the XDMoD data up to the commit `WHATEVER_COMMIT_HASH_IS` in the sge_accounting repository. 

## DATA REPOSITORY  
Clone the sge_accounting repository to the container so it can be used for automated data upload:  
```
cd /
eval $(ssh-agent -s)
ssh-add /xdmod_ansible/roles/common/files/dice_sif_rsa  
git clone git@github.com:klin938/sge_accounting.git 
```

Make sure it is cloned by SSH as required by passwordless git pull by cron (See below).

A special repo commit marker file needs to be created directly under the repository. The commit hash number is choosen according to which portion of the SGE data has been loaded in the init_load_data phase.  
`cd /sge_accounting`  
`echo "WHATEVER_COMMIT_HASH_IS" > FROM_COMMIT_HASH`  

This only needs to be done once on the newly built container, it will be updated by the cron data load process automatically.

## CRON DATA LOAD  
Once the initial data load is done, all future data will be loaded by cron fetching new data from the repository:  
`/etc/cron.daily/xdmod.cron.daily`  

crond is not activated by default, this is intentional. It should be activated manually after initial data load completed:  
`crond -s`  

IMPORTANT: make sure FROM_COMMIT_HASH has been created for the first run of the cron script.

