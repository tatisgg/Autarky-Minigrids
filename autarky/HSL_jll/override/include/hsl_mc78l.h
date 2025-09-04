/*
 * COPYRIGHT (c) 2012 Science and Technology Facilities Council (STFC)
 * Original date 16 January 2012
 * All rights reserved
 *
 * Written by: Jonathan Hogg
 *
 * THIS FILE ONLY may be redistributed under the below modified BSD licence.
 * All other files distributed as part of the HSL_MC78 package
 * require a licence to be obtained from STFC and may NOT be redistributed
 * without permission. Please refer to your licence for HSL_MC78 for full terms
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
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ""AS IS""
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
#include <stdint.h>

#ifndef HSL_MC78_LONG_H
#define HSL_MC78_LONG_H

#ifndef mc78_control
#define mc78_control mc78_control_l
#define mc78_default_control mc78_default_control_l
#define mc78_analyse_asm mc78_analyse_asm_l
#define mc78_analyse_elt mc78_analyse_elt_l
#define mc78_supervars mc78_supervars_l
#define mc78_compress_by_svar mc78_compress_by_svar_l
#define mc78_etree mc78_etree_l
#define mc78_elt_equiv_etree mc78_elt_equiv_etree_l
#define mc78_postorder mc78_postorder_l
#define mc78_col_counts mc78_col_counts_l
#define mc78_supernodes mc78_supernodes_l
#define mc78_stats mc78_stats_l
#define mc78_row_lists_svar mc78_row_lists_svar_l
#define mc78_optimize_locality mc78_optimize_locality_l
#endif

typedef int64_t mc78_pkgtype_l_;

struct mc78_control_l {
   int f_arrays; /* Use 1-based indexing if true */
   int heuristic; /* 1=ma77 2=cholmod */
   int nrelax[3]; /* CHOLMOD-like parameters */
   double zrelax[3]; /* CHOLMOD-like parameters */
   int nemin; /* Node amalgamation parameter */

   int unit_error;
   int unit_warning;
   int ssa_abort; /* Abort on sym. singular matrix if true (else warning) */
   int svar; /* If true use supervariables in assembled case */
   int sort; /* If true sort entries within row lists */
   int lopt; /* If true optimize ordering for cache locality */
};

/* Set default values in control */
void mc78_default_control_l(struct mc78_control_l *control);

/* Wrapper interface */
int mc78_analyse_asm_l(int n, const mc78_pkgtype_l_ ptr[], const int row[],
      int perm[], int *nnodes, int **sptr, int **sparent, int64_t **rptr,
      int **rlist, const struct mc78_control_l *control, int *stat,
      int64_t *nfact, int64_t *nflops, int *piv_size);
int mc78_analyse_elt_l(int n, int nelt, const mc78_pkgtype_l_ starts[],
      const int vars[], int perm[], int eparent[], int *nnodes, int **sptr,
      int **sparent, int64_t **rptr, int **rlist,
      const struct mc78_control_l *control, int *stat,
      int64_t *nfact, int64_t *nflops, int *piv_size);

/* Expert interface */
int mc78_supervars_l(int *n, const mc78_pkgtype_l_ ptr[], const int row[],
      int perm[], int invp[], int *nsvar, int svar[]);
int mc78_compress_by_svar_l(int n, const mc78_pkgtype_l_ ptr[],
      const int row[], const int invp[], int nsvar, const int svar[],
      mc78_pkgtype_l_ ptr2[], mc78_pkgtype_l_ lrow2, int row2[], int *st);
int mc78_etree_l(int n, const mc78_pkgtype_l_ ptr[], const int row[],
      const int perm[], const int invp[], int parent[]);
int mc78_elt_equiv_etree_l(int *n, int nelt, const mc78_pkgtype_l_ starts[],
      const int vars[], int perm[], int invp[], int *nsvar, int svar[],
      mc78_pkgtype_l_ ptr[], int row[], int eparent[], int parent[],
      int block_pivots[]);
int mc78_postorder_l(int n, int *realn, const mc78_pkgtype_l_ ptr[],
      int perm[], int invp[], int parent[], int block_pivots[]);
int mc78_col_counts_l(int n, const mc78_pkgtype_l_ ptr[], const int row[],
      const int perm[], const int invp[], const int parent[], int cc[],
      const int wt[]);
int mc78_supernodes_l(int n, int realn, const int parent[], const int cc[],
      int sperm[], int *nnodes, int sptr[], int sparent[], int scc[],
      const int invp[], const struct mc78_control_l *control, int *st,
      const int wt[], const int block_pivots[]);
void mc78_stats_l(int nnodes, const int sptr[], const int scc[], int64_t *nfact,
      int64_t *nflops);
int mc78_row_lists_l(int nsvar, const int svar[], int n,
      const mc78_pkgtype_l_ ptr[], const int row[], const int perm[],
      const int invp[], const int nnodes, const int sptr[],
      const int sparent[], const int scc[], int64_t rptr[], int rlist[],
      const struct mc78_control_l *control, int *st);
int mc78_optimize_locality_l(int n, int realn, int perm[], int invp[],
      const int nnodes, const int sptr[], const int sparent[],
      const int64_t rptr[], int rlist[], int sort);

#endif
