# FunDocker

This repository contains Dockerfiles and process to build and push images used for building and testing FunOS to private docker registry docker.fungible.com

## Structure

It is flat directory containing Dockerfiles, makefile called doc.mk, main build script called build.sh and helper script called fun_docker.sh

Docker images are pushed to private registry at docker.fungible.com. Toplevel directory contains images for run time only and build time which is a superset of run time and build. For example: run_funos, bld_funos. Some build and test steps need a user account inside the containers which are at pushed under a directory below top level registry and are refered to as wrapper images which are dereived from corresponding run or bld toplevel images. Directory is named after the user. (Currently only jenkins user can push such wrapper images). The image dependencies are defined in the doc.mk makefile and build.sh is used to build the images.

## Registry contents

- run_funos        
- bld_funos
- dind_funcp
- jenkins/run_funos
- jenkins/bld_funos

## Process

Jenkins user builds and pushes the images to registry whenever there is commit to master branch. Any mistake in those Dockerfile can potentially break all build and test operations. Merge to master is to testes offline and reviewed via PR.

## Developer wrapper images

Any user can build wrapper images for their use on their laptops or developement machines. To do so, just clone this repo and run build.sh $USER/bld_funos

