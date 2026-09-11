FROM ubuntu:20.04

ARG steam_user=anonymous
ARG steam_password=

#RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt update && apt install -y lib32gcc1 curl nano libstdc++6 lib32stdc++6

RUN useradd -m -d /home/lan -s /bin/bash lan
USER lan
WORKDIR /home/lan

# Install SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

RUN ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ./hlds/ \
        # mod must be chosen first (only for HLDS)
        +app_set_config 90 mod cstrike \
        +app_update 90 -beta steam_legacy validate \
        +quit \
        ; exit 0

# 2 runs required for successful install
RUN ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ./hlds/ \
        +app_set_config 90 mod cstrike \
        +app_update 90 -beta steam_legacy validate \
        +quit \
        ; exit 0

RUN mkdir -p /home/lan/.steam && ln -s /home/lan/hlds /home/lan/.steam/sdk32
#RUN ln -s /home/lan/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /home/lan/hlds/steam_appid.txt
ADD hlds_run.sh /home/lan/hlds_run.sh
USER root
RUN chmod +x /home/lan/hlds_run.sh
#USER lan

# inject files
ADD files/ /home/lan/hlds/
RUN mv /home/lan/linux32/libstdc++.so.6 /home/lan/linux32/libstdc++.so.6.old
# Cleanup

RUN apt remove -y curl
RUN chown -R lan:users /home/lan/hlds
RUN chmod -R +x /home/lan/hlds
USER lan

WORKDIR /home/lan/hlds

ENTRYPOINT ["/home/lan/hlds_run.sh"]

#example run: docker run -d -p 26900:26900/udp -p 27020:27020/udp -p 27015:27015/udp -p 27015:27015 -e ADMIN_STEAM=1:1:35880 --name cs cs
