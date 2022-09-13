xtrandr

xrdb --merge ~/.Xresources

# No such secret collection at path. (https://wiki.archlinux.org/title/GNOME/Keyring#No_such_secret_collection_at_path:_/)
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

# Start i3
exec i3
