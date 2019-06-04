#!/bin/bash

[[ -n $_FUN_DOC_DEBUG ]] && set -x
DOC_REG=docker.fungible.com
ACTION=''
IMG=''
DOCK_FILE=''
DOCKER_OPTIONS="--build-arg DOC_REG=${DOC_REG}"
arg_user=$(id -un)
arg_uid=$(id -u)
VER=$(date +%y.%m)

usage () {
	echo "usage: $0 -a prepare|build -i image -f dockerfile passthrough args
	echo "\nwhere,"
	echo "\nprepare: Prepares the workspace by adjusting timestamps of git file and docker image file"
	echo "build:	 Build docker image for give dockerfile and passthrough args, tag and optionally push"
	"
	exit $1
}

prepare_ws () {
	# touch img file if image pulled / exists 
	echo Pulling docker image ${REG_IMG}...
	docker pull ${REG_IMG} 2> /dev/null > ${IMG}.pull.log
	if [[ $? -eq 0 ]]
	then
		iso_date=$(docker inspect -f '{{ .Created }}' ${REG_IMG}:latest)
		touch --date=${iso_date} $IMG
	else
		# Image not in registry, check local
		iso_date=$(docker inspect -f '{{ .Created }}' ${IMG} 2> /dev/null)
		if [[ $? -eq 0 ]]
		then
			touch --date=${iso_date} $IMG
		else
			rm -f $IMG # remove if left over kruft
		fi
	fi

	# Adjust Dockerfile timestamp
	# reset file timestamp to last commit time if unmodifed git file 
	git ls-files --error-unmatch $DOC_FILE > /dev/null 2>&1
	if [[ $? -eq 0 ]]
	then
		echo "unmodified git tracked file"
		touch $DOC_FILE --date=@$(git log -n1 --pretty=format:%ct $DOC_FILE)
		return 0
	fi
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
	echo Building docker image $IMG...
	docker rmi $IMG 2> /dev/null || :
	docker build -t $IMG -f $DOC_FILE $DOCKER_OPTIONS . > ${IMG}.bld.log
	[[ $? -ne 0 ]] && cat ${IMG}.bld.log && exit 1
	docker tag $IMG ${REG_IMG}
	if [[ $_PUSH_IMAGE == 'true' ]]
	then
		docker push ${REG_IMG}
		[[ $? -ne 0 ]] && echo Failed to push ${REG_IMG} && exit 1
		echo ${REG_IMG} >> pushed
	fi
	iso_date=$(docker inspect -f '{{ .Created }}' ${IMG} 2> /dev/null)
	touch --date=${iso_date} $IMG
	;;
*)
	echo "Something wrong"
	exit 1
	;;
esac
exit 0

