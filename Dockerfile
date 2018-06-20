FROM relateiq/oracle-java8

# install xvfb and other X dependencies for IB
RUN apt-get update -y \
    && apt-get install -y xvfb libxrender1 libxtst6 x11vnc socat unzip libgtk2.0-bin libXtst6 libxslt1.1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# install IB from local file
RUN wget https://download2.interactivebrokers.com/installers/tws/stable-standalone/tws-stable-standalone-linux-x64.sh -O /opt/tws-stable-standalone-linux-x64.sh && \
 chmod +x /opt/tws-stable-standalone-linux-x64.sh && \
 echo -e "n\n" | /opt/tws-stable-standalone-linux-x64.sh

# install IBController
RUN wget https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip -O /tmp/IBController.zip && \
 mkdir /opt/IBController && \
 unzip /tmp/IBController.zip -d /opt/IBController/ && \
 chmod +x /opt/IBController/*.sh /opt/IBController/Scripts/*.sh && \
 rm /tmp/IBController.zip

#change the default version to current
RUN export TWS_MAJOR_VRSN=$(ls -1 ~/Jts/ | egrep -x '[0-9]+') && echo "TWS_MAJOR_VRSN:$TWS_MAJOR_VRSN" && \
 sed -ie "s/TWS_MAJOR_VRSN=$(cat /opt/IBController/IBControllerStart.sh | grep -i TWS_MAJOR_VRSN= | cut -d '=' -f2)/TWS_MAJOR_VRSN=$TWS_MAJOR_VRSN /g" /opt/IBController/IBControllerStart.sh && \
 sed -i "s/TWSUSERID=/#TWSUSERID=/g" /opt/IBController/IBControllerStart.sh && \
 sed -i "s/TWSPASSWORD=/#TWSPASSWORD=/g" /opt/IBController/IBControllerStart.sh

COPY config/IBController.ini /root/IBController/IBController.ini
COPY init/xvfb init/vnc /etc/init.d/
COPY bin/xvfb-daemon-run bin/run-tws bin/enable-api /usr/bin/

# 5900 for VNC, 7497 for the tws API via socat, 7462 for IBController via telnet.
EXPOSE 5900 7497 7462

ENV DISPLAY :0


CMD ["/usr/bin/run-tws"]
