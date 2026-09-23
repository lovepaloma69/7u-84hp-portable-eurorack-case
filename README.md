# Eurorack 84HP / 7U — Removable Mounting System

Custom, 3D-printed mounting hardware that holds a **7U × 84HP Eurorack frame**
(~440 mm × 311 mm) removably inside a transport / tool case — and, in progress,
inside a wooden rack case. Everything is modeled parametrically in **OpenSCAD**
and verified against the real frame geometry with **trimesh** cross-sections
(no "just print and see" — parts are checked against measured geometry first).

**Designed to fit:** the **RGC Cases 170/48H184** polypropylene case —
<https://rgcases.com/cases-in-polypropylene/170-48h184.html> — which this whole
mounting system is dimensioned around.

> This project is an **accessory** built on top of **kowend's** open Eurorack
> case design (see [Credits & Source](#credits--source)). This repository
> contains **only my own original work** — brackets, rails/profiles, spacer,
> snap latch, clip and holders. It does **not** redistribute kowend's STL / CAD
> / image files; get those from the original project.

## Components

| File | Part | Notes |
|------|------|-------|
| `openscad/bracket.scad` | Rail bracket, split into 3 printable segments | References kowend's body STL at build time (see [Setup](#setup--build)) — the STL is not shipped here |
| `openscad/case_holder.scad` | Short-wall rails/profiles, snap latch, flex clip | Firm side (rigid snap, wide neck) + release side (support-only + flex-arm profiles) |
| `openscad/spacer.scad` | Long-wall spacer | 100 × 11 × 11 mm strip; fills the gap between the cover underside and the rail |
| `openscad/wood_holder.scad` | Wooden-case holder | Work in progress |
| `openscad/assembly_explainer.scad`, `openscad/install_context_preview.scad` | Assembly / install visualizations | |
| `analysis/*.py` | Geometry analysis (trimesh + matplotlib) | Cross-sections & measurements used to fit the parts |

## Printed parts (`openscad/export/`)

Ready-to-print STLs for the **original** parts:
`profil*.stl`, `spacer.stl`, `wood_holder.stl`, `flex_clip.stl`.

The **bracket segments** are derived from kowend's model and are therefore
**not** included — regenerate them from `bracket.scad` after obtaining kowend's
STL (see below).

## Setup / Build

1. Install **OpenSCAD** (tested with 2021.01).
2. `bracket.scad` imports kowend's body geometry. Download the corresponding
   STL from the [original project](https://github.com/kowend/Eurorack_84HP_7U_case)
   and place it at:
   ```
   printables/variant1/variant1_body0_local.stl
   ```
3. Export a part, e.g. the toothed profile:
   ```bash
   openscad -D render_part=1 -D with_teeth=true \
     -o export/profil_zaehne.stl case_holder.scad
   ```
4. Verify a part's real dimensions (optional):
   ```bash
   python -c "import trimesh; m=trimesh.load('export/spacer.stl'); print(m.bounds[1]-m.bounds[0])"
   ```

## Print settings

- **Printer:** Bambu Lab A1 Mini
- **Material:** PETG
- **Orientation matters** for the flexing/snap features: the snap latch uses a
  *rigid* arm with a wide neck (push-to-open by tilting the frame flange), and
  the flex clip prints **upright** so it flexes in-plane rather than across
  layer lines. Teeth print flat (across layers) for strength.

## Contributing

**Collaboration and further development of the design are explicitly welcome!**
Feel free to open an [issue](../../issues) for ideas, problems or measurements,
or send a [pull request](../../pulls) with improvements, new variants or
adaptations to other cases. Remixes and forks are encouraged — within the
non-commercial terms of the license below.

## Credits & Source

Frame and case design: **kowend — _Eurorack 84HP 7U case_** —
<https://github.com/kowend/Eurorack_84HP_7U_case>

This project is a derivative *accessory* for that frame. All frame CAD, STL and
image files belong to kowend and are intentionally **not** included in this
repository — please obtain them from the link above.

## License

The original files in this repository are licensed under
**Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**
(see [`LICENSE`](LICENSE)). You are free to use, modify and further develop the
work and share your versions — **as long as you give credit and do not use it
for commercial purposes**.

This covers *my* files only. The underlying Eurorack frame is kowend's work and
is not included here; refer to the
[original project](https://github.com/kowend/Eurorack_84HP_7U_case) for its
terms.
