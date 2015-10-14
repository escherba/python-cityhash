CXX := g++
CXXFLAGS := -O3
LDFLAGS := -stdlib=libc++
SRCEXT := cc
INC := -I include
LIB := -L lib

INPUT := ./data/sample_100k.txt

BINDIR := bin
SRCDIR := src
TESTDIR := tests
BUILDDIR := $(shell $(PYTHON) ./scripts/get_build_dir.py)
ALL_SOURCES := $(wildcard $(SRCDIR)/*.$(SRCEXT) $(TESTDIR)/*.$(SRCEXT))

RUN_SOURCES := $(wildcard $(SRCDIR)/*_main.$(SRCEXT) $(TESTDIR)/*_main.$(SRCEXT))
RUN_OBJECTS := $(patsubst %, $(BUILDDIR)/%, $(RUN_SOURCES:.$(SRCEXT)=.o))
RUN_TARGETS := $(patsubst $(BUILDDIR)/%.o, $(BINDIR)/%, $(RUN_OBJECTS))

TEST_SOURCES := $(wildcard $(TESTDIR)/test_*.$(SRCEXT))
TEST_OBJECTS := $(patsubst %, $(BUILDDIR)/%, $(TEST_SOURCES:.$(SRCEXT)=.o))
TEST_TARGETS := $(patsubst $(BUILDDIR)/%.o, $(BINDIR)/%, $(TEST_OBJECTS))

SOURCES := $(filter-out $(RUN_SOURCES) $(TEST_SOURCES), $(ALL_SOURCES))
OBJECTS := $(patsubst %, $(BUILDDIR)/%, $(SOURCES:.$(SRCEXT)=.o))

.PHONY: clean_cpp test_cpp run_cpp

.SECONDARY: $(RUN_OBJECTS) $(TEST_OBJECTS) $(OBJECTS)

clean_cpp:
	rm -rf ./$(BINDIR)/ ./$(BUILDDIR)/

$(BUILDDIR)/%.o: %.$(SRCEXT)
	@mkdir -p $(dir $@)
	$(CC) $(INC) $(CXXFLAGS) -c $< -o $@

$(BINDIR)/%: $(BUILDDIR)/%.o $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CXX) $(LIB) $(LDFLAGS) $^ -o $@

run_cpp: $(RUN_TARGETS)
	@for target in $(RUN_TARGETS); do \
		echo $$target >&2; \
		time ./$$target $(INPUT); \
		done

test_cpp: $(TEST_TARGETS)
	$(foreach target, $^, ./$(target);)
