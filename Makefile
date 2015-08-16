all: test_gpio test_pwm test_uart test_blink test5

BOOTLOADER=test/UART_Bootloader.elf
TSIZE=$(shell arm-none-eabi-size $(BOOTLOADER) | grep UART_Bootloader | awk '{ print $$1 }')
ftest:
	-rm -f "test/Bootloadable Blinking LED_new.cyacd"
	perl ihex2cyacd.pl $(TSIZE) 128 "test/Bootloadable Blinking LED.hex" "test/Bootloadable Blinking LED_new.cyacd"
	diff test/Bootloadable\ Blinking\ LED_new.cyacd test/Bootloadable\ Blinking\ LED.cyacd



# BOOTLOADER1="../examples/CY8CKIT-049-41XX_GPIO_Example/Bootloader_Dependencies/UART_Bootloader.elf"
BOOTLOADER1=test/CY8CKIT-049-41XX_UART_Bootloader.elf 
TSIZE1=$(shell arm-none-eabi-size $(BOOTLOADER1) | grep $(notdir $(BOOTLOADER1)) | awk '{ print $$1 }')
test_gpio:
	-rm -f test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd
	perl ihex2cyacd.pl $(TSIZE1) 128 test/CY8CKIT-049-41XX_GPIO_Example.hex test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd
	diff test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd test/CY8CKIT-049-41XX_GPIO_Example.cyacd	
	diff --strip-trailing-cr test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd test/CY8CKIT-049-41XX_GPIO_Example.cyacd	

# BOOTLOADER2="../examples/CY8CKIT-049-41XX_PWM_Example/Bootloader_Dependencies/UART_Bootloader.elf"
BOOTLOADER2=test/CY8CKIT-049-41XX_UART_Bootloader.elf
TSIZE2=$(shell arm-none-eabi-size $(BOOTLOADER2) | grep $(notdir $(BOOTLOADER2)) | awk '{ print $$1 }')
test_pwm:
	-rm -f test/CY8CKIT-049-41XX_PWM_Example_new.cyacd
	perl ihex2cyacd.pl $(TSIZE2) 128 test/CY8CKIT-049-41XX_PWM_Example.hex test/CY8CKIT-049-41XX_PWM_Example_new.cyacd
	diff test/CY8CKIT-049-41XX_PWM_Example_new.cyacd test/CY8CKIT-049-41XX_PWM_Example.cyacd	
	diff --strip-trailing-cr test/CY8CKIT-049-41XX_PWM_Example_new.cyacd test/CY8CKIT-049-41XX_PWM_Example.cyacd	


# BOOTLOADER3="../examples/CY8CKIT-049-41XX_UART_Example/Bootloader_Dependencies/UART_Bootloader.elf"
BOOTLOADER3=test/CY8CKIT-049-41XX_UART_Bootloader.elf
TSIZE3=$(shell arm-none-eabi-size $(BOOTLOADER3) | grep $(notdir $(BOOTLOADER3)) | awk '{ print $$1 }')
test_uart:
	-rm -f test/CY8CKIT-049-41XX_UART_Example_new.cyacd
	perl ihex2cyacd.pl $(TSIZE3) 128 test/CY8CKIT-049-41XX_UART_Example.hex test/CY8CKIT-049-41XX_UART_Example_new.cyacd
	diff test/CY8CKIT-049-41XX_UART_Example_new.cyacd test/CY8CKIT-049-41XX_UART_Example.cyacd	
	diff --strip-trailing-cr test/CY8CKIT-049-41XX_UART_Example_new.cyacd test/CY8CKIT-049-41XX_UART_Example.cyacd	

BOOTLOADER4=test/UART_Bootloader.elf
TSIZE4=$(shell arm-none-eabi-size $(BOOTLOADER4) | grep $(notdir $(BOOTLOADER4)) | awk '{ print $$1 }')
test_blink:
	-rm -f "test/Bootloadable Blinking LED_new.cyacd"
	perl ihex2cyacd.pl $(TSIZE4) 128 "test/Bootloadable Blinking LED.hex" "test/Bootloadable Blinking LED_new.cyacd"
	diff "test/Bootloadable Blinking LED.cyacd" "test/Bootloadable Blinking LED_new.cyacd"
	diff --strip-trailing-cr "test/Bootloadable Blinking LED.cyacd" "test/Bootloadable Blinking LED_new.cyacd"

test5:
	-rm -f "test/test.cyacd"
	perl ihex2cyacd.pl $(TSIZE4) 128 "test/test.hex" "test/test.cyacd"

debug d:
	perl -d ihex2cyacd.pl $(TSIZE1) 128 test/CY8CKIT-049-41XX_GPIO_Example.hex test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd


BOOTLOADER5=test/UART_Bootloader.elf
TSIZE5=$(shell arm-none-eabi-size $(BOOTLOADER5) | grep $(notdir $(BOOTLOADER5)) | awk '{ print $$1 }')
new:
	perl new.pl $(TSIZE5) 128 "test/test.hex" "test/test.cyacd"


# Creates .cyacd all the way from .elf, and flash
BOOTLOADERFT=test/CY8CKIT-049-41XX_UART_Bootloader.elf
TSIZEFT=$(shell arm-none-eabi-size $(BOOTLOADERFT) | grep $(notdir $(BOOTLOADERFT)) | awk '{ print $$1 }')
flashtest ft:
	-rm -f test/CY8CKIT-049-41XX_GPIO_Example_ft.hex
	arm-none-eabi-objcopy --gap-fill 0x00 -O ihex -v test/CY8CKIT-049-41XX_GPIO_Example_ft.elf test/CY8CKIT-049-41XX_GPIO_Example_ft.hex
	perl ../hex2cyacd/ihex2cyacd.pl $(TSIZEFT) 128 test/CY8CKIT-049-41XX_GPIO_Example_ft.hex test/CY8CKIT-049-41XX_GPIO_Example_ft.cyacd
	../cybootload_linux/cybootload_linux test/CY8CKIT-049-41XX_GPIO_Example_ft.cyacd
	
flash_gpio fg:
	make test_gpio
	../cybootload_linux/cybootload_linux test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd
	
flash_pwm fp:
	make test_pwm
	../cybootload_linux/cybootload_linux test/CY8CKIT-049-41XX_PWM_Example_new.cyacd

flash_uart fu:
	make test_uart
	../cybootload_linux/cybootload_linux test/CY8CKIT-049-41XX_UART_Example_new.cyacd

flash_blink fb:
	make test_blink
	../cybootload_linux/cybootload_linux "test/Bootloadable Blinking LED_new.cyacd"

clean:
	-rm -f test/*_new.cyacd
