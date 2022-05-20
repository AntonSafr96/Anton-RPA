ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      written by the UFO converter
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE MP_COUP2( VECID)

      IMPLICIT NONE
      INTEGER VECID
      INCLUDE 'model_functions.inc'
      REAL*16 MP__PI, MP__ZERO
      PARAMETER (MP__PI=3.1415926535897932384626433832795E0_16)
      PARAMETER (MP__ZERO=0E0_16)
      INCLUDE 'mp_input.inc'
      INCLUDE 'mp_coupl.inc'

      MP__GC_5(VECID) = MP__MDL_COMPLEXI*MP__G
      MP__R2_GGHB(VECID) = 4.000000E+00_16*(-((MP__MDL_COMPLEXI
     $ *MP__MDL_YB)/MP__MDL_SQRT__2))*(1.000000E+00_16/2.000000E+00_16)
     $ *(MP__MDL_G__EXP__2/(8.000000E+00_16*MP__PI**2))*MP__MDL_MB
      MP__R2_GGHT(VECID) = 4.000000E+00_16*(-((MP__MDL_COMPLEXI
     $ *MP__MDL_YT)/MP__MDL_SQRT__2))*(1.000000E+00_16/2.000000E+00_16)
     $ *(MP__MDL_G__EXP__2/(8.000000E+00_16*MP__PI**2))*MP__MDL_MT
      MP__R2_GGHHB(VECID) = 4.000000E+00_16*(-MP__MDL_YB__EXP__2
     $ /2.000000E+00_16)*(1.000000E+00_16/2.000000E+00_16)
     $ *((MP__MDL_COMPLEXI*MP__MDL_G__EXP__2)/(8.000000E+00_16*MP__PI*
     $ *2))
      MP__R2_GGHHT(VECID) = 4.000000E+00_16*(-MP__MDL_YT__EXP__2
     $ /2.000000E+00_16)*(1.000000E+00_16/2.000000E+00_16)
     $ *((MP__MDL_COMPLEXI*MP__MDL_G__EXP__2)/(8.000000E+00_16*MP__PI*
     $ *2))
      END
