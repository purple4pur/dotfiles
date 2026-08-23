#!/usr/bin/env python3
"""Monospace-align every Markdown table in files, in place (skill §Tables).

Column width = max rendered cell length (min 3); numeric columns right-aligned
(`---:`), text left (`---`); separator row padded with dashes to match column
widths, alignment colons preserved.
Skips fenced code blocks. Idempotent. Cells containing a literal `|` break
row parsing — escape or avoid them.
"""
import sys


def align(text):
    lines = text.split('\n')
    out, i, n = [], 0, len(lines)
    in_fence = False
    while i < n:
        line = lines[i]
        if line.lstrip().startswith('```'):
            in_fence = not in_fence
            out.append(line)
            i += 1
            continue
        if not in_fence and line.startswith('|'):
            block = []
            while i < n and lines[i].startswith('|'):
                block.append(lines[i])
                i += 1
            rows = [[c.strip() for c in l.strip().strip('|').split('|')] for l in block]
            aligns = ['right' if s.endswith(':') else 'left' for s in rows[1]]
            ncols = max(len(r) for r in rows)
            rows = [r + [''] * (ncols - len(r)) for r in rows]
            widths = [max(max(len(r[c]) for r in rows), 3) for c in range(ncols)]
            for ri, r in enumerate(rows):
                if ri == 1:
                    cells = []
                    for c in range(ncols):
                        w, al = widths[c], aligns[c]
                        cells.append(('-' * (w - 1) + ':') if al == 'right' else '-' * w)
                    out.append('| ' + ' | '.join(cells) + ' |')
                else:
                    cells = []
                    for c in range(ncols):
                        cell, w, al = r[c], widths[c], aligns[c]
                        cells.append((' ' * (w - len(cell)) + cell) if al == 'right'
                                     else cell + ' ' * (w - len(cell)))
                    out.append('| ' + ' | '.join(cells) + ' |')
        else:
            out.append(line)
            i += 1
    return '\n'.join(out)


def main():
    if len(sys.argv) < 2:
        print('usage: align_tables.py <file.md> [...]', file=sys.stderr)
        sys.exit(1)
    for f in sys.argv[1:]:
        orig = open(f).read()
        new = align(orig)
        if new != orig:
            open(f, 'w').write(new)
            print('aligned:', f)
        else:
            print('unchanged:', f)


if __name__ == '__main__':
    main()
