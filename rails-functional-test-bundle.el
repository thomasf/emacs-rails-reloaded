;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Constants
;;

(defconst rails/functional-test/dir "test/functional/")
(defconst rails/functional-test/file-suffix "_controller_test")
(defconst rails/functional-test/buffer-type :functional-test)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Functions
;;

(defun rails/functional-test/canonical-name (file)
  (let* ((name (file-name-sans-extension file))
         (name (string-ext/cut name rails/functional-test/dir :begin))
         (name (string-ext/cut name rails/functional-test/file-suffix :end)))
    name))

(defun rails/functional-test/exist-p (root tests-name)
  (when tests-name
    (let ((file (concat rails/functional-test/dir
                        (pluralize-string tests-name)
                        rails/functional-test/file-suffix
                        rails/ruby/file-suffix)))
      (when (rails/file-exist-p root file)
        file))))

(defun rails/functional-test/functional-test-p (file)
  (rails/with-root file
    (when-bind (buf (rails/determine-type-of-file (rails/root) (rails/cut-root file)))
      (eq rails/functional-test/buffer-type (rails/buffer-type buf)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Callbacks
;;

(defun rails/functional-test/determine-type-of-file (rails-root file)
  (when (string-ext/start-p file rails/functional-test/dir)
    (let ((name (rails/functional-test/canonical-name file)))
      (make-rails/buffer :type   rails/functional-test/buffer-type
                         :name   name
                         :resource-name (pluralize-string name)))))

(defun rails/functional-test/goto-item-from-file (root file rails-current-buffer)
  (when (rails/resource-type-of-buffer rails-current-buffer
                                       :exclude rails/functional-test/buffer-type)
    (when-bind (file-name
                (rails/functional-test/exist-p root (rails/buffer-tests-name rails-current-buffer)))
       (make-rails/goto-item :group :test
                             :name "Functional Test"
                             :file file-name))))

(defalias 'rails/functional-test/goto-item-from-rails-buffer
          'rails/functional-test/goto-item-from-file)

(defun rails/functional-test/load ()
  (rails/add-to-resource-types-list rails/functional-test/buffer-type)
  (rails/define-goto-key "f" 'rails/functional-test/goto-from-list)
  (rails/define-goto-menu  "Functional Test" 'rails/functional-test/goto-from-list)
  (rails/define-toggle-key "f" 'rails/functional-test/goto-current)
  (rails/define-toggle-menu  "Functional Test" 'rails/functional-test/goto-current))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Interactives
;;

(defun rails/functional-test/goto-from-list ()
  (interactive)
  (rails/with-current-buffer
   (rails/directory-to-goto-menu (rails/root)
                                 rails/functional-test/dir
                                 "Select a Functional Test"
                                 :name-by (funcs-chain file-name-sans-extension string-ext/decamelize))))

(defun rails/functional-test/goto-current ()
  (interactive)
  (rails/with-current-buffer
   (when-bind (goto-item
               (rails/functional-test/goto-item-from-file (rails/root)
                                                          (rails/cut-root (buffer-file-name))
                                                          rails/current-buffer))
       (rails/toggle-file-by-goto-item (rails/root) goto-item))))

(provide 'rails-functional-test-bundle)