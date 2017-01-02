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

# Download and unzip SDK
ENV ANDROID_HOME /opt/android-sdk-linux
RUN mkdir /opt/android-sdk-linux && cd /opt/android-sdk-linux && wget -q https://dl.google.com/android/repository/tools_r25.2.4-linux.zip -O /opt/android-sdk-linux/tools.zip ; \
    unzip tools.zip ; \
    rm -f tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/bin

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.
RUN echo y | sdkmanager "platform-tools" | grep 'done'

# SDKs
# Please keep these in descending order!
RUN echo y | sdkmanager "platforms;android-25" | grep 'done'

# build tools
# Please keep these in descending order!
RUN echo y | sdkmanager "build-tools;25.0.2" | grep 'done'

# Extras
RUN echo y | sdkmanager "extras;android;m2repository" | grep 'done'
RUN echo y | sdkmanager "extras;google;m2repository" | grep 'done'

# Support Gradle
ENV TERM dumb
