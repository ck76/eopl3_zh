#lang racket/base
(require scriblib/autobib
         scriblib/bibtex)

(define-bibtex-cite "chapters/bibliography.bib" ~cite citet generate-bibliography
  #:style author+date-style)

(provide (all-defined-out))
