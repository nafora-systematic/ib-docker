FROM relateiq/oracle-java8

# install xvfb and other X dependencies for IB
RUN apt-get update -y \
    && apt-get install -y xvfb libxrender1 libxtst6 x11vnc socat unzip\
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# install IB from local file
ADD ibgateway-latest-standalone-linux-x64.sh /opt/
RUN chmod +x /opt/ibgateway-latest-standalone-linux-x64.sh && \
 echo -e "n\n" | /opt/ibgateway-latest-standalone-linux-x64.sh

# install IBController
RUN wget https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip -O /tmp/IBController.zip && \
 mkdir /opt/IBController && \
 unzip /tmp/IBController.zip -d /opt/IBController/ && \
 chmod +x /opt/IBController/*.sh /opt/IBController/Scripts/*.sh && \
 rm /tmp/IBController.zip

#change the default version to current
RUN export TWS_MAJOR_VRSN=$(ls ~/Jts/ibgateway/) && echo "TWS version: $TWS_MAJOR_VRSN" && \
 sed -ie "s/TWS_MAJOR_VRSN=$(cat /opt/IBController/IBControllerGatewayStart.sh | grep -i TWS_MAJOR_VRSN= | cut -d '=' -f2)/TWS_MAJOR_VRSN=$TWS_MAJOR_VRSN /g" /opt/IBController/IBControllerGatewayStart.sh

COPY config/IBController.ini /root/IBController/IBController.ini
COPY config/jts.ini /opt/IBJts/jts.ini
COPY init/xvfb_init /etc/init.d/xvfb
COPY init/vnc_init /etc/init.d/vnc
COPY bin/xvfb-daemon-run /usr/bin/xvfb-daemon-run
COPY bin/run-gateway /usr/bin/run-gateway

# 5900 for VNC, 4003 for the gateway API via socat
EXPOSE 5900 4003

ENV DISPLAY :0

CMD ["/usr/bin/run-gateway"]
