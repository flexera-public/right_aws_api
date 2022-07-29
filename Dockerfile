FROM ruby:2.1.9

RUN apt-get update -qq \
&& apt-get install -y nodejs net-tools libxml2 libxml2-dev

ADD . /code/right_aws_api
WORKDIR /code/right_aws_api

RUN bundle install

CMD ["bash"]
