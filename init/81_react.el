(add-to-list 'auto-mode-alist '("\\.jsx\\'" . my-react-hook))

(defun my-react-hook ()
  (setq web-mode-engines-alist '(("jsx" . "\\.jsx\\'")))
  (web-mode)
  (setq flycheck-checker 'javascript-eslint)
  (flycheck-mode)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
)
