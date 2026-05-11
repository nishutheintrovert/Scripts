#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 10/05/2026
#    Purpose    : Normalize file and directory names (lowercase, replace 'underscore' and 'spaces' with 'hyphen')

# Get time (16 digits=microseconds, 10=seconds, 13=milliseconds) (Bash 5.0+)
start_time="${EPOCHREALTIME/./}"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Guardrail: Prevent accidental execution
if [[ "$1" != "--i-am-aware" ]]; then
    script_name="${BASH_SOURCE[0]}"
    printf '%b Usage: "%s" --i-am-aware\n' "${RED}[BLOCKED]${RESET}" "$script_name"
    return 1 >/dev/null 2>&1 || exit 1
fi

pad_one_second() {
    local now_us="${EPOCHREALTIME/./}"
    local elapsed=$((now_us - start_time))

    if ((elapsed < 1000000)); then
        local remaining_us=$((1000000 - elapsed))

        # Format for sleep
        local sleep_time=$(printf "0.%03d" $((remaining_us / 1000)))
        sleep "$sleep_time"
    fi
}

# Indexed Arrays
declare -a raw_files
declare -a search_targets
declare -a perl_results
declare -a grep_flags
declare -a failed_renames
declare -a success_renames
declare -a rename_sources
declare -a rename_targets
declare -a file_not_found
declare -a successful_sources
declare -a successful_targets
declare -a tracked_sources
declare -a tracked_targets

# Associative Arrays
declare -A success_strings
declare -A fail_strings
declare -A ref_map
declare -A failed_dict
declare -A is_untracked

# Guardrail: Prevent accidental execution
if [[ "$1" != "--i-am-aware" ]]; then
    script_name="${BASH_SOURCE[0]}"
    printf '%b Usage: "%s" --i-am-aware\n' "${RED}[BLOCKED]${RESET}" "$script_name"
    return 1 >/dev/null 2>&1 || exit 1
fi

# Git variables extraction
if output=$(git rev-parse --short HEAD --show-toplevel 2>/dev/null); then
    GIT_ROOT="${output%%$'\n'*}"
    GIT_HASH="${output#*$'\n'}"
    GIT_REPO=1
else
    GIT_REPO=0
fi

# Smart directory scanning
if ((GIT_REPO)); then
    cd "$GIT_ROOT" || exit

    # 1. Get tracked and untracked files in one go for raw_files
    mapfile -d '' raw_files < <(git ls-files -z -c -o --exclude-standard -- ":(exclude)rename_logs")

    # 2. Identify which ones are strictly untracked for the staging logic
    while IFS= read -r -d '' untracked_file; do
        is_untracked["$untracked_file"]=1
    done < <(git ls-files -z -o --exclude-standard -- ":(exclude)rename_logs")
else
    # Fallback when it's run outside a git repo.
    mapfile -d '' raw_files < <(find . -type d \( -name ".git" -o -name "rename_logs" \) -prune -o -type f -print0)
fi

# Only add files to the search pattern if they actually need renaming
for f in "${raw_files[@]}"; do
    current_base="${f##*/}"
    target_base="${current_base,,}"
    target_base="${target_base//_/-}"
    target_base="${target_base// /-}"
    if [ "$current_base" != "$target_base" ] && [ "$current_base" != "." ]; then
        search_targets+=("$current_base")
    fi
done

if [ ${#search_targets[@]} -gt 0 ]; then
    # Dynamically build flags
    grep_flags=("-I" "--ignore-case" "--word-regexp" "--fixed-strings" "-f" "-" "--only-matching" "--exclude-standard")

    if ((GIT_REPO)); then
        # Exclude the rename_logs directory using the proper pathspec separator
        grep_flags+=("--untracked" "--" "." ":(exclude)rename_logs")
    else
        grep_flags+=("--no-index")
    fi

    # Capture the stream
    raw_grep_output=$(printf "%s\n" "${search_targets[@]}" | git grep "${grep_flags[@]}" 2>/dev/null)

    # Parse it
    if [[ -n "$raw_grep_output" ]]; then
        while IFS=: read -r matched_file match_text; do
            if [[ ! "${ref_map["$match_text"]}" == *"$matched_file, "* ]]; then
                ref_map["$match_text"]+="$matched_file, "
            fi
        done <<<"$raw_grep_output"
    fi
else
    printf "${YELLOW}%b No candidates for renaming.${RESET}\n" "[INFO]"
    return 0 >/dev/null 2>&1 || exit 0
fi

for f in "${raw_files[@]}"; do
    # Native bash dirname and basename extraction
    dir="${f%/*}"
    [ "$dir" = "$f" ] && dir="." # To match all files in the current directory
    current_base="${f##*/}"

    # Skip the root directory reference
    [ "$current_base" = "." ] && continue

    # 2. Native bash string manipulation
    target_base="${current_base,,}"   # Convert to lowercase (Bash 4.0+)
    target_base="${target_base//_/-}" # Replace all underscores with hyphens
    target_base="${target_base// /-}" # Replace all spaces with hyphens

    if [ "$current_base" != "$target_base" ]; then
        target="$dir/$target_base"

        # Guardrail: Target exists AND is not the exact same file (true collision)
        if [ -e "$target" ] && ! [ "$f" -ef "$target" ]; then
            failed_renames+=("$dir/|$current_base|$target_base|Target already exists")
            continue
        fi

        # Guardrail: Dependency Check for references in files
        refs="${ref_map["$current_base"]}"
        if [[ -n "$refs" ]]; then
            # Trim the trailing comma and space for clean logging
            clean_refs="${refs%, }"
            failed_renames+=("$dir/|$current_base|$target_base|Referenced in -> $clean_refs")
            continue
        fi

        # Stage for bulk processing
        rename_sources+=("$f")
        rename_targets+=("$target")

        # Cache log strings for later sorting
        success_strings["$f"]="$dir/|$current_base|$target_base"
        fail_strings["$f"]="$dir/|$current_base|$target_base|OS Rejected (File Locked/Perms)"
    fi
done

# 3. Execution & Logging
log_dir="$PWD/rename_logs"
[[ ! -d "$log_dir" ]] && mkdir -p "$log_dir"

# Bulk rename via Perl (1 process spawn for all files)
if [ ${#rename_sources[@]} -gt 0 ]; then
    # Run Perl and capture NOT_FOUND or REJECTED statuses
    mapfile -t perl_results < <(
        for ((i = 0; i < ${#rename_sources[@]}; i++)); do
            printf "%s\0%s\0" "${rename_sources[i]}" "${rename_targets[i]}"
        done | perl -0 -e '
            while (defined(my $src = <STDIN>) && defined(my $tgt = <STDIN>)) {
                chomp $src; chomp $tgt;
                if (! -e $src) {
                    print "NOT_FOUND:$src\n";
                } elsif (!rename($src, $tgt)) {
                    print "REJECTED:$src\n";
                }
            }
        '
    )

    # Sort successes, not found, and OS failures
    for res in "${perl_results[@]}"; do
        status="${res%%:*}"
        file="${res#*:}"
        failed_dict["$file"]=1

        if [[ "$status" == "NOT_FOUND" ]]; then
            file_not_found+=("$file")
            failed_renames+=("${success_strings["$file"]}|File Not Found")
        else
            failed_renames+=("${fail_strings["$file"]}")
        fi
    done

    for ((i = 0; i < ${#rename_sources[@]}; i++)); do
        src="${rename_sources[i]}"
        if [[ -z "${failed_dict["$src"]}" ]]; then
            success_renames+=("${success_strings["$src"]}")
            successful_sources+=("$src")
            successful_targets+=("${rename_targets[i]}")
        fi
    done

    # Bulk update Git Index using ONLY the successful tracked files
    if ((GIT_REPO)) && [ ${#successful_sources[@]} -gt 0 ]; then

        for ((i = 0; i < ${#successful_sources[@]}; i++)); do
            src="${successful_sources[i]}"
            # Only stage if the file was NOT in our untracked list
            if [[ -z "${is_untracked["$src"]}" ]]; then
                tracked_sources+=("$src")
                tracked_targets+=("${successful_targets[i]}")
            fi
        done

        if [ ${#tracked_sources[@]} -gt 0 ]; then
            git rm --cached -q -- "${tracked_sources[@]}"
            git add "${tracked_targets[@]}"
        fi
    fi
fi

printf -v LOG_TIMESTAMP "%(%Y-%m-%d___%H:%M:%S)T" -1
log_file="$log_dir/${LOG_TIMESTAMP//:/-}.txt"

{
    echo "============================================================================================================"
    echo -e "Date: ${LOG_TIMESTAMP//___/\\nTime: }"
    echo "Working Directory: $PWD"
    ((GIT_REPO)) && echo "Commit: $GIT_HASH"
    echo "============================================================================================================"

    # Append failed log
    if [ "${#failed_renames[@]}" -ne 0 ]; then
        echo -e "\nFailed renames:\n"
        printf "%-25s %-40s %-40s %s\n" "Directories/" "old names" "new names" "Reason"
        for entry in "${failed_renames[@]}"; do
            IFS='|' read -r d o n r <<<"$entry"
            printf "%-25s %-40s %-40s %s\n" "$d" "$o" "$n" "$r"
        done
    fi

    # Append successful log
    if [ "${#success_renames[@]}" -ne 0 ]; then
        echo -e "\nSuccessful renames:\n"
        printf "%-25s %-40s %-40s\n" "Directories/" "old names" "new names"
        for entry in "${success_renames[@]}"; do
            IFS='|' read -r d o n <<<"$entry"
            printf "%-25s %-40s %-40s\n" "$d" "$o" "$n"
        done
    fi
} >"$log_file"

# DEBUG: Dump of all script state
{
    # List of indexed arrays to dump
    declare -a indexed_to_dump=(
        "raw_files"
        "search_targets"
        "perl_results"
        "file_not_found"
        "failed_renames"
        "success_renames"
    )

    for arr_name in "${indexed_to_dump[@]}"; do
        declare -n current_arr=$arr_name
        len=${#current_arr[@]}

        echo -e "\n--- $arr_name ($len items) ========================="

        if ((len > 0)); then
            printf '%s\n' "${current_arr[@]}"
        fi
        unset -n current_arr
    done

    # List of associative arrays to dump
    declare -a associative_to_dump=(
        "ref_map"
        "failed_dict"
        "success_strings"
    )

    for map_name in "${associative_to_dump[@]}"; do
        echo -e "\n--- $map_name ===================================="

        declare -n current_map=$map_name
        for key in "${!current_map[@]}"; do
            echo "[$key] -> ${current_map[$key]}"
        done
        unset -n current_map
    done

    if ((GIT_REPO)); then
        echo -e "\n--- successful_sources (git rm) ===================="
        printf "%s\n" "${successful_sources[@]}"

        echo -e "\n--- successful_targets (git add) ===================="
        printf "%s\n" "${successful_targets[@]}"
    fi
} >>"$log_file"

# Pad execution to 1 second
pad_one_second
