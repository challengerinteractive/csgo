FROM ubuntu:16.04

ENV LAST_UPDATED_AT 2018-07-31

ADD https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz /tmp/steamcmd_linux.tar.gz
ADD https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6247-linux.tar.gz /tmp/sourcemod.tar.gz
ADD https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git965-linux.tar.gz /tmp/metamod.tar.gz
ADD http://users.alliedmods.net/~kyles/builds/SteamWorks/SteamWorks-git128-linux.tar.gz /tmp/steamworks.tar.gz
ADD smjansson_2.3.1.3_binaries.zip /tmp/smjansson.zip

RUN apt-get update && \
# install dependencies
    apt-get install --no-install-recommends -y unzip lib32gcc1 lib32stdc++6 ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
# get steamcmd
    mkdir /steamcmd && \
    mkdir -p /csgo/csgo/logs && \
    tar -zxvf /tmp/steamcmd_linux.tar.gz -C /steamcmd && \
    cd /steamcmd && \
# install csgo via steamcmd
    ./steamcmd.sh +login anonymous +force_install_dir /csgo +app_update 740 validate +quit && \
# decompress metamod on top of csgo
    tar -xvf /tmp/metamod.tar.gz -C /csgo/csgo && \
# decompress sourcemod on top of csgo
    tar -xvf /tmp/sourcemod.tar.gz -C /csgo/csgo && \
# decompress steamworks on top of csgo
    tar -xvf /tmp/steamworks.tar.gz -C /csgo/csgo && \
# decompress smjannson to proper dir
    unzip /tmp/smjansson.zip *.so -d /csgo/csgo/addons/sourcemod/extensions/ && \
    chown 1000:1000 /csgo/csgo/addons/sourcemod/extensions/smjansson.ext.so && \
    chmod 700 /csgo/csgo/addons/sourcemod/extensions/smjansson.ext.so && \
    mv /csgo/csgo/addons/sourcemod/plugins/disabled/mapchooser.smx /csgo/csgo/addons/sourcemod/plugins/mapchooser.smx

# Contains wrapper scripts and .cfg files
COPY containerfs /

WORKDIR /csgo/csgo/addons/sourcemod/scripting
RUN ./compile.sh challenger-telemetry.sp && \
    mv compiled/challenger-telemetry.smx ../plugins/

# Fix for missing library
RUN mkdir /root/.steam/sdk32
RUN ln -s /steamcmd/linux32/steamclient.so /root/.steam/sdk32/steamclient.so

WORKDIR /csgo

CMD ["./start.sh"]
