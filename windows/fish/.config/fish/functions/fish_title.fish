# Terminal tab text. The default is prompt_pwd, which renders as /c/A/D/AhwooClient
# and is unreadable at tab width.
function fish_title
    set -l dir (string replace -- $HOME '~' $PWD | path basename)
    set -l cmd (status current-command)

    if test -z "$cmd" -o "$cmd" = fish
        echo $dir
    else
        echo "$cmd ($dir)"
    end
end
