from elixir:1.5.1-alpine

RUN apk update && apk add ffmpeg
RUN mkdir -p /var/www/diana
WORKDIR /var/www/diana

ADD mix.exs /var/www/diana/
ADD mix.lock /var/www/diana/
RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get

ADD . /var/www/diana
RUN mix compile
