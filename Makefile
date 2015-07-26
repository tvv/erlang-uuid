APPNAME=uuid
REBAR=./rebar
ERLC=erlc
DIALYZER_PLT := erlang-uuid.plt

.PHONY:deps

all: deps compile

./rebar:
	erl -noshell -s inets start -s ssl start \
		-eval 'httpc:request(get, {"https://raw.github.com/wiki/rebar/rebar/rebar", []}, [], [{stream, "./rebar"}])' \
		-s inets stop -s init stop
	chmod +x ./rebar


$(DIALYZER_PLT): compile
	dialyzer --add_to_plt -r ebin --output_plt $(DIALYZER_PLT)

dialyzer: $(DIALYZER_PLT)
	dialyzer --plt $(DIALYZER_PLT) ebin/uuid.beam

compile: $(REBAR)
	@$(REBAR) compile

clean: $(REBAR)
	@$(REBAR) clean

deps: $(REBAR)
	@$(REBAR) check-deps || (export GPROC_DIST=true; $(REBAR) get-deps)

test: compile
	erlc -W +debug_info +compressed +strip -o test/ test/*.erl
	erl -noshell -pa ebin -pa test -eval "uuid_tests:test()" -eval "init:stop()"