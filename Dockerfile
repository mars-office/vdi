FROM manjarolinux/base

ENV XRES 1280x800x24
ENV TZ Etc/UTC

RUN pacman-mirrors --country Germany
RUN pacman -Syyu
RUN pacman --noconfirm -S plasma kio-extras plasma-meta kde-accessibility-meta kde-system-meta konsole yay xorg-server-xvfb x11vnc supervisor
RUN pacman --noconfirm -S yay

CMD ["/start.sh"]
EXPOSE 6080 5900
LABEL org.opencontainers.image.source=https://github.com/mars-office/vdi

COPY ./supervisord.conf /etc/supervisord.conf
COPY ./start.sh /start.sh
RUN chmod +x /start.sh