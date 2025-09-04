/*
 * COPYRIGHT (c) 2011 Science and Technology Facilities Council (STFC)
 * Original date 1 November 2012
 * All rights reserved
 *
 * Written by: Jonathan Hogg
 *
 * Version 1.1.1
 *
 * THIS FILE ONLY may be redistributed under the below modified BSD licence.
 * All other files distributed as part of the HSL_MC79 package
 * require a licence to be obtained from STFC and may NOT be redistributed
 * without permission. Please refer to your licence for HSL_MC79 for full terms
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

#ifndef HSL_MC79I_H
#define HSL_MC79I_H

#ifndef mc79_default_control
#define mc79_control mc79_control_i
#define mc79_info mc79_info_i
#define mc79_default_control mc79_default_control_i
#define mc79_matching mc79_matching_i
#define mc79_coarse mc79_coarse_i
#define mc79_fine mc79_fine_i
#endif

typedef int mc79pkgtype_i_;

struct mc79_control_i {
   int f_arrays; /* Set to true if you are using 1-indexed arrays. */
   int lp; /* Fortran unit for error messages (6=stdout, <0=disabled) */
   int wp; /* Fortran unit for warning messages (6=stdout, <0=disabled) */
   int mp; /* Fortran unit for diagnostic messages (6=stdout, <0=disabled) */
   int print_level; /* Specify level of detail in messages */
};

struct mc79_info_i {
   int flag;      /* Return status */
   int hz_comps;  /* number of horizontal components after fine perm */
   int vt_comps;  /* number of vertical components after fine perm */
   int sq_comps;  /* number of components in square after fine perm */
   int m1; /* number of rows in R1 */
   int m2; /* number of rows in R2 */
   int m3; /* number of rows in R3 */
   int mbar; /* number of rows in Rbar */
   int n1; /* number of columns in C1 */
   int n2; /* number of columns in C2 */
   int n3; /* number of columns in C3 */
   int nbar; /* number of columns in Cbar */
   int stat; /* Fortran stat parameter */
};

/* Set default values of control */
void mc79_default_control_i(struct mc79_control_i *control);
/* Construct a maximum matching for matrix */
void mc79_matching_i(int m, int n, const mc79pkgtype_i_ ptr[], const int row[],
      int rowmatch[], int colmatch[], const struct mc79_control_i *control,
      struct mc79_info_i *info);
/* Construct row and column permutations of coarse Dulmage-Mendelsohn decomp. */
void mc79_coarse_i(int m, int n, const mc79pkgtype_i_ ptr[], const int row[],
      int rowperm[], int colperm[], const struct mc79_control_i *control,
      struct mc79_info_i *info);
/* Construct row and column permutations of fine Dulmage-Mendelsohn decomp. */
void mc79_fine_i(int m, int n, const mc79pkgtype_i_ ptr[], const int row[],
      int rowperm[], int colperm[], int rowcomp[], int colcomp[],
      const struct mc79_control_i *control, struct mc79_info_i *info);

#endif
