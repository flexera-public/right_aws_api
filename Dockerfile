FROM ruby:2.1.9

RUN apt-get update -qq \
&& apt-get install -y nodejs net-tools libxml2 libxml2-dev

ADD . /code/Ruby-Docker
WORKDIR /code/Ruby-Docker

RUN bundle install

CMD ["bash"]
