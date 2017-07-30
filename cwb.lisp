(defpackage cwb-crawler
  (:use :cl
        :drakma
        :cl-ppcre)
  (:export :parse
           :output
           :main))
(in-package cwb-crawler)

(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args)
      (princ a s))))

(defparameter *web-list* '("http://www.cwb.gov.tw/V7/forecast/taiwan/Taipei_City.htm"
                           "http://www.cwb.gov.tw/V7/forecast/taiwan/New_Taipei_City.htm"
                           "http://www.cwb.gov.tw/V7/forecast/taiwan/Kaohsiung_City.htm"))

(defun parse (web)
  (setf drakma:*drakma-default-external-format* :utf-8)
  (let* ((page (http-request web))
         (city-name (subseq (car (all-matches-as-strings "<th width=\"25\%\">...</th>" page)) 16 19))
         (lst (all-matches-as-strings "(<tbody><tr>)(\\s|\\S)*(</tr></tbody>)" page)))
    (values lst city-name)))

(defun spilt-data (parsed name)
  (let* ((comment (mapcar #'(lambda (x)
                              (regex-replace-all "([a-z]|[A-Z]|\"|=)*"
                                                 x ""))
                          (all-matches-as-strings "alt=\".*?\"" (car parsed))))
         (data (all-matches-as-strings "<tr>(\\s|\\S)*?</tr>" (car parsed)))
         (clean-data (mapcar #'(lambda (x y)
                                 (mkstr (regex-replace-all "<.*?>" x "")
                                        y))
                             data
                             comment)))
    (format t "~A  DONE~%" name)
    (append (list name) clean-data)))

(defun clear-space (str)
  (regex-replace-all "\\t\\t\\n" str ""))

(defun output (file data)
  (with-open-file (out (mkstr file ".txt")
                       :direction :output
                       :if-exists :supersede)
    (let ((clean (clear-space (format nil "~{###~%~{~A~%---~}~%~}" data))))
    (format t "~%~A" clean)
    (format out "~A" clean))))

(defun main (filename web-list)
  (output filename (mapcar #'(lambda (x)
                               (multiple-value-bind (parsed name) (parse x)
                                 (spilt-data parsed name)))
                           web-list)))

(main "test" *web-list*)
