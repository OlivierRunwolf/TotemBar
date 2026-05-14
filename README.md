# TotemBar

A simple 4-slot totem bar for Shamans in WoW Classic (TBC / Anniversary / Vanilla). Pick one totem per element, bind a key per slot, cast with one press.

## Features

- Four element slots: Fire, Earth, Air, Water
- Right-click a slot to pick which totem goes in it (icons + element-colored menu)
- Per-slot keybinds in **Esc → Key Bindings → Totem Bar**
- Shift-drag the bar to move it
- Per-character saved settings
- Greys out totems your character doesn't know

## Install

1. Download or clone this repo into your WoW `Interface/AddOns/` folder, keeping the folder name `TotemBar`.
2. Restart WoW (a full client restart, not just `/reload`).
3. At the character-select screen, click **AddOns** and make sure **Totem Bar** is enabled.

## Slash commands

| Command | Description |
|---|---|
| `/totembar` | Show help |
| `/totembar reset` | Reset bar position to center-screen |
| `/tbar`, `/tb` | Aliases |

## Limitations

- No "Call of the Elements" one-button-cast-all. WoW's protected code requires one hardware event per spell cast, so 4 keybinds is the maximum that's possible from an addon.

## License

MIT — see `LICENSE`.
