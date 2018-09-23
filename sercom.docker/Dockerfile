FROM debian:stretch 
MAINTAINER Pablo D. Roca <pablodroca@gmail.com>


ENV DEBIAN_FRONTEND noninteractive
ENV VIRTUALENV_FOLDER /home/sercom/virtualenv
ENV TIMEZONE America/Argentina/Buenos_Aires
ENV SERCOM_SRC_FOLDER /home/sercom/sercom_src/sercom
ENV CHROOT_TEMPLATE_FOLDER $SERCOM_SRC_FOLDER/var/chroot_template
ENV CHROOT_SANDBOX_FOLDER $SERCOM_SRC_FOLDER/var/chroot_sandbox
ENV CHROOT_TEMP_FOLDER $SERCOM_SRC_FOLDER/var/tmp
ENV LANG es_AR.UTF-8  
ENV LANGUAGE es_AR 
ENV LC_ALL es_AR.UTF-8  
ENV PYTHON_EGG_CACHE $SERCOM_SRC_FOLDER/var/tmp/python-eggs

#Instalación de paquetes
RUN apt-get update && \
    #apt-get -yq upgrade \
    apt-get -yq install wget \
                        zip \
                        unzip \
                        build-essential \
                        python \
                        git \
                        python-dev \
                        mysql-client \
                        python-mysqldb \
                        default-libmysqlclient-dev \
                        supervisor \
                        ghostscript \
                        highlight \
                        a2ps \
                        schroot \
                        debootstrap \
                        procps \
                        locales
# Set locale information
ENV LANGUAGE $LANG
RUN echo "$LANG UTF-8" > /etc/locale.gen && \
    locale-gen $LANG && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=$LANG

RUN echo $TIMEZONE > /etc/timezone && \
  cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# Define user and download code base
RUN mkdir /var/lib/sercom && \
  useradd -m sercom && \
  ln -s /var/lib/sercom /home/sercom/sercom_src && \
  git clone -b v2/cherrypy14 https://github.com/sercom/sercom.git /home/sercom/sercom_src/sercom && \
  cd /home/sercom/sercom_src/sercom && \
  git remote rm origin && \
  git remote add -f release https://github.com/sercom/sercom.git

# Install virtualenv
RUN cd tmp && \
  wget https://bootstrap.pypa.io/ez_setup.py && \
  python ez_setup.py && \
  easy_install virtualenv && \
  virtualenv --no-site-packages $VIRTUALENV_FOLDER

# Install Turbo Gears environment within virtualenv
RUN . $VIRTUALENV_FOLDER/bin/activate && \
  # Not available in pip repo: pip install PEAK-rules. Using easy_install instead
  easy_install http://peak.telecommunity.com/snapshots/PEAK-Rules-0.5a1.dev-r2713.tar.gz && \
  pip install TurboGears==1.5.1 && \
  pip install TurboJson==1.3.2 && \
  pip install SQLObject==2.1.0 && \
  pip install kid==0.9.6 && \
  pip install docutils==0.14 && \
  pip install pydns==2.3.6 && \
  pip install MySQL-python==1.2.5 && \
  pip install TurboKid==1.0.5 && \
  pip install nose==1.3.7 && \
  pip install dnspython==1.15.0 && \
  deactivate

# Patch turbojson library because of known issue
#RUN ls $VIRTUALENV_FOLDER/lib/python2.7/site-packages/turbojson
#RUN cd $VIRTUALENV_FOLDER/lib/python2.7/site-packages && \
#  mv TurboJson-1.3.2-py2.7.egg TurboJson-1.3.2-py2.7.egg_tmp && \
#  unzip TurboJson-1.3.2-py2.7.egg_tmp -d TurboJson-1.3.2-py2.7.egg && \
#  rm TurboJson-1.3.2-py2.7.egg_tmp
ADD patchs/jsonify.py $VIRTUALENV_FOLDER/lib/python2.7/site-packages/TurboJson-1.3.2-py2.7.egg/turbojson/jsonify.py


# Define web and backend users. Configure log folders.
# TODO: avoid using new users for the backend service and remove this section.
# User permissions for files/directories does not apply using docker unless
# they live with the same UID/GID within the container and the host system.
# Since most of the jobs are being done using the root user now, the Tester 
# class needs to be updated to use docker-alike behaviour instead of chroot 
# and user switching.
RUN useradd -M sercom_web && \
  useradd -M sercom_backend && \
  mkdir /var/log/sercom &&\
  chmod g+wr /var/log/sercom && \
  addgroup sercom_log && \
  chgrp sercom_log /var/log/sercom && \
  usermod -a -G sercom_log sercom_backend && \
  usermod -a -G sercom_log sercom_web
RUN mkdir -p $CHROOT_TEMP_FOLDER && \ 
  chmod g+wr $CHROOT_TEMP_FOLDER && \
  chgrp sercom_log $CHROOT_TEMP_FOLDER

# Set execution folders, temporary files and python eggs
RUN mkdir -p $PYTHON_EGG_CACHE && \
  chown -R sercom_backend $PYTHON_EGG_CACHE && \
  chmod ugo+w $PYTHON_EGG_CACHE

#Configuracion de CHROOT. Extra folders for sandbox are required since they are not synchronized
RUN mkdir $CHROOT_TEMPLATE_FOLDER && \
  mkdir $CHROOT_SANDBOX_FOLDER 

RUN echo "/proc    $CHROOT_TEMPLATE_FOLDER/proc    none rbind 0 0" >> /etc/fstab && \
  echo "/sys    $CHROOT_TEMPLATE_FOLDER/sys    none rbind 0 0" >> /etc/fstab && \
  echo "/proc    $CHROOT_SANDBOX_FOLDER/proc    none rbind 0 0" >> /etc/fstab && \
  echo "/sys    $CHROOT_SANDBOX_FOLDER/sys    none rbind 0 0" >> /etc/fstab

# supervisor base configuration
RUN mkdir -p /var/log/supervisor
COPY configs/supervisor.conf /etc/supervisor.conf

# Add scripts
COPY scripts/*.sh /
RUN chmod ugo+x /*.sh

COPY configs/prod.web.cfg $SERCOM_SRC_FOLDER/prod.web.cfg
COPY configs/prod.backend.cfg $SERCOM_SRC_FOLDER/prod.backend.cfg

VOLUME ["$CHROOT_TEMPLATE_FOLDER", "$CHROOT_SANDBOX_FOLDER", "$CHROOT_TEMP_FOLDER"]
VOLUME ["$SERCOM_SRC_FOLDER", "/var/log/sercom", "/var/log/supervisord"]

ENV SERCOM_DB_NAME sercom
ENV SERCOM_DB_USER sercom
ENV SERCOM_DB_PASS sercom
ENV MYSQL_SERVER 127.0.0.1
ENV MYSQL_PORT 3306
EXPOSE 8080

CMD ["/run.sh"]

