local wezterm = require 'wezterm'

local function get_colors(window)
    local color_scheme = window:effective_config().color_scheme

    local colors = {}

    -- Use the color_scheme if it's specified, config.colors if it's not
    if color_scheme then
        -- Get colors from a custom color scheme or a built-in color scheme
        colors = window:effective_config().color_schemes[color_scheme]
            or wezterm.get_builtin_color_schemes()[color_scheme]
    else
        -- Get the colors specified in lua in config.colors
        colors = window:effective_config().colors
    end

    -- Fallback colors are from the default color scheme in colors.rs
    local fallback_colors = {
        background = '#000000',
        selection_bg = '#FFFACD',
        selection_fg = '#000000',
        brights = {
            '#858585',
        },
    }

    -- Check whether we have the colors we need in the definitions
    for k, v in pairs(fallback_colors) do
        if not colors[k] then
            -- If not, then we're using the default scheme, so get it from there
            colors[k] = v
        end
    end

    return colors
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

    -- Populate colors and window frame tables from the colors_to_match table
    local tab_bar = build_tab_bar(colors_to_match)
    local window_frame = build_window_frame(colors_to_match)

    -- Get any config overrides that are already specified
    local overrides = window:get_config_overrides() or {}

    -- Set up the overrides table if needed
    if not overrides.colors then
        overrides.colors = {}
    end

    -- Add config override to change the tab colors
    overrides.colors.tab_bar = tab_bar

    -- If using fancy tabs, change the colors that are in window_frame too
    if window:effective_config().use_fancy_tab_bar then
        overrides.window_frame = window_frame
    end

    window:set_config_overrides(overrides)
end


wezterm.on('window-config-reloaded', function(window)
    override_colors(window)
end)
