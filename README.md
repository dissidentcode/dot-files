# Dot-files for Zsh 💻

If you're looking for a souped up Zshell with lots of useful tools and decorations, look no further. If you're not into oh-my-zsh because you think it's bloated and offers way more than you need, look no further. I don't have a snazzy name for any of this. These are just my dotfiles, but I did put in a bunch of work trying to do what oh-my-zsh does without using oh-my-zsh because, after initially using it, I was really disappointed. I spent quite a while making everything pretty, only to realize my prompt tool took over 4 seconds to load... Uh, no. So will the hours I spent doing everything manually make up for the seconds I'll save every time I load Zsh? Perhaps not, but maybe if enough people use these dotfiles, then at some point, the time saved will have been worth the effort. Enjoy! 😁

### MotD (Includes quote of the day from zenquotes.io)

_This took way longer than it should have, but I like the result and hope you do, too. The terminal window needs to be small width-wise before the formatting is broken, so there shouldn't be any problems there. The quote of the day loads from the .zshrc file with a simple curl command. No API key is requited. 'Jq' JSON parser (automatically installed with my 'new-mac-setup script) is a prerequisite to reading the API output, though.👍_

![terminal screenshot with custom motd(neofetch inspired)](/assets/motd-screen.png)

_If my skull ascii is too much you could always change the .zshrc to load neofetch instead, or do what I do, use both. I have the motd set to load when I use the 'r' alias, and I have the neofetch set to load when I clear the screen with the 'c' alias. Of course, you can always &lt;control&gt;+l if you want neither._

![terminal screenshot with neofetch displayed](/assets/neofetch.png)

### Aliases

**_.._** = back one directory  
**_..._** = back two directories  
**_...._** = back three directories  
**_....._** = back four directories  
**_......_** = back five directories
**_home_** = home directory
**_root_** = root directory
**_ave_** = ansible-vault encrypt  
**_avd_** = ansible-vault decrypt  
**\_** = sudo  
**_ga_** = git add  
**_gs_** = git status  
**_gc_** = git commit -m  
**_gp_** = git push origin master  
**_rm_** = verbose remove w/ confirmation when removing more than 3 files  
**_c_** = clear and load neofetch (for when skulls are too edge lord)  
**_mkcd_** = make a directory and cd into it  
**_md_** = mkdir  
**_rmd_** = rmdir (verbose)  
**_del_** = unsafe remove (no confirmation and recursive deletion)  
**_rms_** = save removal (verbose with confirmation for every file)  
**_la_** = list all files including hidden (uses ls)  
**_ls_** = list w/ colors (uses ls)  
**_l_** = list w/ long format, all files including hidden and human-readable byte sizes (uses ls)  
**_ll_** = list w/ long format and human readable byte sizes (uses lsd)  
**ld** = list only directories (uses eza)  
**lf** = list only files (uses eza)  
**_brave_** = open Brave browser  
**_logseq_** = open LogSeq app  
**_chathistory_** = open chat history for aichat (chatGPT tool for command line)  
**_speedtest_** = network speedtest check  
**_pb_** = copy to clipboard via piping  
**_notes_** = LogSeq git repository  
**_repos_** = git repositories directory  
**_trash_** = trash with Finder instead of system API  
**_dnsflush_** = flush DNS cache (password needed)  
**_r_** = clear && source ~/.zshrc  
**_psmem_** = list computer processes by memory use with clean formatting  
**_pscpu_** = list computer processes by CPU use with clean formatting  
**_dusage_** = list disk usage for items in the current directory with clean formatting  
**dust** = enhance 'du' written in rust
**dustf** = 'dust' for files only
**dustd** = 'dust' for directories only
**_greph_** = grep command line history  
**_grepa_** = grep aliases  
**_grep_** = standard grep with colors added  
**_egrep_** = grep -E with colors and ignores common hidden file types  
**_fgrep_** = grep -F with colors and ignores common hidden file types  
**_zsh_** = load .zshrc and its source files: .motd.sh .functions.sh and .alias.sh in VS code

## Functions

### Git

**_acp_** = git automation - check for changes to commit, then git add -A, git commit -m, and git push origin {current branch}. No need to use quotes for commit message.

### ImageMagick

**_orgimg_** = takes a directory and organizes all images into folders named with the file extension.  
**_jpg2png_** = .jpg and .jpeg conversion to .png  
**_jpg2webp_** = .jpg and .jpeg conversion to webp  
**_png2jpg_** = .png conversion to .jpg  
**_png2webp_** = .png conversion to .webp  
**_webp2jpg_** = .webp conversion to .jpg  
**_webp2png_** = .webp conversion to .png  
**_pdf2jpg_** = .png conversion to .jpg  
**_vector2png_** = .ai, .eps, or .svg conversion to .png  
**_heic2jpg_** = Apple's latest HEIC image conversion to .jpg  
**_optjpg_** = optimize all .jpg's in a directory  
**_optpng_** = optimize all .png's in a directory

### Miscellaneous

**_symlink_** = creates a backup of a directory and then creates a symlink of the directory with the original name
**_makegif_** = creates an optimized gif from any segment of a full-length video. You can run it by calling 'makegif' and following the prompts or you can use it immediately by inputting all the correct arguments when you call the script.
**_torrent_** = starts downloading a torrent with aria2. Usage: torrent <label> <info hash>

### Searching the web

**_ddg_**: search Duck Duck Go. Usage: ddg <search terms in quotes>  
**_google_**: search google. Usage: google <rsearch terms in quotes>  
**_youtube_**: search YouTube for specific terms. Usage: youtube <search terms in quotes>  
**_gmailsearch_**: search gmail for specific terms. Usage: gmailsearch <search terms in quotes>  

## Starship prompt configuration file

I've set up the starship.toml config file to have the prompt look like the powerline prompt. I've set it up using iTerm2, so the colors may be broken on another terminal app. Also 'magenta' wasn't working for some reason. Still determining if it's a bug with starship or with iTerm2. I got around it by hard-coding the color with a hex color.

![prompt image](/assets/prompt.png)

Dynamic icons! 🥹

![prompt icons examples](/assets/prompt-icons.png)

You'll want these two lines at the bottom of your .zshrc:

```zsh
export STARSHIP_CONFIG=~/path/to/starship.toml
eval "$(starship init zsh)"
```

If you're using my 'new-mac-setup' script, it will automatically retrieve my dotfiles, so the lines will be there. However, since my actual dotfiles are in this repo, the 'path/to/starship. tool' is a symlink, and you'll want to change that anyway. For reference, my symlink is in `~/.config/starship/starship.toml`.

### Where's my minimalist prompt? 🧐

This is overboard for some people. You can simply delete the sections you don't want from the 'format' block at the top of 'starship.toml'. You don't have to worry about deleting formatting and styling blocks lower in the file.

_Example_ Delete these lines for a minimalist prompt with only the user name, directories, git branch & status, and last-command status:

![lines to delete in starship.toml file for minimalist prompt](/assets/minimal.png)

_Result_

![mini prompt example](/assets/mini-prompt.png)

## iTerm2 color presets file

The file, zsh-colors.itermcolors, is to load the colors I use into iTerm2. Feel free to use your own, but I figured I'd include this as well to avoid any legibility or contrast issues on your machine. The less tweaking, the better, right? Just import them from this 'color presets' menu in iTerm2 settings.

![iTerm2 color palette import image](/assets/iterm-colors.png)
