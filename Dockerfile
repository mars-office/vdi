FROM alpine:latest


ENV DISPLAY :1
ENV RESOLUTION 1920x1080x24
ENV TZ Etc/UTC

RUN apk add --no-cache \
  xfce4 \
  faenza-icon-theme \
  xvfb \
  x11vnc tzdata nano sudo supervisor bash xfce4-terminal xfce4-xkb-plugin mousepad

# setup novnc
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  novnc && \
  ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

SHELL ["/bin/bash", "-c"]

# setup supervisor
COPY supervisor /tmp
RUN echo_supervisord_conf > /etc/supervisord.conf && \
  sed -i -r -f /tmp/supervisor.sed /etc/supervisord.conf && \
  mkdir -pv /etc/supervisor/conf.d /var/log/{novnc,x11vnc,xfce4,xvfb} && \
  mv /tmp/supervisor-*.ini /etc/supervisor/conf.d/ && \
  rm -fr /tmp/supervisor*

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]

EXPOSE 6080 5900

LABEL org.opencontainers.image.source=https://github.com/mars-office/vdi