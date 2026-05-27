# Sources index — Eclipse 2025.4 manuals

## Primary sources (verbatim extractions)

| File | What it is | Coverage |
|------|-----------|----------|
| `td-ch-dual-porosity.txt` | Eclipse Technical Description, Chapter 2 "Dual porosity", pp.100-124 | physics, math, gravity drainage, viscous displacement, integrated Pc, keyword summary table |
| `td-ch-dual-porosity-part2.txt` | TD chapter cont., pp.125-131 | discretized matrix (Russian doll), Eclipse 300 partitioning, single-medium conductive fractures |
| `td-ch-multi-porosity.txt` | TD Chapter 2 "Multi porosity", pp.132-138 | Eclipse 300 N>2 matrix porosities, NMATRIX, examples |
| `refman-keywords.txt` | Eclipse Reference Manual — full keyword pages for 33 DP/DK keywords | syntax, units, defaults, section, example, exclusions |

## Path to the manuals
`/mnt/c/ecl/2025.4/manuals/`
- `EclipseTechnicalDescription.pdf` — 1066 pages (physics + math)
- `EclipseReferenceManual.pdf` — 2305+ pages (keyword syntax)
- `EclipseUserGuide.pdf` — workflow examples (not yet sampled here)
- `bookshelf.pdf` — index of all manuals

## Re-extraction (if Eclipse version changes)
The scripts that produced these files:
- `/tmp/eclpdf_toc.py`     — dumps the TOC of a PDF
- `/tmp/eclpdf_search.py`  — finds pages containing keywords
- `/tmp/eclpdf_kwfind.py`  — locates keyword anchor pages by bookmark
- `/tmp/eclpdf_extract.py` — extracts a page range to text
- `/tmp/eclpdf_kw_extract.py` — extracts the keyword pages used in `refman-keywords.txt`

Requires Python 3 + PyMuPDF (`pip install pymupdf`).

## Keyword anchor pages (Reference Manual)
For quick navigation back into the PDF:

| Keyword | Anchor page | Section |
|---------|-------------|---------|
| DUALPORO | 699 | RUNSPEC |
| DUALPERM | 698 | RUNSPEC |
| GRAVDR | 995 | RUNSPEC |
| GRAVDRM | 997 | RUNSPEC |
| GRAVDRB | 996 | RUNSPEC |
| NMATRIX | 1465 | RUNSPEC |
| SIGMA | 2119 | GRID |
| SIGMAV | 2125 | GRID |
| SIGMAGD | 2120 | GRID |
| SIGMAGDV | 2122 | GRID |
| MULTSIG | 1418 | GRID |
| MULTSIGV | 1419 | GRID |
| MULSGGD | 1385 | GRID |
| LTOSIGMA | 1302 | GRID |
| LX / LY / LZ | 1321 / 1324 / 1327 | GRID |
| DZMTRX / DZMTRXV | 715 / 716 | GRID |
| NMATOPTS | 1463 | GRID |
| DPGRID | 673 | GRID |
| DPNUM | 676 | GRID |
| NODPPM | 1480 | GRID |
| PERMMF | 1710 | GRID |
| MULTMF | 1399 | GRID |
| BTOBALFA / BTOBALFV | 443 / 444 | GRID |
| DIFFDP | 642 | RUNSPEC |
| DIFFMMF | 643 | GRID, SCHEDULE |
| INTPC | 1190 | PROPS |
| DPKRMOD | 674 | PROPS |
| KRNUMMF | 1219 | REGIONS |
| IMBNUMMF | 1174 | REGIONS |
| ROCKSPLV | 1908 | GRID |
