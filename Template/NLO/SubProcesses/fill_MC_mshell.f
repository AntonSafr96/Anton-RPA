      subroutine fill_MC_mshell()
      implicit none
      integer i
c Monte Carlo masses: use PDG conventions.
c May be given in input eventually
      double precision mcmass(-5:21)
      common/cmcmass/mcmass
c
      character*10 MonteCarlo
      common/cMonteCarloType/MonteCarlo
c
      do i=-5,21
        mcmass(i)=-1.d10
      enddo
      if (MonteCarlo.eq.'HERWIG6') then
         include "MCmasses_HERWIG6.inc"
      elseif(MonteCarlo.eq.'HERWIGPP')then
         include "MCmasses_HERWIGPP.inc"
      elseif(MonteCarlo.eq.'PYTHIA6Q')then
         include "MCmasses_PYTHIA6Q.inc"
      elseif(MonteCarlo.eq.'PYTHIA6PT')then
         include "MCmasses_PYTHIA6PT.inc"
      elseif(MonteCarlo.eq.'PYTHIA8')then
         include "MCmasses_PYTHIA8.inc"
      else
         write (*,*) 'Wrong MC ', MonteCarlo, ' in fill_MC_mshell'
         stop
      endif
      do i=-5,-1
         mcmass(i)=mcmass(-i)
      enddo
      return      
      end
