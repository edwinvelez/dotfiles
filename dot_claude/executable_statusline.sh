#!/usr/bin/env bash
# Claude Code status line. Reads the session JSON on stdin, prints one line:
#   Opus 5.5 · high │ ctx 23% │ 5h 12% · 7d 4% │ ~$0.42 │ chezmoi main* │ my-desktop
# Fields: https://code.claude.com/docs/en/statusline#available-data

input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }

model=$(j '.model.display_name')
effort=$(j '.effort.level')
ctx=$(j '.context_window.used_percentage')
five=$(j '.rate_limits.five_hour.used_percentage')
week=$(j '.rate_limits.seven_day.used_percentage')
cost=$(j '.cost.total_cost_usd')
dir=$(j '.workspace.current_dir')

dim=$'\e[2m' reset=$'\e[0m'
sep="${dim} │ ${reset}"

# Green under 50%, yellow under 80%, red from 80%.
pct() {
  local n=${1%.*}
  local color=$'\e[32m'
  ((n >= 50)) && color=$'\e[33m'
  ((n >= 80)) && color=$'\e[31m'
  printf '%s%s%%%s' "$color" "$n" "$reset"
}

out="${model:-?}"
[[ -n $effort ]] && out+=" ${dim}·${reset} ${effort}"

[[ -n $ctx ]] && out+="${sep}ctx $(pct "$ctx")"

# Only present on claude.ai subscriptions, after the first response.
limits=""
[[ -n $five ]] && limits+="5h $(pct "$five")"
[[ -n $week ]] && limits+="${limits:+ ${dim}·${reset} }7d $(pct "$week")"
[[ -n $limits ]] && out+="${sep}${limits}"

# List-price estimate; on a subscription this is what the session would cost
# on the API, not a charge.
[[ -n $cost ]] && out+="${sep}${dim}~\$$(printf '%.2f' "$cost")${reset}"

if [[ -n $dir ]]; then
  out+="${sep}${dir##*/}"
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
  if [[ -n $branch ]]; then
    dirty=""
    [[ -n $(git -C "$dir" --no-optional-locks status --porcelain -uno 2>/dev/null) ]] && dirty="*"
    out+=" ${dim}${branch}${dirty}${reset}"
  fi
fi

out+="${sep}${dim}$(uname -n)${reset}"

printf '%s\n' "$out"
