FROM debian:wheezy

USER root

RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

RUN apt-get update && apt-get install --assume-yes \
    ntp \
    python \
    python-dev \
    python-pip

RUN pip install \
    ConfigObj \
    psutil

RUN useradd --create-home --home-dir /opt/diamond --shell /bin/bash diamond
ENV HOME /opt/diamond
ENV USER diamond
WORKDIR /opt/diamond

# FIXME should be a fixed release
ADD https://github.com/python-diamond/Diamond/archive/master.tar.gz /opt/diamond/archive/
RUN tar -zxvf /opt/diamond/archive/master.tar.gz -C /opt/diamond
RUN mv Diamond-master Diamond
RUN rm -rf /opt/diamond/archive

RUN find /opt/diamond/Diamond/src -type f | xargs sed -i 's/\/proc/\/host_proc/g'

RUN mkdir /var/log/diamond && chown diamond:diamond /var/log/diamond

RUN make --directory=/opt/diamond/Diamond/ --file=/opt/diamond/Diamond/Makefile install

RUN chown -R diamond:diamond /opt/diamond

USER diamond

ONBUILD COPY diamond.conf /etc/diamond/diamond.conf

CMD [ "/opt/diamond/Diamond/bin/diamond", "--skip-pidfile", "--configfile=/etc/diamond/diamond.conf", "--log-stdout", "--foreground" ]
