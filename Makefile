LIBDIR ?= ./lib
LDFLAGS = -L$(LIBDIR) -pie -z noexecstack -z relro -z now
LDLIBS = -lpqos -lpthread
CFLAGS = -I$(LIBDIR) \
	-W -Wall -Wextra -Wstrict-prototypes -Wmissing-prototypes \
	-Wmissing-declarations -Wold-style-definition -Wpointer-arith \
	-Wcast-qual -Wundef -Wwrite-strings \
	-Wformat -Wformat-security -fstack-protector -fPIE \
	-Wunreachable-code -Wsign-compare -Wno-endif-labels
ifneq ($(EXTRA_CFLAGS),)
CFLAGS += $(EXTRA_CFLAGS)
endif
ifneq ($(EXTRA_LDFLAGS),)
LDFLAGS += $(EXTRA_LDFLAGS)
endif

# ICC and GCC options
ifeq ($(CC),icc)
else
CFLAGS += -Wcast-align \
    -Wnested-externs \
    -Wmissing-noreturn
endif

# DEBUG build
ifeq ($(DEBUG),y)
CFLAGS += -g -ggdb -O0 -DDEBUG
else
CFLAGS += -g -O2 -D_FORTIFY_SOURCE=2
endif

# Build targets and dependencies
APP = emba
MAN = pqos.8

# XXX: modify as desired
PREFIX ?= /usr/local
BIN_DIR = $(PREFIX)/bin
MAN_DIR = $(PREFIX)/man/man8

SRCS = $(sort $(wildcard *.c))
OBJS = $(SRCS:.c=.o)
DEPFILES = $(SRCS:.c=.d)

all: $(APP)

$(APP): $(OBJS)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

%.o: %.c %.d

%.d: %.c
	$(CC) -MM -MP -MF $@ $(CFLAGS) $<
	cat $@ | sed 's/$(@:.d=.o)/$@/' >> $@

.PHONY: clean install uninstall

install: $(APP) $(MAN)
ifeq ($(shell uname), FreeBSD)
	install -d $(BIN_DIR)
	install -d $(MAN_DIR)
	install -s $(APP) $(BIN_DIR)
	install $(APP)-msr $(BIN_DIR)
	install -m 0444 $(MAN) $(MAN_DIR)
	ln -f -s $(MAN) $(MAN_DIR)/$(APP)-msr.8
else
	install -D -s $(APP) $(BIN_DIR)/$(APP)
	install -D $(APP)-msr $(BIN_DIR)/$(APP)-msr
	install -D $(APP)-os $(BIN_DIR)/$(APP)-os
	install -m 0444 $(MAN) -D $(MAN_DIR)/$(MAN)
	ln -f -s $(MAN) $(MAN_DIR)/$(APP)-msr.8
	ln -f -s $(MAN) $(MAN_DIR)/$(APP)-os.8
endif

uninstall:
	-rm $(BIN_DIR)/$(APP)
	-rm $(MAN_DIR)/$(MAN)
	-rm $(BIN_DIR)/$(APP)-msr
	-rm $(MAN_DIR)/$(APP)-msr.8
ifneq ($(shell uname), FreeBSD)
	-rm $(BIN_DIR)/$(APP)-os
	-rm $(MAN_DIR)/$(APP)-os.8
endif

clean:
	-rm -f $(APP) $(OBJS) $(DEPFILES) ./*~

CHECKPATCH?=checkpatch.pl
.PHONY: style
style:
	$(CHECKPATCH) --no-tree --no-signoff --emacs \
	--ignore CODE_INDENT,INITIALISED_STATIC,LEADING_SPACE,SPLIT_STRING,UNSPECIFIED_INT,ARRAY_SIZE,\
	SPDX_LICENSE_TAG \
	 -f main.c -f main.h -f monitor.c -f monitor.h -f alloc.c -f alloc.h -f profiles.c -f profiles.h \
	 -f cap.h -f cap.c

CPPCHECK?=cppcheck
.PHONY: cppcheck
cppcheck:
	$(CPPCHECK) --enable=warning,portability,performance,unusedFunction,missingInclude \
	--std=c99 -I$(LIBDIR) --template=gcc \
	main.c main.h alloc.c alloc.h monitor.c monitor.h profiles.c profiles.h \
	cap.h cap.c

# if target not clean then make dependencies
ifneq ($(MAKECMDGOALS),clean)
-include $(DEPFILES)
endif
