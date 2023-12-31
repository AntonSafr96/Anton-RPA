      SUBROUTINE SBORN_HEL(P1,ANS)
C     
C     Generated by MadGraph5_aMC@NLO v. %(version)s, %(date)s
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     
C     RETURNS AMPLITUDE SQUARED SUMMED/AVG OVER COLORS
C     AND HELICITIES
C     FOR THE POINT IN PHASE SPACE P1(0:3,NEXTERNAL-1)
C     
C     Process: u u~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     Process: c c~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     Process: d d~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     Process: s s~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INCLUDE 'nexternal.inc'
      INCLUDE 'born_nhel.inc'
      INTEGER     NCOMB
      PARAMETER ( NCOMB=  16 )
      INTEGER    THEL
      PARAMETER (THEL=NCOMB*0)
      INTEGER NGRAPHS
      PARAMETER (NGRAPHS = 1)
C     
C     ARGUMENTS 
C     
      REAL*8 P1(0:3,NEXTERNAL-1),ANS
C     
C     LOCAL VARIABLES 
C     
      INTEGER IHEL,IDEN,J
      REAL*8 BORN_HEL
      INTEGER IDEN_VALUES(1)
      DATA IDEN_VALUES / 36 /
C     
C     GLOBAL VARIABLES
C     
      LOGICAL GOODHEL(NCOMB,0)
      COMMON /C_GOODHEL/ GOODHEL
      DOUBLE PRECISION SAVEMOM(NEXTERNAL-1,2)
      COMMON/TO_SAVEMOM/SAVEMOM
      LOGICAL CALCULATEDBORN
      COMMON/CCALCULATEDBORN/CALCULATEDBORN
      INTEGER NFKSPROCESS
      COMMON/C_NFKSPROCESS/NFKSPROCESS
      DOUBLE PRECISION WGT_HEL(MAX_BHEL)
      COMMON/C_BORN_HEL/WGT_HEL

C     ----------
C     BEGIN CODE
C     ----------
      IDEN=IDEN_VALUES(NFKSPROCESS)
      IF (CALCULATEDBORN) THEN
        DO J=1,NEXTERNAL-1
          IF (SAVEMOM(J,1).NE.P1(0,J) .OR. SAVEMOM(J,2).NE.P1(3,J))
     $      THEN
            CALCULATEDBORN=.FALSE.
            WRITE (*,*) 'momenta not the same in Born_hel'
            STOP
          ENDIF
        ENDDO
      ELSE
        WRITE(*,*) 'Error in born_hel: should be called only with'
     $   //' calculatedborn = true'
        STOP
      ENDIF
      ANS = 0D0
      DO IHEL=1,NCOMB
        WGT_HEL(IHEL)=0D0
        IF (GOODHEL(IHEL,NFKSPROCESS)) THEN
          WGT_HEL(IHEL)=BORN_HEL(P1,IHEL)/DBLE(IDEN)
          ANS=ANS+WGT_HEL(IHEL)
        ENDIF
      ENDDO
      END


      REAL*8 FUNCTION BORN_HEL(P,HELL)
C     
C     Generated by MadGraph5_aMC@NLO v. %(version)s, %(date)s
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     RETURNS AMPLITUDE SQUARED SUMMED/AVG OVER COLORS
C     FOR THE POINT WITH EXTERNAL LINES W(0:6,NEXTERNAL-1)

C     Process: u u~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     Process: c c~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     Process: d d~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     Process: s s~ > t t~ WEIGHTED<=2 [ LOonly = QCD ]
C     
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INTEGER     NGRAPHS
      PARAMETER ( NGRAPHS = 1 )
      INTEGER    NCOLOR
      PARAMETER (NCOLOR=2)
      REAL*8     ZERO
      PARAMETER (ZERO=0D0)
      COMPLEX*16 IMAG1
      PARAMETER (IMAG1 = (0D0,1D0))
      INCLUDE 'nexternal.inc'
      INCLUDE 'born_nhel.inc'
C     
C     ARGUMENTS 
C     
      REAL*8 P(0:3,NEXTERNAL-1)
      INTEGER HELL
C     
C     LOCAL VARIABLES 
C     
      INTEGER I,J
      REAL*8 CF(NCOLOR,NCOLOR)
      COMPLEX*16 ZTEMP, AMP(NGRAPHS), JAMP(NCOLOR)
      COMPLEX*16 TMP_JAMP(0)
C     
C     GLOBAL VARIABLES
C     
      DOUBLE COMPLEX SAVEAMP(NGRAPHS,MAX_BHEL)
      COMMON/TO_SAVEAMP/SAVEAMP
      LOGICAL CALCULATEDBORN
      COMMON/CCALCULATEDBORN/CALCULATEDBORN
C     
C     COLOR DATA
C     
      DATA (CF(I,  1),I=  1,  2) /9.000000000000000D+00
     $ ,3.000000000000000D+00/
C     1 T(2,1) T(3,4)
      DATA (CF(I,  2),I=  1,  2) /3.000000000000000D+00
     $ ,9.000000000000000D+00/
C     1 T(2,4) T(3,1)
C     ----------
C     BEGIN CODE
C     ----------
      IF (.NOT. CALCULATEDBORN) THEN
        WRITE(*,*) 'Error in born_hel.f: this should be called only'
     $   //' with calculatedborn = true'
        STOP
      ELSEIF (CALCULATEDBORN) THEN
        DO I=1,NGRAPHS
          AMP(I)=SAVEAMP(I,HELL)
        ENDDO
      ENDIF
      JAMP(1) = (1.666666666666667D-01)*AMP(1)
      JAMP(2) = (-5.000000000000000D-01)*AMP(1)
      BORN_HEL = 0.D0
      DO I = 1, NCOLOR
        ZTEMP = (0.D0,0.D0)
        DO J = 1, NCOLOR
          ZTEMP = ZTEMP + CF(J,I)*JAMP(J)
        ENDDO
        BORN_HEL =BORN_HEL+ZTEMP*DCONJG(JAMP(I))
      ENDDO
      END

