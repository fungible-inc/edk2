# FunDocker

This repository contains Dockerfiles and the process to build and push images used for building and testing FunOS to private docker registry docker.fungible.com

## Structure

It is a flat directory containing various Dockerfiles, a makefile called doc.mk, main build script called build.sh and helper script called fun_docker.sh

Docker images are pushed to private registry at docker.fungible.com. Top-level directory contains ‘run_<IMG>’ images that are suitable for run time tasks only and ‘bld_<IMG>’ images suitable for both run time and build time. Some steps in the build and test processes need a user account inside the containers to be present and some even require sudo privilege for such user account.  These are referred to as user wrapper images which are extensions of corresponding ‘run’ or ‘bld’ image with user account added inside the container. Such images for user Jenkins are pushed pushed under a directory below top level registry and named after the user id. (Currently only jenkins user can push such wrapper images). The image dependencies are defined in the doc.mk makefile and build.sh is used to build the images.

## Registry contents

- run_funos        
- bld_funos
- jenkins/dind
- jenkins/run_funos
- jenkins/bld_funos

## Build Process

Jenkins user (manually) builds and pushes the images to registry whenever there is commit to master branch. Any mistake in those Dockerfile can potentially break all build and test operations. Merge to master needs to be tested offline and reviewed via PR before the merge. 

### Developer wrapper images

Any user can build wrapper images for their use on their laptops or development machines. To do so, just clone this repo and run ‘./build.sh $USER/bld_funos’ in it. Docker image ‘bld_funos’ being a superset one can build and run test by creating a wrapper image $USER/bld_funos for it. You can add to Dockerfile.bld_funos.usr on your branch if you need to further personalize your wrapper image before running build.sh $USER/bld_funos.

## Usage

FunOS related builds based on FunJenkins pipeline use these docker images via docker pipeline plugin. Any user can make use of these docker images to build and run tests inside a container on their development machines. For example:

```
$> docker pull docker.fungible.com/bld_funos:latest
$> docker run [options] docker.fungible.com/bld_funos [build commands]
```
#### Note: 
You may need to update certificate store on your machine to pull images via SSL from private registry. To do so:

```
sudo cp ~admin/SSL-Wildcard_Cert/fungible.com.crt /usr/local/share/ca-certificates/
```
or use your ldap credentials to scp from an VNC server
```
sudo scp yourself@vncserver:/project/users/doc/sw/tools/fungible.com-certs/fungible.com.crt /usr/local/share/ca-certificates
```
or from dochub
```
curl http://dochub.fungible.local/doc/sw/tools/fungible.com-certs/fungible.com.crt | sudo tee /usr/local/share/ca-certificates/fungible.com.crt
```
and then
```
sudo update-ca-certificates -v -f 
sudo /sbin/shutdown -r now
```
#### Note: Docker installation instruction:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 
sudo apt-get update 
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-compose
sudo usermod -aG docker your_userid
```

Though docker image bld_funos is sufficient for most of the build tasks above command may not be very user friendly considering all the options that are needed for smooth operation. Also, running the tests requires user account inside the container for which one needs to build a user wrapper image on their local machine. So it is recommended that users just create one wrapper bld_funos image and use that instead. For example, assuming your current working directory is your WORKSPACE populated with needed git repositories then you could use following command.

```
$> docker run -t --rm -u $USER --cap-add SYS_PTRACE -v $PWD:$PWD -w $PWD $USER/bld_funos make MACHINE=f1
```

You could write a wrapper script with all your personal customization to suit your needs. For example:

With a simple doc_run bash script shown below, one can execute doc_run make MACHINE=posix or doc_run FunOS/scripts/build_test.sh mips-f1

``` bash
#!/bin/bash
export WORKSPACE=$PWD
cd FunDocker
git pull
./build.sh $USER/bld_funos
cd $WORKSPACE
docker run -t --rm --cap-add SYS_PTRACE -v $PWD:$PWD -v $HOME:/home/$USER -w $PWD $USER/bld_funos $*
```

