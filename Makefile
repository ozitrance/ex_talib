MIX = mix
CFLAGS = -g -O3 -std=c23 
ERLANG_PATH = $(shell erl -noshell -eval 'io:format("~s", [code:root_dir()])' -s init stop)/usr/include
ERL_INTERFACE_PATH = $(shell erl -noshell -eval 'io:format("~s/lib", [code:root_dir()])' -s init stop)
FILES =  c_src/ex_talib.c
CFLAGS += -I$(ERLANG_PATH)
CFLAGS += -Wno-unused-parameter
CC= gcc
LDFLAGS += -lta_lib -lei

NIF_NAME = ex_talib
TARGET = priv/$(NIF_NAME).so

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
		CFLAGS  += -I/opt/homebrew/Cellar/ta-lib/0.4.0/include/ta-lib/
		LDFLAGS += -L/opt/homebrew/Cellar/ta-lib/0.4.0/lib/
	endif

	ifeq ($(shell uname),Linux)
		CFLAGS  += -I/usr/include/ta-lib
		LDFLAGS += -L/usr/lib
		LDFLAGS += -L$(ERL_INTERFACE_PATH)
	endif

	LDFLAGS += -shared 
endif

.PHONY: all clean

all: 
	@mkdir -p priv
	$(CC) $(CFLAGS) $(FILES) $(LDFLAGS) -o $(TARGET)

clean:
	$(MIX) clean
	$(RM) $(TARGET)