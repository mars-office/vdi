# Start with latest manjaro image
FROM manjarolinux/base

# Env vars
ENV XRES 1280x800x24
ENV TZ Etc/UTC

# Set fastest repo
RUN pacman-mirrors --country Germany

# Update all existing packages and repos
RUN pacman -Syyu

# Install lxqt desktop + lightdm display manager
RUN pacman --noconfirm -S plasma kio-extras xorg-server-xvfb x11vnc supervisor

# Expose VNC and noVNC ports out of the container
EXPOSE 6080 5900

WORKDIR /root

COPY ./supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord","-n", "-c","/etc/supervisord.conf"]

# Label for GHCR - set repo
LABEL org.opencontainers.image.source=https://github.com/mars-office/vdi
