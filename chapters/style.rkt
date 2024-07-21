#lang racket
(require scribble/base
         scribble/core
         scribble/latex-properties
         scribble/html-properties
         scribble/decode
         scriblib/render-cond
         scribble-math
         latex-utils/scribble/math
         pinyin)

(define book-prefix-and-style
  (make-latex-defaults+replacements
   "style/prefix.tex"
   "style/style.tex"
   '()
   (hash "scribble-load-replace.tex"
         "style/style-load-prefix.tex")))

;;; common utility
(define (remove-leading-newlines c)
  (cond [(null? c) c]
        [(and (string? (car c))
              (string=? (car c) "\n"))
         (remove-leading-newlines (cdr c))]
        [else c]))

;;; given a content, return a normalized string with first char upcased
(define (normalize-content c)
  (let ((str (clean-up-index-string (content->string c))))
    (if (non-empty-string? str)
        (string-append (string (char-upcase (string-ref str 0)))
                       (substring str 1))
        str)))

;;; constants
(define (Int-$) ($ "\\mathit{Int}"))
(define (Int-m) (m "\\mathit{Int}"))
(define (List-of-Int-$) ($ "\\mathit{List\\mbox{-}of\\mbox{-}Int}"))
(define (List-of-Int-m) (m "\\mathit{List\\mbox{-}of\\mbox{-}Int}"))
(define (List-of-Int-raw) "\\mathit{List\\mbox{-}of\\mbox{-}Int}")

;;; options
(define racket-block-offset 4)
(define origin-page-number 0)
(define dump-glossary-translations #f)

;;; for title format
(define book-title-style (make-style #f (list 'toc 'no-index book-prefix-and-style)))
(define part-title-style-numbered '(numbered no-index))
(define part-title-style-unnumbered '(unnumbered no-index))
(define section-title-style-numbered '(numbered no-index))
(define section-title-style-unumbered '(unnumbered no-index))

;;; styles
(define question
  (make-style "Squestion" (list (make-tex-addition "style/question.tex")
                                (make-css-addition "style/question.css"))))
(define right
  (make-style "Sright" (list (make-tex-addition "style/right.tex")
                             (make-css-addition "style/right.css"))))

(define underline
  (make-style "Sunderline" (list (make-tex-addition "style/underline.tex")
                                 (make-css-addition "style/underline.css"))))

(define small
  (make-style "Small" (list (make-tex-addition "style/small.tex"))))

(define htt
  (make-style "Shtt" (list (make-tex-addition "style/htt.tex"))))

(define two-columns
  (make-style "TwoColumns" (list (make-tex-addition "style/two-columns.tex"))))

(define hangindent
  (make-style "Hangindent" (list (make-tex-addition "style/hangindent.tex"))))

(define normalfont
  (make-style "NormalFont" (list (make-tex-addition "style/normalfont.tex"))))

(define tip
  (make-style "Tip" (list (make-tex-addition "style/tip.tex")
                          (make-css-addition "style/tip.css"))))

(define tip-content
  (make-style "TipContent" (list (make-tex-addition "style/tip.tex")
                                 (make-css-addition "style/tip.css"))))

(define eopl-style-figure
  (make-style "EoplFigure" (list (make-tex-addition "style/figure.tex"))))

(define eopl-style-figure*
  (make-style "EoplFigure*" (list (make-tex-addition "style/figure.tex"))))

(define eopl-style-subfigure
  (make-style "EoplSubfigure" (list (make-tex-addition "style/figure.tex"))))

(define eopl-figure-ref
  (make-style "EoplFigureRef" (list (make-tex-addition "style/figure.tex"))))

(define eopl-example
  (make-style "EoplExample" (list (make-tex-addition "style/example.tex"))))

(define eopl-example-ref
  (make-style "EoplExampleRef" (list (make-tex-addition "style/example.tex"))))

(define eopl-exercise
  (make-style "EoplExercise" (list (make-tex-addition "style/exercise.tex"))))

(define eopl-exercise-ref
  (make-style "EoplExerciseRef" (list (make-tex-addition "style/exercise.tex"))))

(define eopl-definition
  (make-style "EoplDefinition" (list (make-tex-addition "style/definition.tex"))))

(define eopl-definition-title
  (make-style "EoplDefinitionTitle" (list (make-tex-addition "style/definition.tex"))))

(define eopl-definition-ref
  (make-style "EoplDefinitionRef" (list (make-tex-addition "style/definition.tex"))))

(define eopl-theorem
  (make-style "EoplTheorem" (list (make-tex-addition "style/theorem.tex"))))

(define eopl-theorem-ref
  (make-style "EoplTheoremRef" (list (make-tex-addition "style/theorem.tex"))))

(define margin-page-number
  (make-style "MarginPage" (list (make-tex-addition "style/margin-page.tex"))))

(define bib-para
  (make-style "BibPara" (list (make-tex-addition "style/bib-para.tex"))))

(define eopl-plain-label
  (make-style "PlainLabel" (list (make-tex-addition "style/plain-label.tex"))))

(define eopl-exer-ref-range
  (make-style "EoplExerRefRange" (list (make-tex-addition "style/exercise.tex"))))

;;; for code
(define (eopl-proc . c)
  (bold (tt c)))

(define eopl-samepage
  (make-style "Samepage" (list (make-tex-addition "style/samepage.tex"))))

(define eopl-code-inset
  (make-style "EoplCodeInset" (list (make-tex-addition "style/code-inset.tex"))))

(define eopl-equation-inset
  (make-style "EoplEquationInset" (list (make-tex-addition "style/code-inset.tex"))))

(define eopl-computation-inset
  (make-style "EoplComputationInset" (list (make-tex-addition "style/code-inset.tex"))))

(define eopl-proof-style
  (make-style "EoplProof" (list (make-tex-addition "style/proof.tex"))))

;; make sure the code title does not become orphan
(define (samepage . c)
  (nested #:style eopl-samepage c))

;; used for code in a paragraph
(define (eopl-code . content)
  (nested #:style eopl-code-inset
          content))

;; used for code equation example, left margin is 0pt
(define (eopl-computation . content)
  (nested #:style eopl-computation-inset
          content))

;; used for code equation in a paragraph
(define (eopl-equation . content)
  (nested #:style eopl-equation-inset
          content))

;; used for code equation in a paragraph
(define (eopl-proof . content)
  (nested #:style eopl-proof-style
          content))

;;; for exercise
(define exercise-level-mark "{\\star}")

(define (make-level-mark l)
  (define (make-level-mark-iter n str)
    (if (zero? n)
        str
        (make-level-mark-iter (- n 1)
                              (string-append exercise-level-mark str))))
  (make-level-mark-iter l ""))

(define (make-exer-marker level)
  ($ "\\textnormal{[}" (make-level-mark level) "\\textnormal{]}"))

(define (make-exer-decorator c)
  ($ "\\textnormal{[}" c "\\textnormal{]}"))

(define (exercise #:decorator [decorator #f] #:level [level 1] #:tag [tag ""] . c)
  (nested #:style eopl-exercise
          (elemtag tag "")
          (if decorator
              (make-exer-decorator decorator)
              (make-exer-marker level))
          (hspace 1)
          (remove-leading-newlines c)))

(define (exercise-ref tag)
  (void))

;;; for example
(define (example #:tag [tag ""] . c)
  (nested #:style eopl-example
          (elemtag tag "") c))

(define (example-ref tag)
  (void))

;;; for figure
(define (eopl-figure #:position [position #f] . c)
  (nested #:style eopl-style-figure
          (when position
            (make-floating-recommend position))
          c))

(define (eopl-subfigure . c)
  (nested #:style eopl-style-subfigure
          c))

;; for unnumbered figure
(define (eopl-figure* #:position [position #f] . c)
  (nested #:style eopl-style-figure*
          (when position
            (make-floating-recommend position))
          c))

(define (make-floating-recommend recommends)
  (exact-elem "[" recommends "]"))

(define (eopl-caption tag . c)
  (nested #:style
          (make-style "caption" (list 'multicommand))
          (remove-leading-newlines c)
          (when tag (elemtag tag ""))))

(define (figure-ref tag)
  (void))

;;; for definition
(define (definition #:title [title #f] #:tag [tag ""] . c)
  (nested #:style eopl-definition
          (elemtag tag "")
          (if title
              (elem #:style eopl-definition-title
                    title)
              (hspace 1))
          (remove-leading-newlines c)))

(define (definition-ref tag)
  (void))

;;; for theorem
(define (theorem #:title [title #f] #:tag [tag ""] . c)
  (nested #:style eopl-theorem
          (elemtag tag "")
          (if title
              (elem #:style eopl-definition-title
                    title)
              (hspace 1))
          (remove-leading-newlines c)))

(define (theorem-ref tag)
  (void))

(define (exact-elem . c)
  (make-element (make-style #f '(exact-chars)) c))

;;; for interface
(define (big-bracket #:breakable [breakable #t] #:title [title #f] . c)
  (nested
   (if breakable
       (exact-elem "\\begin{cornertext}")
       (exact-elem "\\begin{cornerbox}"))
   (when title
     (exact-elem "[title=" title "]"))
   (exact-elem "\n")
   c
   (if breakable
       (exact-elem "\n\\end{cornertext}")
       (exact-elem "\n\\end{cornerbox}"))))

;;; for margin page
;;; margin-page, every call to this increments the internal counter
(define (margin-page)
  (set! origin-page-number (+ origin-page-number 1))
  (margin-note* (elem #:style margin-page-number (number->string origin-page-number))))

(define pg margin-page)

;;; set page number to the specified value, used when the translation crosses
;;; some pages of the original
(define (set-margin-page page)
  (set! origin-page-number page))

;;; front matter, as in latex
(define frontmatter
  (make-paragraph (make-style 'pretitle '())
                  (make-element (make-style "frontmatter" '(exact-chars)) '())))

;;; main matter, as in latex
(define mainmatter
  (make-paragraph (make-style 'pretitle '())
                  (make-element (make-style "mainmatter" '(exact-chars)) '())))

;;; special format for index
(define index-prefix
  (make-paragraph (make-style 'pretitle '())
                  (elem
                   (exact-elem "\\setlength{\\columnsep}{35pt}")
                   (exact-elem "\\twocolumn"))))

(define print-index
  (elem
   (exact-elem "\\printindex")
   "\n"
   (exact-elem "\\onecolumn")))

;;; for glossary table
;;; term: content | #f x content -> content
;;; Note that if you don't want original, use #f instead. Missing it causes
;;; unexpected expansion
(define (term #:tag [tag #f] #:full [full #t] original . translation)
  (when (and dump-glossary-translations (not (equal? original #f)))
    (displayln (format "@elem{~a} @elem{~a}"
                       (if (list? original)
                           (add-between (map (lambda (e)
                                               (clean-up-index-string (content->string e)))
                                             original)
                                        ", ")
                           (clean-up-index-string (content->string original)))
                       (clean-up-index-string (content->string translation)))))
  (cond [(equal? original #f)
         (elem (when tag (elemtag tag)) (emph translation))]
        [(list? original)
         (elem (when tag (elemtag tag))
               (emph translation)
               (when full
                 (cond [(null? original) (void)]
                       [(null? (cdr original))
                        (list " (" (emph original) ")")]
                       [else
                        (list " ("
                              (emph (car original))
                              (map (lambda (ele)
                                     (elem ", " (emph ele)))
                                   (cdr original))
                              ")")])))]
        [(content? original)
         (elem (when tag (elemtag tag))
               (emph translation)
               (when full (elem " (" (emph original) ")")))]
        [else
         (error 'term "Expect original content or #f, given ~a" original)]))

(define (wrappable-cell . content)
  (compound-paragraph
   (make-style #f '())
   (list (para content))))

(define (glossary-note . content)
  (elem "（" (emph content) "）"))

;;; for bibliography
(define (bib . content)
  (nested #:style bib-para content))

(define (bib-title . content)
  (emph content))

;;; a smart function for marking and indexing authors in bibliography
;;; it does the following things:
;;; 1. split first and last name from the content string, which are separated by
;;;    ",", the "," will also be regarded as part of the first name
;;; 2. check name:
;;;    (1). if the first name starts with a all-lower-case word, the first part
;;;    will be removed from the index key; otherwise the whole first name will
;;;    be used as the first name in the index key.
;;;    (2). if the last name has the form "([[:alpha:]]+ )+([A-Z]\.)", the first
;;;    part will be extracted as the last name in the index; otherwise the whole
;;;    last name will be used as the last name in the index;
;;; 3. optionally, if you have special needs, you can specify key or index by
;;;    hand, in this case key or index will not be inferred from content
(define (extract-name-part tokens)
  (define (extract-first-and-last tokens first-name)
    (cond [(null? tokens)
           (cons first-name '())]
          [(regexp-match-positions #rx"[^,]$" (car tokens))
           (extract-first-and-last (cdr tokens)
                                   (cons (car tokens) first-name))]
          [(regexp-match-positions #rx",$" (car tokens))
           (cond [(regexp-match-positions #rx"^[JS]r\\.,$" (cadr tokens))
                  (cons (cons (cadr tokens) (cons (car tokens) first-name))
                        (cddr tokens))]
                 [else
                  (cons (cons (car tokens) first-name)
                        (cdr tokens))])]
          [else
           (extract-first-and-last (cdr tokens)
                                   (cons (car tokens) first-name))]))
  (when (or (null? tokens) (null? (cdr tokens)))
    (error 'bib-author "Invalid name strings ~a, expect a string with at least two words"
           (string-append* (add-between tokens " "))))
  (let* ((result (extract-first-and-last tokens '()))
         (first (reverse (car result)))
         (last (cdr result)))
    (cons first last)))

(define (construct-author-key first last)
  (let* ((f-part (if (regexp-match-positions #px"^[[:lower:]]" (car first))
                     (cdr first)
                     first))
         (l-string (string-append* (add-between last " ")))
         (l-part (cond [(regexp-match-positions #px"^([[:alpha:]]+ )+[A-Z]\\.$" l-string)
                        (list (car last))]
                       [else last])))
    (string-append* (add-between (append f-part l-part) " "))))

(define (construct-author-index first last)
  (let* ((l-string (string-append* (add-between last " ")))
         (l-part (cond [(regexp-match-positions #px"^([[:alpha:]]+ )+[A-Z]\\.$" l-string)
                        (list (car last))]
                       [else last])))
    (string-append* (add-between (append first l-part) " "))))

(define (bib-author #:key [key #f] #:index [index #f] . content)
  (let* ((purged-name (if (and key index) #f (extract-name-part (string-split (content->string content)))))
         (first (if (and key index) #f (car purged-name)))
         (last (if (and key index) #f (cdr purged-name)))
         (key (if key key (construct-author-key first last)))
         (index (if index index (construct-author-index first last)))
         ;; author-key is the first name of the author, used as the key to
         ;; search the index entry
         (author-key (if first
                         (regexp-replace #rx"([^,]+),.*$"
                                         (string-append* (add-between first " "))
                                         "\\1")
                         ;; this assumes the specified key is two words
                         ;; separated by comma
                         (regexp-replace #rx"([^,]+),.*$" index "\\1")))
         (author-index (eopl-index-entry (if index index content)
                                         (if (string=? key index) #f key))))
    (traverse-element
     (lambda (get set)
       (lambda (get set)
         (set (string->symbol author-key) author-index)
         (elem (eopl-index-internal #f #f #f #f (list author-index)
                                    (get 'scribble:current-render-mode #f))
               content))))))

(define (author-ref . author)
  (let* ((author (content->string author))
         (author-key (regexp-replace #px"[[:space:]]+" author " ")))
    (traverse-element
     (lambda (get set)
       (lambda (get set)
         (lambda (get set)
           (let* ((author-index-entry (get (string->symbol author-key)
                                           (format "(Unknown author ~a)" author-key))))
             (elem (eopl-index-internal #f #f #f #f (list author-index-entry)
                                        (get 'scribble:current-render-mode #f))
                   author))))))))

;;; for indexing
(define-struct eopl-index-entry (value key))

(define (eopl-index-entry-print entry)
  (match entry
    [(struct eopl-index-entry (v k))
     (if (equal? k #f)
         v
         (list k "@" v))]))

(define (eopl-index-entry->key entry)
  (match entry
    [(struct eopl-index-entry (v k))
     (string->symbol
      (string-append
       (content->string v)
       (if k k "#f")))]))

(define (exer-ref-range . tags)
  (void))

(define idx-value-of
  (eopl-index-entry (eopl-proc "value-of") "valueof"))

(define (eopl-index #:prefix [prefix #f]
                    #:suffix [suffix #f]
                    #:range-mark [range-mark #f]
                    #:decorator [decorator #f]
                    #:delayed [delayed #t]
                    . entries)
  (let ((index-entries (map make-an-index-entry entries))
        (delayed-prefix (if (and delayed
                                 (or (equal? decorator 'see) (equal? decorator 'seealso)))
                            (make-an-index-entry prefix)
                            prefix)))
    ;; wrap traverse element into element to avoid direct print of a
    ;; traverse print in code block
    (elem
     (traverse-element
      (lambda (get set)
        (lambda (get set)
          (let ((index-entries
                 (map (lambda (e)
                        (get (eopl-index-entry->key e) e))
                      index-entries))
                (actual-prefix
                 (if (or (equal? decorator 'see) (equal? decorator 'seealso))
                     (eopl-index-entry-value (get (eopl-index-entry->key delayed-prefix) delayed-prefix))
                     prefix))
                (render (get 'scribble:current-render-mode #f)))
            (eopl-index-internal actual-prefix suffix range-mark decorator index-entries render))))))))

(define (eopl-index-internal prefix suffix range-mark decorator entries render)
  (case render
    ['(latex)
     (elem
      (exact-elem "\\index{")
      (make-latex-entry-list (map eopl-index-entry-print entries))
      (exact-elem "|"
                  (cond [(equal? range-mark 'start) "("]
                        [(equal? range-mark 'end) ")"]
                        [else ""])
                  (cond [(equal? decorator #f) "idxdecorator{"]
                        [(equal? decorator 'see)
                         (case (length entries)
                           [(1) "see{"]
                           [(2) "seeSublevel{"]
                           [(3) "seeSubSublevel{"]
                           [else "seeSubSublevel{"])]
                        [(equal? decorator 'seealso)
                         (case (length entries)
                           [(1) "seealso{"]
                           [(2) "seealsoSublevel{"]
                           [(3) "seealsoSubSublevel{"]
                           [else "seealsoSubSublevel{"])]
                        [else (error 'eopl-index "Unknown decorator, expect 'see or 'seealso or #f, given ~a" decorator)]))
      (unless (equal? prefix #f) prefix)
      (when (equal? decorator #f) (exact-elem "}{"))
      (unless (equal? suffix #f) suffix)
      (exact-elem "}}"))]
    ['(html)
     (elem
      (index* (map (lambda (e)
                     (if (equal? (eopl-index-entry-key e) #f)
                         (eopl-index-entry-value e)
                         (eopl-index-entry-key e)))
                   entries)
              (map eopl-index-entry-value entries)))]
    ;; TODO: for other renders, how should indices be output?
    [else (elem)]))

;; content is a list of eopl index entry item
(define (make-latex-entry-list entries)
  (add-between entries "!"))

;; make-an-index-entry : eopl-index-entry | string -> eopl-index-entry
(define (make-an-index-entry entry)
  (match entry
    [(struct eopl-index-entry (v k)) entry]
    [(? string?)
     (let ((cstr (clean-up-index-string entry)))
       (if (regexp-match? #px"[[:space:]\\(\\):'（）]|-" cstr)
           (eopl-index-entry cstr (regexp-replace* #px"[[:space:]\\(\\):'（）]|-" cstr ""))
           (eopl-index-entry cstr #f)))]
    [else
     (error 'eopl-index
            "Invalid eopl index entry ~a, expect an eopl-index-entry or a string"
            entry)]))

;;; for index translation
;; eopl-translation-block: wrap all the translation into a block, for doing
;; some cleaning work
(define (eopl-translation-block . c)
  (elem c))

;; eopl-index-translation : eopl-index-entry x eopl-index-entry -> traverse-element
;; taken a entry and its translation, records the translation as a traverse
;; element
(define (eopl-index-entry-translate original translation)
  (traverse-element
   (lambda (get set)
     (set (eopl-index-entry->key (make-an-index-entry original))
          (let ((et (make-an-index-entry translation)))
            (eopl-index-entry
             (eopl-index-entry-value et)
             (if (eopl-index-entry-key et)
                 (eopl-index-entry-key-translate (eopl-index-entry-key et))
                 (eopl-index-entry-key-translate (eopl-index-entry-value et))))))
     (elem))))

(define (char->pinyin c)
  (let ((p (hash-ref pinyin-hash-table c (string c))))
    (if (and (list? p) (not (null? p)))
        (cons (pinyin->key (car p)) #t)
        (cons p #f))))

(define (add-z-to-pinyin key)
  (let ((chars (string->list key)))
    (list->string (cons (car chars)
                        (cons #\z
                              (cdr chars))))))

(define (decorate-pinyin keys)
  (cond [(null? keys) keys]
        [(cdar keys) (cons
                      (cons (add-z-to-pinyin (caar keys))
                            (cdar keys))
                      (cdr keys))]
        [else (cons (car keys)
                    (decorate-pinyin (cdr keys)))]))

(define (eopl-index-entry-key-translate key)
  (let* ((keys (decorate-pinyin (map char->pinyin (string->list key)))))
    (string-append* (map car keys))))

(define (pinyin->key pinyin)
  (let ((tone 0))
    ;; for searching the tone
    (define (pinyin->tone c)
      (case c
        [(#\ā #\ē #\ī #\ō #\ū #\ǖ) 1]
        [(#\á #\é #\í #\ó #\ú #\ǘ #\ń) 2]
        [(#\ǎ #\ě #\ǐ #\ǒ #\ǔ #\ǚ #\ň) 3]
        [(#\à #\è #\ì #\ò #\ù #\ǜ #\ǹ) 4]
        [else 0]))
    ;; for searching the special char
    (define (pinyin->letter c)
      (case c
        [(#\ā #\á #\ǎ #\à) (set! tone (pinyin->tone c)) #\a]
        [(#\ē #\é #\ě #\è) (set! tone (pinyin->tone c)) #\e]
        [(#\ī #\í #\ǐ #\ì) (set! tone (pinyin->tone c)) #\i]
        [(#\ō #\ó #\ǒ #\ò) (set! tone (pinyin->tone c)) #\o]
        [(#\ū #\ú #\ǔ #\ù) (set! tone (pinyin->tone c)) #\u]
        [(#\ü #\ǖ #\ǘ #\ǚ #\ǜ) (set! tone (pinyin->tone c)) #\v]
        [(#\ń #\ň #\ǹ) (set! tone (pinyin->tone c)) #\n]
        [else c]))
    (let* ((chars (string->list pinyin)))
      (string-append (list->string (map pinyin->letter chars))
                     (if (eq? tone 0) "" (format "~a" tone))))))

(provide (except-out (all-defined-out)
                     remove-leading-newlines
                     origin-page-number
                     make-latex-entry-list
                     extract-name-part))
