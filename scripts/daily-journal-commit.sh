#!/bin/zsh

# Create a descriptor (number 3) pointing to the log file
exec 3>>/Users/nate/.logs/log.txt

{
    # Get the current date
    date=$(date +"%Y_%m_%d")

    # Logseq journal directory
    journal_dir="/Users/nate/Personal/LogSeq-PKB/journals"

    # Today's journal file path
    journal_file="${journal_dir}/${date}.md"

    # Check if today's journal file exists
    if [ ! -f "$journal_file" ]; then
        # The file does not exist, create it
        touch "$journal_file"
    fi

    # Change directory to the correct git repository
    cd /Users/nate/Personal/LogSeq-PKB

    # Commit message
    commit_message="save $(date +"%m.%d.%y")"

    # Print current changes in git
    echo " " >&3
    echo "$(date)" >&3
    echo "Current changes:" >&3
    git diff >&3

    # Run acp function with the formatted date
    git add -A >&3
    git commit -m "$commit_message" >&3
    git push origin master >&3

    echo "$(date): Daily Journal Script Ran via launchd." >&3
    echo " " >&3
} |& tee -a /Users/nate/.logs/log.txt

# Close the file descriptor
exec 3<&-

#put computer to sleep
pmset sleepnow


