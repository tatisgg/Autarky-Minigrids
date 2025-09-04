/*
 * COPYRIGHT (c) 2023 Science and Technology Facilities Council (STFC)
 * Original date 27 March 2023
 * All rights reserved
 *
 * Written by: Niall Bootland
 *
 * THIS FILE ONLY may be redistributed under the modified BSD licence below.
 * All other files distributed as part of the HSL_MI28 package
 * require a licence to be obtained from STFC and may NOT be redistributed
 * without permission. Please refer to your licence for HSL_MI28 for full terms
 * and conditions. STFC may be contacted via hsl(at)stfc.ac.uk.
 *
 * Modified BSD licence (this header file only):
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of STFC nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL STFC BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

#ifndef HSL_MI28S_H /* start include guard */
#define HSL_MI28S_H

#ifndef mi28_control
#define mi28_control mi28_control_s
#define mi28_info mi28_info_s
#define mi28_default_control mi28_default_control_s
#define mi28_factorize mi28_factorize_s
#define mi28_precondition mi28_precondition_s
#define mi28_solve mi28_solve_s
#define mi28_finalise mi28_finalise_s
#endif

typedef float mi28pkgtype_s_;

/* Derived type to hold control parameters for hsl_mi28 */
struct mi28_control_s {
   int f_arrays;           /* use 1-based indexing if true(!=0) else 0-based */
   mi28pkgtype_s_ alpha;   /* initial shift */
   bool check;             /* if set to true, user's data is checked.
        ! Otherwise, no checking and may fail in unexpected way if
        ! there are duplicates/out-of-range entries. */
   int iorder;             /* controls ordering of A. Options:
!       ! <=0  no ordering
!       !   1  RCM
!       !   2  AMD
!       !   3  user-supplied ordering
!       !   4  ascending degree
!       !   5  Metis
!       ! >=6  Sloan (MC61) */
   int iscale;             /* controls whether scaling is used.
        ! iscale = 1 is Lin and More scaling (l2 scaling)
        ! iscale = 2 is mc77 scaling
        ! iscale = 3 is mc64 scaling
        ! iscale = 4 is diagonal scaling
        ! iscale = 5 user-supplied scaling
        ! iscale <= 0, no scaling
        ! iscale >= 6, Lin and More */
   mi28pkgtype_s_ lowalpha; /* Shift after first breakdown is
        ! max(shift_factor*alpha,lowalpha) */
   int maxshift;           /* During search for shift, we decrease
        ! the lower bound max(alpha,lowalpha) on the shift by
        ! shift_factor2 at most maxshift times (so this limits the
        ! number of refactorizations that are performed ... idea is
        ! reducing alpha as much as possible will give better preconditioner
        ! but reducing too far will lead to breakdown and then a refactorization
        ! is required (expensive so limit number of reductions)
        ! Note: Lin and More set this to 3. */
   bool rrt;               /* controls whether entries of RR^T that cause no
        ! additional fill are allowed. They are allowed if
        ! rrt = true and not otherwise. */
   mi28pkgtype_s_ shift_factor;  /* if the current shift is found
        ! to be too small, it is increased by at least a factor of shift_factor.
        ! Values <= 1.0 are treated as default. */
   mi28pkgtype_s_ shift_factor2; /* if factorization is successful
        ! with current (non zero) shift, the shift
        ! is reduced by a factor of shift_factor2.
        ! Values <= 1.0 are treated as default. */
   mi28pkgtype_s_ small;   /* small value */
   mi28pkgtype_s_ tau1;    /* used to select "small" entries that
        ! are dropped from L (but may be included in R).  */
   mi28pkgtype_s_ tau2;    /* used to select "tiny" entries that are
        ! dropped from R.  Require
        ! tau2 < tau1 (otherwise, tau2 = 0.0 is used locally). */
   int unit_error;         /* unit number for error messages.
        ! Printing is suppressed if unit_error  <  0. */
   int unit_warning;       /* unit number for warning messages.
        ! Printing is suppressed if unit_warning  <  0. */
};

/* Communicates errors and information to the user. */
struct mi28_info_s {
  int band_after;          /* semibandwidth after MC61 */
  int band_before;         /* semibandwidth before MC61 */
  int dup;                 /* number of duplicated entries found in row */
  int flag;                /* error flag */
  int flag61;              /* error flag from mc61 */
  int flag64;              /* error flag from hsl_mc64 */
  int flag68;              /* error flag from hsl_mc68 */
  int flag77;              /* error flag from mc77 */
  int nrestart;            /* number of restarts (after reducing the shift) */
  int nshift;              /* number of non-zero shifts used */
  int oor;                 /* number of out-of-range entries found in row */
  mi28pkgtype_s_ profile_before; /* semibandwidth before MC61 */
  mi28pkgtype_s_ profile_after;  /* semibandwidth after MC61 */
  int64_t size_r;          /* size of arrays jr and ar that are used for r */
  int stat;                /* Fortran stat parameter */
  mi28pkgtype_s_ alpha;    /* on successful exit, holds shift used */
};

/* Set default values of control */
void mi28_default_control_s(struct mi28_control *control);
/* Perform the factorize operation */
void mi28_factorize_s(const int n, int ptr[], int row[],
      mi28pkgtype_s_ val[], const int lsize, const int rsize, void **keep,
      const struct mi28_control_s *control, struct mi28_info_s *info,
      const mi28pkgtype_s_ scale[], const int perm[]);
/* Perform the preconditioning operation */
void mi28_precondition_s(const int n, void **keep, const mi28pkgtype_s_ z[],
      mi28pkgtype_s_ y[], struct mi28_info_s *info);
/* Perform the solve operation */
void mi28_solve_s(const bool trans, const int n, void **keep,
      const mi28pkgtype_s_ z[], mi28pkgtype_s_ y[], struct mi28_info_s *info);
/* Free memory */
void mi28_finalise_s(void **keep, struct mi28_info_s *info);

#endif /* end include guard */

#ifdef __cplusplus
} /* end extern "C" */
#endif
