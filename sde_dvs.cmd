(sde:clear)
; Declacacion de variables
(define Alto 1)
(define Lg @Lg@)
(define tox @tox@)
(define Nds @Nds@)
(define Ndd @Ndd@)
(define Nas @Nas@)

; Calculo de coordenadas
(define Ltot (* Lg 1.5))
(define x1.sub 0)
(define x2.sub Ltot)

(define x1.source 0)
(define x2.source (* Lg 0.25))
(define y1.source 0)
(define y2.source 0.1)

(define x1.source.ext x2.source)
(define x2.source.ext (+ x1.source.ext 0.02))
(define y1.source.ext 0)
(define y2.source.ext 0.03)

(define x1.drain Ltot)
(define x2.drain (- x1.drain x2.source))
(define y1.drain 0)
(define y2.drain 0.1)

(define x1.drain.ext x2.drain)
(define x2.drain.ext (- x1.drain.ext 0.02))
(define y1.drain.ext 0)
(define y2.drain.ext 0.03)

(define x1.gate x1.source.ext)
(define x2.gate x1.drain.ext)
(define y1.gate 0)
(define y2.gate (- 0 tox))

(define vertice1.s (+ x1.source 0.01))
(define vertice2.s (- x2.source 0.01))
(define vertice1.d (- x1.drain 0.01))
(define vertice2.d (+ x2.drain 0.01))
(define vertice2.g (+ x1.gate 0.01))
(define vertice1.g (- x2.gate 0.01))

(define borde.s (+ (* (- vertice2.s vertice1.s) 0.5) vertice1.s))
(define borde.d (+ (* (- vertice2.d vertice1.d) 0.5) vertice1.d))
(define borde.g (+ (* (- vertice2.g vertice1.g) 0.5) vertice1.g))

(sdegeo:create-rectangle (position x1.sub 0 0)  (position x2.sub Alto 0) "Silicon" "substrato")
(sdegeo:create-rectangle (position x1.source y1.source 0)  (position x2.source y2.source 0) "Silicon" "source")
(sdegeo:create-rectangle (position x1.drain y1.drain 0)  (position x2.drain y2.drain 0) "Silicon" "drain")
(sdegeo:create-rectangle (position x1.source.ext y1.source.ext 0)  (position x2.source.ext y2.source.ext 0) "Silicon" "source_ext")
(sdegeo:create-rectangle (position x1.drain.ext y1.drain.ext 0)  (position x2.drain.ext y2.drain.ext 0) "Silicon" "drain_ext")
(sdegeo:create-rectangle (position x1.gate y1.gate 0)  (position x2.gate (- 0 tox) 0) "SiO2" "gate")

(sdegeo:fillet-2d (list (car (find-vertex-id (position x2.source y2.source 0)))) 0.02)
(sdegeo:fillet-2d (list (car (find-vertex-id (position x2.drain y2.drain 0)))) 0.02)
(sdegeo:fillet-2d (list (car (find-vertex-id (position x2.source.ext y2.source.ext 0)))) 0.01)
(sdegeo:fillet-2d (list (car (find-vertex-id (position x2.drain.ext y2.drain.ext 0)))) 0.01)

(sdegeo:insert-vertex (position vertice1.s 0 0))
(sdegeo:insert-vertex (position vertice2.s 0 0))
(sdegeo:insert-vertex (position vertice1.d 0 0))
(sdegeo:insert-vertex (position vertice2.d 0 0))
(sdegeo:insert-vertex (position vertice1.g (- 0 tox) 0))
(sdegeo:insert-vertex (position vertice2.g (- 0 tox) 0))

(sdegeo:define-contact-set "S" 4  (color:rgb 1 0 0 ) "##")
(sdegeo:define-contact-set "G" 4  (color:rgb 1 1 0 ) "##")
(sdegeo:define-contact-set "D" 4  (color:rgb 1 0 1 ) "##")
(sdegeo:define-contact-set "B" 4  (color:rgb 0 1 0 ) "##")

(sdegeo:set-current-contact-set "S")
(sdegeo:set-contact-edges (list (car (find-edge-id (position borde.s 0 0)))) "S")
(sdegeo:set-current-contact-set "G")
(sdegeo:set-contact-edges (list (car (find-edge-id (position borde.g (- 0 tox) 0)))) "G")
(sdegeo:set-current-contact-set "D")
(sdegeo:set-contact-edges (list (car (find-edge-id (position borde.d 0 0)))) "D")
(sdegeo:set-current-contact-set "B")
(sdegeo:set-contact-edges (list (car (find-edge-id (position (* Ltot 0.5) Alto 0)))) "B")

(sdedr:define-refeval-window "RefEvalWin.substrato" "Rectangle"  (position 0 0 0) (position x2.sub Alto 0))
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition.substrato" "BoronActiveConcentration" "PeakPos" 0  "PeakVal" Nas "StdDev" 0.1 "Gauss" "Factor" 1)
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement.substrato" "AnalyticalProfileDefinition.substrato" "RefEvalWin.substrato" "Positive" "NoReplace" "Eval" "substrato" 0.5 "Gauss" "region")

(sdedr:define-refeval-window "RefEvalWin.source" "Rectangle"  (position x1.source y1.source 0) (position x2.source y2.source 0))
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition.source" "PhosphorusActiveConcentration" "PeakPos" 0  "PeakVal" Nds "StdDev" 0.005 "Gauss" "Factor" 1)
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement.source" "AnalyticalProfileDefinition.source" "RefEvalWin.source" "Positive" "NoReplace" "Eval" "source" 0.005 "Gauss" "region")

(sdedr:define-refeval-window "RefEvalWin.source_ext" "Rectangle"  (position x1.source.ext y1.source.ext 0) (position x2.source.ext y2.source.ext 0))
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition.source_ext" "PhosphorusActiveConcentration" "PeakPos" 0  "PeakVal" 1e+16 "StdDev" 0.005 "Gauss" "Factor" 1)
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement.source_ext" "AnalyticalProfileDefinition.source_ext" "RefEvalWin.source_ext" "Positive" "NoReplace" "Eval" "source_ext" 0.005 "Gauss" "region")

(sdedr:define-refeval-window "RefEvalWin.drain" "Rectangle"  (position x1.drain y1.drain 0) (position x2.drain y2.drain 0))
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition.drain" "PhosphorusActiveConcentration" "PeakPos" 0  "PeakVal" Ndd "StdDev" 0.005 "Gauss" "Factor" 1)
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement.drain" "AnalyticalProfileDefinition.drain" "RefEvalWin.drain" "Positive" "NoReplace" "Eval" "drain" 0.005 "Gauss" "region")

(sdedr:define-refeval-window "RefEvalWin.drain_ext" "Rectangle"  (position x1.drain.ext y1.drain.ext 0) (position x2.drain.ext y2.drain.ext 0))
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition.drain_ext" "PhosphorusActiveConcentration" "PeakPos" 0  "PeakVal" 1e+16 "StdDev" 0.005 "Gauss" "Factor" 1)
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement.drain_ext" "AnalyticalProfileDefinition.drain_ext" "RefEvalWin.drain_ext" "Positive" "NoReplace" "Eval" "drain_ext" 0.005 "Gauss" "region")

(sdedr:define-refeval-window "RefEvalWin.total" "Rectangle" (position 0 (- 0 tox) 0) (position Ltot Alto 0))
(sdedr:define-refinement-size "RefinementDefinition.total" 0.02 0.02 0.01 0.01)
(sdedr:define-refinement-placement "RefinementPlacement.total" "RefinementDefinition.total" (list "window" "RefEvalWin.total"))

(sdedr:define-refeval-window "RefEvalWin.canal" "Rectangle" (position 0 y1.source 0.0) (position Ltot (- 0 tox) 0.0))
(sdedr:define-multibox-size "MultiboxDefinition.canal" 0.01 0.01 0.005 0.005 1 1.35)
(sdedr:define-multibox-placement "MultiboxPlacement.canal" "MultiboxDefinition.canal" "RefEvalWin.canal")

(sde:set-meshing-command "snmesh -a")
(sde:build-mesh "-a" "n@node@")
(sde:save-model "n@node@")
