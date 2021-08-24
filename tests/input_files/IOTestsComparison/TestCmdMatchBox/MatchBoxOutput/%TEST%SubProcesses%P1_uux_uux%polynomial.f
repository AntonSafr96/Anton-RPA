      MODULE MG5_1_POLYNOMIAL_CONSTANTS
      IMPLICIT NONE
      INCLUDE 'coef_specs.inc'
      INCLUDE 'loop_max_coefs.inc'

C     Map associating a rank to each coefficient position
      INTEGER COEFTORANK_MAP(0:LOOPMAXCOEFS-1)
      DATA COEFTORANK_MAP(0:0)/1*0/
      DATA COEFTORANK_MAP(1:4)/4*1/
      DATA COEFTORANK_MAP(5:14)/10*2/

C     Map defining the number of coefficients for a symmetric tensor
C      of a given rank
      INTEGER NCOEF_R(0:2)
      DATA NCOEF_R/1,5,15/

C     Map defining the coef position resulting from the multiplication
C      of two lower rank coefs.
      INTEGER COMB_COEF_POS(0:LOOPMAXCOEFS-1,0:4)
      DATA COMB_COEF_POS(  0,  0:  4) /  0,  1,  2,  3,  4/
      DATA COMB_COEF_POS(  1,  0:  4) /  1,  5,  6,  8, 11/
      DATA COMB_COEF_POS(  2,  0:  4) /  2,  6,  7,  9, 12/
      DATA COMB_COEF_POS(  3,  0:  4) /  3,  8,  9, 10, 13/
      DATA COMB_COEF_POS(  4,  0:  4) /  4, 11, 12, 13, 14/
      DATA COMB_COEF_POS(  5,  0:  4) /  5, 15, 16, 19, 25/
      DATA COMB_COEF_POS(  6,  0:  4) /  6, 16, 17, 20, 26/
      DATA COMB_COEF_POS(  7,  0:  4) /  7, 17, 18, 21, 27/
      DATA COMB_COEF_POS(  8,  0:  4) /  8, 19, 20, 22, 28/
      DATA COMB_COEF_POS(  9,  0:  4) /  9, 20, 21, 23, 29/
      DATA COMB_COEF_POS( 10,  0:  4) / 10, 22, 23, 24, 30/
      DATA COMB_COEF_POS( 11,  0:  4) / 11, 25, 26, 28, 31/
      DATA COMB_COEF_POS( 12,  0:  4) / 12, 26, 27, 29, 32/
      DATA COMB_COEF_POS( 13,  0:  4) / 13, 28, 29, 30, 33/
      DATA COMB_COEF_POS( 14,  0:  4) / 14, 31, 32, 33, 34/

      END MODULE MG5_1_POLYNOMIAL_CONSTANTS


C     THE SUBROUTINE TO CREATE THE COEFFICIENTS FROM LAST LOOP WF AND 
C     MULTIPLY BY THE BORN

      SUBROUTINE MG5_1_CREATE_LOOP_COEFS(LOOP_WF,RANK,LCUT_SIZE
     $ ,LOOP_GROUP_NUMBER,SYMFACT,MULTIPLIER,COLOR_ID,HELCONFIG)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      IMPLICIT NONE
C     
C     CONSTANTS 
C     
      INTEGER NBORNAMPS
      PARAMETER (NBORNAMPS=2)
      REAL*8 ZERO,ONE
      PARAMETER (ZERO=0.0D0,ONE=1.0D0)
      COMPLEX*16 IMAG1
      PARAMETER (IMAG1=(ZERO,ONE))
      COMPLEX*16 CMPLX_ZERO
      PARAMETER (CMPLX_ZERO=(ZERO,ZERO))
      INTEGER    NCOLORROWS
      PARAMETER (NCOLORROWS=76)
      INTEGER    NLOOPGROUPS
      PARAMETER (NLOOPGROUPS=13)
      INTEGER    NCOMB
      PARAMETER (NCOMB=16)
C     These are constants related to the split orders
      INTEGER    NSO, NSQUAREDSO, NAMPSO
      PARAMETER (NSO=1, NSQUAREDSO=1, NAMPSO=2)
C     
C     ARGUMENTS 
C     
      COMPLEX*16 LOOP_WF(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER RANK, COLOR_ID, SYMFACT, MULTIPLIER, LCUT_SIZE,
     $  HELCONFIG, LOOP_GROUP_NUMBER
C     
C     LOCAL VARIABLES 
C     
      COMPLEX*16 CFTOT
      COMPLEX*16 CONST(NAMPSO)
      INTEGER I,J
C     
C     FUNCTIONS
C     
      INTEGER MG5_1_ML5SOINDEX_FOR_BORN_AMP,
     $  MG5_1_ML5SOINDEX_FOR_LOOP_AMP, MG5_1_ML5SQSOINDEX
C     
C     GLOBAL VARIABLES
C     
      INTEGER CF_D(NCOLORROWS,NBORNAMPS)
      INTEGER CF_N(NCOLORROWS,NBORNAMPS)
      COMMON/MG5_1_CF/CF_D,CF_N

      LOGICAL CHECKPHASE
      LOGICAL HELDOUBLECHECKED
      COMMON/MG5_1_INIT/CHECKPHASE, HELDOUBLECHECKED

      INTEGER HELOFFSET
      INTEGER GOODHEL(NCOMB)
      LOGICAL GOODAMP(NSQUAREDSO,NLOOPGROUPS)
      COMMON/MG5_1_FILTERS/GOODAMP,GOODHEL,HELOFFSET

      COMPLEX*16 LOOPCOEFS(0:LOOPMAXCOEFS-1,NSQUAREDSO,NLOOPGROUPS)
      COMMON/MG5_1_LCOEFS/LOOPCOEFS

      INTEGER HELPICKED
      COMMON/MG5_1_HELCHOICE/HELPICKED

      COMPLEX*16 AMP(NBORNAMPS)
      COMMON/MG5_1_AMPS/AMP

      DO I=1,NAMPSO
        CONST(I)=CMPLX_ZERO
      ENDDO

      DO I=1,NBORNAMPS
        CFTOT=CMPLX(CF_N(COLOR_ID,I)/(ONE*ABS(CF_D(COLOR_ID,I))),ZERO
     $   ,KIND=8)
        IF(CF_D(COLOR_ID,I).LT.0) CFTOT=CFTOT*IMAG1
        CONST(MG5_1_ML5SOINDEX_FOR_BORN_AMP(I))
     $   =CONST(MG5_1_ML5SOINDEX_FOR_BORN_AMP(I))+CFTOT*CONJG(AMP(I))
      ENDDO

      DO I=1,NAMPSO
        IF (CONST(I).NE.CMPLX_ZERO) THEN
          CONST(I)=(CONST(I)*MULTIPLIER)/SYMFACT
          IF (.NOT.CHECKPHASE.AND.HELDOUBLECHECKED.AND.HELPICKED.EQ.-1)
     $      THEN
            CONST(I)=CONST(I)*GOODHEL(HELCONFIG)
          ENDIF
          CALL MG5_1_MERGE_WL(LOOP_WF,RANK,LCUT_SIZE,CONST(I)
     $     ,LOOPCOEFS(0,MG5_1_ML5SQSOINDEX(I
     $     ,MG5_1_ML5SOINDEX_FOR_LOOP_AMP(COLOR_ID)),LOOP_GROUP_NUMBER)
     $     )
        ENDIF
      ENDDO

      END

      SUBROUTINE MG5_1_INVERT_MOMENTA_IN_POLYNOMIAL(NCOEFS,POLYNOMIAL)
C     Just a handy subroutine to modify the coefficients for the
C     tranformation q_loop -> -q_loop
C     It is only used for the NINJA interface
      USE MG5_1_POLYNOMIAL_CONSTANTS
      IMPLICIT NONE

      INTEGER I, NCOEFS

      COMPLEX*16 POLYNOMIAL(0:NCOEFS-1)

      DO I=0,NCOEFS-1
        IF (MOD(COEFTORANK_MAP(I),2).EQ.1) THEN
          POLYNOMIAL(I)=-POLYNOMIAL(I)
        ENDIF
      ENDDO

      END

C     Now the routines to update the wavefunctions



C     THE SUBROUTINE TO CREATE THE COEFFICIENTS FROM LAST LOOP WF AND 
C     MULTIPLY BY THE BORN

      SUBROUTINE MP_MG5_1_CREATE_LOOP_COEFS(LOOP_WF,RANK,LCUT_SIZE
     $ ,LOOP_GROUP_NUMBER,SYMFACT,MULTIPLIER,COLOR_ID,HELCONFIG)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      IMPLICIT NONE
C     
C     CONSTANTS 
C     
      INTEGER NBORNAMPS
      PARAMETER (NBORNAMPS=2)
      REAL*16 ZERO,ONE
      PARAMETER (ZERO=0.0E0_16,ONE=1.0E0_16)
      COMPLEX*32 IMAG1
      PARAMETER (IMAG1=(ZERO,ONE))
      COMPLEX*32 CMPLX_ZERO
      PARAMETER (CMPLX_ZERO=(ZERO,ZERO))
      INTEGER    NCOLORROWS
      PARAMETER (NCOLORROWS=76)
      INTEGER    NLOOPGROUPS
      PARAMETER (NLOOPGROUPS=13)
      INTEGER    NCOMB
      PARAMETER (NCOMB=16)
C     These are constants related to the split orders
      INTEGER    NSO, NSQUAREDSO, NAMPSO
      PARAMETER (NSO=1, NSQUAREDSO=1, NAMPSO=2)
C     
C     ARGUMENTS 
C     
      COMPLEX*32 LOOP_WF(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER RANK, COLOR_ID, SYMFACT, MULTIPLIER, LCUT_SIZE,
     $  HELCONFIG, LOOP_GROUP_NUMBER
C     
C     LOCAL VARIABLES 
C     
      COMPLEX*32 CFTOT
      COMPLEX*32 CONST(NAMPSO)
      INTEGER I,J
C     
C     FUNCTIONS
C     
      INTEGER MG5_1_ML5SOINDEX_FOR_BORN_AMP,
     $  MG5_1_ML5SOINDEX_FOR_LOOP_AMP, MG5_1_ML5SQSOINDEX
C     
C     GLOBAL VARIABLES
C     
      INTEGER CF_D(NCOLORROWS,NBORNAMPS)
      INTEGER CF_N(NCOLORROWS,NBORNAMPS)
      COMMON/MG5_1_CF/CF_D,CF_N

      LOGICAL CHECKPHASE
      LOGICAL HELDOUBLECHECKED
      COMMON/MG5_1_INIT/CHECKPHASE, HELDOUBLECHECKED

      INTEGER HELOFFSET
      INTEGER GOODHEL(NCOMB)
      LOGICAL GOODAMP(NSQUAREDSO,NLOOPGROUPS)
      COMMON/MG5_1_FILTERS/GOODAMP,GOODHEL,HELOFFSET

      COMPLEX*32 LOOPCOEFS(0:LOOPMAXCOEFS-1,NSQUAREDSO,NLOOPGROUPS)
      COMMON/MG5_1_MP_LCOEFS/LOOPCOEFS

      INTEGER HELPICKED
      COMMON/MG5_1_HELCHOICE/HELPICKED

      COMPLEX*32 AMP(NBORNAMPS)
      COMMON/MG5_1_MP_AMPS/AMP

      DO I=1,NAMPSO
        CONST(I)=CMPLX_ZERO
      ENDDO

      DO I=1,NBORNAMPS
        CFTOT=CMPLX(CF_N(COLOR_ID,I)/(ONE*ABS(CF_D(COLOR_ID,I))),ZERO
     $   ,KIND=16)
        IF(CF_D(COLOR_ID,I).LT.0) CFTOT=CFTOT*IMAG1
        CONST(MG5_1_ML5SOINDEX_FOR_BORN_AMP(I))
     $   =CONST(MG5_1_ML5SOINDEX_FOR_BORN_AMP(I))+CFTOT*CONJG(AMP(I))
      ENDDO

      DO I=1,NAMPSO
        IF (CONST(I).NE.CMPLX_ZERO) THEN
          CONST(I)=(CONST(I)*MULTIPLIER)/SYMFACT
          IF (.NOT.CHECKPHASE.AND.HELDOUBLECHECKED.AND.HELPICKED.EQ.-1)
     $      THEN
            CONST(I)=CONST(I)*GOODHEL(HELCONFIG)
          ENDIF
          CALL MP_MG5_1_MERGE_WL(LOOP_WF,RANK,LCUT_SIZE,CONST(I)
     $     ,LOOPCOEFS(0,MG5_1_ML5SQSOINDEX(I
     $     ,MG5_1_ML5SOINDEX_FOR_LOOP_AMP(COLOR_ID)),LOOP_GROUP_NUMBER)
     $     )
        ENDIF
      ENDDO

      END

      SUBROUTINE MP_MG5_1_INVERT_MOMENTA_IN_POLYNOMIAL(NCOEFS
     $ ,POLYNOMIAL)
C     Just a handy subroutine to modify the coefficients for the
C     tranformation q_loop -> -q_loop
C     It is only used for the NINJA interface
      USE MG5_1_POLYNOMIAL_CONSTANTS
      IMPLICIT NONE

      INTEGER I, NCOEFS

      COMPLEX*32 POLYNOMIAL(0:NCOEFS-1)

      DO I=0,NCOEFS-1
        IF (MOD(COEFTORANK_MAP(I),2).EQ.1) THEN
          POLYNOMIAL(I)=-POLYNOMIAL(I)
        ENDIF
      ENDDO

      END

C     Now the routines to update the wavefunctions



      SUBROUTINE MG5_1_EVAL_POLY(C,R,Q,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      COMPLEX*16 C(0:LOOPMAXCOEFS-1)
      INTEGER R
      COMPLEX*16 Q(0:3)
      COMPLEX*16 OUT

      OUT=C(0)
      IF (R.GE.1) THEN
        OUT=OUT+C(1)*Q(0)+C(2)*Q(1)+C(3)*Q(2)+C(4)*Q(3)
      ENDIF
      IF (R.GE.2) THEN
        OUT=OUT+C(5)*Q(0)*Q(0)+C(6)*Q(0)*Q(1)+C(7)*Q(1)*Q(1)+C(8)*Q(0)
     $   *Q(2)+C(9)*Q(1)*Q(2)+C(10)*Q(2)*Q(2)+C(11)*Q(0)*Q(3)+C(12)
     $   *Q(1)*Q(3)+C(13)*Q(2)*Q(3)+C(14)*Q(3)*Q(3)
      ENDIF
      END

      SUBROUTINE MP_MG5_1_EVAL_POLY(C,R,Q,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      COMPLEX*32 C(0:LOOPMAXCOEFS-1)
      INTEGER R
      COMPLEX*32 Q(0:3)
      COMPLEX*32 OUT

      OUT=C(0)
      IF (R.GE.1) THEN
        OUT=OUT+C(1)*Q(0)+C(2)*Q(1)+C(3)*Q(2)+C(4)*Q(3)
      ENDIF
      IF (R.GE.2) THEN
        OUT=OUT+C(5)*Q(0)*Q(0)+C(6)*Q(0)*Q(1)+C(7)*Q(1)*Q(1)+C(8)*Q(0)
     $   *Q(2)+C(9)*Q(1)*Q(2)+C(10)*Q(2)*Q(2)+C(11)*Q(0)*Q(3)+C(12)
     $   *Q(1)*Q(3)+C(13)*Q(2)*Q(3)+C(14)*Q(3)*Q(3)
      ENDIF
      END

      SUBROUTINE MG5_1_ADD_COEFS(A,RA,B,RB)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I
      COMPLEX*16 A(0:LOOPMAXCOEFS-1),B(0:LOOPMAXCOEFS-1)
      INTEGER RA,RB

      DO I=0,NCOEF_R(RB)-1
        A(I)=A(I)+B(I)
      ENDDO
      END

      SUBROUTINE MP_MG5_1_ADD_COEFS(A,RA,B,RB)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I
      COMPLEX*32 A(0:LOOPMAXCOEFS-1),B(0:LOOPMAXCOEFS-1)
      INTEGER RA,RB

      DO I=0,NCOEF_R(RB)-1
        A(I)=A(I)+B(I)
      ENDDO
      END

      SUBROUTINE MG5_1_MERGE_WL(WL,R,LCUT_SIZE,CONST,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J
      COMPLEX*16 WL(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER R,LCUT_SIZE
      COMPLEX*16 CONST
      COMPLEX*16 OUT(0:LOOPMAXCOEFS-1)

      DO I=1,LCUT_SIZE
        DO J=0,NCOEF_R(R)-1
          OUT(J)=OUT(J)+WL(I,J,I)*CONST
        ENDDO
      ENDDO
      END

      SUBROUTINE MP_MG5_1_MERGE_WL(WL,R,LCUT_SIZE,CONST,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J
      COMPLEX*32 WL(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER R,LCUT_SIZE
      COMPLEX*32 CONST
      COMPLEX*32 OUT(0:LOOPMAXCOEFS-1)

      DO I=1,LCUT_SIZE
        DO J=0,NCOEF_R(R)-1
          OUT(J)=OUT(J)+WL(I,J,I)*CONST
        ENDDO
      ENDDO
      END

      SUBROUTINE MG5_1_UPDATE_WL_0_1(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*16 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,4
            OUT(J,K,I)=(0.0D0,0.0D0)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,0,I)*B(J,1,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,0,I)*B(J,2,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,0,I)*B(J,3,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,0,I)*B(J,4,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MP_MG5_1_UPDATE_WL_0_1(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*32 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,4
            OUT(J,K,I)=CMPLX(0.0E0_16,0.0E0_16,KIND=16)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,0,I)*B(J,1,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,0,I)*B(J,2,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,0,I)*B(J,3,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,0,I)*B(J,4,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MG5_1_UPDATE_WL_0_0(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*16 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,0
            OUT(J,K,I)=(0.0D0,0.0D0)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MP_MG5_1_UPDATE_WL_0_0(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*32 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,0
            OUT(J,K,I)=CMPLX(0.0E0_16,0.0E0_16,KIND=16)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MG5_1_UPDATE_WL_1_1(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*16 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,14
            OUT(J,K,I)=(0.0D0,0.0D0)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,0,I)*B(J,1,K)+A(K,1,I)*B(J,0,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,0,I)*B(J,2,K)+A(K,2,I)*B(J,0,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,0,I)*B(J,3,K)+A(K,3,I)*B(J,0,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,0,I)*B(J,4,K)+A(K,4,I)*B(J,0,K)
            OUT(J,5,I)=OUT(J,5,I)+A(K,1,I)*B(J,1,K)
            OUT(J,6,I)=OUT(J,6,I)+A(K,1,I)*B(J,2,K)+A(K,2,I)*B(J,1,K)
            OUT(J,7,I)=OUT(J,7,I)+A(K,2,I)*B(J,2,K)
            OUT(J,8,I)=OUT(J,8,I)+A(K,1,I)*B(J,3,K)+A(K,3,I)*B(J,1,K)
            OUT(J,9,I)=OUT(J,9,I)+A(K,2,I)*B(J,3,K)+A(K,3,I)*B(J,2,K)
            OUT(J,10,I)=OUT(J,10,I)+A(K,3,I)*B(J,3,K)
            OUT(J,11,I)=OUT(J,11,I)+A(K,1,I)*B(J,4,K)+A(K,4,I)*B(J,1,K)
            OUT(J,12,I)=OUT(J,12,I)+A(K,2,I)*B(J,4,K)+A(K,4,I)*B(J,2,K)
            OUT(J,13,I)=OUT(J,13,I)+A(K,3,I)*B(J,4,K)+A(K,4,I)*B(J,3,K)
            OUT(J,14,I)=OUT(J,14,I)+A(K,4,I)*B(J,4,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MP_MG5_1_UPDATE_WL_1_1(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*32 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,14
            OUT(J,K,I)=CMPLX(0.0E0_16,0.0E0_16,KIND=16)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,0,I)*B(J,1,K)+A(K,1,I)*B(J,0,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,0,I)*B(J,2,K)+A(K,2,I)*B(J,0,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,0,I)*B(J,3,K)+A(K,3,I)*B(J,0,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,0,I)*B(J,4,K)+A(K,4,I)*B(J,0,K)
            OUT(J,5,I)=OUT(J,5,I)+A(K,1,I)*B(J,1,K)
            OUT(J,6,I)=OUT(J,6,I)+A(K,1,I)*B(J,2,K)+A(K,2,I)*B(J,1,K)
            OUT(J,7,I)=OUT(J,7,I)+A(K,2,I)*B(J,2,K)
            OUT(J,8,I)=OUT(J,8,I)+A(K,1,I)*B(J,3,K)+A(K,3,I)*B(J,1,K)
            OUT(J,9,I)=OUT(J,9,I)+A(K,2,I)*B(J,3,K)+A(K,3,I)*B(J,2,K)
            OUT(J,10,I)=OUT(J,10,I)+A(K,3,I)*B(J,3,K)
            OUT(J,11,I)=OUT(J,11,I)+A(K,1,I)*B(J,4,K)+A(K,4,I)*B(J,1,K)
            OUT(J,12,I)=OUT(J,12,I)+A(K,2,I)*B(J,4,K)+A(K,4,I)*B(J,2,K)
            OUT(J,13,I)=OUT(J,13,I)+A(K,3,I)*B(J,4,K)+A(K,4,I)*B(J,3,K)
            OUT(J,14,I)=OUT(J,14,I)+A(K,4,I)*B(J,4,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MG5_1_UPDATE_WL_2_0(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*16 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,14
            OUT(J,K,I)=(0.0D0,0.0D0)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,1,I)*B(J,0,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,2,I)*B(J,0,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,3,I)*B(J,0,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,4,I)*B(J,0,K)
            OUT(J,5,I)=OUT(J,5,I)+A(K,5,I)*B(J,0,K)
            OUT(J,6,I)=OUT(J,6,I)+A(K,6,I)*B(J,0,K)
            OUT(J,7,I)=OUT(J,7,I)+A(K,7,I)*B(J,0,K)
            OUT(J,8,I)=OUT(J,8,I)+A(K,8,I)*B(J,0,K)
            OUT(J,9,I)=OUT(J,9,I)+A(K,9,I)*B(J,0,K)
            OUT(J,10,I)=OUT(J,10,I)+A(K,10,I)*B(J,0,K)
            OUT(J,11,I)=OUT(J,11,I)+A(K,11,I)*B(J,0,K)
            OUT(J,12,I)=OUT(J,12,I)+A(K,12,I)*B(J,0,K)
            OUT(J,13,I)=OUT(J,13,I)+A(K,13,I)*B(J,0,K)
            OUT(J,14,I)=OUT(J,14,I)+A(K,14,I)*B(J,0,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MP_MG5_1_UPDATE_WL_2_0(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*32 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,14
            OUT(J,K,I)=CMPLX(0.0E0_16,0.0E0_16,KIND=16)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,1,I)*B(J,0,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,2,I)*B(J,0,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,3,I)*B(J,0,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,4,I)*B(J,0,K)
            OUT(J,5,I)=OUT(J,5,I)+A(K,5,I)*B(J,0,K)
            OUT(J,6,I)=OUT(J,6,I)+A(K,6,I)*B(J,0,K)
            OUT(J,7,I)=OUT(J,7,I)+A(K,7,I)*B(J,0,K)
            OUT(J,8,I)=OUT(J,8,I)+A(K,8,I)*B(J,0,K)
            OUT(J,9,I)=OUT(J,9,I)+A(K,9,I)*B(J,0,K)
            OUT(J,10,I)=OUT(J,10,I)+A(K,10,I)*B(J,0,K)
            OUT(J,11,I)=OUT(J,11,I)+A(K,11,I)*B(J,0,K)
            OUT(J,12,I)=OUT(J,12,I)+A(K,12,I)*B(J,0,K)
            OUT(J,13,I)=OUT(J,13,I)+A(K,13,I)*B(J,0,K)
            OUT(J,14,I)=OUT(J,14,I)+A(K,14,I)*B(J,0,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MG5_1_UPDATE_WL_1_0(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*16 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*16 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,4
            OUT(J,K,I)=(0.0D0,0.0D0)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,1,I)*B(J,0,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,2,I)*B(J,0,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,3,I)*B(J,0,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,4,I)*B(J,0,K)
          ENDDO
        ENDDO
      ENDDO
      END

      SUBROUTINE MP_MG5_1_UPDATE_WL_1_0(A,LCUT_SIZE,B,IN_SIZE,OUT_SIZE
     $ ,OUT)
      USE MG5_1_POLYNOMIAL_CONSTANTS
      INTEGER I,J,K
      COMPLEX*32 A(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 B(MAXLWFSIZE,0:VERTEXMAXCOEFS-1,MAXLWFSIZE)
      COMPLEX*32 OUT(MAXLWFSIZE,0:LOOPMAXCOEFS-1,MAXLWFSIZE)
      INTEGER LCUT_SIZE,IN_SIZE,OUT_SIZE

      DO I=1,LCUT_SIZE
        DO J=1,OUT_SIZE
          DO K=0,4
            OUT(J,K,I)=CMPLX(0.0E0_16,0.0E0_16,KIND=16)
          ENDDO
          DO K=1,IN_SIZE
            OUT(J,0,I)=OUT(J,0,I)+A(K,0,I)*B(J,0,K)
            OUT(J,1,I)=OUT(J,1,I)+A(K,1,I)*B(J,0,K)
            OUT(J,2,I)=OUT(J,2,I)+A(K,2,I)*B(J,0,K)
            OUT(J,3,I)=OUT(J,3,I)+A(K,3,I)*B(J,0,K)
            OUT(J,4,I)=OUT(J,4,I)+A(K,4,I)*B(J,0,K)
          ENDDO
        ENDDO
      ENDDO
      END
