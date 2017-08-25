from elixir

RUN mkdir -p /var/www/diana
WORKDIR /var/www/diana

RUN mix local.hex --force && mix local.rebar --force

ADD mix.exs /var/www/diana/
ADD mix.lock /var/www/diana/
RUN mix deps.get

ADD . /var/www/diana
RUN mix compile
