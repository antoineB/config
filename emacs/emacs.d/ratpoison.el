;; ratpoison same move windows
(require 'windmove)

(defun go-window-left ()
  (interactive)
  (if (windmove-find-other-window 'left)
      (windmove-left)
    (call-process "bash" nil 0 nil "-c" "ratpoison -c \"focusleft\"")))


(defun go-window-right ()
  (interactive)
  (if (windmove-find-other-window 'right)
      (windmove-right)
    (call-process "bash" nil 0 nil "-c" "ratpoison -c \"focusright\"")))


(defun go-window-down ()
  (interactive)
  (if (windmove-find-other-window 'down)
      (windmove-down)
    (call-process "bash" nil 0 nil "-c" "ratpoison -c \"focusdown\"")))

(defun go-window-up ()
  (interactive)
  (if (windmove-find-other-window 'up)
      (windmove-up)
    (call-process "bash" nil 0 nil "-c" "ratpoison -c \"focusup\"")))
