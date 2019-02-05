#!/bin/bash 

[[ -n $_FUN_DOC_DEBUG ]] && set -x
DOC_REG=fundocker.fungible.com
ACTION=''
IMG=''
DOCK_FILE=''
DOCKER_OPTIONS="--build-arg DOC_REG=${DOC_REG}"
arg_user=$(id -un)
arg_uid=$(id -u)
VER=$(date +%y.%m)

usage () {
	echo "usage: $0 -a prepare|build|push -i image -f dockerfile passthrough args
	echo "\nwhere,"
	echo "\nprepare: Prepares the workspace by adjusting timestamps of git file and docker image file"
	echo "build:	 Build docker image for give dockerfile and passthrough args"
	echo "push:    Tag and push the image"
	"
	exit $1
}

prepare_ws () {
	# Adjust Dockerfile timestamp
	git ls-files --error-unmatch $DOC_FILE > /dev/null 2>&1
	[[ $? -ne 0 ]] && return 0 # unmodified git tracked file
	git ls-files -m --error-unmatch $DOC_FILE > /dev/null 2>&1
	[[ $? -eq 0 ]] && return 0 # locally modified git tracked file
	touch $DOC_FILE --date=@$(git log -n1 --pretty=format:%ct $DOC_FILE)
	
	# touch img file if image pulled / exists 
	docker pull ${REG_IMG}:latest 2> /dev/null
	if [[ $? -eq 0 ]]
	then
		iso_date=$(docker inspect -f '{{ .Created }}' ${REG_IMG}:latest)
		touch --date=${iso_date} $IMG
		return 0
	fi

	# Image not in registry, check local
	iso_date=$(docker inspect -f '{{ .Created }}' ${IMG}:latest)
	if [[ $? -eq 0 ]]
	then
		touch --date=${iso_date} $IMG
		return 0
	fi
	
	# new image rm it just in case.
	/bin/rm -f $IMG
}

# main

while getopts :a:i:f: arg 
do
	case $arg in
	a)
		ACTION="$OPTARG"
		;;
	i)
		IMG="$OPTARG"
		REG_IMG=${DOC_REG}/$IMG
		;;
	f)
		DOC_FILE="$OPTARG"
		[[ $DOC_FILE =~ .usr ]] && DOCKER_OPTIONS="$DOCKER_OPTIONS --build-arg arg_user=$arg_user --build-arg arg_uid=$arg_uid"
		;;
	\?) usage 0
		;;
	esac
done
shift $((OPTIND -1))

[[ $ACTION == '' || $IMG == '' ]] && usage 1

case $ACTION in 
prepare)
	[[ $DOC_FILE == '' ]] && usage 1
	prepare_ws
	;;
build)
	[[ $DOC_FILE == '' ]] && usage 1
	docker build -t $IMG -f $DOC_FILE $DOCKER_OPTIONS .
	[[ $? -eq 0 ]] && echo $IMG >> push_images
	;;
push)
	docker tag $IMG ${REG_IMG}:$VER
	docker tag $REG_IMG ${REG_IMG}:latest
	docker push ${REG_IMG}:$VER
	docker push ${REG_IMG}:latest
	;;
*)
	echo "Something wrong"
	exit 1
	;;
esac
exit 0

