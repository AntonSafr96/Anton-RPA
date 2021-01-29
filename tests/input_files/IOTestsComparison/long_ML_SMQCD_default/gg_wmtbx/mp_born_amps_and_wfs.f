      SUBROUTINE ML5_0_MP_BORN_AMPS_AND_WFS(P)
C     
C     Generated by MadGraph5_aMC@NLO v. %(version)s, %(date)s
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     
C     Computes all the AMP and WFS in quadruple precision for the 
C     phase space point P(0:3,NEXTERNAL)
C     
C     Process: g g > w- t b~ QCD<=2 QED<=1 [ virt = QCD ]
C     
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INTEGER NBORNAMPS
      PARAMETER (NBORNAMPS=8)
      INTEGER    NLOOPAMPS, NCTAMPS
      PARAMETER (NLOOPAMPS=396, NCTAMPS=252)
      INTEGER    NEXTERNAL
      PARAMETER (NEXTERNAL=5)
      INTEGER    NWAVEFUNCS
      PARAMETER (NWAVEFUNCS=28)
      INTEGER    NCOMB
      PARAMETER (NCOMB=48)
      REAL*16     ZERO
      PARAMETER (ZERO=0E0_16)
      COMPLEX*32 IMAG1
      PARAMETER (IMAG1=(0E0_16,1E0_16))

C     
C     ARGUMENTS 
C     
      REAL*16 P(0:3,NEXTERNAL)
C     
C     LOCAL VARIABLES 
C     
      INTEGER I,J,H
      INTEGER NHEL(NEXTERNAL), IC(NEXTERNAL)
      DATA IC/NEXTERNAL*1/
C     
C     FUNCTIONS
C     
      LOGICAL ML5_0_IS_HEL_SELECTED
C     
C     GLOBAL VARIABLES
C     
      INCLUDE 'mp_coupl_same_name.inc'

      INTEGER NTRY
      LOGICAL CHECKPHASE,HELDOUBLECHECKED
      REAL*8 REF
      COMMON/ML5_0_INIT/NTRY,CHECKPHASE,HELDOUBLECHECKED,REF

      LOGICAL GOODHEL(NCOMB)
      LOGICAL GOODAMP(NLOOPAMPS,NCOMB)
      COMMON/ML5_0_FILTERS/GOODAMP,GOODHEL

      INTEGER HELPICKED
      COMMON/ML5_0_HELCHOICE/HELPICKED

      COMPLEX*32 AMP(NBORNAMPS,NCOMB)
      COMMON/ML5_0_MP_AMPS/AMP
      COMPLEX*16 DPAMP(NBORNAMPS,NCOMB)
      COMMON/ML5_0_AMPS/DPAMP
      COMPLEX*32 W(20,NWAVEFUNCS,NCOMB)
      COMMON/ML5_0_MP_WFS/W

      COMPLEX*32 AMPL(3,NCTAMPS)
      COMMON/ML5_0_MP_AMPL/AMPL

      COMPLEX*16 DPW(20,NWAVEFUNCS,NCOMB)
      COMMON/ML5_0_WFCTS/DPW

      COMPLEX*16 DPAMPL(3,NLOOPAMPS)
      LOGICAL S(NLOOPAMPS)
      COMMON/ML5_0_AMPL/DPAMPL,S

      INTEGER HELC(NEXTERNAL,NCOMB)
      COMMON/ML5_0_HELCONFIGS/HELC

      LOGICAL MP_DONE_ONCE
      COMMON/ML5_0_MP_DONE_ONCE/MP_DONE_ONCE

C     This array specify potential special requirements on the
C      helicities to
C     consider. POLARIZATIONS(0,0) is -1 if there is not such
C      requirement.
      INTEGER POLARIZATIONS(0:NEXTERNAL,0:5)
      COMMON/ML5_0_BEAM_POL/POLARIZATIONS

C     ----------
C     BEGIN CODE
C     ---------

      MP_DONE_ONCE=.TRUE.

C     To be on the safe side, we always update the MP params here.
C     It can be redundant as this routine can be called a couple of
C      times for the same PS point during the stability checks.
C     But it is really not time consuming and I would rather be safe.
      CALL MP_UPDATE_AS_PARAM()

      DO H=1,NCOMB
        IF ((HELPICKED.EQ.H).OR.((HELPICKED.EQ.-1)
     $   .AND.((CHECKPHASE.OR..NOT.HELDOUBLECHECKED).OR.GOODHEL(H))))
     $    THEN
C         Handle the possible requirement of specific polarizations
          IF ((.NOT.CHECKPHASE)
     $     .AND.HELDOUBLECHECKED.AND.POLARIZATIONS(0,0)
     $     .EQ.0.AND.(.NOT.ML5_0_IS_HEL_SELECTED(H))) THEN
            CYCLE
          ENDIF
          DO I=1,NEXTERNAL
            NHEL(I)=HELC(I,H)
          ENDDO
          CALL MP_VXXXXX(P(0,1),ZERO,NHEL(1),-1*IC(1),W(1,1,H))
          CALL MP_VXXXXX(P(0,2),ZERO,NHEL(2),-1*IC(2),W(1,2,H))
          CALL MP_VXXXXX(P(0,3),MDL_MW,NHEL(3),+1*IC(3),W(1,3,H))
          CALL MP_OXXXXX(P(0,4),MDL_MT,NHEL(4),+1*IC(4),W(1,4,H))
          CALL MP_IXXXXX(P(0,5),MDL_MB,NHEL(5),-1*IC(5),W(1,5,H))
          CALL MP_VVV1P0_1(W(1,1,H),W(1,2,H),GC_4,ZERO,ZERO,W(1,6,H))
          CALL MP_FFV2_1(W(1,4,H),W(1,3,H),GC_11,MDL_MB,ZERO,W(1,7,H))
C         Amplitude(s) for born diagram with ID 1
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),GC_5,AMP(1,H))
          CALL MP_FFV2_2(W(1,5,H),W(1,3,H),GC_11,MDL_MT,MDL_WT,W(1,8,H)
     $     )
C         Amplitude(s) for born diagram with ID 2
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),GC_5,AMP(2,H))
          CALL MP_FFV1_1(W(1,4,H),W(1,1,H),GC_5,MDL_MT,MDL_WT,W(1,9,H))
          CALL MP_FFV1_2(W(1,5,H),W(1,2,H),GC_5,MDL_MB,ZERO,W(1,10,H))
C         Amplitude(s) for born diagram with ID 3
          CALL MP_FFV2_0(W(1,10,H),W(1,9,H),W(1,3,H),GC_11,AMP(3,H))
C         Amplitude(s) for born diagram with ID 4
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),GC_5,AMP(4,H))
          CALL MP_FFV1_2(W(1,5,H),W(1,1,H),GC_5,MDL_MB,ZERO,W(1,11,H))
          CALL MP_FFV1_1(W(1,4,H),W(1,2,H),GC_5,MDL_MT,MDL_WT,W(1,12,H)
     $     )
C         Amplitude(s) for born diagram with ID 5
          CALL MP_FFV2_0(W(1,11,H),W(1,12,H),W(1,3,H),GC_11,AMP(5,H))
C         Amplitude(s) for born diagram with ID 6
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),GC_5,AMP(6,H))
C         Amplitude(s) for born diagram with ID 7
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),GC_5,AMP(7,H))
C         Amplitude(s) for born diagram with ID 8
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),GC_5,AMP(8,H))
          CALL MP_FFV1P0_3(W(1,5,H),W(1,7,H),GC_5,ZERO,ZERO,W(1,13,H))
C         Counter-term amplitude(s) for loop diagram number 9
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,13,H),R2_GGQ,AMPL(1,1))
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,13,H),R2_GGQ,AMPL(1,2))
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,13,H),R2_GGQ,AMPL(1,3))
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,13,H),R2_GGQ,AMPL(1,4))
          CALL MP_FFV1P0_3(W(1,8,H),W(1,4,H),GC_5,ZERO,ZERO,W(1,14,H))
C         Counter-term amplitude(s) for loop diagram number 10
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,14,H),R2_GGQ,AMPL(1,5))
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,14,H),R2_GGQ,AMPL(1,6))
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,14,H),R2_GGQ,AMPL(1,7))
          CALL MP_R2_GG_1_0(W(1,6,H),W(1,14,H),R2_GGQ,AMPL(1,8))
C         Counter-term amplitude(s) for loop diagram number 11
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB_1EPS
     $     ,AMPL(2,9))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB_1EPS
     $     ,AMPL(2,10))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB_1EPS
     $     ,AMPL(2,11))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB_1EPS
     $     ,AMPL(2,12))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB,AMPL(1,13))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB_1EPS
     $     ,AMPL(2,14))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GT,AMPL(1,15))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GB_1EPS
     $     ,AMPL(2,16))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),UV_3GG_1EPS
     $     ,AMPL(2,17))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GQ,AMPL(1,18))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GQ,AMPL(1,19))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GQ,AMPL(1,20))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GQ,AMPL(1,21))
C         Counter-term amplitude(s) for loop diagram number 12
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB_1EPS
     $     ,AMPL(2,22))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB_1EPS
     $     ,AMPL(2,23))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB_1EPS
     $     ,AMPL(2,24))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB_1EPS
     $     ,AMPL(2,25))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB,AMPL(1,26))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB_1EPS
     $     ,AMPL(2,27))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GT,AMPL(1,28))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GB_1EPS
     $     ,AMPL(2,29))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),UV_3GG_1EPS
     $     ,AMPL(2,30))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GQ,AMPL(1,31))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GQ,AMPL(1,32))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GQ,AMPL(1,33))
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GQ,AMPL(1,34))
          CALL MP_FFV1_2(W(1,5,H),W(1,6,H),GC_5,MDL_MB,ZERO,W(1,15,H))
C         Counter-term amplitude(s) for loop diagram number 15
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,15,H),W(1,7,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,35))
          CALL MP_R2_QQ_2_0(W(1,15,H),W(1,7,H),UV_BMASS,AMPL(1,36))
          CALL MP_R2_QQ_2_0(W(1,15,H),W(1,7,H),UV_BMASS_1EPS,AMPL(2,37)
     $     )
C         Counter-term amplitude(s) for loop diagram number 16
          CALL MP_R2_GG_1_R2_GG_3_0(W(1,6,H),W(1,13,H),R2_GGQ,R2_GGB
     $     ,AMPL(1,38))
C         Counter-term amplitude(s) for loop diagram number 17
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,39))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,40))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,41))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,42))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB,AMPL(1,43))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,44))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQT,AMPL(1,45))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,46))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),UV_GQQG_1EPS
     $     ,AMPL(2,47))
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),R2_GQQ,AMPL(1,48))
C         Counter-term amplitude(s) for loop diagram number 19
          CALL MP_R2_GG_1_R2_GG_3_0(W(1,6,H),W(1,14,H),R2_GGQ,R2_GGB
     $     ,AMPL(1,49))
C         Counter-term amplitude(s) for loop diagram number 20
          CALL MP_FFV2_0(W(1,15,H),W(1,4,H),W(1,3,H),R2_BXTW,AMPL(1,50)
     $     )
          CALL MP_FFV1_1(W(1,4,H),W(1,6,H),GC_5,MDL_MT,MDL_WT,W(1,16,H)
     $     )
C         Counter-term amplitude(s) for loop diagram number 23
          CALL MP_FFV2_0(W(1,5,H),W(1,16,H),W(1,3,H),R2_BXTW,AMPL(1,51)
     $     )
          CALL MP_FFV2_1(W(1,9,H),W(1,3,H),GC_11,MDL_MB,ZERO,W(1,17,H))
C         Counter-term amplitude(s) for loop diagram number 25
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,10,H),W(1,17,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,52))
          CALL MP_R2_QQ_2_0(W(1,10,H),W(1,17,H),UV_BMASS,AMPL(1,53))
          CALL MP_R2_QQ_2_0(W(1,10,H),W(1,17,H),UV_BMASS_1EPS,AMPL(2
     $     ,54))
C         Counter-term amplitude(s) for loop diagram number 26
          CALL MP_FFV2_0(W(1,10,H),W(1,9,H),W(1,3,H),R2_BXTW,AMPL(1,55)
     $     )
C         Counter-term amplitude(s) for loop diagram number 27
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,56))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,57))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,58))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,59))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB,AMPL(1,60)
     $     )
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,61))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQT,AMPL(1,62)
     $     )
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,63))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),UV_GQQG_1EPS
     $     ,AMPL(2,64))
          CALL MP_FFV1_0(W(1,5,H),W(1,17,H),W(1,2,H),R2_GQQ,AMPL(1,65))
          CALL MP_FFV1_1(W(1,9,H),W(1,2,H),GC_5,MDL_MT,MDL_WT,W(1,18,H)
     $     )
C         Counter-term amplitude(s) for loop diagram number 29
          CALL MP_FFV2_0(W(1,5,H),W(1,18,H),W(1,3,H),R2_BXTW,AMPL(1,66)
     $     )
          CALL MP_FFV2_1(W(1,12,H),W(1,3,H),GC_11,MDL_MB,ZERO,W(1,19,H)
     $     )
C         Counter-term amplitude(s) for loop diagram number 33
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,11,H),W(1,19,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,67))
          CALL MP_R2_QQ_2_0(W(1,11,H),W(1,19,H),UV_BMASS,AMPL(1,68))
          CALL MP_R2_QQ_2_0(W(1,11,H),W(1,19,H),UV_BMASS_1EPS,AMPL(2
     $     ,69))
C         Counter-term amplitude(s) for loop diagram number 34
          CALL MP_FFV2_0(W(1,11,H),W(1,12,H),W(1,3,H),R2_BXTW,AMPL(1
     $     ,70))
C         Counter-term amplitude(s) for loop diagram number 35
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,71))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,72))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,73))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,74))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB,AMPL(1,75)
     $     )
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,76))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQT,AMPL(1,77)
     $     )
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,78))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),UV_GQQG_1EPS
     $     ,AMPL(2,79))
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),R2_GQQ,AMPL(1,80))
          CALL MP_FFV1_2(W(1,11,H),W(1,2,H),GC_5,MDL_MB,ZERO,W(1,20,H))
C         Counter-term amplitude(s) for loop diagram number 37
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,20,H),W(1,7,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,81))
          CALL MP_R2_QQ_2_0(W(1,20,H),W(1,7,H),UV_BMASS,AMPL(1,82))
          CALL MP_R2_QQ_2_0(W(1,20,H),W(1,7,H),UV_BMASS_1EPS,AMPL(2,83)
     $     )
          CALL MP_FFV1_1(W(1,7,H),W(1,2,H),GC_5,MDL_MB,ZERO,W(1,21,H))
C         Counter-term amplitude(s) for loop diagram number 38
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,11,H),W(1,21,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,84))
          CALL MP_R2_QQ_2_0(W(1,11,H),W(1,21,H),UV_BMASS,AMPL(1,85))
          CALL MP_R2_QQ_2_0(W(1,11,H),W(1,21,H),UV_BMASS_1EPS,AMPL(2
     $     ,86))
C         Counter-term amplitude(s) for loop diagram number 40
          CALL MP_FFV2_0(W(1,20,H),W(1,4,H),W(1,3,H),R2_BXTW,AMPL(1,87)
     $     )
C         Counter-term amplitude(s) for loop diagram number 43
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,88))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,89))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,90))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,91))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB,AMPL(1,92)
     $     )
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,93))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQT,AMPL(1,94)
     $     )
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,95))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),UV_GQQG_1EPS
     $     ,AMPL(2,96))
          CALL MP_FFV1_0(W(1,5,H),W(1,19,H),W(1,1,H),R2_GQQ,AMPL(1,97))
C         Counter-term amplitude(s) for loop diagram number 45
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,98))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,99))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,100))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,101))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB,AMPL(1
     $     ,102))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,103))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQT,AMPL(1
     $     ,104))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,105))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),UV_GQQG_1EPS
     $     ,AMPL(2,106))
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),R2_GQQ,AMPL(1,107)
     $     )
C         Counter-term amplitude(s) for loop diagram number 48
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GQ,AMPL(1,108)
     $     )
C         Counter-term amplitude(s) for loop diagram number 50
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GQ,AMPL(1,109)
     $     )
C         Counter-term amplitude(s) for loop diagram number 53
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,110))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,111))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,112))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,113))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB,AMPL(1
     $     ,114))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,115))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQT,AMPL(1
     $     ,116))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,117))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),UV_GQQG_1EPS
     $     ,AMPL(2,118))
          CALL MP_FFV1_0(W(1,5,H),W(1,21,H),W(1,1,H),R2_GQQ,AMPL(1,119)
     $     )
          CALL MP_FFV1_1(W(1,12,H),W(1,1,H),GC_5,MDL_MT,MDL_WT,W(1,22
     $     ,H))
C         Counter-term amplitude(s) for loop diagram number 59
          CALL MP_FFV2_0(W(1,5,H),W(1,22,H),W(1,3,H),R2_BXTW,AMPL(1
     $     ,120))
          CALL MP_FFV1_2(W(1,10,H),W(1,1,H),GC_5,MDL_MB,ZERO,W(1,23,H))
C         Counter-term amplitude(s) for loop diagram number 63
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,23,H),W(1,7,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,121))
          CALL MP_R2_QQ_2_0(W(1,23,H),W(1,7,H),UV_BMASS,AMPL(1,122))
          CALL MP_R2_QQ_2_0(W(1,23,H),W(1,7,H),UV_BMASS_1EPS,AMPL(2
     $     ,123))
          CALL MP_FFV1_1(W(1,7,H),W(1,1,H),GC_5,MDL_MB,ZERO,W(1,24,H))
C         Counter-term amplitude(s) for loop diagram number 64
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,10,H),W(1,24,H),R2_QQQ,R2_QQB
     $     ,AMPL(1,124))
          CALL MP_R2_QQ_2_0(W(1,10,H),W(1,24,H),UV_BMASS,AMPL(1,125))
          CALL MP_R2_QQ_2_0(W(1,10,H),W(1,24,H),UV_BMASS_1EPS,AMPL(2
     $     ,126))
C         Counter-term amplitude(s) for loop diagram number 66
          CALL MP_FFV2_0(W(1,23,H),W(1,4,H),W(1,3,H),R2_BXTW,AMPL(1
     $     ,127))
C         Counter-term amplitude(s) for loop diagram number 69
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,128))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,129))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,130))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,131))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB,AMPL(1
     $     ,132))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,133))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQT,AMPL(1
     $     ,134))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,135))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),UV_GQQG_1EPS
     $     ,AMPL(2,136))
          CALL MP_FFV1_0(W(1,5,H),W(1,24,H),W(1,2,H),R2_GQQ,AMPL(1,137)
     $     )
C         Counter-term amplitude(s) for loop diagram number 85
          CALL MP_R2_GG_1_R2_GG_3_0(W(1,6,H),W(1,13,H),R2_GGQ,R2_GGT
     $     ,AMPL(1,138))
C         Counter-term amplitude(s) for loop diagram number 86
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,8,H),W(1,16,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,139))
          CALL MP_R2_QQ_2_0(W(1,8,H),W(1,16,H),UV_TMASS,AMPL(1,140))
          CALL MP_R2_QQ_2_0(W(1,8,H),W(1,16,H),UV_TMASS_1EPS,AMPL(2
     $     ,141))
C         Counter-term amplitude(s) for loop diagram number 87
          CALL MP_R2_GG_1_R2_GG_3_0(W(1,6,H),W(1,14,H),R2_GGQ,R2_GGT
     $     ,AMPL(1,142))
C         Counter-term amplitude(s) for loop diagram number 88
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,143))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,144))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,145))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,146))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB,AMPL(1,147)
     $     )
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,148))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQT,AMPL(1,149)
     $     )
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQB_1EPS
     $     ,AMPL(2,150))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),UV_GQQG_1EPS
     $     ,AMPL(2,151))
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),R2_GQQ,AMPL(1,152))
          CALL MP_FFV2_2(W(1,10,H),W(1,3,H),GC_11,MDL_MT,MDL_WT,W(1,25
     $     ,H))
C         Counter-term amplitude(s) for loop diagram number 90
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,25,H),W(1,9,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,153))
          CALL MP_R2_QQ_2_0(W(1,25,H),W(1,9,H),UV_TMASS,AMPL(1,154))
          CALL MP_R2_QQ_2_0(W(1,25,H),W(1,9,H),UV_TMASS_1EPS,AMPL(2
     $     ,155))
C         Counter-term amplitude(s) for loop diagram number 91
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,156))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,157))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,158))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,159))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB,AMPL(1,160)
     $     )
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,161))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQT,AMPL(1,162)
     $     )
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,163))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),UV_GQQG_1EPS
     $     ,AMPL(2,164))
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),R2_GQQ,AMPL(1,165))
C         Counter-term amplitude(s) for loop diagram number 92
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,8,H),W(1,18,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,166))
          CALL MP_R2_QQ_2_0(W(1,8,H),W(1,18,H),UV_TMASS,AMPL(1,167))
          CALL MP_R2_QQ_2_0(W(1,8,H),W(1,18,H),UV_TMASS_1EPS,AMPL(2
     $     ,168))
          CALL MP_FFV1_2(W(1,8,H),W(1,2,H),GC_5,MDL_MT,MDL_WT,W(1,26,H)
     $     )
C         Counter-term amplitude(s) for loop diagram number 93
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,26,H),W(1,9,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,169))
          CALL MP_R2_QQ_2_0(W(1,26,H),W(1,9,H),UV_TMASS,AMPL(1,170))
          CALL MP_R2_QQ_2_0(W(1,26,H),W(1,9,H),UV_TMASS_1EPS,AMPL(2
     $     ,171))
          CALL MP_FFV2_2(W(1,11,H),W(1,3,H),GC_11,MDL_MT,MDL_WT,W(1,27
     $     ,H))
C         Counter-term amplitude(s) for loop diagram number 95
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,27,H),W(1,12,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,172))
          CALL MP_R2_QQ_2_0(W(1,27,H),W(1,12,H),UV_TMASS,AMPL(1,173))
          CALL MP_R2_QQ_2_0(W(1,27,H),W(1,12,H),UV_TMASS_1EPS,AMPL(2
     $     ,174))
C         Counter-term amplitude(s) for loop diagram number 96
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,175))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,176))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,177))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,178))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB,AMPL(1
     $     ,179))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,180))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQT,AMPL(1
     $     ,181))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,182))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),UV_GQQG_1EPS
     $     ,AMPL(2,183))
          CALL MP_FFV1_0(W(1,27,H),W(1,4,H),W(1,2,H),R2_GQQ,AMPL(1,184)
     $     )
C         Counter-term amplitude(s) for loop diagram number 98
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,185))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,186))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,187))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,188))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB,AMPL(1
     $     ,189))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,190))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQT,AMPL(1
     $     ,191))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,192))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),UV_GQQG_1EPS
     $     ,AMPL(2,193))
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),R2_GQQ,AMPL(1,194)
     $     )
C         Counter-term amplitude(s) for loop diagram number 99
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,195))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,196))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,197))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,198))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB,AMPL(1
     $     ,199))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,200))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQT,AMPL(1
     $     ,201))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,202))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),UV_GQQG_1EPS
     $     ,AMPL(2,203))
          CALL MP_FFV1_0(W(1,25,H),W(1,4,H),W(1,1,H),R2_GQQ,AMPL(1,204)
     $     )
C         Counter-term amplitude(s) for loop diagram number 100
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GQ,AMPL(1,205)
     $     )
C         Counter-term amplitude(s) for loop diagram number 101
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GQ,AMPL(1,206)
     $     )
C         Counter-term amplitude(s) for loop diagram number 107
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,207))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,208))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,209))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,210))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB,AMPL(1
     $     ,211))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,212))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQT,AMPL(1
     $     ,213))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQB_1EPS
     $     ,AMPL(2,214))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),UV_GQQG_1EPS
     $     ,AMPL(2,215))
          CALL MP_FFV1_0(W(1,26,H),W(1,4,H),W(1,1,H),R2_GQQ,AMPL(1,216)
     $     )
C         Counter-term amplitude(s) for loop diagram number 108
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,8,H),W(1,22,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,217))
          CALL MP_R2_QQ_2_0(W(1,8,H),W(1,22,H),UV_TMASS,AMPL(1,218))
          CALL MP_R2_QQ_2_0(W(1,8,H),W(1,22,H),UV_TMASS_1EPS,AMPL(2
     $     ,219))
          CALL MP_FFV1_2(W(1,8,H),W(1,1,H),GC_5,MDL_MT,MDL_WT,W(1,28,H)
     $     )
C         Counter-term amplitude(s) for loop diagram number 109
          CALL MP_R2_QQ_1_R2_QQ_2_0(W(1,28,H),W(1,12,H),R2_QQQ,R2_QQT
     $     ,AMPL(1,220))
          CALL MP_R2_QQ_2_0(W(1,28,H),W(1,12,H),UV_TMASS,AMPL(1,221))
          CALL MP_R2_QQ_2_0(W(1,28,H),W(1,12,H),UV_TMASS_1EPS,AMPL(2
     $     ,222))
C         Counter-term amplitude(s) for loop diagram number 112
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,223))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,224))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,225))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,226))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB,AMPL(1
     $     ,227))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,228))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQT,AMPL(1
     $     ,229))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQB_1EPS
     $     ,AMPL(2,230))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),UV_GQQG_1EPS
     $     ,AMPL(2,231))
          CALL MP_FFV1_0(W(1,28,H),W(1,4,H),W(1,2,H),R2_GQQ,AMPL(1,232)
     $     )
C         Counter-term amplitude(s) for loop diagram number 119
          CALL MP_R2_GG_1_R2_GG_2_0(W(1,6,H),W(1,13,H),R2_GGG_1
     $     ,R2_GGG_2,AMPL(1,233))
C         Counter-term amplitude(s) for loop diagram number 120
          CALL MP_R2_GG_1_R2_GG_2_0(W(1,6,H),W(1,14,H),R2_GGG_1
     $     ,R2_GGG_2,AMPL(1,234))
C         Counter-term amplitude(s) for loop diagram number 121
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,13,H),R2_3GG,AMPL(1,235)
     $     )
C         Counter-term amplitude(s) for loop diagram number 122
          CALL MP_VVV1_0(W(1,1,H),W(1,2,H),W(1,14,H),R2_3GG,AMPL(1,236)
     $     )
C         Amplitude(s) for UVCT diagram with ID 135
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),GC_5,AMPL(2,237))
          AMPL(2,237)=AMPL(2,237)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 136
          CALL MP_FFV1_0(W(1,5,H),W(1,7,H),W(1,6,H),GC_5,AMPL(1,238))
          AMPL(1,238)=AMPL(1,238)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 137
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),GC_5,AMPL(2,239))
          AMPL(2,239)=AMPL(2,239)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 138
          CALL MP_FFV1_0(W(1,8,H),W(1,4,H),W(1,6,H),GC_5,AMPL(1,240))
          AMPL(1,240)=AMPL(1,240)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 139
          CALL MP_FFV2_0(W(1,10,H),W(1,9,H),W(1,3,H),GC_11,AMPL(2,241))
          AMPL(2,241)=AMPL(2,241)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 140
          CALL MP_FFV2_0(W(1,10,H),W(1,9,H),W(1,3,H),GC_11,AMPL(1,242))
          AMPL(1,242)=AMPL(1,242)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 141
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),GC_5,AMPL(2,243))
          AMPL(2,243)=AMPL(2,243)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 142
          CALL MP_FFV1_0(W(1,8,H),W(1,9,H),W(1,2,H),GC_5,AMPL(1,244))
          AMPL(1,244)=AMPL(1,244)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 143
          CALL MP_FFV2_0(W(1,11,H),W(1,12,H),W(1,3,H),GC_11,AMPL(2,245)
     $     )
          AMPL(2,245)=AMPL(2,245)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 144
          CALL MP_FFV2_0(W(1,11,H),W(1,12,H),W(1,3,H),GC_11,AMPL(1,246)
     $     )
          AMPL(1,246)=AMPL(1,246)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 145
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),GC_5,AMPL(2,247))
          AMPL(2,247)=AMPL(2,247)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 146
          CALL MP_FFV1_0(W(1,11,H),W(1,7,H),W(1,2,H),GC_5,AMPL(1,248))
          AMPL(1,248)=AMPL(1,248)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 147
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),GC_5,AMPL(2,249))
          AMPL(2,249)=AMPL(2,249)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 148
          CALL MP_FFV1_0(W(1,8,H),W(1,12,H),W(1,1,H),GC_5,AMPL(1,250))
          AMPL(1,250)=AMPL(1,250)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Amplitude(s) for UVCT diagram with ID 149
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),GC_5,AMPL(2,251))
          AMPL(2,251)=AMPL(2,251)*(4.0D0*UVWFCT_G_1_1EPS+2.0D0
     $     *UVWFCT_B_0_1EPS)
C         Amplitude(s) for UVCT diagram with ID 150
          CALL MP_FFV1_0(W(1,10,H),W(1,7,H),W(1,1,H),GC_5,AMPL(1,252))
          AMPL(1,252)=AMPL(1,252)*(2.0D0*UVWFCT_G_1+1.0D0*UVWFCT_B_0
     $     +2.0D0*UVWFCT_G_2+1.0D0*UVWFCT_T_0)
C         Copy the qp wfs to the dp ones as they are used to setup the
C          CT calls.
          DO I=1,NWAVEFUNCS
            DO J=1,20
              DPW(J,I,H)=W(J,I,H)
            ENDDO
          ENDDO
C         Same for the counterterms amplitudes
          DO I=1,NCTAMPS
            DO J=1,3
              DPAMPL(J,I)=AMPL(J,I)
              S(I)=.TRUE.
            ENDDO
          ENDDO
          DO I=1,NBORNAMPS
            DPAMP(I,H)=AMP(I,H)
          ENDDO
        ENDIF
      ENDDO

      END

