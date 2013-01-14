      double precision function gamma(q0)
c**************************************************
c   calculates the branching probability
c**************************************************
      implicit none
      include 'nexternal.inc'
      include 'message.inc'
      include 'nFKSconfigs.inc'
      include 'cluster.inc'
      include 'sudakov.inc'
      include 'run.inc'
      integer i
      double precision q0, val, add, add2
      double precision qr,lf
      double precision alphas
      external alphas
      double precision pi
      parameter (pi=3.141592654d0)

      gamma=0.0d0

      if (Q1<m_qmass(iipdg)) return
      m_lastas=Alphas(alpsfact*q0)
      val=2d0*m_colfac(iipdg)*m_lastas/PI/q0
c   if (m_mode & bpm::power_corrs) then
      qr=q0/Q1
      if(m_pca(iipdg,iimode).eq.0)then
        lf=log(1d0/qr-1d0)
      else 
        lf=log(1d0/qr)
      endif
      val=val*(m_dlog(iipdg)*(1d0+m_kfac*m_lastas/(2d0*PI))*lf+m_slog(iipdg)
     $   +qr*(m_power(iipdg,1,iimode)+qr*(m_power(iipdg,2,iimode)
     $   +qr*m_power(iipdg,3,iimode))))
c   else
c   val=val*m_dlog*(1d0+m_kfac*m_lastas/(2d0*PI))*log(Q1/q0)+m_slog;
c   endif
      if(m_qmass(iipdg).gt.0d0)then
        val=val+m_colfac(iipdg)*m_lastas/PI/q0*(0.5-q0/m_qmass(iipdg)*
     $     atan(m_qmass(iipdg)/q0)-
     $     (1.0-0.5*(q0/m_qmass(iipdg))**2)*log(1.0+(m_qmass(iipdg)/q0)**2))
      endif
      val=max(val,0d0)
      if (iipdg.eq.21) then
        add=0d0
        do i=-6,-1
          if(m_qmass(abs(i)).gt.0d0)then
            add2=m_colfac(i)*m_lastas/PI/q0/
     $         (1.0+(m_qmass(abs(i))/q0)**2)*
     $         (1.0-1.0/3.0/(1.0+(m_qmass(abs(i))/q0)**2))
          else
            add2=2d0*m_colfac(i)*m_lastas/PI/q0*(m_slog(i)
     $         +qr*(m_power(i,1,iimode)+qr*(m_power(i,2,iimode)
     $         +qr*m_power(i,3,iimode))))
          endif
          add=add+max(add2,0d0)
        enddo
        val=val+add
      endif
      
      gamma = max(val,0d0)

      if (btest(mlevel,6)) then
        write(*,*)'       \\Delta^I_{',iipdg,'}(',
     &     q0,',',q1,') -> ',gamma
        write(*,*) val,m_lastas,m_dlog(iipdg),m_slog(iipdg)
        write(*,*) m_power(iipdg,1,iimode),m_power(iipdg,2,iimode)
     $       ,m_power(iipdg,3,iimode)
      endif

      return
      end

      double precision function sud(q0,Q11,ipdg,imode)
c**************************************************
c   actually calculates is sudakov weight
c**************************************************
      implicit none
      include 'message.inc'
      include 'nexternal.inc'
      include 'nFKSconfigs.inc'
      include 'cluster.inc'      
      integer ipdg,imode
      double precision q0, Q11
      double precision gamma,DGAUSS
      external gamma,DGAUSS
      double precision eps
      parameter (eps=1d-5)
      
      sud=0.0d0

      Q1=Q11
      iipdg=iabs(ipdg)
      iimode=imode

      sud=exp(-DGAUSS(gamma,q0,Q1,eps))

      if (btest(mlevel,6)) then
        write(*,*)'       \\Delta^',imode,'_{',ipdg,'}(',
     &     2*log10(q0/q1),') -> ',sud
      endif

      return
      end

      double precision function sudwgt(q0,q1,q2,ipdg,imode)
c**************************************************
c   calculates is sudakov weight
c**************************************************
      implicit none
      include 'message.inc'
      integer ipdg,imode
      double precision q0, q1, q2
      double precision sud
      external sud
      
      sudwgt=1.0d0

      if(q2.le.q1)then
         if(q2.lt.q1.and.btest(mlevel,4))
     $        write(*,*)'Warning! q2 < q1 in sudwgt. Return 1.'
         return
      endif

      sudwgt=sud(q0,q2,ipdg,imode)/sud(q0,q1,ipdg,imode)

      if (btest(mlevel,5)) then
        write(*,*)'       \\Delta^',imode,'_{',ipdg,'}(',
     &     q0,',',q1,',',q2,') -> ',sudwgt
      endif

      return
      end

      logical function isqcd(ipdg)
c**************************************************
c   determines whether particle is qcd particle
c**************************************************
      implicit none
      integer ipdg, irfl
      integer get_color

      isqcd=(iabs(get_color(ipdg)).gt.1)

      return
      end

      logical function isjet(ipdg)
c**************************************************
c   determines whether particle is qcd jet particle
c**************************************************
      implicit none

      include 'cuts.inc'

      integer ipdg, irfl

      isjet=.true.

      irfl=abs(ipdg)
      if (irfl.gt.maxjetflavor.and.irfl.ne.21) isjet=.false.
c      write(*,*)'isjet? pdg = ',ipdg,' -> ',irfl,' -> ',isjet

      return
      end

      logical function isparton(ipdg)
c**************************************************
c   determines whether particle is qcd jet particle
c**************************************************
      implicit none

      include 'cuts.inc'

      integer ipdg, irfl

      isparton=.true.

      irfl=abs(ipdg)
      if (irfl.gt.5.and.irfl.ne.21) isparton=.false.
c      write(*,*)'isparton? pdg = ',ipdg,' -> ',irfl,' -> ',isparton

      return
      end

      subroutine ipartupdate(p,imo,ida1,ida2,ipdg,ipart)
c**************************************************
c   Traces particle lines according to CKKW rules
c**************************************************
      implicit none

      include 'ncombs.inc'
      include 'nexternal.inc'
      include 'message.inc'

      double precision p(0:3,nexternal)
      integer imo,ida1,ida2,i,idmo,idda1,idda2
      integer ipdg(n_max_cl),ipart(2,n_max_cl)

      idmo=ipdg(imo)
      idda1=ipdg(ida1)
      idda2=ipdg(ida2)

      if (btest(mlevel,4)) then
        write(*,*) ' updating ipart for: ',ida1,ida2,' -> ',imo
      endif

      if (btest(mlevel,4)) then
         write(*,*) ' daughters: ',(ipart(i,ida1),i=1,2),
     &        (ipart(i,ida2),i=1,2)
      endif

c     Initial State clustering - just transmit info on incoming line
      if((ipart(1,ida1).ge.1.and.ipart(1,ida1).le.2).or.
     $   (ipart(1,ida2).ge.1.and.ipart(1,ida2).le.2))then
         ipart(2,imo)=0
         if(ipart(1,ida1).le.2.and.ipart(1,ida2).le.2)then
c           This is last clustering - keep mother ipart
            ipart(1,imo)=ipart(1,imo)
         elseif(ipart(1,ida2).ge.1.and.ipart(1,ida2).le.2)then
            ipart(1,imo)=ipart(1,ida2)        
         elseif(ipart(1,ida1).ge.1.and.ipart(1,ida1).le.2)then
            ipart(1,imo)=ipart(1,ida1)
         endif
         if (btest(mlevel,4))
     $        write(*,*) ' -> ',(ipart(i,imo),i=1,2)
         return
      endif        

c     Final State clustering
      if(idmo.eq.21.and.idda1.eq.21.and.idda2.eq.21)then
c     gluon -> 2 gluon splitting: Choose hardest gluon
         if ( p(1,ipart(1,ida1))**2+p(2,ipart(1,ida1))**2.gt.
     $        p(1,ipart(1,ida2))**2+p(2,ipart(1,ida2))**2 ) then
            ipart(1,imo)=ipart(1,ida1)
            ipart(2,imo)=ipart(2,ida1)
         else
            ipart(1,imo)=ipart(1,ida2)
            ipart(2,imo)=ipart(2,ida2)
         endif
      else if(idmo.eq.21.and.idda1.eq.-idda2)then
c     gluon -> quark anti-quark: use both, but take hardest as 1
         if ( p(1,ipart(1,ida1))**2+p(2,ipart(1,ida1))**2.gt.
     $        p(1,ipart(1,ida2))**2+p(2,ipart(1,ida2))**2 ) then
            ipart(1,imo)=ipart(1,ida1)
            ipart(2,imo)=ipart(1,ida2)
         else
            ipart(1,imo)=ipart(1,ida2)
            ipart(2,imo)=ipart(1,ida1)
         endif
      else if(idmo.eq.idda1.or.idmo.eq.idda1+sign(1,idda2))then
c     quark -> quark-gluon or quark-Z or quark-h or quark-W
         ipart(1,imo)=ipart(1,ida1)
         ipart(2,imo)=0
      else if(idmo.eq.idda2.or.idmo.eq.idda2+sign(1,idda1))then
c     quark -> gluon-quark or Z-quark or h-quark or W-quark
         ipart(1,imo)=ipart(1,ida2)
         ipart(2,imo)=0
      else
c     Color singlet
         ipart(1,imo)=ipart(1,ida1)
         ipart(2,imo)=ipart(1,ida2)
      endif
      
      if (btest(mlevel,4)) then
         write(*,*) ' -> ',(ipart(i,imo),i=1,2)
      endif

      return
      end
      
      logical function isjetvx(imo,ida1,ida2,ipdg,ipart,islast)
c***************************************************
c   Checks if a qcd vertex generates a jet
c***************************************************
      implicit none

      include 'ncombs.inc'
      include 'nexternal.inc'

      integer imo,ida1,ida2,idmo,idda1,idda2,i
      integer ipdg(n_max_cl),ipart(2,n_max_cl)
      logical isqcd,isjet,islast
      external isqcd,isjet

      idmo=ipdg(imo)
      idda1=ipdg(ida1)
      idda2=ipdg(ida2)

c     Check QCD vertex
      if(islast.or..not.isqcd(idmo).or..not.isqcd(idda1).or.
     &     .not.isqcd(idda2)) then
         isjetvx = .false.
         return
      endif

c     Initinal State clustering
      if((ipart(1,ida1).ge.1.and.ipart(1,ida1).le.2).or.
     $   (ipart(1,ida2).ge.1.and.ipart(1,ida2).le.2))then
c     Check if ida1 is outgoing parton or ida2 is outgoing parton
         if((ipart(1,ida2).ge.1 .and.ipart(1,ida2).le.2
     $        .and.isjet(idda1)).or.
     $      (ipart(1,ida1).ge.1 .and.ipart(1,ida1).le.2
     $        .and.isjet(idda2)))then
           isjetvx=.true.
        else
           isjetvx=.false.
        endif
        return
      endif        

c     Final State clustering
      if(isjet(idda1).or.isjet(idda2))then
         isjetvx=.true.
      else
         isjetvx=.false.
      endif
      
      return
      end

      logical function ispartonvx(imo,ida1,ida2,ipdg,ipart,islast)
c***************************************************
c   Checks if a qcd vertex generates a jet
c***************************************************
      implicit none

      include 'ncombs.inc'
      include 'nexternal.inc'

      integer imo,ida1,ida2,idmo,idda1,idda2,i
      integer ipdg(n_max_cl),ipart(2,n_max_cl)
      logical isqcd,isparton,islast
      external isqcd,isparton

      idmo=ipdg(imo)
      idda1=ipdg(ida1)
      idda2=ipdg(ida2)

c     Check QCD vertex
      if(.not.isqcd(idmo).or..not.isqcd(idda1).or..not.isqcd(idda2))
     $     then
         ispartonvx = .false.
         return
      endif

c     IS clustering
      if((ipart(1,ida1).ge.1.and.ipart(1,ida1).le.2).or.
     $   (ipart(1,ida2).ge.1.and.ipart(1,ida2).le.2))then
c     Check if ida1 is outgoing parton or ida2 is outgoing parton
         if(.not.islast.and.ipart(1,ida2).ge.1
     $        .and.ipart(1,ida2).le.2.and.isparton(idda1).or.ipart(1
     $        ,ida1).ge.1.and.ipart(1
     $        ,ida1).le.2.and.isparton(idda2))then
           ispartonvx=.true.
        else
           ispartonvx=.false.
        endif
        return
      endif        

c     FS clustering
      if(isparton(idda1).or.isparton(idda2))then
         ispartonvx=.true.
      else
         ispartonvx=.false.
      endif
      
      return
      end

      logical function setclscales(p)
c**************************************************
c     Calculate dynamic scales based on clustering
c**************************************************
      implicit none

c Include
      include 'nexternal.inc'
      include 'run.inc'
      include 'nFKSconfigs.inc'
      include 'maxparticles.inc'
      include 'cluster.inc'
      include 'message.inc'
      include 'coupl.inc'
      double precision ZERO,PI
      parameter (ZERO=0d0)
      parameter( PI = 3.14159265358979323846d0 )
c Argument
      double precision p(0:3,nexternal)
c Local
      integer i,j,n,ibeam(2),jlast(2),jfirst(2),jcentral(2),ipart(2
     $     ,n_max_cl)
      logical partonline(2),qcdline(2)
      integer nwarning
      data nwarning /0/
c Common
      INTEGER NFKSPROCESS
      COMMON/C_NFKSPROCESS/NFKSPROCESS
      double precision q2bck(2)
      common /to_q2bck/q2bck
c External
      logical cluster,isqcd,isparton,isjetvx,isjet
      double precision alphas
      external cluster,isqcd,isparton,isjetvx,isjet,alphas
c
      setclscales=.true.
c   
c   Cluster the configuration
c   
      
      clustered = cluster(p(0,1))
      if(.not.clustered) then
         write(*,*) 'Error: Clustering failed in cluster.f.'
         stop
      endif

      if (btest(mlevel,1)) then
         write(*,*)'setclscales: identified tree {'
         do i=1,nexternal-2
            write(*,*)'  ',i,': ',idacl(i,1),'(',ipdgcl(idacl(i,1)
     $           ,igraphs(1),nFKSprocess),')','&',idacl(i,2),'('
     $           ,ipdgcl(idacl(i,2),igraphs(1),nFKSprocess),')',' -> '
     $           ,imocl(i),'(',ipdgcl(imocl(i),igraphs(1),nFKSprocess)
     $           ,')' ,', ptij = ',dsqrt(pt2ijcl(i))
         enddo
         write(*,*)'  process: ',nFKSprocess
         write(*,*)'  graphs (',igraphs(0),'):',(igraphs(i),i=1
     $        ,igraphs(0))
         write(*,*)'}'
      endif

c     If last clustering is s-channel QCD (e.g. ttbar) use mt2last instead
c     (i.e. geom. average of transverse mass of t and t~)
      if(mt2last.gt.4d0 .and. nexternal.gt.3) then
         if(isqcd(ipdgcl(idacl(nexternal-3,1),igraphs(1),nFKSprocess))
     $        .and. isqcd(ipdgcl(idacl(nexternal-3,2),igraphs(1),nFKSprocess))
     $        .and. isqcd(ipdgcl(imocl(nexternal-3),igraphs(1),nFKSprocess)))then
            mt2ij(nexternal-2)=mt2last
            mt2ij(nexternal-3)=mt2last
            if (btest(mlevel,3)) then
               write(*,*)' setclscales: set last vertices to mtlast: '
     $              ,sqrt(mt2last)
            endif
         endif
      endif

      do i=1,2
         ibeam(i)=ishft(1,i-1)
         jfirst(i)=0
         jlast(i)=0
         jcentral(i)=0
         partonline(i)=isparton(ipdgcl(ibeam(i),igraphs(1),nFKSprocess))
         qcdline(i)=isqcd(ipdgcl(ibeam(i),igraphs(1),nFKSprocess))
      enddo

c   Go through clusterings and set factorization scales for use in dsig
      if (nexternal.eq.3) goto 10
      do n=1,nexternal-2        ! loop over cluster nodes
         do i=1,2               ! loop over daughters in clusterings
            do j=1,2            ! loop over the two initial state partons
               if (isqcd(ipdgcl(idacl(n,i),igraphs(1),nFKSprocess)).and.
     $              idacl(n,i).eq.ibeam(j).and.qcdline(j)) then
c     initial state emission - this is what we want
c     Total pdf weight is f1(x1,pt2E)*fj(x1*z,Q)/fj(x1*z,pt2E)
c     f1(x1,pt2E) is given by DSIG, just need to set scale.
                  ibeam(j)=imocl(n)
                  if(jfirst(j).eq.0)then
c FIXTHIS FIXTHIS FIXTHIS: ipart not defined here???
                     if(isjetvx(imocl(n),idacl(n,1),idacl(n,2),
     $                    ipdgcl(1,igraphs(1),nFKSprocess),ipart,
     $                    n.eq.nexternal-2)) then
                        jfirst(j)=n
                     else
                        jfirst(j)=-1
                     endif
                  endif
                  if(partonline(j))then
c     Stop fact scale where parton line stops
                     jlast(j)=n
                     partonline(j)=
     &                    isjet(ipdgcl(imocl(n),igraphs(1),nFKSprocess))
                  endif
c     Trace QCD line through event
                  jcentral(j)=n
                  qcdline(j)=
     &                 isqcd(ipdgcl(imocl(n),igraphs(1),nFKSprocess))
               endif
            enddo
         enddo
      enddo

 10   if(jfirst(1).le.0) jfirst(1)=jlast(1)
      if(jfirst(2).le.0) jfirst(2)=jlast(2)

      if (btest(mlevel,3))
     $     write(*,*) 'jfirst is ',jfirst(1),jfirst(2),
     $     ' jlast is ',jlast(1),jlast(2),
     $     ' and jcentral is ',jcentral(1),jcentral(2)

c     Set central scale to mT2
      if(jcentral(1).gt.0) then
         if(mt2ij(jcentral(1)).gt.0d0)
     $        pt2ijcl(jcentral(1))=mt2ij(jcentral(1))
      endif
      if(jcentral(2).gt.0)then
         if(mt2ij(jcentral(2)).gt.0d0)
     $        pt2ijcl(jcentral(2))=mt2ij(jcentral(2))
      endif
      if(btest(mlevel,4))then
         write (*,*)'jlast, jcentral: ',(jlast(i),i=1,2),(jcentral(i),i
     $        =1,2)
         if(jlast(1).gt.0) write(*,*)'pt(jlast 1): ',
     $        sqrt(pt2ijcl(jlast(1)))
         if(jlast(2).gt.0) write(*,*)'pt(jlast 2): ',
     $        sqrt(pt2ijcl(jlast(2)))
         if(jcentral(1).gt.0) write(*,*)'pt(jcentral 1): ',
     $        sqrt(pt2ijcl(jcentral(1)))
         if(jcentral(2).gt.0) write(*,*)'pt(jcentral 2): ',
     $        sqrt(pt2ijcl(jcentral(2)))
      endif
      
      if(ickkw.eq.0.and.(fixed_fac_scale.or.q2fact(1).gt.0).and.
     $     (fixed_ren_scale.or.scale.gt.0)) return

c     Ensure that last scales are at least as big as first scales
      if(jlast(1).gt.0)
     $     pt2ijcl(jlast(1))=max(pt2ijcl(jlast(1)),pt2ijcl(jfirst(1)))
      if(jlast(2).gt.0)
     $     pt2ijcl(jlast(2))=max(pt2ijcl(jlast(2)),pt2ijcl(jfirst(2)))

c     Set renormalization scale to geom. aver. of central scales
c     if both beams are qcd
      if(scale.eq.0d0) then
         if(jcentral(1).gt.0.and.jcentral(2).gt.0) then
            scale=(pt2ijcl(jcentral(1))*pt2ijcl(jcentral(2)))**0.25d0
         elseif(jcentral(1).gt.0) then
            scale=sqrt(pt2ijcl(jcentral(1)))
         elseif(jcentral(2).gt.0) then
            scale=sqrt(pt2ijcl(jcentral(2)))
         else
            scale=sqrt(pt2ijcl(nexternal-2))
         endif
         scale = scalefact*scale
         if(scale.gt.0)
     $        G = SQRT(4d0*PI*ALPHAS(scale))
      endif
      if (btest(mlevel,3))
     $     write(*,*) 'Set ren scale to ',scale

      if(ickkw.gt.0.and.q2fact(1).gt.0) then
c     Use the fixed or previously set scale for central scale
         if(jcentral(1).gt.0) pt2ijcl(jcentral(1))=q2fact(1)
         if(jcentral(2).gt.0.and.jcentral(2).ne.jcentral(1))
     $        pt2ijcl(jcentral(2))=q2fact(2)
      endif

      if(nexternal.eq.3.and.nincoming.eq.2.and.q2fact(1).eq.0) then
         q2fact(1)=pt2ijcl(nexternal-2)
         q2fact(2)=pt2ijcl(nexternal-2)
      endif

      if(q2fact(1).eq.0d0) then
c     Use the geom. average of central scale and first non-radiation vertex
         if(jlast(1).gt.0) q2fact(1)=sqrt(pt2ijcl(jlast(1))*pt2ijcl(jcentral(1)))
         if(jlast(2).gt.0) q2fact(2)=sqrt(pt2ijcl(jlast(2))*pt2ijcl(jcentral(2)))
         if(jcentral(1).gt.0.and.jcentral(1).eq.jcentral(2))then
c     We have a qcd line going through the whole event, use single scale
            q2fact(1)=max(q2fact(1),q2fact(2))
            q2fact(2)=q2fact(1)
         endif
      endif
      if(.not. fixed_fac_scale) then
         q2fact(1)=scalefact**2*q2fact(1)
         q2fact(2)=scalefact**2*q2fact(2)
         q2bck(1)=q2fact(1)
         q2bck(2)=q2fact(2)
         if (btest(mlevel,3))
     $      write(*,*) 'Set central fact scales to ',sqrt(q2bck(1)),sqrt(q2bck(2))
      endif
         
      if(jcentral(1).eq.0.and.jcentral(2).eq.0)then
         if(q2fact(1).gt.0)then
            pt2ijcl(nexternal-2)=q2fact(1)
            pt2ijcl(nexternal-3)=q2fact(1)
         else
            q2fact(1)=pt2ijcl(nexternal-2)
            q2fact(2)=q2fact(1)
         endif
      elseif(ickkw.eq.2.or.pdfwgt)then
c     Use the minimum scale found for fact scale in ME
         if(jlast(1).gt.0.and.jfirst(1).lt.jlast(1))
     $        q2fact(1)=min(pt2ijcl(jfirst(1)),q2fact(1))
         if(jlast(2).gt.0.and.jfirst(2).lt.jlast(2))
     $        q2fact(2)=min(pt2ijcl(jfirst(2)),q2fact(2))
      endif

c     Check that factorization scale is >= 2 GeV
      if(lpp(1).ne.0.and.q2fact(1).lt.4d0.or.
     $   lpp(2).ne.0.and.q2fact(2).lt.4d0)then
         if(nwarning.le.10) then
             nwarning=nwarning+1
             write(*,*) 'Warning: Too low fact scales: ',
     $            sqrt(q2fact(1)), sqrt(q2fact(2))
          endif
         if(nwarning.eq.11) then
             nwarning=nwarning+1
             write(*,*) 'No more warnings written out this run.'
          endif
         setclscales=.false.
         clustered = .false.
         return
      endif

      if (btest(mlevel,3))
     $     write(*,*) 'Set fact scales to ',sqrt(q2fact(1)),sqrt(q2fact(2))
      return
      end
      

      double precision function rewgt(p)
c**************************************************
c   reweight the hard me according to ckkw
c   employing the information in common/cl_val/
c**************************************************
      implicit none

c Include
      include 'nexternal.inc'
      include 'nFKSconfigs.inc'
      include 'cluster.inc'
      include 'message.inc'
      include 'run.inc'
      include 'coupl.inc'
      double precision ZERO,PI
      parameter (ZERO=0d0)
      parameter( PI = 3.14159265358979323846d0 )
c Argument
      double precision p(0:3,nexternal)
c Local
      logical isvx
      integer i,j,n,ipart(2,n_max_cl),ibeam(2)
      double precision pt2min,etot,pt2prev(n_max_cl),pt2pdf(n_max_cl)
     $     ,xnow(2),asref,q2now,tmp,pdfj1,pdfj2
      integer ib(2)
      data ib /1,2/
c Common
      INTEGER NFKSPROCESS
      COMMON/C_NFKSPROCESS/NFKSPROCESS
      double precision q2bck(2)
      common /to_q2bck/q2bck
c External
      logical ispartonvx,isqcd,isparton,isjetvx,isjet
      double precision alphas,getissud,pdg2pdf,sudwgt
      external ispartonvx,alphas,isqcd,isparton,isjetvx,getissud,pdg2pdf
     $     ,isjet,sudwgt

c$$$c SET THE DEFAULT KTSCHEME
      double precision xqcut
c$$$      logical hmult,pdfwgt
c$$$      integer ickkw
      xqcut=0d0
c$$$      hmult=.false.
c$$$      pdfwgt=.false.
c$$$      ickkw=1
      

      rewgt=1.0d0
      clustered=.false.

      if(ickkw.le.0) return

c   Set mimimum kt scale, depending on highest mult or not
      if(hmult.or.ickkw.eq.1)then
        pt2min=0d0
      else
        pt2min=xqcut**2
      endif
      if (btest(mlevel,3))
     $     write(*,*) 'pt2min set to ',pt2min

c   Set etot, used for non-radiating partons
      etot=sqrt(4d0*ebeam(1)*ebeam(2))

c   Since we use pdf reweighting, need to know particle identities
      if (btest(mlevel,1)) then
         write(*,*) 'Set process number ',nFKSprocess
      endif

c   Preparing graph particle information (ipart, needed to keep track of
c   external particle clustering scales)
      do i=1,nexternal
         pt2prev(ishft(1,i-1))=0d0
         if (ickkw.eq.2) then
            if(pt2min.gt.0)then
               pt2prev(ishft(1,i-1))=
     $              max(pt2min,p(0,i)**2-p(1,i)**2-p(2,i)**2-p(3,i)**2)
            endif
            pt2pdf(ishft(1,i-1))=pt2prev(ishft(1,i-1))
         else if(pdfwgt) then
            pt2pdf(ishft(1,i-1))=0d0
         endif
         ptclus(i)=sqrt(pt2prev(ishft(1,i-1)))
         if (btest(mlevel,3))
     $        write(*,*) 'Set ptclus for ',i,' to ', ptclus(i)
         ipart(1,ishft(1,i-1))=i
         ipart(2,ishft(1,i-1))=0
         if (btest(mlevel,4))
     $        write(*,*) 'Set ipart for ',ishft(1,i-1),' to ',
     $        ipart(1,ishft(1,i-1)),ipart(2,ishft(1,i-1))
      enddo
      ibeam(1)=ishft(1,0)
      ibeam(2)=ishft(1,1)
      if (btest(mlevel,1)) then
         write(*,*)'rewgt: identified tree {'
         do i=1,nexternal-2
            write(*,*)'  ',i,': ',idacl(i,1),'(',ipdgcl(idacl(i,1)
     $           ,igraphs(1),nFKSprocess),')','&',idacl(i,2),'('
     $           ,ipdgcl(idacl(i ,2),igraphs(1),nFKSprocess),')',' -> '
     $           ,imocl(i),'(' ,ipdgcl(imocl(i),igraphs(1),nFKSprocess)
     $           ,')' ,', ptij = ' ,dsqrt(pt2ijcl(i))
         enddo
         write(*,*)'  graphs (',igraphs(0),'):',(igraphs(i),i=1
     $        ,igraphs(0))
         write(*,*)'}'
      endif
c     Set x values for the two sides, for Initial State Sudakovs
      do i=1,2
         xnow(i)=xbk(ib(i))
      enddo
      if(btest(mlevel,3))then
         write(*,*) 'Set x values to ',xnow(1),xnow(2)
      endif

c     Prepare for resetting q2fact based on PDF reweighting
      if(ickkw.eq.2)then
         q2fact(1)=0d0
         q2fact(2)=0d0
      endif
c   
c     Set strong coupling used
c   
      asref=G**2/(4d0*PI)

c     Perform alpha_s reweighting based on type of vertex
      do n=1,nexternal-2
c       scale for alpha_s reweighting
         q2now=pt2ijcl(n)
         if(n.eq.nexternal-2) then
            q2now = scale**2
         endif
         if (btest(mlevel,3)) then
            write(*,*)'  ',n,': ',idacl(n,1),'(',ipdgcl(idacl(n,1)
     $           ,igraphs(1),nFKSprocess),')&',idacl(n,2),'('
     $           ,ipdgcl(idacl(n ,2) ,igraphs(1),nFKSprocess),') -> '
     $           ,imocl(n),'(' ,ipdgcl(imocl(n) ,igraphs(1),nFKSprocess)
     $           ,'), ptij = ' ,dsqrt(q2now) 
         endif
c     perform alpha_s reweighting only for vertices where a parton is produced
c     and not for the last clustering (use non-fixed ren. scale for these)
         if (n.lt.nexternal-2)then
            if(ispartonvx(imocl(n),idacl(n,1),idacl(n,2),
     $           ipdgcl(1,igraphs(1),nFKSprocess),ipart,.false.)) then
c       alpha_s weight
c FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS
c  the renormalization scale should be set as the geometric mean of all
c  scales involved: we cannot simply reweight the alpha_s's here.
c FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS
               rewgt=rewgt*alphas(alpsfact*sqrt(q2now))/asref
               if (btest(mlevel,3)) then
                  write(*,*)' reweight vertex: ',ipdgcl(imocl(n)
     $                 ,igraphs(1),nFKSprocess),ipdgcl(idacl(n,1)
     $                 ,igraphs(1) ,nFKSprocess),ipdgcl(idacl(n,2)
     $                 ,igraphs(1),nFKSprocess)
                  write(*,*)'       as: ',alphas(alpsfact*dsqrt(q2now)),
     $                 '/',asref,' -> ',alphas(alpsfact*dsqrt(q2now))
     $                 /asref
                  write(*,*)' and G=',SQRT(4d0*PI*ALPHAS(scale))
               endif
            endif
         endif
c   Update starting values for Final State parton showering
         do i=1,2               ! Loop over 2 daughers
            do j=1,2            ! Loop over 2 ipart elements
c FIXTHIS FIXTHIS FIXTHIS: These seems a rather strange "if" statement.
               if ( .not.( ipart(j,idacl(n,i)).gt.0 .and. 
     &              ipart(j,idacl(n,i)).gt.2 ) ) cycle
               ptclus(ipart(j,idacl(n,i)))=max(
     &              ptclus(ipart(j,idacl(n,i))) , dsqrt(pt2ijcl(n)) )
               if(ickkw.ne.2.and.
     $              (.not.isqcd(ipdgcl(imocl(n),igraphs(1),nFKSprocess))
     $              .or. ipart(1,idacl(n,3-i)).le.2.and.
     $              .not.isqcd(ipdgcl(idacl(n,3-i),igraphs(1),nFKSprocess))
     $              .or. isbw(imocl(n))))then
c     For particles originating in non-qcd t-channel vertices or decay
c     vertices, set origination scale to machine energy since we don't
c     want these to be included in matching.
                  ptclus(ipart(j,idacl(n,i)))=etot
               endif
               if (btest(mlevel,3)) write(*,*) 'Set ptclus for '
     $              ,ipart(j,idacl(n,i)), ' to ', ptclus(ipart(j
     $              ,idacl(n,i))), ipdgcl(imocl(n),igraphs(1)
     $              ,nFKSprocess), isqcd(ipdgcl(imocl(n),igraphs(1)
     $              ,nFKSprocess)) ,isbw(imocl(n))
            enddo
         enddo
c     Special case for last 1,2->i vertex
         if(n.eq.nexternal-2)then
            ptclus(ipart(1,imocl(n)))=
     $           max(ptclus(ipart(1,imocl(n))),dsqrt(pt2ijcl(n)))
            if(ickkw.ne.2.and.(.not.
     &         isqcd(ipdgcl(idacl(n,1),igraphs(1),nFKSprocess)).or..not.
     $         isqcd(ipdgcl(idacl(n,2),igraphs(1),nFKSprocess))))then
c     For particles originating in non-qcd vertices or decay vertices,
c     set origination scale to machine energy since we don't want these
c     to be included in matching.
               ptclus(ipart(1,imocl(n)))=etot
            endif
            if (btest(mlevel,3))
     $           write(*,*) 'Set ptclus for ',ipart(1,imocl(n)),
     $           ' to ', ptclus(ipart(1,imocl(n))),
     $           ipdgcl(idacl(n,1),igraphs(1),nFKSprocess),
     $           ipdgcl(idacl(n,2),igraphs(1),nFKSprocess)
         endif
c   Update particle tree map
         call ipartupdate(p,imocl(n),idacl(n,1),idacl(n,2),
     $        ipdgcl(1,igraphs(1),nFKSprocess),ipart)
c     Cycle if we don't need to perform PDF or, if ickkw=2, Sudakov
c     reweighting
         if(.not.(ickkw.eq.2.or.pdfwgt)) cycle
         isvx=.false.
         do i=1,2               ! loop over daughters
c     If the daugher i is not charge under QCD: cycle
            if (.not.isqcd(ipdgcl(idacl(n,i),igraphs(1),nFKSprocess)))
     $           cycle
            if(ickkw.eq.2.and.pt2min.eq.0d0) then
               pt2min=pt2ijcl(n)
               if (btest(mlevel,3)) write(*,*) 'pt2min set to '
     $              ,pt2min
            endif
            if(ickkw.eq.2.and.pt2prev(idacl(n,i)).eq.0d0)
     $           pt2prev(idacl(n,i))= max(pt2min,
     $           p(0,i)**2-p(1,i)**2-p(2,i)**2-p(3,i)**2)
c     Initial State:
            do j=1,2            ! Loop over the two beams
               if (isparton(ipdgcl(idacl(n,i),igraphs(1),nFKSprocess))
     $              .and.idacl(n,i).eq.ibeam(j)) then
c     is sudakov weight - calculate only once for each parton line where
c     parton line ends with change of parton id or non-radiation vertex
                  isvx=.true.
                  ibeam(j)=imocl(n)
c     Perform Sudakov reweighting if ickkw=2
                  if(ickkw.eq.2.and.
     $                 (ipdgcl(idacl(n,i),igraphs(1),nFKSprocess).ne.
     $                  ipdgcl(imocl(n),igraphs(1),nFKSprocess).or.
     $                 .not.isjetvx(imocl(n),idacl(n,1),idacl(n,2),
     $                 ipdgcl(1,igraphs(1),nFKSprocess),
     &                                     ipart,n.eq.nexternal-2)).and.
     $                 pt2prev(idacl(n,i)).lt.pt2ijcl(n)  )then
c tmp is the ratio of the two sudakovs
                     tmp=min(1d0,max(
     &                    getissud(ibeam(j),
     &                        ipdgcl(idacl(n,i),igraphs(1),nFKSprocess),
     &                        xnow(j),xnow(3-j),pt2ijcl(n)) ,
     &                    1d-20 ) /
     $                    max(
     &                    getissud(ibeam(j),
     &                        ipdgcl(idacl(n,i),igraphs(1),nFKSprocess),
     &                        xnow(j),xnow(3-j),pt2prev(idacl(n,i))) ,
     &                    1d-20 ))
                     rewgt=rewgt*tmp
                     pt2prev(imocl(n))=pt2ijcl(n)
                     if (btest(mlevel,3)) then
                        write(*,*)' reweight line: ',ipdgcl(idacl(n ,i)
     $                       ,igraphs(1),nFKSprocess), idacl(n,i)
                        write(*,*)'     pt2prev, pt2new, x1, x2: '
     $                       ,pt2prev(idacl(n,i)),pt2ijcl(n),xnow(j)
     $                       ,xnow(3-j)
                        write(*,*)'           Sud: ',tmp
                        write(*,*)'        -> rewgt: ',rewgt
                     endif
                  elseif(ickkw.eq.2) then
                     pt2prev(imocl(n))=pt2prev(idacl(n,i))
                  endif
c     End Sudakov reweighting when we reach a non-radiation vertex
                  if(ickkw.eq.2.and..not.
     $                 ispartonvx(imocl(n),idacl(n,1),idacl(n,2),
     $                            ipdgcl(1,igraphs(1),nFKSprocess),
     $                            ipart,n.eq.nexternal-2) ) then
                     pt2prev(imocl(n))=1d30
                     if (btest(mlevel,3)) then
                        write(*,*)' rewgt: ending reweighting for vx' ,
     $                       idacl(n,1),idacl(n,2),imocl(n)
     $                       ,' with ids ',ipdgcl(idacl(n,1) ,igraphs(1)
     $                       ,nFKSprocess),ipdgcl(idacl(n,2) ,igraphs(1)
     $                       ,nFKSprocess),ipdgcl(imocl(n) ,igraphs(1)
     $                       ,nFKSprocess)
                     endif
                  endif
c     PDF reweighting
c     Total pdf weight is f1(x1,pt2E)*fj(x1*z,Q)/fj(x1*z,pt2E)
c     f1(x1,pt2E) is given by DSIG, already set scale for that
                  if (zcl(n).gt.0d0.and.zcl(n).lt.1d0) then
                     xnow(j)=xnow(j)*zcl(n)
                  endif
c     PDF scale

c FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS
c We cannot do PDF reweighting at NLO. Needs to be carefully checked
c that we get the correct factorization scale.
c FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS FIXTHIS

                  q2now=min(pt2ijcl(n), q2bck(j))
c     Set PDF scale to central factorization scale if non-radiating
c     vertex or last 2->2
                  if(.not.isjetvx(imocl(n),idacl(n,1),idacl(n,2),
     $                            ipdgcl(1,igraphs(1),nFKSprocess),
     $                                   ipart,n.eq.nexternal-2) ) then
                     q2now=q2bck(j)
                  endif
                  if (btest(mlevel,3))
     $                 write(*,*)' set q2now for pdf to ',sqrt(q2now)
                  if(q2fact(j).eq.0d0.and.ickkw.eq.2)then
                     q2fact(j)=pt2min ! Starting scale for PS
                     pt2pdf(imocl(n))=q2now
                     if (btest(mlevel,3))
     $                    write(*,*)' set fact scale ',j,
     $                    ' for PS scale to: ',sqrt(q2fact(j))
                  else if(pt2pdf(idacl(n,i)).eq.0d0)then
                     pt2pdf(imocl(n))=q2now
                     if (btest(mlevel,3))
     $                    write(*,*)' set pt2pdf for ',imocl(n),
     $                    ' to: ',sqrt(pt2pdf(imocl(n)))
                  else if(pt2pdf(idacl(n,i)).lt.q2now .and.
     $                    isjet(ipdgcl(idacl(n,i),igraphs(1),nFKSprocess))) then
                     pdfj1=pdg2pdf(abs(lpp(IB(j))),ipdgcl(idacl(n,i),
     $                    igraphs(1),nFKSprocess)*sign(1,lpp(IB(j))),
     $                    xnow(j),sqrt(q2now))
                     pdfj2=pdg2pdf(abs(lpp(IB(j))),ipdgcl(idacl(n,i),
     $                    igraphs(1),nFKSprocess)*sign(1,lpp(IB(j))),
     $                    xnow(j),sqrt(pt2pdf(idacl(n,i))))
                     if(pdfj2.lt.1d-10)then
c     Scale too low for heavy quark
                        rewgt=0d0
                        if (btest(mlevel,3)) write(*,*)
     $                       'Too low scale for quark pdf: ',
     $                       sqrt(pt2pdf(idacl(n,i))),pdfj2,pdfj1
                        return
                     endif
                     rewgt=rewgt*pdfj1/pdfj2
                     if (btest(mlevel,3)) then
                        write(*,*)' reweight ',n,i,ipdgcl(idacl(n,i)
     $                       ,igraphs(1),nFKSprocess),' by pdfs: '
                        write(*,*)'     x, ptprev, ptnew: ',xnow(j),
     $                       sqrt(pt2pdf(idacl(n,i))),sqrt(q2now)
                        write(*,*)'           PDF: ',pdfj1,' / '
     $                       ,pdfj2
                        write(*,*)'        -> rewgt: ',rewgt
                     endif
c     Set scale for mother as this scale
                     pt2pdf(imocl(n))=q2now                           
                  else if(pt2pdf(idacl(n,i)).ge.q2now) then
c     If no reweighting, just copy daughter scale for mother
                     pt2pdf(imocl(n))=pt2pdf(idacl(n,i))
                  endif
                  cycle         ! go to the next daugther or cluster node
               endif
            enddo
c     Final State sudakov weight
            if(ickkw.eq.2.and.pt2prev(idacl(n,i)).lt.pt2ijcl(n).and.
     $           (isvx.or.ipdgcl(idacl(n,i),igraphs(1),nFKSprocess).ne.
     $           ipdgcl(imocl(n),igraphs(1),nFKSprocess).or.
     $           (ipdgcl(idacl(n,i),igraphs(1),nFKSprocess).ne.
     $           ipdgcl(idacl(n,3-i),igraphs(1),nFKSprocess).and.
     $           pt2prev(idacl(n,i)).gt.pt2prev(idacl(n,3-i))))) then
               tmp=sudwgt(sqrt(pt2min),sqrt(pt2prev(idacl(n,i))),
     $              dsqrt(pt2ijcl(n)),ipdgcl(idacl(n,i),igraphs(1)
     $              ,nFKSprocess),1)
               rewgt=rewgt*tmp
               if (btest(mlevel,3)) then
                  write(*,*)' reweight fs line: ',ipdgcl(idacl(n,i)
     $                 ,igraphs(1),nFKSprocess), idacl(n,i)
                  write(*,*)'     pt2prev, pt2new: ',pt2prev(idacl(n
     $                 ,i)),pt2ijcl(n)
                  write(*,*)'           Sud: ',tmp
                  write(*,*)'        -> rewgt: ',rewgt
               endif
               pt2prev(imocl(n))=pt2ijcl(n)
            else
               pt2prev(imocl(n))=pt2prev(idacl(n,i))
            endif 
         enddo
         if (ickkw.eq.2.and.n.eq.nexternal-2.and.
     $        isqcd(ipdgcl(imocl(n),igraphs(1),nFKSprocess)).and.
     $        pt2prev(imocl(n)).lt.pt2ijcl(n))then
            tmp=sudwgt(sqrt(pt2min),sqrt(pt2prev(imocl(n))),
     $           dsqrt(pt2ijcl(n)),ipdgcl(imocl(n),igraphs(1)
     $           ,nFKSprocess),1)
            rewgt=rewgt*tmp
            if (btest(mlevel,3)) then
               write(*,*)' reweight last fs line: ',ipdgcl(imocl(n)
     $              ,igraphs(1),nFKSprocess), imocl(n)
               write(*,*)'     pt2prev, pt2new: ',pt2prev(imocl(n))
     $              ,pt2ijcl(n)
               write(*,*)'           Sud: ',tmp
               write(*,*)'        -> rewgt: ',rewgt
            endif
         endif
      enddo

      if(ickkw.eq.2.and.lpp(1).eq.0.and.lpp(2).eq.0)then
         q2fact(1)=pt2min
         q2fact(2)=q2fact(1)
      else if (ickkw.eq.1.and.pdfwgt) then
         q2fact(1)=q2bck(1)
         q2fact(2)=q2bck(2)         
         if (btest(mlevel,3))
     $        write(*,*)' set fact scales for PS to ',
     $        sqrt(q2fact(1)),sqrt(q2fact(2))
      endif

      if (btest(mlevel,3)) then
        write(*,*)'} ->  w = ',rewgt
      endif
      return
      end
      
