# Auto-discover and source all module files
# Finds all .sh files in modules directory except module_master.sh
for module in ./modules/*.sh; do
    # Skip module_master.sh itself
    if [[ "$(basename "$module")" != "module_master.sh" ]]; then
        source "$module"
    fi
done