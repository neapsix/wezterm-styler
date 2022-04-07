# wezterm-styler

Changes the colors of the tabs in [WezTerm](https://wezfurlong.org/wezterm/index.html) to match your selected color scheme or the colors defined in your configuration file.

## Installation

Add `wezterm-styler.lua` to the same directory as your `wezterm.lua` configuration file.

## Usage

Add the following line to your `wezterm.lua` configuration above the `return` block:

```lua
require 'wezterm-styler'
```
Colors for the tab bar are determined using the values for `background`, `selection_bg`, `selection_fg`, and ANSI gray (the first color in `brights`).

## License
[MIT](https://choosealicense.com/licenses/mit/)
