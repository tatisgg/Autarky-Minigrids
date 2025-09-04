/*
 * COPYRIGHT (c) 2023--present Science and Technology Facilities Council (STFC)
 * All rights reserved
 *
 * Written by: Alexis Montoison
 *
 * THIS FILE ONLY may be redistributed under the below modified BSD licence.
 * All other files distributed as part of the libHSL package
 * require a licence to be obtained from STFC and may NOT be redistributed
 * without permission. Please refer to your licence for libHSL for full terms
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

#include <stdbool.h>

#ifndef _LIBHSL_H_
#define _LIBHSL_H_ 

bool LIBHSL_isfunctional();

/* Version number of LIBHSL */
#define LIBHSL_VER_MAJOR 2023
#define LIBHSL_VER_MINOR 11
#define LIBHSL_VER_PATCH 7
void LIBHSL_version(int *major, int *minor, int *patch);

/* Version number of HSL_AD02 */
#define HSL_AD02_VER_MAJOR 1
#define HSL_AD02_VER_MINOR 1
#define HSL_AD02_VER_PATCH 0
void HSL_AD02_version(int *major, int *minor, int *patch);

/* Version number of HSL_ZD13 */
#define HSL_ZD13_VER_MAJOR 1
#define HSL_ZD13_VER_MINOR 0
#define HSL_ZD13_VER_PATCH 0
void HSL_ZD13_version(int *major, int *minor, int *patch);

/* Version number of MA27 */
#define MA27_VER_MAJOR 1
#define MA27_VER_MINOR 0
#define MA27_VER_PATCH 0
void MA27_version(int *major, int *minor, int *patch);

/* Version number of MA28 */
#define MA28_VER_MAJOR 1
#define MA28_VER_MINOR 0
#define MA28_VER_PATCH 0
void MA28_version(int *major, int *minor, int *patch);

/* Version number of MA30 */
#define MA30_VER_MAJOR 1
#define MA30_VER_MINOR 0
#define MA30_VER_PATCH 0
void MA30_version(int *major, int *minor, int *patch);

/* Version number of MA33 */
#define MA33_VER_MAJOR 1
#define MA33_VER_MINOR 0
#define MA33_VER_PATCH 0
void MA33_version(int *major, int *minor, int *patch);

/* Version number of MC19 */
#define MC19_VER_MAJOR 1
#define MC19_VER_MINOR 0
#define MC19_VER_PATCH 0
void MC19_version(int *major, int *minor, int *patch);

/* Version number of MC20 */
#define MC20_VER_MAJOR 1
#define MC20_VER_MINOR 0
#define MC20_VER_PATCH 0
void MC20_version(int *major, int *minor, int *patch);

/* Version number of MC23 */
#define MC23_VER_MAJOR 1
#define MC23_VER_MINOR 0
#define MC23_VER_PATCH 0
void MC23_version(int *major, int *minor, int *patch);

/* Version number of MC24 */
#define MC24_VER_MAJOR 1
#define MC24_VER_MINOR 0
#define MC24_VER_PATCH 0
void MC24_version(int *major, int *minor, int *patch);

/* Version number of TD22 */
#define TD22_VER_MAJOR 1
#define TD22_VER_MINOR 1
#define TD22_VER_PATCH 0
void TD22_version(int *major, int *minor, int *patch);

/* Version number of BTF */
#define BTF_VER_MAJOR 1
#define BTF_VER_MINOR 0
#define BTF_VER_PATCH 0
void BTF_version(int *major, int *minor, int *patch);

/* Version number of FA01 */
#define FA01_VER_MAJOR 1
#define FA01_VER_MINOR 0
#define FA01_VER_PATCH 0
void FA01_version(int *major, int *minor, int *patch);

/* Version number of FA04 */
#define FA04_VER_MAJOR 1
#define FA04_VER_MINOR 0
#define FA04_VER_PATCH 0
void FA04_version(int *major, int *minor, int *patch);

/* Version number of FD05 */
#define FD05_VER_MAJOR 1
#define FD05_VER_MINOR 0
#define FD05_VER_PATCH 0
void FD05_version(int *major, int *minor, int *patch);

/* Version number of ID05 */
#define ID05_VER_MAJOR 1
#define ID05_VER_MINOR 0
#define ID05_VER_PATCH 0
void ID05_version(int *major, int *minor, int *patch);

/* Version number of MC36 */
#define MC36_VER_MAJOR 1
#define MC36_VER_MINOR 0
#define MC36_VER_PATCH 0
void MC36_version(int *major, int *minor, int *patch);

/* Version number of MC49 */
#define MC49_VER_MAJOR 1
#define MC49_VER_MINOR 0
#define MC49_VER_PATCH 0
void MC49_version(int *major, int *minor, int *patch);

/* Version number of ME20 */
#define ME20_VER_MAJOR 1
#define ME20_VER_MINOR 0
#define ME20_VER_PATCH 0
void ME20_version(int *major, int *minor, int *patch);

/* Version number of MF36 */
#define MF36_VER_MAJOR 1
#define MF36_VER_MINOR 0
#define MF36_VER_PATCH 0
void MF36_version(int *major, int *minor, int *patch);

/* Version number of YM01 */
#define YM01_VER_MAJOR 1
#define YM01_VER_MINOR 0
#define YM01_VER_PATCH 0
void YM01_version(int *major, int *minor, int *patch);

/* Version number of EA16 */
#define EA16_VER_MAJOR 1
#define EA16_VER_MINOR 4
#define EA16_VER_PATCH 1
void EA16_version(int *major, int *minor, int *patch);

/* Version number of EA22 */
#define EA22_VER_MAJOR 1
#define EA22_VER_MINOR 2
#define EA22_VER_PATCH 0
void EA22_version(int *major, int *minor, int *patch);

/* Version number of EA25 */
#define EA25_VER_MAJOR 1
#define EA25_VER_MINOR 1
#define EA25_VER_PATCH 0
void EA25_version(int *major, int *minor, int *patch);

/* Version number of EB13 */
#define EB13_VER_MAJOR 1
#define EB13_VER_MINOR 1
#define EB13_VER_PATCH 3
void EB13_version(int *major, int *minor, int *patch);

/* Version number of EB22 */
#define EB22_VER_MAJOR 1
#define EB22_VER_MINOR 2
#define EB22_VER_PATCH 2
void EB22_version(int *major, int *minor, int *patch);

/* Version number of EP25 */
#define EP25_VER_MAJOR 2
#define EP25_VER_MINOR 0
#define EP25_VER_PATCH 0
void EP25_version(int *major, int *minor, int *patch);

/* Version number of FA14 */
#define FA14_VER_MAJOR 1
#define FA14_VER_MINOR 0
#define FA14_VER_PATCH 1
void FA14_version(int *major, int *minor, int *patch);

/* Version number of FD15 */
#define FD15_VER_MAJOR 1
#define FD15_VER_MINOR 0
#define FD15_VER_PATCH 0
void FD15_version(int *major, int *minor, int *patch);

/* Version number of HSL_EA19 */
#define HSL_EA19_VER_MAJOR 1
#define HSL_EA19_VER_MINOR 4
#define HSL_EA19_VER_PATCH 2
void HSL_EA19_version(int *major, int *minor, int *patch);

/* Version number of HSL_EA20 */
#define HSL_EA20_VER_MAJOR 1
#define HSL_EA20_VER_MINOR 1
#define HSL_EA20_VER_PATCH 0
void HSL_EA20_version(int *major, int *minor, int *patch);

/* Version number of HSL_FA14 */
#define HSL_FA14_VER_MAJOR 1
#define HSL_FA14_VER_MINOR 1
#define HSL_FA14_VER_PATCH 0
void HSL_FA14_version(int *major, int *minor, int *patch);

/* Version number of HSL_KB22 */
#define HSL_KB22_VER_MAJOR 1
#define HSL_KB22_VER_MINOR 0
#define HSL_KB22_VER_PATCH 0
void HSL_KB22_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA42 */
#define HSL_MA42_VER_MAJOR 1
#define HSL_MA42_VER_MINOR 3
#define HSL_MA42_VER_PATCH 0
void HSL_MA42_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA42_ELEMENT */
#define HSL_MA42_ELEMENT_VER_MAJOR 3
#define HSL_MA42_ELEMENT_VER_MINOR 0
#define HSL_MA42_ELEMENT_VER_PATCH 0
void HSL_MA42_ELEMENT_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA48 */
#define HSL_MA48_VER_MAJOR 3
#define HSL_MA48_VER_MINOR 4
#define HSL_MA48_VER_PATCH 1
void HSL_MA48_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA54 */
#define HSL_MA54_VER_MAJOR 1
#define HSL_MA54_VER_MINOR 4
#define HSL_MA54_VER_PATCH 2
void HSL_MA54_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA55 */
#define HSL_MA55_VER_MAJOR 1
#define HSL_MA55_VER_MINOR 2
#define HSL_MA55_VER_PATCH 0
void HSL_MA55_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA57 */
#define HSL_MA57_VER_MAJOR 5
#define HSL_MA57_VER_MINOR 3
#define HSL_MA57_VER_PATCH 2
void HSL_MA57_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA64 */
#define HSL_MA64_VER_MAJOR 6
#define HSL_MA64_VER_MINOR 3
#define HSL_MA64_VER_PATCH 1
void HSL_MA64_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA69 */
#define HSL_MA69_VER_MAJOR 1
#define HSL_MA69_VER_MINOR 0
#define HSL_MA69_VER_PATCH 0
void HSL_MA69_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA74 */
#define HSL_MA74_VER_MAJOR 1
#define HSL_MA74_VER_MINOR 5
#define HSL_MA74_VER_PATCH 0
void HSL_MA74_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA77 */
#define HSL_MA77_VER_MAJOR 6
#define HSL_MA77_VER_MINOR 4
#define HSL_MA77_VER_PATCH 0
void HSL_MA77_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA78 */
#define HSL_MA78_VER_MAJOR 3
#define HSL_MA78_VER_MINOR 6
#define HSL_MA78_VER_PATCH 0
void HSL_MA78_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA79 */
#define HSL_MA79_VER_MAJOR 1
#define HSL_MA79_VER_MINOR 2
#define HSL_MA79_VER_PATCH 0
void HSL_MA79_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA85 */
#define HSL_MA85_VER_MAJOR 1
#define HSL_MA85_VER_MINOR 3
#define HSL_MA85_VER_PATCH 0
void HSL_MA85_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA86 */
#define HSL_MA86_VER_MAJOR 1
#define HSL_MA86_VER_MINOR 7
#define HSL_MA86_VER_PATCH 3
void HSL_MA86_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA87 */
#define HSL_MA87_VER_MAJOR 2
#define HSL_MA87_VER_MINOR 6
#define HSL_MA87_VER_PATCH 5
void HSL_MA87_version(int *major, int *minor, int *patch);

/* Version number of HSL_MA97 */
#define HSL_MA97_VER_MAJOR 2
#define HSL_MA97_VER_MINOR 8
#define HSL_MA97_VER_PATCH 0
void HSL_MA97_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC34 */
#define HSL_MC34_VER_MAJOR 1
#define HSL_MC34_VER_MINOR 1
#define HSL_MC34_VER_PATCH 0
void HSL_MC34_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC56 */
#define HSL_MC56_VER_MAJOR 1
#define HSL_MC56_VER_MINOR 1
#define HSL_MC56_VER_PATCH 0
void HSL_MC56_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC64 */
#define HSL_MC64_VER_MAJOR 2
#define HSL_MC64_VER_MINOR 4
#define HSL_MC64_VER_PATCH 2
void HSL_MC64_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC65 */
#define HSL_MC65_VER_MAJOR 2
#define HSL_MC65_VER_MINOR 3
#define HSL_MC65_VER_PATCH 0
void HSL_MC65_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC66 */
#define HSL_MC66_VER_MAJOR 2
#define HSL_MC66_VER_MINOR 2
#define HSL_MC66_VER_PATCH 1
void HSL_MC66_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC68 */
#define HSL_MC68_VER_MAJOR 3
#define HSL_MC68_VER_MINOR 3
#define HSL_MC68_VER_PATCH 3
void HSL_MC68_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC69 */
#define HSL_MC69_VER_MAJOR 1
#define HSL_MC69_VER_MINOR 4
#define HSL_MC69_VER_PATCH 2
void HSL_MC69_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC73 */
#define HSL_MC73_VER_MAJOR 2
#define HSL_MC73_VER_MINOR 8
#define HSL_MC73_VER_PATCH 1
void HSL_MC73_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC78 */
#define HSL_MC78_VER_MAJOR 1
#define HSL_MC78_VER_MINOR 6
#define HSL_MC78_VER_PATCH 1
void HSL_MC78_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC79 */
#define HSL_MC79_VER_MAJOR 1
#define HSL_MC79_VER_MINOR 1
#define HSL_MC79_VER_PATCH 1
void HSL_MC79_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC80 */
#define HSL_MC80_VER_MAJOR 1
#define HSL_MC80_VER_MINOR 1
#define HSL_MC80_VER_PATCH 3
void HSL_MC80_version(int *major, int *minor, int *patch);

/* Version number of HSL_MC81 */
#define HSL_MC81_VER_MAJOR 1
#define HSL_MC81_VER_MINOR 0
#define HSL_MC81_VER_PATCH 0
void HSL_MC81_version(int *major, int *minor, int *patch);

/* Version number of HSL_ME57 */
#define HSL_ME57_VER_MAJOR 1
#define HSL_ME57_VER_MINOR 1
#define HSL_ME57_VER_PATCH 3
void HSL_ME57_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI02 */
#define HSL_MI02_VER_MAJOR 1
#define HSL_MI02_VER_MINOR 0
#define HSL_MI02_VER_PATCH 0
void HSL_MI02_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI13 */
#define HSL_MI13_VER_MAJOR 1
#define HSL_MI13_VER_MINOR 2
#define HSL_MI13_VER_PATCH 0
void HSL_MI13_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI20 */
#define HSL_MI20_VER_MAJOR 2
#define HSL_MI20_VER_MINOR 1
#define HSL_MI20_VER_PATCH 0
void HSL_MI20_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI27 */
#define HSL_MI27_VER_MAJOR 1
#define HSL_MI27_VER_MINOR 1
#define HSL_MI27_VER_PATCH 0
void HSL_MI27_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI28 */
#define HSL_MI28_VER_MAJOR 2
#define HSL_MI28_VER_MINOR 4
#define HSL_MI28_VER_PATCH 1
void HSL_MI28_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI29 */
#define HSL_MI29_VER_MAJOR 1
#define HSL_MI29_VER_MINOR 1
#define HSL_MI29_VER_PATCH 0
void HSL_MI29_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI30 */
#define HSL_MI30_VER_MAJOR 1
#define HSL_MI30_VER_MINOR 4
#define HSL_MI30_VER_PATCH 0
void HSL_MI30_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI31 */
#define HSL_MI31_VER_MAJOR 1
#define HSL_MI31_VER_MINOR 2
#define HSL_MI31_VER_PATCH 1
void HSL_MI31_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI32 */
#define HSL_MI32_VER_MAJOR 1
#define HSL_MI32_VER_MINOR 1
#define HSL_MI32_VER_PATCH 0
void HSL_MI32_version(int *major, int *minor, int *patch);

/* Version number of HSL_MI35 */
#define HSL_MI35_VER_MAJOR 2
#define HSL_MI35_VER_MINOR 1
#define HSL_MI35_VER_PATCH 0
void HSL_MI35_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP01 */
#define HSL_MP01_VER_MAJOR 1
#define HSL_MP01_VER_MINOR 1
#define HSL_MP01_VER_PATCH 0
void HSL_MP01_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP42 */
#define HSL_MP42_VER_MAJOR 2
#define HSL_MP42_VER_MINOR 0
#define HSL_MP42_VER_PATCH 0
void HSL_MP42_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP43 */
#define HSL_MP43_VER_MAJOR 2
#define HSL_MP43_VER_MINOR 1
#define HSL_MP43_VER_PATCH 0
void HSL_MP43_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP48 */
#define HSL_MP48_VER_MAJOR 2
#define HSL_MP48_VER_MINOR 1
#define HSL_MP48_VER_PATCH 0
void HSL_MP48_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP54 */
#define HSL_MP54_VER_MAJOR 1
#define HSL_MP54_VER_MINOR 2
#define HSL_MP54_VER_PATCH 0
void HSL_MP54_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP62 */
#define HSL_MP62_VER_MAJOR 2
#define HSL_MP62_VER_MINOR 1
#define HSL_MP62_VER_PATCH 0
void HSL_MP62_version(int *major, int *minor, int *patch);

/* Version number of HSL_MP82 */
#define HSL_MP82_VER_MAJOR 1
#define HSL_MP82_VER_MINOR 0
#define HSL_MP82_VER_PATCH 1
void HSL_MP82_version(int *major, int *minor, int *patch);

/* Version number of HSL_OF01 */
#define HSL_OF01_VER_MAJOR 3
#define HSL_OF01_VER_MINOR 3
#define HSL_OF01_VER_PATCH 0
void HSL_OF01_version(int *major, int *minor, int *patch);

/* Version number of HSL_ZB01 */
#define HSL_ZB01_VER_MAJOR 3
#define HSL_ZB01_VER_MINOR 0
#define HSL_ZB01_VER_PATCH 0
void HSL_ZB01_version(int *major, int *minor, int *patch);

/* Version number of HSL_ZD11 */
#define HSL_ZD11_VER_MAJOR 1
#define HSL_ZD11_VER_MINOR 1
#define HSL_ZD11_VER_PATCH 0
void HSL_ZD11_version(int *major, int *minor, int *patch);

/* Version number of KB05 */
#define KB05_VER_MAJOR 1
#define KB05_VER_MINOR 0
#define KB05_VER_PATCH 0
void KB05_version(int *major, int *minor, int *patch);

/* Version number of KB06 */
#define KB06_VER_MAJOR 1
#define KB06_VER_MINOR 0
#define KB06_VER_PATCH 0
void KB06_version(int *major, int *minor, int *patch);

/* Version number of KB07 */
#define KB07_VER_MAJOR 1
#define KB07_VER_MINOR 0
#define KB07_VER_PATCH 0
void KB07_version(int *major, int *minor, int *patch);

/* Version number of KB08 */
#define KB08_VER_MAJOR 1
#define KB08_VER_MINOR 0
#define KB08_VER_PATCH 0
void KB08_version(int *major, int *minor, int *patch);

/* Version number of LA04 */
#define LA04_VER_MAJOR 1
#define LA04_VER_MINOR 2
#define LA04_VER_PATCH 0
void LA04_version(int *major, int *minor, int *patch);

/* Version number of LA15 */
#define LA15_VER_MAJOR 1
#define LA15_VER_MINOR 3
#define LA15_VER_PATCH 0
void LA15_version(int *major, int *minor, int *patch);

/* Version number of MA38 */
#define MA38_VER_MAJOR 1
#define MA38_VER_MINOR 3
#define MA38_VER_PATCH 0
void MA38_version(int *major, int *minor, int *patch);

/* Version number of MA41 */
#define MA41_VER_MAJOR 1
#define MA41_VER_MINOR 2
#define MA41_VER_PATCH 0
void MA41_version(int *major, int *minor, int *patch);

/* Version number of MA42 */
#define MA42_VER_MAJOR 1
#define MA42_VER_MINOR 3
#define MA42_VER_PATCH 0
void MA42_version(int *major, int *minor, int *patch);

/* Version number of MA43 */
#define MA43_VER_MAJOR 1
#define MA43_VER_MINOR 0
#define MA43_VER_PATCH 1
void MA43_version(int *major, int *minor, int *patch);

/* Version number of MA44 */
#define MA44_VER_MAJOR 1
#define MA44_VER_MINOR 0
#define MA44_VER_PATCH 0
void MA44_version(int *major, int *minor, int *patch);

/* Version number of MA46 */
#define MA46_VER_MAJOR 1
#define MA46_VER_MINOR 0
#define MA46_VER_PATCH 1
void MA46_version(int *major, int *minor, int *patch);

/* Version number of MA48 */
#define MA48_VER_MAJOR 2
#define MA48_VER_MINOR 2
#define MA48_VER_PATCH 0
void MA48_version(int *major, int *minor, int *patch);

/* Version number of MA49 */
#define MA49_VER_MAJOR 2
#define MA49_VER_MINOR 0
#define MA49_VER_PATCH 1
void MA49_version(int *major, int *minor, int *patch);

/* Version number of MA50 */
#define MA50_VER_MAJOR 2
#define MA50_VER_MINOR 0
#define MA50_VER_PATCH 0
void MA50_version(int *major, int *minor, int *patch);

/* Version number of MA51 */
#define MA51_VER_MAJOR 1
#define MA51_VER_MINOR 0
#define MA51_VER_PATCH 0
void MA51_version(int *major, int *minor, int *patch);

/* Version number of MA52 */
#define MA52_VER_MAJOR 1
#define MA52_VER_MINOR 0
#define MA52_VER_PATCH 1
void MA52_version(int *major, int *minor, int *patch);

/* Version number of MA57 */
#define MA57_VER_MAJOR 3
#define MA57_VER_MINOR 11
#define MA57_VER_PATCH 2
void MA57_version(int *major, int *minor, int *patch);

/* Version number of MA60 */
#define MA60_VER_MAJOR 1
#define MA60_VER_MINOR 2
#define MA60_VER_PATCH 0
void MA60_version(int *major, int *minor, int *patch);

/* Version number of MA61 */
#define MA61_VER_MAJOR 1
#define MA61_VER_MINOR 1
#define MA61_VER_PATCH 0
void MA61_version(int *major, int *minor, int *patch);

/* Version number of MA62 */
#define MA62_VER_MAJOR 1
#define MA62_VER_MINOR 0
#define MA62_VER_PATCH 0
void MA62_version(int *major, int *minor, int *patch);

/* Version number of MA65 */
#define MA65_VER_MAJOR 1
#define MA65_VER_MINOR 0
#define MA65_VER_PATCH 2
void MA65_version(int *major, int *minor, int *patch);

/* Version number of MA67 */
#define MA67_VER_MAJOR 1
#define MA67_VER_MINOR 0
#define MA67_VER_PATCH 2
void MA67_version(int *major, int *minor, int *patch);

/* Version number of MA69 */
#define MA69_VER_MAJOR 1
#define MA69_VER_MINOR 0
#define MA69_VER_PATCH 0
void MA69_version(int *major, int *minor, int *patch);

/* Version number of MA72 */
#define MA72_VER_MAJOR 1
#define MA72_VER_MINOR 0
#define MA72_VER_PATCH 0
void MA72_version(int *major, int *minor, int *patch);

/* Version number of MA75 */
#define MA75_VER_MAJOR 1
#define MA75_VER_MINOR 1
#define MA75_VER_PATCH 1
void MA75_version(int *major, int *minor, int *patch);

/* Version number of MC13 */
#define MC13_VER_MAJOR 1
#define MC13_VER_MINOR 0
#define MC13_VER_PATCH 0
void MC13_version(int *major, int *minor, int *patch);

/* Version number of MC21 */
#define MC21_VER_MAJOR 1
#define MC21_VER_MINOR 0
#define MC21_VER_PATCH 0
void MC21_version(int *major, int *minor, int *patch);

/* Version number of MC22 */
#define MC22_VER_MAJOR 1
#define MC22_VER_MINOR 0
#define MC22_VER_PATCH 0
void MC22_version(int *major, int *minor, int *patch);

/* Version number of MC25 */
#define MC25_VER_MAJOR 1
#define MC25_VER_MINOR 0
#define MC25_VER_PATCH 0
void MC25_version(int *major, int *minor, int *patch);

/* Version number of MC26 */
#define MC26_VER_MAJOR 1
#define MC26_VER_MINOR 0
#define MC26_VER_PATCH 0
void MC26_version(int *major, int *minor, int *patch);

/* Version number of MC29 */
#define MC29_VER_MAJOR 1
#define MC29_VER_MINOR 0
#define MC29_VER_PATCH 0
void MC29_version(int *major, int *minor, int *patch);

/* Version number of MC30 */
#define MC30_VER_MAJOR 1
#define MC30_VER_MINOR 0
#define MC30_VER_PATCH 0
void MC30_version(int *major, int *minor, int *patch);

/* Version number of MC33 */
#define MC33_VER_MAJOR 1
#define MC33_VER_MINOR 0
#define MC33_VER_PATCH 0
void MC33_version(int *major, int *minor, int *patch);

/* Version number of MC34 */
#define MC34_VER_MAJOR 1
#define MC34_VER_MINOR 0
#define MC34_VER_PATCH 0
void MC34_version(int *major, int *minor, int *patch);

/* Version number of MC37 */
#define MC37_VER_MAJOR 1
#define MC37_VER_MINOR 0
#define MC37_VER_PATCH 0
void MC37_version(int *major, int *minor, int *patch);

/* Version number of MC38 */
#define MC38_VER_MAJOR 1
#define MC38_VER_MINOR 0
#define MC38_VER_PATCH 0
void MC38_version(int *major, int *minor, int *patch);

/* Version number of MC44 */
#define MC44_VER_MAJOR 1
#define MC44_VER_MINOR 0
#define MC44_VER_PATCH 0
void MC44_version(int *major, int *minor, int *patch);

/* Version number of MC46 */
#define MC46_VER_MAJOR 1
#define MC46_VER_MINOR 0
#define MC46_VER_PATCH 0
void MC46_version(int *major, int *minor, int *patch);

/* Version number of MC47 */
#define MC47_VER_MAJOR 2
#define MC47_VER_MINOR 1
#define MC47_VER_PATCH 0
void MC47_version(int *major, int *minor, int *patch);

/* Version number of MC53 */
#define MC53_VER_MAJOR 1
#define MC53_VER_MINOR 1
#define MC53_VER_PATCH 0
void MC53_version(int *major, int *minor, int *patch);

/* Version number of MC54 */
#define MC54_VER_MAJOR 1
#define MC54_VER_MINOR 0
#define MC54_VER_PATCH 1
void MC54_version(int *major, int *minor, int *patch);

/* Version number of MC55 */
#define MC55_VER_MAJOR 1
#define MC55_VER_MINOR 0
#define MC55_VER_PATCH 0
void MC55_version(int *major, int *minor, int *patch);

/* Version number of MC56 */
#define MC56_VER_MAJOR 1
#define MC56_VER_MINOR 1
#define MC56_VER_PATCH 1
void MC56_version(int *major, int *minor, int *patch);

/* Version number of MC57 */
#define MC57_VER_MAJOR 1
#define MC57_VER_MINOR 1
#define MC57_VER_PATCH 0
void MC57_version(int *major, int *minor, int *patch);

/* Version number of MC58 */
#define MC58_VER_MAJOR 1
#define MC58_VER_MINOR 0
#define MC58_VER_PATCH 0
void MC58_version(int *major, int *minor, int *patch);

/* Version number of MC59 */
#define MC59_VER_MAJOR 1
#define MC59_VER_MINOR 0
#define MC59_VER_PATCH 2
void MC59_version(int *major, int *minor, int *patch);

/* Version number of MC60 */
#define MC60_VER_MAJOR 1
#define MC60_VER_MINOR 1
#define MC60_VER_PATCH 0
void MC60_version(int *major, int *minor, int *patch);

/* Version number of MC61 */
#define MC61_VER_MAJOR 1
#define MC61_VER_MINOR 1
#define MC61_VER_PATCH 0
void MC61_version(int *major, int *minor, int *patch);

/* Version number of MC62 */
#define MC62_VER_MAJOR 1
#define MC62_VER_MINOR 0
#define MC62_VER_PATCH 0
void MC62_version(int *major, int *minor, int *patch);

/* Version number of MC63 */
#define MC63_VER_MAJOR 1
#define MC63_VER_MINOR 0
#define MC63_VER_PATCH 0
void MC63_version(int *major, int *minor, int *patch);

/* Version number of MC64 */
#define MC64_VER_MAJOR 1
#define MC64_VER_MINOR 6
#define MC64_VER_PATCH 0
void MC64_version(int *major, int *minor, int *patch);

/* Version number of MC67 */
#define MC67_VER_MAJOR 1
#define MC67_VER_MINOR 0
#define MC67_VER_PATCH 0
void MC67_version(int *major, int *minor, int *patch);

/* Version number of MC71 */
#define MC71_VER_MAJOR 1
#define MC71_VER_MINOR 0
#define MC71_VER_PATCH 0
void MC71_version(int *major, int *minor, int *patch);

/* Version number of MC72 */
#define MC72_VER_MAJOR 1
#define MC72_VER_MINOR 0
#define MC72_VER_PATCH 0
void MC72_version(int *major, int *minor, int *patch);

/* Version number of MC75 */
#define MC75_VER_MAJOR 1
#define MC75_VER_MINOR 1
#define MC75_VER_PATCH 0
void MC75_version(int *major, int *minor, int *patch);

/* Version number of MC77 */
#define MC77_VER_MAJOR 1
#define MC77_VER_MINOR 0
#define MC77_VER_PATCH 1
void MC77_version(int *major, int *minor, int *patch);

/* Version number of ME22 */
#define ME22_VER_MAJOR 1
#define ME22_VER_MINOR 0
#define ME22_VER_PATCH 0
void ME22_version(int *major, int *minor, int *patch);

/* Version number of ME38 */
#define ME38_VER_MAJOR 1
#define ME38_VER_MINOR 2
#define ME38_VER_PATCH 1
void ME38_version(int *major, int *minor, int *patch);

/* Version number of ME42 */
#define ME42_VER_MAJOR 1
#define ME42_VER_MINOR 2
#define ME42_VER_PATCH 1
void ME42_version(int *major, int *minor, int *patch);

/* Version number of ME43 */
#define ME43_VER_MAJOR 1
#define ME43_VER_MINOR 0
#define ME43_VER_PATCH 0
void ME43_version(int *major, int *minor, int *patch);

/* Version number of ME48 */
#define ME48_VER_MAJOR 1
#define ME48_VER_MINOR 1
#define ME48_VER_PATCH 1
void ME48_version(int *major, int *minor, int *patch);

/* Version number of ME50 */
#define ME50_VER_MAJOR 1
#define ME50_VER_MINOR 1
#define ME50_VER_PATCH 0
void ME50_version(int *major, int *minor, int *patch);

/* Version number of ME57 */
#define ME57_VER_MAJOR 2
#define ME57_VER_MINOR 4
#define ME57_VER_PATCH 2
void ME57_version(int *major, int *minor, int *patch);

/* Version number of ME62 */
#define ME62_VER_MAJOR 1
#define ME62_VER_MINOR 0
#define ME62_VER_PATCH 1
void ME62_version(int *major, int *minor, int *patch);

/* Version number of MF29 */
#define MF29_VER_MAJOR 1
#define MF29_VER_MINOR 0
#define MF29_VER_PATCH 0
void MF29_version(int *major, int *minor, int *patch);

/* Version number of MF30 */
#define MF30_VER_MAJOR 1
#define MF30_VER_MINOR 0
#define MF30_VER_PATCH 0
void MF30_version(int *major, int *minor, int *patch);

/* Version number of MF64 */
#define MF64_VER_MAJOR 1
#define MF64_VER_MINOR 1
#define MF64_VER_PATCH 0
void MF64_version(int *major, int *minor, int *patch);

/* Version number of MF71 */
#define MF71_VER_MAJOR 1
#define MF71_VER_MINOR 1
#define MF71_VER_PATCH 0
void MF71_version(int *major, int *minor, int *patch);

/* Version number of MI11 */
#define MI11_VER_MAJOR 1
#define MI11_VER_MINOR 2
#define MI11_VER_PATCH 0
void MI11_version(int *major, int *minor, int *patch);

/* Version number of MI12 */
#define MI12_VER_MAJOR 1
#define MI12_VER_MINOR 1
#define MI12_VER_PATCH 0
void MI12_version(int *major, int *minor, int *patch);

/* Version number of MI15 */
#define MI15_VER_MAJOR 1
#define MI15_VER_MINOR 3
#define MI15_VER_PATCH 0
void MI15_version(int *major, int *minor, int *patch);

/* Version number of MI21 */
#define MI21_VER_MAJOR 1
#define MI21_VER_MINOR 3
#define MI21_VER_PATCH 0
void MI21_version(int *major, int *minor, int *patch);

/* Version number of MI23 */
#define MI23_VER_MAJOR 1
#define MI23_VER_MINOR 1
#define MI23_VER_PATCH 0
void MI23_version(int *major, int *minor, int *patch);

/* Version number of MI24 */
#define MI24_VER_MAJOR 1
#define MI24_VER_MINOR 3
#define MI24_VER_PATCH 1
void MI24_version(int *major, int *minor, int *patch);

/* Version number of MI25 */
#define MI25_VER_MAJOR 1
#define MI25_VER_MINOR 1
#define MI25_VER_PATCH 0
void MI25_version(int *major, int *minor, int *patch);

/* Version number of MI26 */
#define MI26_VER_MAJOR 1
#define MI26_VER_MINOR 1
#define MI26_VER_PATCH 0
void MI26_version(int *major, int *minor, int *patch);

/* Version number of NS23 */
#define NS23_VER_MAJOR 2
#define NS23_VER_MINOR 0
#define NS23_VER_PATCH 0
void NS23_version(int *major, int *minor, int *patch);

/* Version number of PA16 */
#define PA16_VER_MAJOR 1
#define PA16_VER_MINOR 1
#define PA16_VER_PATCH 0
void PA16_version(int *major, int *minor, int *patch);

/* Version number of PA17 */
#define PA17_VER_MAJOR 2
#define PA17_VER_MINOR 0
#define PA17_VER_PATCH 0
void PA17_version(int *major, int *minor, int *patch);

/* Version number of YM11 */
#define YM11_VER_MAJOR 1
#define YM11_VER_MINOR 1
#define YM11_VER_PATCH 0
void YM11_version(int *major, int *minor, int *patch);

#endif  /* _LIBHSL_H_ */
