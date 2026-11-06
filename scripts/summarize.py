#!/usr/bin/env python3
"""Turn the console output of `make test` into a Markdown results table.

    make test 2>&1 | tee build/test.log
    python3 scripts/summarize.py build/test.log            # print the table
    python3 scripts/summarize.py build/test.log --readme README.md
                                                          # replace the block between
                                                          # <!-- results:begin --> and <!-- results:end -->
"""
import re
import sys

def parse(lines):
    project = None
    rows, legacy, cov, sva = [], {}, {}, {}
    for line in lines:
        m = re.match(r'^== (\S+)', line)
        if m:
            project = m.group(1)
            continue
        m = re.match(r'^LEGACY (\S+) (PASS|FAIL)', line)
        if m:
            legacy.setdefault(project, []).append((m.group(1), m.group(2)))
            continue
        m = re.match(r'^COVERAGE (\S+)\s+([\d.]+)', line)
        if m:
            cov.setdefault(project, []).append((m.group(1), float(m.group(2))))
            continue
        m = re.match(r'^\s+SVA\s+failures=(\d+)', line)
        if m:
            sva[project] = sva.get(project, 0) + int(m.group(1))
            continue
        m = re.match(r'^\s+(\S.*?)\s+checks=(\d+)\s+errors=(\d+)\s+(PASS|FAIL)(.*)$', line)
        if m and project:
            rows.append((project, m.group(1), int(m.group(2)), int(m.group(3)), m.group(4), m.group(5).strip()))
    return rows, legacy, cov, sva

def table(rows, legacy, cov, sva):
    out = ['| Project | Checker | Checks | Errors | Result |', '|---|---|---:|---:|:---:|']
    for p, name, n, e, res, extra in rows:
        note = f' {extra}' if extra.startswith('(') else (f' ({extra})' if extra else '')
        out.append(f'| {p} | {name}{note} | {n:,} | {e} | {"✅" if res == "PASS" else "❌"} |')
    out += ['', '| Project | Course testbenches (Icarus) | Functional coverage | SVA failures |', '|---|---|---|---:|']
    for p in sorted(set(list(legacy) + list(cov))):
        lg = legacy.get(p, [])
        lg_s = f'{sum(r == "PASS" for _, r in lg)}/{len(lg)} pass' if lg else '—'
        cv = cov.get(p, [])
        cv_s = ', '.join(sorted({f'{g} {v:.1f} %' for g, v in cv})) if cv else '—'
        out.append(f'| {p} | {lg_s} | {cv_s} | {sva.get(p, 0)} |')
    return '\n'.join(out) + '\n'

def main():
    lines = open(sys.argv[1], errors='replace').read().splitlines()
    md = table(*parse(lines))
    if '--readme' in sys.argv:
        path = sys.argv[sys.argv.index('--readme') + 1]
        text = open(path).read()
        new = re.sub(r'(<!-- results:begin -->\n).*?(<!-- results:end -->)', lambda m: m.group(1) + md + m.group(2),
                     text, flags=re.S)
        open(path, 'w').write(new)
    else:
        sys.stdout.write(md)

if __name__ == '__main__':
    main()
