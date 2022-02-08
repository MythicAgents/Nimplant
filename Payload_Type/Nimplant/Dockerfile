#from notoriousrebel/nimplant:0.0.1
FROM python:3.8-buster

ARG CA_CERTIFICATE
ARG NPM_REGISTRY
ARG PYPI_INDEX
ARG PYPI_INDEX_URL
ARG DOCKER_REGSITRY_MIRROR
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN pip install dynaconf==3.1.4
RUN pip install aio-pika
RUN pip install pycrypto
RUN pip install pycryptodome
RUN pip install mythic-payloadtype-container==0.1.7

RUN set -xe 		&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d 	&& echo 'exit 101' >> /usr/sbin/policy-rc.d 	&& chmod +x /usr/sbin/policy-rc.d 		&& dpkg-divert --local --rename --add /sbin/initctl 	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl 	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl 		&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup 		&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean 	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean 	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean 		&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages 		&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes 		&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
#RUN "$(apt-get indextargets)"
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
RUN apt-get update; apt-get install -y wget xz-utils g++;     wget -qO- https://deb.nodesource.com/setup_17.x | bash -;     apt-get install -y nodejs
RUN wget http://nim-lang.org/download/nim-1.6.2.tar.xz;     tar xf nim-1.6.2.tar.xz; rm nim-1.6.2.tar.xz;     mv nim-1.6.2 nim;     cd nim; sh build.sh;     rm -r c_code tests;     ln -s `pwd`/bin/nim /bin/nim
RUN apt-get update; apt-get install -y git mercurial
RUN cd nim; nim c koch; ./koch tools; ./koch nimble;    ln -s `pwd`/bin/nimble /bin/nimble;    ln -s `pwd`/bin/nimsuggest /bin/nimsuggest;    ln -s `pwd`/bin/testament /bin/testament
#ENV PATH="/bin/nimble/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install build-essential -y
RUN apt-get install gcc-mingw-w64-x86-64 -y
RUN apt-get install g++-mingw-w64-x86-64 -y
RUN nimble install winim -y
RUN nimble install nimcrypto -y
RUN nimble install sysrandom -y
RUN apt-get install software-properties-common apt-utils make build-essential libssl-dev zlib1g-dev libbz2-dev     libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev     xz-utils tk-dev libffi-dev liblzma-dev -y
RUN apt-get update


ENTRYPOINT ["/Mythic/mythic/payload_service.sh"]