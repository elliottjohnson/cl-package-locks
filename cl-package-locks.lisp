;;;; cl-package-locks.lisp

(in-package #:cl-package-locks)

(defun resolve-package (package)
  "Accepts multiple types of arguments and returns a package 
if found or errors if the type can not be resolved to a package.."
  (assert (atom package))
  (etypecase package
    (package package)
    (symbol (find-package package))
    (string (find-package (intern (string-upcase package)
				  (find-package 'keyword))))))

(defun resolve-packages (packages)
  "Resolves a list of package names to a list of packages or errors otherwise."
  (assert (listp packages))
  (let ((pkgs (mapcar #'resolve-package packages)))
    (unless (every #'packagep pkgs)
      (error "Failed to resolve packages ~S to ~S!" packages pkgs))
    pkgs))

(defun package-locked-p (package)
  "Returns true if a given resolveable PACKAGE is locked."
  (assert (atom package))
  (let ((pkg (resolve-package package)))
    #+allegro (values (excl:package-lock pkg) 
		      (excl:package-definition-lock pkg))
    #+clisp (ext:package-lock pkg)
    #+cmucl (values (ext:package-lock pkg)
		    (ext:package-definition-lock pkg))
    #+sb-package-locks (sb-ext:package-locked-p pkg)
    #-(or allegro clisp cmucl sb-package-locks) nil))

(defun locked-packages (packages)
  "Accepts a list of packages and returns those that are locked."
  (assert (listp packages))
  (loop for package in (resolve-packages packages)
     when (package-locked-p package)
     collect package))

(defun all-locked-packages ()
  "Returns a list of all locked packages."
  (locked-packages (list-all-packages)))

(defun unlocked-packages (packages)
  "Accepts a list of packages and returns those that are unlocked."
  (assert (listp packages))
  (loop for package in (resolve-packages packages)
     unless (package-locked-p package)
     collect package))

(defun all-unlocked-packages ()
  "Returns a list of all unlocked packages."
  (unlocked-packages (list-all-packages)))

(defun lock-package (package)
  "Locks a provided package."
  (assert (atom package))
  (let ((pkg (resolve-package package)))
    (when pkg
      #+allegro (setf (excl:package-lock pkg) t
		      (excl:package-definition-lock pkg) t)
      #+clisp (setf (ext:package-lock pkg) t)
      #+cmucl (setf (ext:package-lock pkg) t
		    (ext:package-definition-lock pkg) t)
      #+sb-package-locks (sb-ext:lock-package pkg)
      #-(or allegro clisp cmucl sb-package-locks) nil)))

(defun lock-packages (packages)
  "Locks the provided packages."
  (assert (listp packages))
  (loop for package in packages
     do (lock-package package)))

(defun unlock-package (package)
  "Unlocks a provided package."
  (assert (atom package))
  (let ((pkg (resolve-package package)))
    (when pkg
      #+allegro (setf (excl:package-lock pkg) nil
		      (excl:package-definition-lock pkg) nil)
      #+clisp (setf (ext:package-lock pkg) nil)
      #+cmucl (setf (ext:package-lock pkg) nil
		    (ext:package-definition-lock pkg) nil)
      #+sb-package-locks (sb-ext:unlock-package pkg)
      #-(or allegro clisp cmucl sb-package-locks) nil)))

(defun unlock-packages (packages)
  "Unlocks the provided packages."
  (assert (listp packages))
  (loop for package in packages
       do (unlock-package package)))

(defmacro with-packages-unlocked (packages &body body)
  "Accepts a list of packages that be unlocked for the duration 
of BODY and locked upon return."
  (let ((locked (gensym "packages")))
    `(let ((,locked (locked-packages ',packages)))
       (unlock-packages ,locked)
       (unwind-protect
	    ,@body
	 (lock-packages ,locked)))))

(defmacro without-package-locks (&body body)
  "Unlocks all packages for the duration of body."
  `(with-packages-unlocked ,(list-all-packages)
     ,@body))
