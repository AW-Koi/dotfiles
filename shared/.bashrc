case $- in *i*)
    command -v fastfetch >/dev/null && fastfetch
    ;;
esac

command -v starship >/dev/null && eval "$(starship init bash)"

# Setting LC_ALL to a locale the system hasn't generated makes perl and friends
# warn on every invocation, so it is only exported where it actually exists.
if locale -a 2>/dev/null | grep -qix 'en_NZ.utf8'; then
    export LANG=en_NZ.utf8
    export LC_ALL=en_NZ.utf8
fi
