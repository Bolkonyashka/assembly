@echo on
set filename=%1
tasm %filename%.asm
tlink /t /x %filename%.obj