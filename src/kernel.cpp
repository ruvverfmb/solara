// kernel.cpp

typedef unsigned short uint16_t;
volatile uint16_t* vga_buffer = (volatile uint16_t*)0xB8000; // 0xB000 VGA text address

[[noreturn]] void halt() {
    while (1) {
        __asm__("hlt");
    }
}

void clear_screen() {
    for (int i = 0; i < 80 * 25; ++i) {
        vga_buffer[i] = (uint16_t)0x0F00 | ' ';
    }
}

void print_str(const char* str, int x = 0, int y = 0) {
    int index = y * 80 + x;
    for (int i = 0; str[i] != '\0'; ++i) {
        vga_buffer[index + i] = (uint16_t)0x0F00 | str[i];
    }
}

[[noreturn]] void panic(const char *reason) {

    clear_screen();
    print_str("KERNEL PANIC!", 0, 0);
    print_str("System halted. Please reboot your computer.", 0, 1);
    print_str(reason, 0, 3); // print reason below

    halt();
}

void welcome_msg() {
    clear_screen();
    print_str("This is Solara.", 0, 0);
    print_str("", 0, 1);
    print_str("You can find Solara GitHub repository at:", 0, 2);
    print_str("http://github.com/ruvverfmb/solara", 0, 3);
    print_str("", 0, 4);
    print_str("I'd like your feedback!", 0, 5);
}

// kernel entry point
extern "C" void kernel_main() {
    clear_screen();
    welcome_msg();
    halt();
}