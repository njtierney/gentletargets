# The whole course in miniature

One file per chapter, showing what `toad-analysis/` looks like at the end of it. Sketches rather than working code, so you can see the shape of the eight chapters without reading eight chapters.

The point of reading these in order is that **chapter 2's script is chapter 4's pipeline with six characters added per line**. Everything after that is the same idea getting more load.

| File                  | Chapter | What changed                               |
|-----------------------|---------|--------------------------------------------|
| `01-flat-script.R`    | 1       | Everything in one file. This is what they  |
|                       |         | are given.                                 |
|-----------------------|---------|--------------------------------------------|
| `02-functions.R`      | 2       | Same work, as named calls. Bodies move to  |
|                       |         | `R/`.                                      |
|-----------------------|---------|--------------------------------------------|
| —                     | 3       | Debugging changes no code.                 |
|-----------------------|---------|--------------------------------------------|
| `04-first-pipeline.R` | 4       | The same calls, wrapped in `tar_assign()`. |
|-----------------------|---------|--------------------------------------------|
| `05-deeper.R`         | 5       | File targets, a report, validation.        |
|-----------------------|---------|--------------------------------------------|
| `06-branching.R`      | 6       | Twelve species. Branching, then a          |
|                       |         | controller.                                |
|-----------------------|---------|--------------------------------------------|
| `07-geotargets.R`     | 7       | Rasters arrive. `tar_terra_rast()`.        |
|-----------------------|---------|--------------------------------------------|
| `08-production.R`     | 8       | What it looks like organised, with         |
|                       |         | `packages.R` and section comments.         |
|-----------------------|---------|--------------------------------------------|

Conventions follow the targets skill: verbs in `R/`, nouns in the plan, one call per target, piped `|> tar_target()`, files as `format = "file"`, writers return paths.
