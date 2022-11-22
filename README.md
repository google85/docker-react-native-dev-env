## Docker React-Native dev environment
#### - from scratch
#### - image size: 3,77 GB

#

### Reqs:
- Node - v14 or later   Dockerfile FROM node:16                 ==> Node    v16.18.1
- Java - OpenJDK        Dockerfile apt-get...                   ==> OpenJDK v11.0.16 2022-07-19
       -  as we need `jlink` for gradle build APK, default-jre is not an acceptable version
- Gradle                Dockerfile intentionat 6.5              ==> Gradle  v6.5
- Gradle from project   - v7.5.1
- android SDK,build-tools

### NOTICES:
- It's better to start from JDK, like this person said here: https://stackoverflow.com/questions/43769730/create-docker-container-with-both-java-and-node-js
- We will start from Node, because starting from JDK gives errors
- apt-get -y install default-jre ==> OpenJDK v11.0.16 2022-07-19



### Using

- build & run [via Makefile]
    ```bash
    make start
    ```

- [OPTIONAL] outside of container, finding `WSL/host`t IP:
    ```bash
    tail -1 /etc/resolv.conf | cut -d' ' -f2
    ```

- enter / attach to the container... and create a `react-native` app
    ```bash
    docker exec --it ... bash

    create-react-native-app hello-meetup
    cd ./hello-meetup
    # optionally, install web deps
    npx expo install react-native-web@~0.18.9 react-dom@18.1.0 @expo/webpack-config@^0.17.2

    # start
    yarn start


    ```
- now we'll have access to:
    - Debugger UI - on port 8081    - http://localhost:8081/debugger-ui/
    - in browser react - on 19006   - http://localhost:19006

- [OPTIONAL] chown to our WSL user of project files so we can change them in VSCode
    ```bash
    sudo chown -fR $(whoami):$(whoami) hello-meetup/
    ```

- [TODO] pt moment mai sunt necesare urmatoarele editari in proiect:
    - SDK dir not being recognized (maybe because was runned without root?)
    ```bash
    echo 'sdk.dir=/opt/android-sdk-linux' > /android/local.properties
    ```
    - sdk version not accepted as variable [maybe because was runned without root?]
    in `android/app/build.gradle`
    ```gradle
     android {
    ndkVersion rootProject.ext.ndkVersion

    #compileSdkVersion rootProject.ext.compileSdkVersion    ==> compileSdkVersion 31
    ```


- export / build APK [password for user 'node' is 'password']
    ```bash
    cd /android
    sudo ./gradlew assembleDebug
    ```





### Bibliography:
- https://www.youtube.com/watch?v=9ygH_lYnpbg
- https://reactnative.dev/docs/environment-setup
- https://github.com/Cangol/android-gradle-docker/blob/master/Dockerfile