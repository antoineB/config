This library defines a global minor mode called `wn-mode' that adds
keyboard shortcuts to quickly switch between visible windows within
the current Emacs frame.

To activate, simply add
  (wn-mode)
to your `~/.emacs'.

By default, the shortcuts are M-1, ..., M-9, M-0, M-#.

Customize `wn-keybinding-format' if you wish to use different key
bindings, e.g.:
  (setq wn-keybinding-format "C-c %s")

Invoke M-x remake-wn-mode-map if you want it to take effect
immediately.
