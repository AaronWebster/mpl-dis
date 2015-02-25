# Makefile

TARGET = scatter

CC = gcc

CFLAGS = -finline $(DFLAGS)

INCLUDE_PATH = -I$(WOODYHOME)/include $(GSL_INC) $(HDF5_INC)
LIBRARY_PATH = -L$(WOODYHOME)/lib  $(GSL_LIB) $(HDF5_LIB)

LIBS = -lgsl -lgslcblas -lhdf5 -lz -lm 

OBJS = scatter.o

all : $(TARGET)

$(TARGET) : $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBRARY_PATH) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c $*.c $(INCLUDE_PATH)

clean:
	rm -f $(OBJS) $(TARGET)

