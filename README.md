# FunDocker

This repository contains Dockerfiles and the process to build and push images used for building and testing FunOS to private docker registry docker.fungible.com. Notes that these images are used in FunJenkins more like light weight VM's. It is recommended that images shipped to customers not be placed here as there is no dev-line branching to support maintenance of these images for released dev-lines.

## Structure

It is a flat directory containing various Dockerfiles, a makefile called doc.mk, main build script called build.sh and helper script called fun_docker.sh

Docker images are pushed to private registry at docker.fungible.com. Top-level directory contains ‘run_<IMG>’ images that are suitable for run time tasks only and ‘bld_<IMG>’ images suitable for both run time and build time.

### User wrapper images.

Some steps in the build and test processes need a user account inside the containers to be present and some even require sudo privilege for such user account.  These are referred to as user wrapper images which are extensions of corresponding ‘run’ or ‘bld’ image with user account added inside the container. Such images for user Jenkins are pushed under a directory below top level registry and named after the user id. (Currently only jenkins user can push such wrapper images). The image dependencies are defined in the doc.mk makefile and build.sh is used to build the images.

Some user wrapper images even require that the embedded user has docker group privilages. For now, docker gid is hardcoded to 999 and this may require some manual intervention while installing ubuntu 20.04 + OS on new machines

## Registry contents

Examples of images:

- run_funos        
- bld_funos
- jenkins/dind
- jenkins/run_funos
- jenkins/bld_funos

## Build Process

Jenkins user automatically builds and pushes the images to registry whenever there is a merge ommit to master branch. Any mistake in those Dockerfile can potentially break all build and test operations. Merge to master needs to be tested offline and reviewed via PR before the merge. 

### Developer wrapper images

Any user can build wrapper images for their use on their laptops or development machines. To do so, just clone this repo and run ‘./build.sh $USER/bld_funos’ in it. Docker image ‘bld_funos’ being a superset one can build and run test by creating a wrapper image $USER/bld_funos for it. You can add to Dockerfile.bld_funos.usr on your branch if you need to further personalize your wrapper image before running build.sh $USER/bld_funos.

## Usage

FunOS related builds based on FunJenkins pipeline use these docker images via docker pipeline plugin. Any user can make use of these docker images to build and run tests inside a container on their development machines. For example:

```
$> docker pull docker.fungible.com/bld_funos:master # replace master for other dev-lines when needed.
$> docker run [options] docker.fungible.com/bld_funos [build commands]
```
** Note: **
You may need to update certificate store on your machine to pull images via SSL from private registry. See below for istructions:

### Docker installation instructions on Ubuntu:
IT would have already installed and configured docker on your IT provided VM. If you need to install docker on other machines within Fungible VPN then use these instructions for installations on Ubuntu 18.04+.  Don't use the snap installer suggested by Ubuntu - it installs the Enterprise/paid edition which is different from the Community version.
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 
sudo apt-get update 
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce
sudo usermod -aG docker your_userid
# debian docker-compose is too old, 1.17. May need to replace following when reving base image with apt-get install
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.0/docker-compose-$(uname -s)-$(uname -m)" \
	-o /usr/bin/docker-compose \
	&& sudo chmod +x /usr/bin/docker-compose

```
Until certificate issue is figured out follow the steps below to pull images from docker.fungible.com registry and to make use of docker mirror.
```
curl http://dochub.fungible.local/doc/sw/tools/fungible.com-certs/fungible.com.crt | sudo tee /usr/local/share/ca-certificates/fungible.com.crt
```
and then
```
sudo update-ca-certificates -v -f 
sudo /sbin/shutdown -r now
```
#### Recommended docker configurations:
As sudo add following to /etc/docker/daemon.json, creating the file if it doesn't exist.

* Use mirror to avoid contributing to pull rate limit
 "registry-mirrors": ["https://docker-mirror.fungible.com"] to /etc/docker/daemon.json. 
* Limit concurrent download on slow VM connections.
  "max-concurrent-downloads": 1

Resulting file may looks like:
```
{
  "registry-mirrors": ["https://docker-mirror.fungible.com"],
  "max-concurrent-downloads": 1
}
```

#### Note: Example of building funos-f1 using docker image:
Though docker image bld_funos is sufficient for most of the build tasks above command may not be very user friendly considering all the options that are needed for smooth operation. Also, running the tests requires user account inside the container for which one needs to build a user wrapper image on their local machine. So it is recommended that users just create one wrapper bld_funos image and use that instead. For example, assuming your current working directory is your WORKSPACE populated with needed git repositories then you could use following command.

```
$> docker run -t --rm -u $USER --cap-add SYS_PTRACE -v $PWD:$PWD -w $PWD $USER/bld_funos bash -c "cd FunOS && make MACHINE=f1"
```

#### Advanced usage:
You could write a wrapper script with all your personal customization to suit your needs. For example to customize docker image with some new packages you can create a branch in FunDocker, modify dockerfile, build an image and use that to build funos-f1:

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
