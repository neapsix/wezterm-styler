local wezterm = require 'wezterm'

local function get_colors(window)
    local color_scheme = window:effective_config().color_scheme

    -- Use the color_scheme if it's specified, config.colors if it's not
    if color_scheme then
        -- Get colors from a custom color scheme or a built-in color scheme
        return window:effective_config().color_schemes[color_scheme]
            or wezterm.get_builtin_color_schemes()[color_scheme]
    else
        -- Get the colors specified in lua in config.colors
        return window:effective_config().colors
    end
end

local function build_tab_bar(source)
    local active_tab = {
        bg_color = source['selection_bg'],
        fg_color = source['selection_fg'],
    }

    local inactive_tab = {
        bg_color = source['background'],
        fg_color = source.brights[1], -- brights[1]: gray
    }

    return {
        background = source['background'],
        active_tab = active_tab,
        inactive_tab = inactive_tab,
        inactive_tab_hover = active_tab,
        new_tab = inactive_tab,
        new_tab_hover = active_tab,
        inactive_tab_edge = source.brights[1], -- (Fancy tab bar only)
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

    -- Check whether we have the colors we need in the definitions
    local must_have_keys = {'background', 'selection_bg', 'selection_fg', 'brights'}

    for _, v in ipairs(must_have_keys) do
        if not colors_to_match[v] then return end
    end

    -- TODO: Check whether config.colors.tab_bar.* or config.window_frame.* is already specified; don't clobber existing config

    -- Populate colors and window frame tables from the colors_to_match table
    local tab_bar = build_tab_bar(colors_to_match)
    local window_frame = build_window_frame(colors_to_match)

    -- Get any config overrides that are already specified
    local overrides = window:get_config_overrides() or {}

    -- Add config override to change the tab colors
    overrides.colors.tab_bar = tab_bar

    -- If using fancy tabs, change the colors that are in window_frame too
    if window:effective_config().use_fancy_tab_bar then
        overrides.window_frame = window_frame
    end

    window:set_config_overrides(overrides)
end


wezterm.on('window-config-reloaded', function(window, pane)
    override_colors(window)
end)

