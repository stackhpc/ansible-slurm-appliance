# EESSI Guide

## How to load EESSI
Loading an EESSI environment module:
```[bash]
source /cvmfs/software.eessi.io/versions/2023.06/init/lmod/bash
```
Activating EESSI environment:
```[bash]
source /cvmfs/software.eessi.io/versions/2023.06/init/bash
```

## GPU Support with EESI
To enable GPU support you need a site-specific build that has `cuda` enabled. For guide to do this please refer to `docs/image-build`. This is
because CUDA-drivers are host specific and EESSI can not ship NVIDIA drivers due to licensing + kernel specific constraints. This means that the
host must provide the drivers in a known location (`host_injections`).

### Using GPUs
All CUDA-enabled software in EESSI expects CUDA drivers in a specific `host_injections` subdirectory.<br>
```[bash]
ls -l /cvmfs/software.eessi.io/versions/2023.06/software/linux/x86_64/amd/zen3/software/CUDA/12.1.1/bin/nvcc
```
The output of this should show a symlink to the EESSI `host_injections` dir like so:
```[bash]
lrwxrwxrwx 1 cvmfs cvmfs 109 May  6  2024 /cvmfs/software.eessi.io/versions/2023.06/software/linux/x86_64/amd/zen3/software/CUDA/12.1.1/bin/nvcc
-> /cvmfs/software.eessi.io/host_injections/2023.06/software/linux/x86_64/amd/zen3/software/CUDA/12.1.1/bin/nvcc
```
To expose the Nvidia GPU drivers.
```[bash]
/cvmfs/software.eessi.io/versions/2023.06/scripts/gpu_support/nvidia/link_nvidia_host_libraries.sh
```

### Buidling with GPUs

Checking `nvcc --version` and `which nvcc` to see if `CUDA` compiler is found.<br>
<br>
If `nvcc` not found run:<br>
```[bash]
export PATH=/usr/local/cuda-13.0/bin:$PATH
```
(with your specific cuda version)<br>
`which nvcc` should now show path to compiler.<br>
<br>
Running `which gcc` will give path `.../2023.06/compat...`<br>
Loading EESSI module (It is important to load a `gcc` that is compatible with the host's CUDA version.):<br>
```[bash]
module load GCC/12.3.0
```
Now running `which gcc` will give path `.../2023.06/software...`<br>
<br>
Now you can run `cmake` and `make` to compile `CUDA` using EESSI's `gcc`.<br>

#### Test setup: Compile deviceQuery from CUDA-Samples
To test that your EESSI set up can compile `CUDA`, try compiling deviceQuery from CUDA-Samples with the following steps:<br>
```[bash]
git clone https://github.com/NVIDIA/cuda-samples.git
cd cuda-samples/Samples/1_Utilities/deviceQuery
mkdir -p build
cd build
cmake ..
make
./deviceQuery
```
