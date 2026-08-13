# Reading the prompt

```
┌─ahwoouser@AHWOO-01 …/AhwooClient «task/brand-pages»  MOD:3  STG:1  NEW:2     11:42:44
└─▶
```

Git status spells each state out rather than encoding it in a symbol, since an abstract
glyph can't tell you whether it means untracked or unstaged. Each label also gets its own
colour.

| Label | Meaning | Colour |
| --- | --- | --- |
| `MOD:3` | modified | amber |
| `STG:1` | staged | green |
| `NEW:2` | untracked | blue |
| `DEL:1` | deleted | red |
| `MV:1` | renamed | purple |
| `CONFLICT:1` | conflicted | bold red |
| `STASH:2` | stashed | pale green |
| `↑2` `↓1` | ahead of, behind upstream | blue |

Arrows are the only symbols left, because a direction needs no legend.

Everything else on the line:

| Element | Meaning |
| --- | --- |
| `«branch»` | current branch |
| `+4s` | last command's runtime, shown past 2s only |
| red `─▶` | last command exited non-zero |
| `NODE` / `NET` | only appear in directories with those projects |

## Fonts

Everything renders in stock DejaVu Sans Mono, which mintty ships with, so no Nerd Font is
needed on either OS.

Keeping that true constrains which glyphs the prompt can use. Box Drawing, Latin-1, Arrows
(U+21xx), and Mathematical Operators (U+22xx) are all covered. Dingbats (`✓`, `✘`) and the
U+27Ex angle brackets are not, and mintty silently substitutes them from another font at a
different width, which shifts the rest of the line. If you swap a glyph, pick one from a
covered block.

An earlier Nerd Font prompt (`➜`, `󰊢`, catppuccin colours) is in the history if you want
those glyphs back:

```sh
git log --all -- shell/.config/starship.toml
```

## Claude Code

`claude-config` carries a matching theme and a statusline that mirrors this prompt, so a
terminal and a Claude Code session sitting side by side read the same way. The colours live
in one place per repo, so changing a hex here means changing it there too.
