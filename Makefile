# Makefile for Sinclair QL boot file generation

# Define the target executable file name
TARGET = MAIN

# Define the QL boot file name
BOOTFILE = boot

# Define the compiler command and options
CC = qcc
CFLAGS = -o $(TARGET)

# Define the boot file template
BOOTTEMPLATE = \
	10 f$$="flp1_$(TARGET)"\n \
	20 l=FLEN(\f$$)\n \
	30 mem=RESPR(l)\n \
	40 LBYTES f$$,mem\n \
	50 SEXEC ram1_$(TARGET),mem,l,<DATASPACE>\n \
	60 EXEC ram1_$(TARGET)\n

# Default rule to build the target
$(TARGET): main.c
	$(CC) $(CFLAGS) main.c

# Rule to generate the boot file
$(BOOTFILE): $(TARGET)
	@DATASPACE=$$(grep -oP '\(\K[0-9]+(?=\))' $(TARGET)) && \
	echo -e "$(BOOTTEMPLATE)" | sed "s/<DATASPACE>/$$DATASPACE/g" > $@

# Rule to clean up generated files
clean:
	rm -f $(TARGET) $(BOOTFILE)
