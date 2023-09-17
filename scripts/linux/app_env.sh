#!/bin/sh

APP_LINUX_NAME=""
APP_LINUX_VERSION=""
APP_LINUX_BUILD_VERSION=""

CAKEWALLET="cakewallet"

TYPES=($CAKEWALLET)
APP_LINUX_TYPE=$CAKEWALLET

if [ -n "$1" ]; then
	APP_LINUX_TYPE=$1
fi

CAKEWALLET_NAME="Cake Wallet"
CAKEWALLET_VERSION="1.1.1"
CAKEWALLET_BUILD_NUMBER=4

if ! [[ " ${TYPES[*]} " =~ " ${APP_LINUX_TYPE} " ]]; then
    echo "Wrong app type."
    exit 1
fi

case $APP_LINUX_TYPE in
	$CAKEWALLET)
		APP_LINUX_NAME=$CAKEWALLET_NAME
		APP_LINUX_VERSION=$CAKEWALLET_VERSION
		APP_LINUX_BUILD_NUMBER=$CAKEWALLET_BUILD_NUMBER;;
esac

export APP_LINUX_TYPE
export APP_LINUX_NAME
export APP_LINUX_VERSION
export APP_LINUX_BUILD_NUMBER
