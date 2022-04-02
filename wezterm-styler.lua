local wezterm = require 'wezterm'

local function get_colors(window)
    local color_scheme = window:effective_config().color_scheme

    -- Use the color_scheme if it's specified, config.colors if it's not
    if color_scheme then
        -- Get the color definitions for the color scheme
        return window:effective_config().color_schemes[color_scheme]
            or wezterm.get_builtin_color_schemes()[color_scheme]
    else
        -- Get the colors specified in lua in config.colors
        return window:effective_config().colors
    end
end

local function build_colors(source)
    local active_tab = {
        bg_color = source['selection_bg'],
        fg_color = source['selection_fg'],
    }

    local inactive_tab = {
        bg_color = source['background'],
        fg_color = source.brights[1], -- brights[0]: gray
    }

    return {
        tab_bar = {
            background = source['background'],
            active_tab = active_tab,
            inactive_tab = inactive_tab,
            inactive_tab_hover = active_tab,
            new_tab = inactive_tab,
            new_tab_hover = active_tab,
            inactive_tab_edge = source.brights[1], -- (Fancy tab bar only)
        }
    }
end

local function build_window_frame(source)
    return {
        active_titlebar_bg = source['background'],
        inactive_titlebar_bg = source['background'],
    }
end

local function override_colors(window)
    -- Get the current colors
    local colors_to_match = get_colors(window)

    if not colors_to_match then
        return
    end

    -- TODO: Check whether we have the colors we need in the definitions (background, gray, selection, selection foreground)

    -- Populate colors and window frame tables from the colors_to_match table
    local colors = build_colors(colors_to_match)
    local window_frame = build_window_frame(colors_to_match)

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
    --[[ local color_scheme = window:effective_config().color_scheme
    local color_scheme_dirs = window:effective_config().color_scheme_dirs
    if color_scheme then
        wezterm.log_info(get_color_scheme_path(color_scheme, color_scheme_dirs))
    else
        wezterm.log_info(window:effective_config().colors)
    end ]]
    override_colors(window)
end)

