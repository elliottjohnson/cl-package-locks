= cl-package-locks =

Provides a uniform way of dealing with package locks across
common lisp implementations.

Let's look at how different common lisp implementations deal with
package locks.  This list is taken from:

  http://common-lisp.net/~dlw/LispSurvey.html 

AllegroCL: 
  Documented here: 
    http://franz.com/support/documentation/current/doc/packages.htm#package-locking-1

Armed Bear CL:
  Not found in documentation.

CMU CL:
  Documented here:
    http://common-lisp.net/project/cmucl/doc/cmu-user/extensions.html#toc26

Clozure CL:
  Not found in documentation.

Corman CL:
  Not found in documentation.

Embedded CL:
  Not found in documentation.

GNU CL:
  Not found in documentation.

GNU Clisp:
  Documented here:
    http://www.gnu.org/software/clisp/impnotes.html section 11.2

LispWorks:
  No documentation found... silencing warning possible.

Scieneer CL:
  Has a package lock, but seems for syncing multithreaded operations.
    
Steel Bank CL:
  Documented here:
    http://www.sbcl.org/manual/#Package-Locks
