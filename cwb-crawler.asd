(defpackage :cwb-crawler-asd
  (:use :cl
        :asdf))
(in-package :cwb-crawler-asd)

(defsystem #:cwb-crawler
    :version "0.1"
    :name "cwb-crawler"
    :author "ex7763"
    :depends-on (:drakma
                 :cl-ppcre)
    :serial t
    :components ((:file "cwb")))
