#/usr/local/bin/emacs --daemon ;
urxvtd &

xsetroot -solid black &
xsetroot -cursor_name left_ptr

#it seems that those lines don't have any effect
xmodmap -e 'clear mod4'
xmodmap -e 'keycode 0x73 = Super_L'
#xmodmap -e 'add mod4 = Super_L'
#xmodmap -e 'add mod4 = Super_R'

exec ratpoison -d :0 
