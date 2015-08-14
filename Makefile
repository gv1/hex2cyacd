all: test1 test2 test3 test4

BOOTLOADER=test/UART_Bootloader.elf
TSIZE=$(shell arm-none-eabi-size $(BOOTLOADER) | grep UART_Bootloader | awk '{ print $$1 }')
ftest:
	-rm -f "test/Bootloadable Blinking LED_new.cyacd"
	perl ihex2cyacd.pl $(TSIZE) 128 "test/Bootloadable Blinking LED.hex" "test/Bootloadable Blinking LED_new.cyacd"
	diff test/Bootloadable\ Blinking\ LED_new.cyacd test/Bootloadable\ Blinking\ LED.cyacd



# BOOTLOADER1="../examples/CY8CKIT-049-41XX_GPIO_Example/Bootloader_Dependencies/UART_Bootloader.elf"
BOOTLOADER1=test/CY8CKIT-049-41XX_UART_Bootloader.elf 
TSIZE1=$(shell arm-none-eabi-size $(BOOTLOADER1) | grep $(notdir $(BOOTLOADER1)) | awk '{ print $$1 }')
test1:
	-rm -f test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd
	perl ihex2cyacd.pl $(TSIZE1) 128 test/CY8CKIT-049-41XX_GPIO_Example.hex test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd
	diff --strip-trailing-cr test/CY8CKIT-049-41XX_GPIO_Example_new.cyacd test/CY8CKIT-049-41XX_GPIO_Example.cyacd	

# BOOTLOADER2="../examples/CY8CKIT-049-41XX_PWM_Example/Bootloader_Dependencies/UART_Bootloader.elf"
BOOTLOADER2=test/CY8CKIT-049-41XX_UART_Bootloader.elf
TSIZE2=$(shell arm-none-eabi-size $(BOOTLOADER2) | grep $(notdir $(BOOTLOADER2)) | awk '{ print $$1 }')
test2:
	-rm -f test/CY8CKIT-049-41XX_PWM_Example_new.cyacd
	perl ihex2cyacd.pl $(TSIZE2) 128 test/CY8CKIT-049-41XX_PWM_Example.hex test/CY8CKIT-049-41XX_PWM_Example_new.cyacd
	diff --strip-trailing-cr test/CY8CKIT-049-41XX_PWM_Example_new.cyacd test/CY8CKIT-049-41XX_PWM_Example.cyacd	


# BOOTLOADER3="../examples/CY8CKIT-049-41XX_UART_Example/Bootloader_Dependencies/UART_Bootloader.elf"
BOOTLOADER3=test/CY8CKIT-049-41XX_UART_Bootloader.elf
TSIZE3=$(shell arm-none-eabi-size $(BOOTLOADER3) | grep $(notdir $(BOOTLOADER3)) | awk '{ print $$1 }')
test3:
	-rm -f test/CY8CKIT-049-41XX_UART_Example_new.cyacd
	perl ihex2cyacd.pl $(TSIZE3) 128 test/CY8CKIT-049-41XX_UART_Example.hex test/CY8CKIT-049-41XX_UART_Example_new.cyacd
	diff --strip-trailing-cr test/CY8CKIT-049-41XX_UART_Example_new.cyacd test/CY8CKIT-049-41XX_UART_Example.cyacd	

BOOTLOADER4=test/UART_Bootloader.elf
TSIZE4=$(shell arm-none-eabi-size $(BOOTLOADER4) | grep $(notdir $(BOOTLOADER4)) | awk '{ print $$1 }')
test4:
	-rm -f "test/Bootloadable Blinking LED_new.cyacd"
	perl ihex2cyacd.pl $(TSIZE4) 128 "test/Bootloadable Blinking LED.hex" "test/Bootloadable Blinking LED_new.cyacd"
	diff --strip-trailing-cr "test/Bootloadable Blinking LED.cyacd" "test/Bootloadable Blinking LED_new.cyacd"
