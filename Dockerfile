FROM ruby:2.3.3

RUN apt-get update; apt-get install -y ssh sudo net-tools wget software-properties-common iputils-ping telnet dnsutils curl nano openvpn git \
    ruby ruby-dev
RUN gem install rails -v 5.1.2

RUN git clone --depth 1 https://github.com/kladkogex/demo_shop demo_shop

WORKDIR /demo_shop

RUN bundle install

RUN rails g spree:install -f --auto-accept --user_class=Spree::User
RUN rails g spree:auth:install -f
RUN rails g spree_gateway:install --auto_run_migrations=true

EXPOSE 3000 

ENTRYPOINT ["rails", "server"]