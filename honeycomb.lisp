(in-package :letcn)

(defun cell-pos (x y z)
  (values (+ (* x 0.5) (* z 0.5))
          (+ (* x 0.5) (* y 1.0) (* z 0.5))
          (+ (* x 0.5) (* z -0.5))))

(defun make-honeycomb (size)
  (let ((result (make-array (list size size size)
                            :element-type 'bit
                            :initial-element 0)))
    (dotimes (i size)
      (dotimes (j size)
        (dotimes (k size)
          (multiple-value-bind (x y z)
              (cell-pos i j k)
            (if (> 0 (* 10 (noise3d-octaves (/ x 10) (/ y 10) (/ z 10)
                                            3 0.25)))
                (setf (aref result i j k) 1))))))
    result))

(defun draw-honeycomb (hc)
  (dotimes (i (array-dimension hc 0))
    (dotimes (j (array-dimension hc 1))
      (dotimes (k (array-dimension hc 2))
        (unless (zerop (aref hc i j k))
          (gl:with-pushed-matrix
            (multiple-value-call #'gl:translate (cell-pos i j k))
            (draw-troct)))))))

;;; Draw truncated octahedron
(defun draw-troct ()
  (let* ((a 0.25)
         (-a (- a))
         (2a (* a 2))
         (-2a (- 2a))
         ;; five slices of different z, starting from x=0, going ccw
         (vertices `((0.0 ,a ,2a) (,-a 0.0 ,2a) (0.0 ,-a ,2a) (,a 0.0 ,2a)
                     (0.0 ,2a ,a) (,-2a 0.0 ,a) (0.0 ,-2a ,a) (,2a 0.0 ,a)
                     (,-a ,2a 0.0) (,-2a ,a 0.0) (,-2a ,-a 0.0) (,-a ,-2a 0.0) (,a ,-2a 0.0) (,2a ,-a 0.0) (,2a ,a 0.0) (,a ,2a 0.0)
                     (0.0 ,2a ,-a) (,-2a 0.0 ,-a) (0.0 ,-2a ,-a) (,2a 0.0 ,-a)
                     (0.0 ,a ,-2a) (,-a 0.0 ,-2a) (0.0 ,-a ,-2a) (,a 0.0 ,-2a))))
    (let (;; x = right, y = top, z = front/back
          (faces '((0 1 2 3)     ;; front
                   (4 15 16 8)   ;; top
                   (5 9 17 10)   ;; left
                   (6 11 18 12)  ;; bottom
                   (7 13 19 14)  ;; right
                   (20 23 22 21) ;; back
                   (0 3 7 14 15 4)     ;; right-top-front
                   (20 16 15 14 19 23) ;; right-top-back
                   (21 17 9 8 16 20)   ;; left-top-back
                   (0 4 8 9 5 1)       ;; left-top-front
                   (2 6 12 13 7 3)     ;; bottom-right-front
                   (23 19 13 12 18 22) ;; bottom-right-back
                   (22 18 11 10 17 21) ;; bottom-left-back
                   (1 5 10 11 6 2)     ;; bottom-left-front
                   )))
      (let* ((b (sqrt 1/3))
             (-b (- b))
             (normals `(( 0.0  0.0  1.0) ;; front
                        ( 0.0  1.0  0.0) ;; top
                        (-1.0  0.0  0.0) ;; left
                        ( 0.0 -1.0  0.0) ;; bottom
                        ( 1.0  0.0  0.0) ;; right
                        ( 0.0  0.0  1.0) ;; back
                        ( ,b  ,b  ,b) ;; right-top-front
                        ( ,b  ,b ,-b) ;; right-top-back
                        (,-b  ,b ,-b) ;; left-top-back
                        (,-b  ,b  ,b) ;; left-top-front
                        ( ,b ,-b  ,b) ;; right-bottom-front
                        ( ,b ,-b ,-b) ;; right-bottom-back
                        (,-b ,-b ,-b) ;; left-bottom-back
                        (,-b ,-b  ,b) ;; left-bottom-front
                        )))
             (loop for f in faces
                   for n in normals
                   do (gl:with-primitives :polygon
                        (apply #'gl:normal n)
                        (loop for v in f
                              do (apply #'gl:vertex (nth v vertices)))))))))