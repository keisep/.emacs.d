;;;; !!! 07_powerline と干渉するためそれより前にロードすること!!!

(bundle! elscreen
  (setq elscreen-tab-display-kill-screen nil)
  (setq elscreen-tab-display-control nil)
  (setq elscreen-display-screen-number nil)
  (elscreen-start))

;;;; Util Functions

;;killした時は、直近のスクリーンを表示する
(defvar elscreen-ignore-buffer-list
 '("*scratch*" "*Backtrace*" "*Colors*" "*Faces*" "*Compile-Log*" "*Packages*" "*vc-" "*Minibuf-" "*Messages" "*WL:Message"))
(defun kill-buffer-for-elscreen ()
  (interactive)
  (kill-buffer)
  (let* ((next-buffer nil)
         (re (regexp-opt elscreen-ignore-buffer-list))
         (next-buffer-list (mapcar (lambda (buf)
                                     (let ((name (buffer-name buf)))
                                       (when (not (string-match re name))
                                         name)))
                                   (buffer-list))))
    (dolist (buf next-buffer-list)
      (if (equal next-buffer nil)
          (setq next-buffer buf)))
    (switch-to-buffer next-buffer)))

;; スクリーン1枚時、スクリーン移動コマンドで自動でスクリーンを作成する
(defmacro elscreen-create-automatically (ad-do-it)
  `(if (not (elscreen-one-screen-p))
       ,ad-do-it
     (elscreen-create)
     (elscreen-notify-screen-modification 'force-immediately)
     (elscreen-message "New screen is automatically created")))
(defadvice elscreen-next (around elscreen-create-automatically activate)
  (elscreen-create-automatically ad-do-it))
(defadvice elscreen-previous (around elscreen-create-automatically activate)
  (elscreen-create-automatically ad-do-it))
(defadvice elscreen-toggle (around elscreen-create-automatically activate)
  (elscreen-create-automatically ad-do-it))

;;;; init-hook

;; スクリーン番号を1から開始
(defadvice elscreen-get-screen-list (after my-ad-elscreen-get-screenlist disable)
  (add-to-list 'ad-return-value 0))
(defadvice elscreen-create (around my-ad-elscreen-create activate)
  (interactive)
  (ad-enable-advice 'elscreen-get-screen-list 'after 'my-ad-elscreen-get-screenlist)
  (ad-activate 'elscreen-get-screen-list)
  ad-do-it
  (ad-disable-advice 'elscreen-get-screen-list 'after 'my-ad-elscreen-get-screenlist)
  (ad-activate 'elscreen-get-screen-list))
(defun my-elscreen-kill-0 ()
  (when (and (elscreen-one-screen-p)
             (elscreen-screen-live-p 0))
    (elscreen-create)
    (elscreen-kill 0)))
(defadvice elscreen-make-frame-confs (after my-ad-elscreen-make-frame-confs activate)
  (let ((selected-frame (selected-frame)))
    (select-frame frame)
    (my-elscreen-kill-0)
    (select-frame selected-frame)))
(add-hook 'after-init-hook 'my-elscreen-kill-0)
