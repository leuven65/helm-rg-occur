;;; helm-rg-occur.el --- support rg in helm-swoop/helm-occur in large size file -*- lexical-binding: t -*-

;; Author: Jian Wang <leuven65@gmail.com>
;; URL: https://github.com/leuven65/helm-rg-occur
;; Version: 0.1.0
;; Keywords: helm-swoop, helm-occur

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;

;;; Code:

(defvar helm-rg-occur-file-size
  (* 2 1024 1024) ;2M
  "If file size [bytes] is large than this value, it will use 'rg' to do the grep")

(with-eval-after-load 'helm-grep

  ;; use helm-do-grep-ag to search on dir
  (defun helm-rg-occur-do-grep-rg-on-dir (dir &optional arg input-idle-delay)
    "grep on the dir"
    (let ((default-directory dir)
          ;; also set `helm-ff-default-directory' to avoid problem when call this command on first time
          (helm-ff-default-directory dir)
          ;; normally grep is slow, it is better to put more input delay
          (helm-grep-input-idle-delay (or input-idle-delay helm-grep-input-idle-delay)))
      (helm-do-grep-ag arg)))

  ;; use helm-do-grep-ag to search on single file
  (defun helm-rg-occur (&optional file-name)
    "Use rg to do grep on file"
    (interactive)
    (setq file-name (or file-name (buffer-file-name)))
    (unless file-name (user-error "File name is empty for ripgrep"))
    (let* ((helm-follow-mode-persistent t)
           (helm-grep-ag-command (concat "rg --color=always --smart-case --no-heading --with-filename --line-number %s %s "
                                         (shell-quote-argument (file-name-nondirectory file-name)))))
      (my-helm-do-grep-rg-on-dir (file-name-directory file-name)))
    )

  ;; extend `helm-swoop'
  (with-eval-after-load 'helm-swoop
    (defun helm-swoop-with-rg-occur (&optional parg)
      (interactive "P")
      (if (and (buffer-file-name)
               (or parg                                 ;if C-u
                   (> (buffer-size) helm-rg-occur-file-size))) ;if file is large than `helm-rg-occur-file-size'
          (helm-rg-occur)            ;use rg to do search
        (helm-swoop :multiline nil))
      )

    ;; rebind the command
    (global-set-key [remap helm-swoop] #'helm-swoop-with-rg-occur)
    )

  ;; extend `helm-occur'
  (with-eval-after-load 'helm-occur
    (defun helm-occur-with-rg-occur (&optional parg)
      (interactive "P")
      (if (and (buffer-file-name)
               (or parg                                 ;if C-u
                   (> (buffer-size) helm-rg-occur-file-size))) ;if file is large than `helm-rg-occur-file-size'
          (helm-rg-occur)            ;use rg to do search
        (helm-occur))
      )

    ;; rebind the command
    (global-set-key [remap helm-swoop] #'helm-occur-with-rg-occur)
    )
  )

(provide 'helm-rg-occur)

;;; helm-rg-occur.el ends here
