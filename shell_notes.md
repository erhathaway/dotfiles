/dev/null 2>&1 &

long-running-command
[Ctrl+Z]
bg

# hack to fix fan bug
echo level 1 > /proc/acpi/ibm/fan && echo level 0 > /proc/acpi/ibm/fan
