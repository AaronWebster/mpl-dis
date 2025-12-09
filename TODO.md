# TODO: Errors in Logic and Reasoning

This document identifies errors in logic, reasoning, and implementation found in the mpl-dis repository.

## Python Code Issues

### ✅ FIXED: Python 2 vs Python 3 Compatibility Issues

**Status:** All Python files have been updated to Python 3 syntax.

#### File: `backmatter/eps_plots/plotall.py`
**Lines:** 19-26
**Severity:** High - Code will not run in Python 3
**Issue:** Uses Python 2 print statements without parentheses
**Status:** ✅ FIXED - All print statements converted to Python 3 syntax

#### File: `backmatter/eps_plots/mktable.py`
**Line:** 15
**Severity:** Critical - Syntax error prevents execution
**Issue:** Incomplete assignment statement `lambda0 = `
**Status:** ✅ FIXED - Variable now properly assigned: `lambda0 = linspace(200e-9,2000e-9,N)`

**Line:** 20
**Issue:** Python 2 print syntax
**Status:** ✅ FIXED - Converted to Python 3 syntax

**Line:** 21
**Severity:** Critical - Syntax error
**Issue:** Invalid Python syntax - for loop without proper syntax
**Status:** ✅ FIXED - Added colon and proper Python syntax

**Line:** 22
**Severity:** Critical - Syntax error
**Issue:** LaTeX code `\multirow{3}{*}{}` in Python file - invalid syntax
**Status:** ✅ FIXED - Converted to comment with TODO marker for future implementation


## C Code Issues

### 2. Logic Error in Scattering Simulation

#### File: `scatteringmicro/tidy/scatter.c`
**Lines:** 256, 308
**Severity:** Medium - Potential division by zero
**Issue:** Use of `atan(scatt[i].y/scatt[i].x)` without checking if x is zero
**Risk:** Division by zero when `scatt[i].x == 0`
**Fix Required:** Use `atan2(scatt[i].y, scatt[i].x)` instead, which handles all cases correctly:
```c
theta = atan2(scatt[i].y, scatt[i].x);
```

#### File: `scatteringmicro/tidy/scatter.c`
**Lines:** 205, 215, 231
**Severity:** Low - Typo in error messages
**Issue:** Misspelling "allcate" instead of "allocate"
**Fix Required:** Correct spelling in error messages

#### File: `scatteringmicro/tidy/scatter.c`
**Line:** 228, 235
**Severity:** Low - Typo in variable names
**Issue:** Misspelling "canidates" instead of "candidates"
**Impact:** Inconsistent naming throughout the code
**Fix Required:** Rename variables to use correct spelling:
- `scanidates` → `scandidates`
- `iscanidates` → `iscandidates`
- `ncanidates` → `ncandidates`

#### File: `scatteringmicro/tidy/scatter.c`
**Lines:** 268-280
**Severity:** Medium - Logic error
**Issue:** In MS==0 (Multiple Scattering disabled) mode, plasmon phase initialization is incorrect
**Current Code:**
```c
plasmon->phase = scatt[i].x;
```
**Problem:** Only sets phase to x-coordinate, should accumulate properly
**Context:** The plasmon structure is zeroed at line 269, then phase is set but not accumulated correctly

#### File: `scatteringmicro/tidy/scatter.c`
**Lines:** 296-304
**Severity:** High - Logic error in termination condition
**Issue:** Loop terminates when `plasmon->nscat < 2` which will always happen after exactly 2 scatterers
**Current Code:**
```c
while(plasmon->nscat<2){
    next_n=random_int(r,NSCAT-1);
    plasmon->phase+=sqrt(...);
    plasmon->nscat++;
    n=next_n;
}
```
**Problem:** The comment says "run around until we're out of path length or we choose the same scatterer twice" but the condition only allows exactly 2 scatterers
**Expected Logic:** Should check:
1. Path length hasn't exceeded maximum (currently not checked)
2. Same scatterer hasn't been chosen twice (currently not checked)
3. The hardcoded limit of 2 doesn't match the described behavior

#### File: `scatteringmicro/tidy/scatter.c`
**Line:** 350
**Severity:** Medium - Off-by-one error
**Issue:** Loop starts at i=1 instead of i=0, skipping the first scatterer
**Current Code:**
```c
for(i=1;i<NSCAT;i++){
    fprintf(out,"%g\t%g\n",scatt[i].x,scatt[i].y); 
}
```
**Problem:** Scatterer at index 0 is never written to output
**Fix Required:** Start loop at i=0:
```c
for(i=0;i<NSCAT;i++){
```

#### File: `scatteringmicro/tidy/scatter.c`
**Lines:** 134-138
**Severity:** Low - Logic inconsistency
**Issue:** Options `--SS` and `--MS` set SS=0 and MS=0 respectively, which is counter-intuitive
**Current Code:**
```c
case 'w':  // --SS option
    SS=0;
    break;
case 'x':  // --MS option
    MS=0;
    break;
```
**Problem:** The flag name suggests enabling the feature, but it actually disables it
**Expected:** Either rename flags or invert logic

#### File: `scatteringmicro/tidy/scatter.c`
**Line:** 18
**Severity:** Low - Duplicate include
**Issue:** `#include <search.h>` appears twice (lines 15 and 18)
**Fix Required:** Remove duplicate include

### 3. Incomplete Permutation Code

#### File: `scatteringmicro/tidy/permswap.c`
**Lines:** 4-13
**Severity:** Medium - Algorithm logic error
**Issue:** Permutation generation is incomplete and doesn't generate proper permutations
**Problem:** The function prints individual numbers recursively but doesn't properly track or generate permutations as sequences
**Expected:** A proper permutation generator should track visited elements and generate complete sequences

## TeX Documentation Issues

### 4. Mathematical/Physical Reasoning Issues

#### File: `scatteringmicro/montecarlosim.tex`
**Lines:** 241-244
**Severity:** Medium - Unresolved logical problem
**Issue:** Author acknowledges uncertainty in combining probability distributions
**Quote:** "It is assumed that the superposition of the two probabilities should produce the statistical results found \Figure{fig:linepickingpdf}, but as yet I have not found a way to do so."
**Impact:** Incomplete theoretical justification for simulation approach
**Action Required:** Either:
1. Derive proper combination of probability distributions
2. Provide empirical validation
3. Acknowledge limitation more explicitly

#### File: `scatteringmicro/montecarlosim.tex`
**Lines:** 246-252
**Severity:** Medium - Physical model limitation
**Issue:** Acknowledged limitation in scattering density simulation
**Quote:** "as the scattering density is increased, a plasmon as simulated does not visit more scatterers, nor does its mean free path decrease. Rather, the result of increasing the number of scatterers is only to suppress single scattering off the tip. This may or may not be physical."
**Impact:** Fundamental limitation of the Monte Carlo simulation model
**Action Required:** 
1. Investigate whether this behavior is physical
2. Consider modifying the simulation model
3. Document the limitation more prominently

#### File: `existence/singleinterface.tex`
**Lines:** 1-2
**Severity:** Low - Incomplete reasoning
**Issue:** Commented-out TODO note about ansatz
**Quote:** "%\todo{the ansatz here is that we're looking for bound solutions k1 must be positive and k2 negative because we are looking for bounds solutions}"
**Note:** This reasoning is actually addressed in lines 131-137 but the TODO remains

## Unused/Dead Code

### 5. Commented-Out Code Sections

Multiple files contain large sections of commented-out code that should either be removed or documented:

#### File: `scatteringmicro/tidy/scatter.c`
- Lines 312-325: Commented alternative implementations
- Should either be removed or documented as future work

#### File: `backmatter/eps_plots/mktable.py`
- Lines 24-36: Commented-out function definitions
- Should be removed if not needed

#### File: `scatteringmicro/montecarlosim.tex`
- Multiple sections with commented-out subsections
- Should either include or remove entirely for clarity

## Missing Error Handling

### 6. Insufficient Bounds Checking

#### File: `scatteringmicro/tidy/scatter.c`
**Line:** 289
**Severity:** Medium - Potential array access violation
**Issue:** No check if `ncanidates` is 0 before accessing array
**Current Code:**
```c
n=iscanidates[random_int(r,ncanidates-1)];
```
**Problem:** If `ncanidates == 0`, `random_int(r, -1)` has undefined behavior
**Fix Required:** Add check:
```c
if(ncanidates == 0) {
    fprintf(stderr, "Error: No scatterers in illuminated region\n");
    return -1;
}
```

## Summary Statistics

- **Critical Issues (Syntax Errors):** 0 (✅ All fixed)
- **High Severity (Logic Errors):** 2
- **Medium Severity (Bugs/Limitations):** 7
- **Low Severity (Typos/Style):** 5

## Priority Order for Fixes

1. ✅ COMPLETED: Fix critical syntax errors in Python files (mktable.py)
2. ✅ COMPLETED: Update Python 2 to Python 3 syntax across all files
3. Fix high severity logic errors in scatter.c (loop termination, array indexing)
4. Fix medium severity issues (division by zero, bounds checking)
5. Address mathematical/theoretical uncertainties in documentation
6. Clean up low severity issues (typos, dead code)
