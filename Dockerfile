FROM node:16 as build

ARG USER
ARG USER_ID
ARG GROUP_ID

RUN npm install -g react-native-cli
RUN npm install -g create-react-native-app
RUN npm install -g exp

# update & upgrade
RUN apt-get --quiet update --yes && apt-get --quiet upgrade --yes

# JDK - as we need jlink for gradle build APK, default-jre is not an acceptable version
RUN apt-get -y install openjdk-11-jdk
#RUN apt-get -y install default-jre
# other versions:
# RUN apt-get -y install openjdk-11-jre-headless
# RUN apt-get -yinstall openjdk-8-jre-headless

# set SDK_HOME
ENV SDK_HOME /usr/local

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1
RUN apt-get --quiet install --yes libqt5widgets5 usbutils

# Gradle
ENV GRADLE_VERSION 7.5.1
#ENV GRADLE_VERSION 6.5
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o gradle-${GRADLE_VERSION}-bin.zip  \
	&& unzip gradle-${GRADLE_VERSION}-bin.zip -d ${SDK_HOME}  \
	&& rm -rf gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME ${SDK_HOME}/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH

# forcing PWD to /opt
WORKDIR /opt

# android sdk|build-tools|image
ENV ANDROID_TARGET_SDK="android-30" \
    ANDROID_BUILD_TOOLS="30.0.2" \
    ANDROID_SDK_TOOLS="7583922"
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
RUN curl -sSL "${ANDROID_SDK_URL}" -o android-sdk-linux.zip \
    && unzip android-sdk-linux.zip -d android-sdk-linux \
  && rm -rf android-sdk-linux.zip

# set ANDROID_HOME
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/bin:$PATH

# optional, daca nu exista
RUN mkdir -p ${ANDROID_HOME}

#RUN file="$(ls -1 /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager )" && echo $file
#RUN echo - debug sdk home: $SDK_HOME
#RUN echo - debug android home: $ANDROID_HOME


# Update and install using sdkmanager 
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses
#RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "tools" "platform-tools" "emulator"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platforms;${ANDROID_TARGET_SDK}"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN echo yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

ENV PATH ${SDK_HOME}/bin:$PATH

# adding to PATH
ENV PATH ${ANDROID_HOME}/tools:$PATH
ENV PATH ${ANDROID_HOME}/tools/bin:$PATH
ENV PATH ${ANDROID_HOME}/platform-tools:$PATH

# [OPTIONAL] sudo & user permissions
RUN apt-get -y install sudo

# [OPTIONAL] making node a root user
RUN usermod -aG sudo node

# [OPTIONAL] set password for user node [non-interactive]
RUN echo "node:password" | chpasswd
#RUN passwd node

# project
RUN mkdir -p /app/react-native-src

# [added] fix permissions for WSL user access (& implicit node?!) to .npm & others
# npm
RUN chown -R $USER_ID:$GROUP_ID "/root/.npm"

# global node_modules [>230 sec]
RUN chown -R $USER_ID:$GROUP_ID "/usr/local/lib/node_modules"
#RUN chown -R node:node "/usr/local/lib/node_modules"
# [>370 sec]
RUN chown -R $USER_ID:$GROUP_ID /opt/android-sdk-linux
RUN chown -R $USER_ID:$GROUP_ID /app/react-native-src

# these must be run from container
#RUN chown -R $USER_ID:$GROUP_ID "/root/.config"
# metro for building stage on opening via Expo mobile app
#RUN chown -R $USER_ID:$GROUP_ID "/tmp/metrocache"

# make ANDROID_HOME symlink
RUN mkdir -p /root/Android
RUN ln -s /opt/android-sdk-linux /root/Android/sdk

# permissions for running under 'node' user
#RUN chown node /app/react-native-src
#RUN chgrp node /app/react-native-src

# optional, for runing under 'node' user ./gradlew commands
# [it takes a lot, over 100 sec]
#RUN chown -R node /opt/android-sdk-linux
#RUN chgrp -R node /opt/android-sdk-linux

# runing under 'node' user
USER node
WORKDIR /app/react-native-src

EXPOSE 19000
EXPOSE 19001
EXPOSE 19002
EXPOSE 19006
RUN echo "Please attach to this container (docker exec -it ... bash) and create a react-native project like in README.md file."

# to always be started
CMD sleep infinity