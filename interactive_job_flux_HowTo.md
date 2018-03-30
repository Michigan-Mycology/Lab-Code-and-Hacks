## How to Run an Interactive Job on Flux

**Replace with your particular resource requirements.**

`qsub -I -V -A lsa_flux -q flux -l nodes=1:ppn=1,pmem=8gb,walltime=4:00:00,qos=flux`

*Note that it may take a while to start if you have requested a good amount of resources. I usually try to keep them low.*
