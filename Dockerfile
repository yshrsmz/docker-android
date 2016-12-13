FROM openjdk:8-jdk

# https://github.com/bitrise-docker/android/blob/master/Dockerfile
# https://github.com/bitrise-steplib/steps-start-android-emulator/blob/master/step.rb

MAINTAINER Shimizu Yasuhiro <the.phantom.bane+github@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -yq git curl wget rsync sudo expect zip unzip file build-essential libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386 && \
    apt-get clean

RUN mkdir /opt/bin && curl -L https://github.com/haya14busa/reviewdog/releases/download/0.9.2/reviewdog_linux_amd64 -o /opt/bin/reviewdog && chmod 777 /opt/bin/reviewdog

# Download and untar SDK
ENV ANDROID_HOME /opt/android-sdk-linux
RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -O /opt/android-sdk.tgz ; \
    tar -xvzf android-sdk.tgz ; \
    rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/bin

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter android-25 | grep 'package installed'

# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.2 | grep 'package installed'

# Extras
RUN echo y | android update sdk --no-ui --all --filter extra-android-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-m2repository | grep 'package installed'

# Support Gradle
ENV TERM dumb
