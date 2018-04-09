File 
{
  Grid ="@tdr@"
  Parameter = "@parameter@"
  Plot = "n@node@_des.tdr"
  Current = "n@node@_des.plt"
  Output = "n@node@_des.log"  
}

Electrode
{
  { Name="S" Voltage=0.0 }
  { Name="G" Voltage=@V_start@ }
  { Name="D" Voltage=0.05 }
  { Name="B" Voltage=0.0 }
}

Physics
{
  Mobility (DopingDependence HighFieldSat Enormal)
  Recombination
  (
    SRH (DopingDependence) 
    SRH (TemperatureDependence)
    Band2BandTunneling
  )
}

Plot
{
  eDensity hDensity eCurrent hCurrent
  Potential SpaceCharge ElectricField
  eMobility hMobility eVelocity hVelocity
  Doping DonorConcentration AcceptorConcentration 
  ConductionBandEnergy ValenceBandEnergy 
  EffectiveIntrinsicDensity IntrinsicDensity
  eDensity hDensity
  eQuasiFermiEnergy hQuasiFermiEnergy
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eMobility hMobility eVelocity hVelocity
  Current/Vector eCurrent/Vector hCurrent/Vector
  eDriftVelocity/Vector hDriftVelocity/Vector
}

Math
{
  Extrapolate
  Derivatives
  RelErrControl
  Digits=7
  Error(electron)=1e8
  Error(hole)=1e8
  eDrForceRefDens=1e10
  hDrForceRefDens=1e10
  Iterations=20
  Method=ParDiSo
  Wallclock
  CNormPrint
  NoSRHperPotential
}

Solve
{
  Poisson
  Coupled { Poisson Electron }
  Quasistationary
  ( MaxStep=0.05 Goal{ Name="G" Voltage=@V_end@ } )
  { Coupled { Poisson Electron }   }
}
