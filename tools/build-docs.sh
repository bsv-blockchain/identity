#!/usr/bin/env bash
# Regenerate the PDF and EPUB editions of the identity papers from their
# markdown sources.
#
#   tools/build-docs.sh                       rebuild documents whose source changed
#   tools/build-docs.sh --all                 rebuild everything
#   tools/build-docs.sh --pdf | --epub        restrict to one format
#   tools/build-docs.sh --check               exit 1 if any output is stale (CI / hooks)
#   tools/build-docs.sh --watch               rebuild on save until interrupted
#   tools/build-docs.sh --install-hook        install a git pre-commit hook
#   tools/build-docs.sh whitepaper.md [...]   rebuild just these
#
# PDF:  pandoc markdown -> typst, tools/template.typ for layout, typst compiles.
# EPUB: pandoc markdown -> epub3, tools/epub.css for styling.
# Outputs land in pdf/ and epub/. Staleness is keyed on the SHA-256 of the
# markdown plus every build input -- including diagrams/, which the papers
# embed -- not on mtime, so a fresh clone or a touch does not trigger a
# rebuild while a real edit always does.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
ROOT=$PWD
TOOLS=$ROOT/tools
CACHE=$TOOLS/.build-cache
PDF_DIR=$ROOT/pdf
EPUB_DIR=$ROOT/epub

# Rendered mermaid diagrams, content-addressed by tools/mermaid.lua.
export MERMAID_CACHE=$CACHE/mermaid
export MERMAID_CONFIG=$TOOLS/mermaid.json

# README.md is repo furniture, not a paper.
DOCS=(whitepaper.md technical-whitepaper.md summary.md zk-proofs-and-poc.md)

die() { echo "error: $*" >&2; exit 2; }
usage() { sed -n '2,11p' "${BASH_SOURCE[0]}" | sed 's/^#\{1,\} \{0,1\}//'; exit "${1:-0}"; }

FORMATS=(pdf epub)

require() {
  command -v pandoc >/dev/null || die "pandoc not found (brew install pandoc)"
  # mmdc is only needed by documents that actually carry a mermaid block.
  # (targets is empty on the --install-hook path, which needs no renderer.)
  if (( ${#targets[@]} )) && grep -q '^```mermaid' "${targets[@]}"; then
    command -v mmdc >/dev/null || die "mmdc not found (npm i -g @mermaid-js/mermaid-cli)"
  fi
  for f in pdf; do
    [[ " ${FORMATS[*]} " == *" $f "* ]] && { command -v typst >/dev/null || die "typst not found (brew install typst)"; }
  done
  for f in "$TOOLS/template.typ" "$TOOLS/frontmatter.lua" "$TOOLS/figures.lua" \
           "$TOOLS/mermaid.lua" "$TOOLS/mermaid.json" "$TOOLS/epub.css"; do
    [[ -f $f ]] || die "missing build input: ${f#"$ROOT"/}"
  done
}

# Every input that can change an output participates in the fingerprint. The
# figures are shared by several papers, so any diagram edit restages them all.
fingerprint() {
  cat "$1" "$TOOLS/template.typ" "$TOOLS/frontmatter.lua" "$TOOLS/figures.lua" \
      "$TOOLS/mermaid.lua" "$TOOLS/mermaid.json" "$TOOLS/epub.css" \
      "${BASH_SOURCE[0]}" "$ROOT"/diagrams/*.svg | shasum -a 256 | cut -d' ' -f1
}

outfile() { # outfile <format> <doc.md>
  local name=${2%.md}
  case $1 in
    pdf)  echo "$PDF_DIR/$name.pdf" ;;
    epub) echo "$EPUB_DIR/$name.epub" ;;
    *)    die "unknown format: $1" ;;
  esac
}

outputs() {
  for f in "${FORMATS[@]}"; do outfile "$f" "$1"; done
}

stale() {
  local md=$1 stamp=$CACHE/${1%.md}.sha256
  [[ -f $stamp ]] || return 0
  while read -r out; do [[ -f $out ]] || return 0; done < <(outputs "$md")
  [[ "$(cat "$stamp")" != "$(fingerprint "$md")" ]]
}

# Front matter (H1 title, the optional H3 subtitle beneath it, the bold
# Status/Editors block) is lifted into the PDF title block and the EPUB
# metadata; frontmatter.lua strips it from the body so it is not typeset twice.
#
# Only whitepaper.md and zk-proofs-and-poc.md lack a subtitle, so the H3 is
# read positionally rather than by first match -- a body heading must never be
# mistaken for one. The Status lines run to changelog length; the title block
# takes only the version, the clause before the first em dash or middot.
meta() {
  case $2 in
    title)    grep -m1 '^# ' "$1" | sed 's/^# *//' ;;
    subtitle) awk 'NR<=4 && /^### / { sub(/^### */, ""); print; exit }' "$1" ;;
    status)   python3 -c '
import re, sys
line = next((l for l in open(sys.argv[1], encoding="utf-8")
             if l.startswith("**Status:**")), "")
short = re.split(r" [\u2014\u00b7] ", line[len("**Status:**"):].strip())[0]
print(re.sub(r"\*\*", "", short)[:90].strip())' "$1" ;;
    editors)  sed -n 's/^\*\*Editors:\*\* *//p' "$1" | head -1 | sed 's/\*\*//g; s/ *$//' ;;
  esac
}

# typst string literal: backslash and double quote are the only escapes needed.
typstr() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

pandoc_common=(--from=markdown+smart --wrap=preserve)

build_pdf() {
  local md=$1 tmp=$2 out; out=$(outfile pdf "$1")
  pandoc "$md" "${pandoc_common[@]}" --to=typst \
    --lua-filter="$TOOLS/frontmatter.lua" --lua-filter="$TOOLS/figures.lua" \
    --lua-filter="$TOOLS/mermaid.lua" \
    --output="$tmp/body.typ" 2>"$tmp/err"

  # typst resolves image paths against the file being compiled, and that file
  # lives in a temp dir while diagrams/ does not. Absolutize them; --root /
  # below is what makes an absolute path acceptable to typst.
  sed 's|image("diagrams/|image("'"$ROOT"'/diagrams/|g' "$tmp/body.typ" > "$tmp/body.abs" \
    && mv "$tmp/body.abs" "$tmp/body.typ"

  # The body is inlined rather than #include-d: a typst module does not inherit
  # the importing file's scope, so an included body could not see the
  # template's helpers (pandoc emits #horizontalrule, defined there).
  {
    cat <<TYP
#import "$TOOLS/template.typ": *
#show: paper.with(
  title:    "$(typstr "$(meta "$md" title)")",
  subtitle: "$(typstr "$(meta "$md" subtitle)")",
  status:   "$(typstr "$(meta "$md" status)")",
  editors:  "$(typstr "$(meta "$md" editors)")",
)

TYP
    cat "$tmp/body.typ"
  } > "$tmp/main.typ"

  mkdir -p "$PDF_DIR"
  typst compile --root / "$tmp/main.typ" "$out" 2>"$tmp/err"
}

build_epub() {
  local md=$1 tmp=$2 out; out=$(outfile epub "$1")
  mkdir -p "$EPUB_DIR"
  pandoc "$md" "${pandoc_common[@]}" --to=epub3 \
    --lua-filter="$TOOLS/frontmatter.lua" --lua-filter="$TOOLS/figures.lua" \
    --lua-filter="$TOOLS/mermaid.lua" \
    --css="$TOOLS/epub.css" \
    --toc --toc-depth=3 \
    --split-level=2 \
    --metadata=title:"$(meta "$md" title)" \
    --metadata=subtitle:"$(meta "$md" subtitle)" \
    --metadata=description:"$(meta "$md" subtitle) ($(meta "$md" status))" \
    --metadata=creator:"$(meta "$md" editors)" \
    --metadata=lang:en-GB \
    --output="$out" 2>"$tmp/err"
}

build() {
  local md=$1 name=${1%.md} tmp built=()
  tmp=$(mktemp -d)
  printf '  %-28s ' "$md"

  for f in "${FORMATS[@]}"; do
    if ! "build_$f" "$md" "$tmp"; then
      echo "FAILED ($f)"
      sed 's/^/    /' "$tmp/err" >&2 || true
      rm -rf "$tmp"
      return 1
    fi
    # Warnings deserve surfacing even on success (glyph fallback, overflow).
    if [[ -s $tmp/err ]]; then
      printf '\n    [%s] ' "$f"; sed 's/^/    /' "$tmp/err" >&2
    fi
    built+=("$f $(du -h "$(outfile "$f" "$md")" | cut -f1 | tr -d ' ')")
  done

  mkdir -p "$CACHE"
  fingerprint "$md" > "$CACHE/$name.sha256"
  echo "ok  ${built[*]}"
  rm -rf "$tmp"
}

install_hook() {
  # --git-common-dir rather than $ROOT/.git: in a worktree that path is a file,
  # and hooks run from the shared git dir, not the per-worktree one.
  local gitdir hook
  gitdir=$(git -C "$ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
    || die "not a git repository"
  hook=$gitdir/hooks/pre-commit
  mkdir -p "$gitdir/hooks"
  if [[ -e $hook ]] && ! grep -q build-docs.sh "$hook"; then
    die "$hook exists and is not ours; add this line to it yourself: tools/build-docs.sh"
  fi
  cat > "$hook" <<'HOOK'
#!/usr/bin/env sh
# Rebuild any stale PDF/EPUB and stage it alongside the markdown edit.
set -e
tools/build-docs.sh
git add -A pdf epub 2>/dev/null || true
HOOK
  chmod +x "$hook"
  echo "installed .git/hooks/pre-commit"
  echo "PDFs and EPUBs now rebuild and stage themselves on every commit."
}

main() {
  local mode=changed targets=() only=()
  for arg in "$@"; do
    case $arg in
      --all|--force)  mode=all ;;
      --check)        mode=check ;;
      --watch)        mode=watch ;;
      --pdf)          only+=(pdf) ;;
      --epub)         only+=(epub) ;;
      --install-hook) require; install_hook; exit 0 ;;
      -h|--help)      usage ;;
      -*)             echo "unknown option: $arg" >&2; usage 2 ;;
      *)              targets+=("$arg"); mode=all ;;
    esac
  done
  (( ${#only[@]} )) && FORMATS=("${only[@]}")
  (( ${#targets[@]} )) || targets=("${DOCS[@]}")

  require
  for md in "${targets[@]}"; do [[ -f $md ]] || die "$md not found"; done
  mkdir -p "$MERMAID_CACHE"

  case $mode in
    check)
      local stale_list=()
      for md in "${targets[@]}"; do stale "$md" && stale_list+=("$md") || true; done
      if (( ${#stale_list[@]} )); then
        echo "stale: ${stale_list[*]}" >&2
        echo "run tools/build-docs.sh" >&2
        exit 1
      fi
      echo "all outputs current (${FORMATS[*]})"
      ;;
    watch)
      echo "watching ${#targets[@]} document(s) for ${FORMATS[*]}, ctrl-c to stop"
      while :; do
        for md in "${targets[@]}"; do
          if stale "$md"; then echo "changed: $md"; build "$md" || true; fi
        done
        sleep 2
      done
      ;;
    *)
      echo "building (${FORMATS[*]}):"
      local n=0
      for md in "${targets[@]}"; do
        if [[ $mode == all ]] || stale "$md"; then build "$md"; n=$((n+1)); fi
      done
      (( n )) || echo "  (nothing stale)"
      ;;
  esac
}

main "$@"
