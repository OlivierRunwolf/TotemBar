# TotemBar

A simple 4-slot totem bar for Shamans in **WoW Forever** (client 1.60, interface 16001).

> This is the `forever` branch. For TBC Anniversary, use the `anniversary` branch / the `-anniversary` releases.
 Pick one totem per element, bind a key per slot, cast with one press.

## Features

- Four element slots: Fire, Earth, Air, Water
- Right-click a slot to pick which totem goes in it (icons + element-colored menu)
- Per-slot keybinds in **Esc → Key Bindings → Totem Bar**
- Shift-drag the bar to move it
- Shift + mouse-wheel over the bar to scale it (or `/tb scale 0.8`)
- Named templates: save your PvP/PvE/farm sets and swap with one command
- Optional Masque support — skin the bar with your favorite button theme
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
| `/tb scale <n>` | Set bar scale (0.4–2.5). Also: Shift + mouse-wheel over the bar |
| `/tb save <name>` | Save the current 4 totems as a named template |
| `/tb load <name>` | Apply a saved template |
| `/tb list` | List saved templates |
| `/tb delete <name>` | Delete a saved template |
| `/tbar`, `/tb` | Aliases |

Templates are per-character (stored in saved variables) and case-sensitive — `PvP` and `pvp` are distinct.

## Limitations

- No one-button-cast-all from the addon itself (WoW requires one hardware event per cast). WoW Forever has its own built-in Call of the Elements / Ancestors / Spirits spells for that; TotemBar is for casting single totems.
- Fire Nova Totem and Tranquil Air Totem are still listed. Some beta guides say Forever removed them. If they were removed, they stay greyed out in the menu.

## License

MIT — see `LICENSE`.
