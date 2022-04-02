# wezterm-styler

Changes the colors of the tabs in [WezTerm](https://wezfurlong.org/wezterm/index.html) to match your terminal color scheme. 

## Usage

Add the following line to your `wezterm.lua` configuration above the `return` block:

```lua
require 'wezterm-styler'
```

Make sure you have a color scheme selected or colors defined in lua. If you use custom colors (not one of the built-in color schemes), your color scheme must include `background`, `selection_bg`, `selection_fg`, and an ANSI Bright Black color (the first color in `brights`).

## License
[MIT](https://choosealicense.com/licenses/mit/)
