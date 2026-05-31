-- nvim-surround — wrap a selection in delimiters / HTML tags.
--   Wrap with a tag:  visual-select → S → t → type tag (`div`, or `a href="#"`) → <CR>
--   Inline vs. own-lines is decided by the SELECTION/MOTION type, NOT a config option.
--   visual_surround forces line_mode when visualmode() == "V", so:
--     charwise  (`v…`, or `yss t` for the whole line)   → <div>text</div>   inline
--     linewise  (`V`+`S`, `gS`, `yS`, `ySS`)            → tags on their own lines
--   For inline tags use `v`/`yss`; avoid the capital / `g`-prefixed "new-line" variants.
--   Re-edit: `cst` change whole tag · `csT` change type, keep attrs · `dst` delete pair
-- * `cst` — change surrounding tag, replacing the whole tag including attributes (`<div class="x">` → retype everything)
-- * `csT` — change only the tag type, keeping attributes
-- * `dst` — delete the surrounding tag pair, leaving the inner text

return {
    "kylechui/nvim-surround",
    config = function()
        require("nvim-surround").setup({})
    end,
}
