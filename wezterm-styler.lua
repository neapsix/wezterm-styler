local wezterm = require 'wezterm'

local function debug_stuff(window)
    wezterm.log_info('Current Color Scheme: ' .. window:effective_config().color_scheme)

    --[[ wezterm.log_info('List of builtin color schemes:')
    for name, scheme in pairs(wezterm.get_builtin_color_schemes()) do
        if name == 'rose-pine' then
            wezterm.log_info(name)
        end
    end ]]

    wezterm.log_info('Color scheme dirs:')
    wezterm.log_info(window:effective_config().color_scheme_dirs)

    wezterm.log_info('Files in default colors dir:')
    for _, v in ipairs(wezterm.read_dir(wezterm.config_dir .. '/colors')) do
        wezterm.log_info(v)
    end
end

local function get_color_scheme_path(color_scheme, color_scheme_dirs)
    if color_scheme_dirs then
        -- Search through directories in color_scheme_dirs option if specified
        for _, directory in ipairs(color_scheme_dirs) do
            -- In each directory, search through files
            for _, filepath in ipairs(wezterm.read_dir(directory)) do
                -- If one of the files is our color scheme, return its path
                if filepath == directory .. color_scheme .. '.toml' then
                    return filepath
                end
            end
        end
    end

    -- Search through files in the default colors directory
    for _, filepath in ipairs(wezterm.read_dir(wezterm.config_dir .. '/colors')) do
        -- If one of the files is our color scheme, return its path
        if filepath == wezterm.config_dir .. '/colors/' .. color_scheme .. '.toml' then
            return filepath
        end
    end

    -- We didn't find our color scheme :(
    return nil
end

local function read_toml_file(path)
    local content = {}
    -- TODO: Parse color scheme TOML content
    return content
end

local function get_color_scheme_definitions(color_scheme, color_scheme_dirs)
    local color_scheme_definitions = {}

    -- Search through the built-in color schemes
    -- If it's one of those, get the color scheme definitions
    if wezterm.get_builtin_color_schemes()[color_scheme] then
        color_scheme_definitions = wezterm.get_builtin_color_schemes()[color_scheme]
    else
        local path = get_color_scheme_path(color_scheme, color_scheme_dirs)
        color_scheme_definitions = read_toml_file(path)
    end

    return color_scheme_definitions
end

local function override_colors(window)
    -- Get the current colors
    local colors_to_match = {}

    local color_scheme = window:effective_config().color_scheme
    local color_scheme_dirs = window:effective_config().color_scheme_dirs

    if color_scheme then
        -- Get the colors from the color scheme in config.color_scheme
        colors_to_match = get_color_scheme_definitions(color_scheme, color_scheme_dirs)
    else
        -- Get the colors specified in lua in config.colors
        colors_to_match = window:effective_config().colors
    end

    local colors = {}
    local window_frame = {}
    -- TODO: Check whether we have the colors we need in the definitions (background, gray, selection, selection foregrounad)
    -- TODO: Populate colors and window frame tables from the colors_to_match table

    -- Get any config overrides that are already specified
    local overrides = window:get_config_overrides() or {}

    -- Add config override to change the tab colors
    overrides.colors = colors

    -- If using fancy tabs, change the colors that are in window_frame too
    if window:effective_config().use_fancy_tab_bar then
        overrides.window_frame = window_frame
    end

    window:set_config_overrides(overrides)
end


wezterm.on('window-config-reloaded', function(window, pane)
    -- debug_stuff(window)
    local color_scheme = window:effective_config().color_scheme
    local color_scheme_dirs = window:effective_config().color_scheme_dirs
    if color_scheme then
        wezterm.log_info(get_color_scheme_path(color_scheme, color_scheme_dirs))
    else
        wezterm.log_info(window:effective_config().colors)
    end
end)

