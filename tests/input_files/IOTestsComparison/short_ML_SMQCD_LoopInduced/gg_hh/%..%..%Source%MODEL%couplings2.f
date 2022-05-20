ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      written by the UFO converter
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      SUBROUTINE COUP2( VECID)

      IMPLICIT NONE
      INTEGER VECID
      INCLUDE 'model_functions.inc'

      DOUBLE PRECISION PI, ZERO
      PARAMETER  (PI=3.141592653589793D0)
      PARAMETER  (ZERO=0D0)
      INCLUDE 'input.inc'
      INCLUDE 'coupl.inc'
      GC_5(VECID) = MDL_COMPLEXI*G
      R2_GGHB(VECID) = 4.000000D+00*(-((MDL_COMPLEXI*MDL_YB)
     $ /MDL_SQRT__2))*(1.000000D+00/2.000000D+00)*(MDL_G__EXP__2
     $ /(8.000000D+00*PI**2))*MDL_MB
      R2_GGHT(VECID) = 4.000000D+00*(-((MDL_COMPLEXI*MDL_YT)
     $ /MDL_SQRT__2))*(1.000000D+00/2.000000D+00)*(MDL_G__EXP__2
     $ /(8.000000D+00*PI**2))*MDL_MT
      R2_GGHHB(VECID) = 4.000000D+00*(-MDL_YB__EXP__2/2.000000D+00)
     $ *(1.000000D+00/2.000000D+00)*((MDL_COMPLEXI*MDL_G__EXP__2)
     $ /(8.000000D+00*PI**2))
      R2_GGHHT(VECID) = 4.000000D+00*(-MDL_YT__EXP__2/2.000000D+00)
     $ *(1.000000D+00/2.000000D+00)*((MDL_COMPLEXI*MDL_G__EXP__2)
     $ /(8.000000D+00*PI**2))
      END
