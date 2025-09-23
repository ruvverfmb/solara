# Makefile

# Tools
CC = x86_64-elf-g++
LD = x86_64-elf-ld
AS = nasm
GRUB_MKRESCUE = grub-mkrescue
QEMU = qemu-system-x86_64

# Compilation flags
CFLAGS = -ffreestanding -nostdlib -fno-exceptions -fno-rtti -Wall -Wextra -m32
LDFLAGS = -nostdlib -T $(SRCDIR)/linker.ld -melf_i386
ASFLAGS = -f elf32

# Targets
TARGET = kernel.bin
ISO = solara_bld.iso

# Directories
SRCDIR = src/kernel
BUILDDIR = build/kernel
ISODIR = isodir

# Source files
SOURCES = $(wildcard $(SRCDIR)/*.cpp)
OBJECTS = $(patsubst $(SRCDIR)/%.cpp,$(BUILDDIR)/%.o,$(SOURCES))
ASM_SOURCES = $(wildcard $(SRCDIR)/*.asm)
ASM_OBJECTS = $(patsubst $(SRCDIR)/%.asm,$(BUILDDIR)/%.o,$(ASM_SOURCES))

# Default rule
all: $(ISO)

# Build ISO image
$(ISO): $(TARGET) | $(ISODIR)
	@echo "[Solara] reported action: build..."
	@echo "Creating ISO image..."
	@mkdir -p $(ISODIR)/boot/grub
	@cp $(TARGET) $(ISODIR)/boot/
	@cp src/kernel/grub.cfg $(ISODIR)/boot/grub/
	@$(GRUB_MKRESCUE) -o $@ $(ISODIR)

# Link kernel
$(TARGET): $(OBJECTS) $(ASM_OBJECTS)
	@echo "Linking kernel..."
	@$(LD) $(LDFLAGS) -o $@ $^

# Compile C++ files
$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp | $(BUILDDIR)
	@echo "Compiling $<..."
	@$(CC) $(CFLAGS) -c $< -o $@

# Compile ASM files
$(BUILDDIR)/%.o: $(SRCDIR)/%.asm | $(BUILDDIR)
	@echo "Assembling $<..."
	@$(AS) $(ASFLAGS) $< -o $@

# Create directories
$(BUILDDIR):
	@mkdir -p $@

$(ISODIR):
	@mkdir -p $@

# Run in QEMU
run: $(ISO)
	@echo "[Solara] reported action: run..."
	@echo "Starting QEMU..."
	@$(QEMU) -cdrom $(ISO)

# Clean build files
clean:
	@echo "[Solara] reported action: clean..."
	@echo "Cleaning build files..."
	@rm -rf build isodir $(TARGET) $(ISO)

# Full rebuild
rebuild: clean
	@echo "[Solara] reported action: rebuild..."
	@$(MAKE) all

.PHONY: all run clean rebuild
