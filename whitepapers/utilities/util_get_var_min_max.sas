/***
  Create a global symbol that contains the MIN and MAX of numeric values, space-delimited

  -INPUT
    DSET    data set containing the numeric variable for which you want MIN and MAX
              REQUIRED
              Syntax:  (libname.)memname
              Example: ANA.ADVS
    VAR     variable on DSET containing non-missing values
              REQUIRED
              Syntax:  variable-name
              Example: AVAL
    SYM     name of symbol (macro variable) to declare globally and assign the result
              REQUIRED
              Syntax:  symbol-name
              Example: aval_min_max
    SQLWHR  complete SQL where expression, to limit check to subset of DS data
              optional
              Syntax:  where sql-where-expression
              Example: where studyid = 'STUDY01'

  -OUTPUT
    &SYM, a global symbol containing the MIN and MAX, space-delimited

  Author:          Dante Di Tommaso
***/

%macro util_get_var_min_max(ds, var, sym, sqlwhr=);

  %global &sym;
  %local OK minval maxval;

  %let OK = %assert_dset_exist(&ds);
  %if &OK %then %let OK = %assert_var_exist(&ds, &var);

  %if &OK %then %do;

    proc sql noprint;
      select min(&var), max(&var) into :minval, :maxval
      from &ds
      &sqlwhr;
    quit;
    %let minval = &minval;
    %let maxval = &maxval;
    %let &sym = &minval &maxval;

    %if &minval = . or &maxval = . %then
      %put WARNING: (UTIL_GET_VAR_MIN_MAX) Missing vals for %upcase(&var) on %upcase(&ds). %upcase(&sym) = &&&sym...;
    %else
      %put NOTE: (UTIL_GET_VAR_MIN_MAX) Successfully created symbol %upcase(&sym) = &&&sym...;
  %end;
  %else %do;
    %put ERROR: (UTIL_GET_VAR_MIN_MAX) Unable to read values from variable %upcase(&var) on data set %upcase(&ds).;
  %end;

%mend util_get_var_min_max;

