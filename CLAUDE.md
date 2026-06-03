# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A LaTeX source tree for a Russian university final qualification thesis (ВКР, ЮЗГУ/SWSU standards), formatted per GOST. The thesis topic is a web system for automated client management for a MikroTik-based internet provider. The prose, comments, and **filenames are in Russian (Cyrillic)** — chapter files like `Анализ.tex`, `ТехПроект.tex`, `РабочийПроект.tex` are referenced by Cyrillic name in `main.tex` and `makefile`. Preserve Cyrillic filenames and `\newcommand` names exactly; the build breaks if they are transliterated.

## Build

```bash
make            # runs: xelatex main.tex (single pass)
```

- **The compiler must be XeLaTeX** (not pdflatex/lualatex) — the class and `setup.tex` rely on `fontspec`/`\setmonofont` and Cyrillic. TexStudio users must select the xelatex compiler.
- A single `xelatex` pass does **not** resolve cross-references, the TOC, or the source list. For a final PDF run `xelatex` 2–3 times (or use `latexmk -xelatex main.tex`) until `main.aux`/`main.toc` stabilize.
- Build artifacts (`main.pdf`, `main.aux`, `main.log`, `main.toc`, `main.out`, `*.fls`, `*.fdb_latexmk`, `main.xdv`) are committed in places but most are git-ignored; do not hand-edit them.

## Document architecture

- `main.tex` — entry point. Sets thesis metadata via `\newcommand` (author, topic, supervisor, etc.) and `\input`s every chapter. It selects one of three **mutually exclusive document modes** by setting exactly one boolean true: `\ВКРtrue` (full diploma), `\Практикаtrue` (internship report), or `\Курсоваяtrue` (coursework). The mode gates which chapters are included via `\ifПрактика`/`\ifВКР` guards — e.g. Введение/Заключение/Код are skipped for practice reports.
- `setup.tex` — the entire preamble: `\documentclass{vkr}`, all packages, GOST caption formats (`Рисунок N`, `Таблица N` with `~--~` separator), custom tabular column types (`T`/`R`/`C`/`r`), listing setup with Cyrillic-comment support, and helper macros. Add packages and global formatting here, not in chapter files.
- `vkr.cls` — custom class implementing SWSU/GOST page geometry, fonts, headings, the three mode booleans (`\ifВКР` etc.), title-page layout, and counters. This is the formatting engine; change it only when GOST layout itself must change.
- `xltabular.sty` — vendored package for long tables spanning pages.
- Chapter `.tex` files (`Введение`, `Реферат`, `Анализ`, `ТехЗадание`, `ТехПроект`, `РабочийПроект`, `Заключение`, `СписокИсточников`, `Обозначения`, `ЛистЗадания`, `Плакаты`, `Код`, title pages) — content only; rely on macros from `setup.tex`/`vkr.cls`.

When adding a new chapter file, register it in **both** `main.tex` (an `\input`, inside the correct mode guard) and the `src=` list in `makefile`.

## Figures and diagrams

- `images/` holds figures. Convention (see README): **EPS** for schematic diagrams/posters, **PNG** for screenshots.
- Architecture diagrams are authored in **D2** (`images/*.d2`) and compiled to PNG/PDF. Regenerate after editing a `.d2`:
  ```bash
  cd images && ./render_png.sh     # d2 → PNG (used by the document)
  cd images && ./render_all.sh     # d2 → PDF (preview)
  ```
  Both scripts hardcode `/home/novox/.local/bin/d2` and a fixed list of diagram names — add new diagrams to that list. `\graphicspath{{images/}}` means `\includegraphics` references are relative to `images/`.
- `Код.tex` appends source listings via `\lstinputlisting{...}` of the `.tex` sources themselves.

## Linting

`check/vkr.pl` is a Perl checker for GOST list/formatting rules in `.tex` files:

```bash
perl check/vkr.pl Анализ.tex      # check one chapter
```

`check/vkr` is a helper that clones a repo to `/tmp` and runs the checker over every `*.tex` (and opens the PDF in evince) — intended for the upstream class repo, not day-to-day use here.

## Auxiliary tools (not part of the thesis build)

- `lib-server/main.py` — standalone script that parses an order/PDF and emits a `.docx` library form (`python lib-server/main.py <prikaz> <pdf>`); requires `python-docx`.
- `lib-ext/` — a Manifest-V3 Chrome extension ("Добавление в библиотеку") that fills a university library web form.

These are utilities for submitting the work to the library and are unrelated to compiling the thesis.

## Conventions

- Em dash: type `-\-` (renders `--`/`—`). Russian guillemets `«…»` for quotes; nested quotes use `\textquotedbl` with the trailing space escaped (`\textquotedbl\ `). See README for examples.
- Custom tabular columns from `setup.tex`: `T` (centered auto-width), `R` (right auto-width), `C{w}` (centered fixed), `r{w}` (right fixed); `\centrow` centers a single cell. Long DB-field/URL strings use `\dbfield{}`, `\dbtype{}`, `\route{}` (wrap via `seqsplit`).
