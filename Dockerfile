FROM centos:7
ENV container docker
MAINTAINER ManageIQ https://github.com/ManageIQ/manageiq

# Set ENV, LANG only needed if building with docker-1.8
ENV LANG en_US.UTF-8
ENV TERM xterm
ENV RUBY_GEMS_ROOT /opt/rubies/ruby-2.2.5/lib/ruby/gems/2.2.0

# Download chruby and chruby-install, install, setup environment, clean all
RUN yum -y install --setopt=tsflags=nodocs bzip2 make &&\
    echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc && \
    curl -sL https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz | tar xz && \
    cd ruby-install-0.6.0 && \
    make install && \
    cd / && \
    rm -rf ruby-install-0.6.0 && \
    ruby-install ruby 2.2.5 -- --disable-install-doc && \
    rm -rf /usr/local/src/* && \
    yum remove -y make bzip2 && \
    yum clean all

ENV PATH $PATH:/opt/rubies/ruby-2.2.5/bin
ADD preamble.rb /
