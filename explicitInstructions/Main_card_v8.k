$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
$ Testing of implicit LS-Dyna                                                 $ 
$ August Brandberg                                                            $ 
$ 17-10-2016                                                                  $ 
$                                                                             $ 
$ Geometry, material etc defined in "file.k".                                 $ 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
*KEYWORD 
$*MAT_ELASTIC
$         1 0.150E-15 0.200E+05  0.200000  
*MAT_PLASTIC_KINEMATIC
         1 1.000E-15 0.500E+03  0.200000 0.270E+01 0.450E+02  1.00    
  0.00      0.00      0.00    
*MAT_RIGID   
         2 0.150E-12 0.100E+06  0.300000       0.0       0.0       0.0   
 1.00       3.00      7.00       
   
*INCLUDE 
file.k 
*INCLUDE 
Database_output_for_explicit.k 
*DAMPING_GLOBAL
           1.5E5
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
$                              CONTACT OPTIONS                                 $ 
$                                                                              $ 
$ Adding force transducers to plates.                                          $ 
$                                                                              $ 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*CONTACT_FORCE_TRANSDUCER
$ by part id
         2         0         3         0         0         0         1         0
         0         0         0         0         0         0         0         0
         0         0         0         0         0         0         0         0
*CONTACT_FORCE_TRANSDUCER
$ by part id
         3         0         3         0         0         0         1         0
         0         0         0         0         0         0         0         0
         0         0         0         0         0         0         0         0
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
$                              CONTROL OPTIONS                                 $ 
$                                                                              $ 
$ Control options                                                              $ 
$                                                                              $ 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*CONTROL_ACCURACY 
$#     osu       inn    pidosu 
         0         4           
*CONTROL_CONTACT 
$#  slsfac    rwpnal    islchk    shlthk    penopt    thkchg     orien    enmass 
  0.100000     0.000         1         1         0         0         1         0 
$#  usrstr    usrfrc     nsbcs    interm     xpene     ssthk      ecdt   tiedprj 
         0         0         0         0    40.000         1         0         0 
$#   sfric     dfric       edc       vfc        th     th_sf    pen_sf 
     0.000     0.000     0.000     0.000     0.000     0.000     0.000 
$#  ignore    frceng   skiprwg    outseg   spotstp   spotdel   spothin 
         1         0         0         0         0         0     0.000 
$#    isym    nserod    rwgaps    rwgdth     rwksf      icov    swradf    ithoff 
         0         0         0     0.000  1.000000         0     0.000         0 
$#  shledg    pstiff    ithcnt    tdcnof     ftall    unused    shltrw 
         0         0         0         0         0               0.000 
*CONTROL_ENERGY 
$#    hgen      rwen    slnten     rylen 
         2         2         2         2 
*CONTROL_HOURGLASS 
$#     ihq        qh 
         8  0.010000 
*CONTROL_SOLID 
$#   esort   fmatrix   niptets    swlocl    psfail 
         1         0         0         0         0 
$#     pm1     pm2     pm3     pm4     pm5     pm6     pm7     pm8     pm9    pm10 
         0       0       0       0       0       0       0       0       0       0 
*CONTROL_SHELL
$    wrang     esort     irnxx    istupd    theory       bwc     miter      proj
        20         0        -1         0         2         2         1         0
*CONTROL_SOLUTION 
$#    soln       nlq     isnan     lcint 
         0         0         0      1000 
*CONTROL_CPU
         0         1
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
$                                 TIME HISTORY                                 $ 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
$                              DATABASE OPTIONS                                $ 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  
*DATABASE_BINARY_D3DUMP
$  dt/cycl   lcdt/nr      beam     npltc    psetid       cid
   1000000       
*DATABASE_EXTENT_BINARY
$#   neiph     neips    maxint    strflg    sigflg    epsflg    rltflg    engflg
         0         0         3         1         1         1         1         1
$#  cmpflg    ieverp    beamip     dcomp      shge     stssz    n3thdt   ialemat
         0         0         4         1         1         1         2         0
$# nintsld   pkp_sen      sclp     hydro     msscl     therm    intout    nodout
         0         0       1.0         0         0         0ALL       ALL
$#    dtdt    resplt     neipb     
         0         0         0
*END 
