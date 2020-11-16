*=======================================================
* Energy Policy Analysis using Jamaica as a case study
*======================================================
Option optca = 0;
option optcr = 0;
option limcol=0;
option limrow=0;
*========================
*Defining Sets & Aliases
*========================
Sets
 dow(*)    Day of week from sun to sat
 hr(*)     Hour Index
 dtype(*)  Day type index
 htype(*)  Hour type index
 quart(*)  Quarters in a year
 year(*)   Year index
 wk(*)     Week index

 byear(year)  Base year
 atqwk(quart,wk) Attaching quarters to week
 attday(dtype,dow) Attaching day types to days
 atth(htype,hr)   Attaching hours to hour types

 node(*)          Node in network
 slackbus(node)   Slack bus

 Plant(*)         Power Plant
 EPlant(Plant)     Existing Plant
 DecomPlant(EPlant) Plants to be decommissioned
*Note that ep13 was out of service in 2017
* I assume it is in service since it was built in 2001
 CPlant(Plant)     Candidate Plants
 MustBuildPlant(CPlant) Plants scheduled for construction
 JPSPlant(Eplant)    Plants owned by JPSCo
 IPPPlant(Eplant)    Plants owned by IPPs

 SnSSDJPS(JPSPlant)  Existing JPSCo steam and slow speed deisel plants
 GTJPS(JPSPlant)     Existing JPSCo gas turbine plants
 CCJPS(JPSPlant)     Existing JPSCo combined cycle plants
 HydroJPS(JPSPlant)  Existing JPSCo hydro plants
;

Alias (dow,ddow),(hr,hhr),(htype,hhtype),(dtype,ddtype),(quart,q),(year,y),(wk,wwk),(node,n);

Sets
 Tline(*)      Transmission Lines
 ETLine(TLine) Existing Transmission Lines
 CTLine(TLine) Candidate Transmission Lines

 Tec(*)       Technology set
 Thermal(Tec) Thermal Fossil Fuel Technologies set
 RETec(Tec)   Renewable Energy Technology set
 RETecnb(tec) Renewable Technology set excluding biomass
 Biomass(tec) Biomass Technology

 PlantType(plant,tec) Attaching Plants to technology
 MapPlant(node,Plant) Attaching Plants to nodes
 MapTline(Tline,node,n) Tranmission network mapping nodes to transmission lines

 TlineHeadings(*)  Column headings for Tline parameter table
 PlantHeadings(*)  Column headings for Plant parameter table
 ScalarHeadings(*) Headings for scalar values for import
 CalHeadings(*)    Headings for Calibration data
 Policy(*)         Policy Index;

Sets
*  ModelType Model Type  /calibrate,sim_KVL,seq_KVL_a,seq_KVL_b,no_KVL,RPS/
  FPScenarios Fuel Price Scenarios /Baseline, High, Low/   ;

*======================
*Parameters for import
*======================
Parameters
 Tlinedata(Tline,Tlineheadings) Relevant parameters for transmission lines
 PlantData(plant,tec,PlantHeadings) Relevant parameters for power plants
 AvailabilityFactor(plant,tec,htype) Availability factor
 FuelPriceBaseline(year,thermal) Fuel Price (baseline) for thermal plants in 2017$ per mmBtu
 FuelPriceLow(year,thermal) Fuel price for low fuel price scenario (2017$ per mmBtu)
 FuelPriceHigh(year,thermal) Fuel price for high fuel price scenario (2017$ per mmBtu)
 Demand(node,year,quart,dtype,htype)  Average Demand in MW each hour
 PeakDem(year,quart)  System Peak Demand in MW each year and quarter
 ScalarParams(ScalarHeadings) Scalars
 MapTline1(tline,node,n) Parameter representation of network
 CalData(CalHeadings)  Actual 2017 data for comparing and calibrating model
 Rainfall(quart)      Seasonal Rainfall

 CO2FactorTon(tec)   CO2 factor (metric ton of CO2 per mmBtu)
 PS(Policy)          Production subsidy ($ per MWh)
 CTAX(Policy)       Carbon Tax in Dollars per ton of CO2
 InvSubsidy(Policy) Investment subsidy (fraction between zero and 1)
 RPS(Policy)        Renewable Portfolio Standard (fraction between 0 and 1)
;

*================================================================================
*The followling creates a text file with coordinates and structure for importing
*data froom the Excel data file
*===============================================================================
$onecho > gtepinput.txt
set=dow    rng=Set_Time!D2:J2     cdim= 1
set=hr    rng=Set_Time!D3:AA3    cdim=1
set=dtype  rng=Set_Time!D4:E4     cdim=1
set=htype  rng=Set_Time!D5:H5     cdim=1
set=quart   rng=Set_Time!D6:G6    cdim=1
set=year    rng=Set_Time!D7:AA7   cdim=1
set=wk      rng=Set_Time!D8:BC8   cdim=1

set=byear   rng=Set_Time!D10      cdim=1
set=atqwk     rng=Set_Time!D13:Bc14  cdim=2
set=attday  rng=Set_Time!D16:E22    rdim=2
set=atth    rng=Set_Time!D24:AA25   cdim=2

set=node    rng=Set_Nodes!D2:S2    cdim=1
set=slackbus rng=Set_Nodes!D3      cdim=1
set=Plant   rng=Set_Plant!D2:CJ2   cdim=1
set=EPlant  rng=Set_Plant!D4:AH4   cdim=1
set=DecomPlant rng=Set_Plant!D5:M5  cdim=1
set=CPlant  rng=Set_Plant!D6:BE6   cdim=1
set=MustBuildPlant rng=Set_Plant!D7 cdim=1
set=JPSPlant rng=Set_Plant!D8:Z8   cdim=1
set=IPPPlant rng=Set_Plant!D9:K9    cdim=1
set=SnSSDJPS  rng=Set_Plant!D10:I10  cdim=1
set=GTJPS     rng=Set_Plant!D11:J11  cdim=1
set=CCJPS     rng=Set_Plant!D12      cdim=1
Set=HydroJPS   rng=Set_Plant!D13:K13  cdim=1


set=Tline   rng=Set_Tline!D2:AR2   cdim=1
set=ETLine  rng=Set_Tline!D4:V4    cdim=1
set=CTLine  rng=Set_Tline!D5:Y5    cdim=1

set=Tec     rng=Set_tec!D2:J2     cdim=1
set=Thermal rng=Set_tec!D4:F4     cdim=1
set=RETec   rng=Set_tec!D5:G5     cdim=1
set=RETecnb  rng=Set_tec!D6:F6    cdim=1
set=Biomass  rng=Set_tec!D7       cdim=1

set=PlantType  rng=Set_PlantType!A3:B87  rdim=2
set=MapPlant   rng=Set_MapPlant!A3:B87   rdim=2
set=MapTline   rng=Set_MapTline!A3:C44   rdim=3

set=TlineHeadings  rng=Par_Tlinedata!B3:J3  cdim=1
set=PlantHeadings  rng=Par_PlantData!C3:AA3  cdim=1
set=ScalarHeadings  rng=par_Scalar!B3:B12     rdim=1
set=CalHeadings     rng=par_CalData!B3:B9    rdim=1
set=Policy          rng=Set_Policy!D2:M2      cdim=1

par=TLineData rng=Par_TLineData!A3:J45   cdim=1 rdim=1
par=PlantData rng=Par_PlantData!A3:AA88  cdim=1 rdim=2
par=AvailabilityFactor rng=Par_AvailabilityFactor!A3:G54 cdim=1 rdim=2
par=Rainfall  rng=Par_AvgRain!A2:B5   rdim=1
par=FuelPriceBaseline rng=Par_FuelPriceBaseline!A4:D28   cdim=1 rdim=1
par=FuelPriceLow   rng = Par_FuelPriceLow!A4:D28   cdim = 1   rdim =1
par=FuelPriceHigh   rng = Par_FuelPriceHigh!A4:D28   cdim = 1   rdim =1
par=Demand    rng=par_demand!A2:I1922   cdim=1 rdim=4
par=Peakdem  rng=Peak_demand_MW!A2:E26  cdim=1 rdim=1
par=ScalarParams  rng=par_Scalar!B3:C12    rdim=1
par=CalData   rng=par_CalData!B3:C9      rdim=1

par=CO2Factorton  rng = par_CO2FactorTon!A3:B5  rdim =1
par=PS       rng=par_PS!A3:B12         rdim=1
par=CTAX      rng = par_CTAX!A3:B12     rdim=1
par=InvSubsidy  rng = par_InvSubsidy!A3:B12  rdim=1
par=RPS       rng = par_RPS!A3:B5      rdim=1
$offecho


$CALL GDXXRW Input_JA_REPolicy_Anonymized.xlsx @gtepinput.txt
$GDXIN Input_JA_REPolicy_Anonymized.gdx

$LOADDC dow,hr,dtype,htype,quart,year,wk,byear,atqwk,attday,atth
$LOADDC node,slackbus,Plant,EPlant,DecomPlant, CPlant, MustBuildPlant, JPSPlant,IPPplant,SnSSDJPS,GTJPS,CCJPS,HydroJPS
$LOADDC Tline,ETline,CTLine
$LOAD tec,thermal,retec,retecnb,biomass
$LOAD PlantType,MapPlant,MapTline
$LOAD TlineHeadings, PlantHeadings, ScalarHeadings,Calheadings,Policy
$LOAD Tlinedata,PlantData,AvailabilityFactor,Rainfall,FuelPriceBaseline,FuelPriceLow,FuelPriceHigh,Demand,Peakdem,ScalarParams,CalData,Co2FactorTon,PS,CTAX,InvSubsidy,RPS
$GDXIN

*=================================================================
*Creating Parameters from imported parameter tables
*=================================================================
Parameters
 TLineDistance(Tline)  Length of transmission lines in km
 Susceptance(TLine)    Susceptance of transmission line in p.u. on 100 MVA
 Reactance(Tline)      Reactance of transmission line in p.u. on 100 MVA
 PFmax(TLine)          Capacity of transmission line (MVA=MW)
 OCCtl(TLine)          Overnight Capital Cost of Transmission Line ($ millions)
 OCCannualTline(Tline) Annualized Capital OCst of Tlines
 crftl(Tline)          Capital recovery Factor for transmission lines


 GrossCap(Plant,tec)   Gross Capacity of plant
 ACapF(Eplant,retecnb) Actual or reported Capacity factors
 MinOpCap(plant,tec)   Minimum Operating capacity
 FOrate(Plant,tec)     Forced outage rate
 UFOrate(Plant,tec)    Unforced outage rate
 Hrate(plant,tec)      Heat rate in mmBtu
 FOM(year,plant,tec)   Fixed O&M Cost in $ per year
 VOM(plant,tec)        Variable O&M COst in $ per MWh
 OCCg(plant,tec)       Overnight Capital Cost (OCC) of Plant ($ millions)
 OCCannualP(plant,tec) Annualized OCC of plants ($ millions)
 crfg(plant,tec)       Capital Recovery Factor
 COD(plant,tec)        Commercial operating date of plant
 DecomDate(plant,tec)  Decommission date of plant
 NEO(plant,tec)        Net energy output of plant (in GWh)

 InvBudget(year)           Annual investment budget ($ millions)
 AnPeakDem(year)           Annual Peak Demand (MW)
;


TLineDistance(Tline) = Tlinedata(tline,"distance");
Susceptance(TLine)= Tlinedata(tline,"b");
Reactance(Tline) = Tlinedata(tline,"x");
PFmax(TLine) = TlineData(tline,"PFmax");
OCCtl(TLine) = TlineData(tline,"occtl");
OCCannualTLine(TLine)= TlineData(tline,"Tlineinvcost_yr");
crftl(tline) = TLineData(TLine,"crftl");

GrossCap(Plant,tec)= PlantData(plant,tec,"GrossCap");
ACapF(Eplant,retecnb) = PlantData(eplant,retecnb,"CapF");
MinOpCap(plant,tec) = PlantData(plant,tec,"MinOpCap");
FOrate(Plant,tec) = PlantData(plant,tec,"FOrate");
UFOrate(Plant,tec)= PlantData(plant,tec,"UFOrate");
Hrate(plant,tec) = PlantData(plant,tec,"hrate");
FOM(year,plant,tec) = PlantData(plant,tec,"FOM");
VOM(plant,tec) = PlantData(plant,tec,"VOM");
OCCg(plant,tec) = PlantData(plant,tec,"occg");
OCCannualP(plant,tec) = PlantData(plant,tec,"occ_annual");
crfg(plant,tec) = PlantData(plant,tec,"crfg");
COD(plant,tec) = PlantData(plant,tec,"COD");
DecomDate(plant,tec) = PlantData(plant,tec,"DecomDate");
NEO(plant,tec) = PlantData(plant,tec,"NEO");
AnPeakDem(year) = Smax(quart,Peakdem(year,quart));


Parameters UFOrateD(Plant,thermal,htype) Disaggregated Unforced Outage Rate;
*Here I assume that no unforced outtage will happen during peak hours
UFOrateD(Plant,thermal,htype)$PlantType(Plant,thermal) = UFOrate(plant,thermal);
UFOrateD(Plant,thermal,'peakh')$PlantType(Plant,thermal) = 0;
display uforated;


Scalars
 disc     Discount rate
 DumpCost Cost ($ per MWh) to dump energy
 UECost   Cost of unserved energy ($ per MWh)
 M        Big M used in model
 UMRCost  Cost of userved reserve capacity ($ per MW)
 ResMarg  Reserve Margin
 pi       assigning pi to 10 dp
 million 1 million
 pubase   Base for per unit conversions
 AvgRainfall Average quarterly rainfall
 RETarget  Renewable energy target (Fraction between zero and 1)
 psrate   Production tax credit ($ per MWh) for use in loop
 CTAXrate  Carbon tax rate ($ per ton) for use in loop
 InvSubRate Investmen subsidy rate (decimal) for use in loop;

disc =ScalarParams("disc");
DumpCost = ScalarParams("DumpCost");
UECost = ScalarParams("UECost");
M = ScalarParams("M");
UMRCost = ScalarParams("UMRCost");
ResMarg = ScalarParams("ResMarg");
pi = ScalarParams("pi");
million = 1E6;
pubase = ScalarParams("pubase");
AvgRainfall = sum(quart,Rainfall(quart))/card(quart);
*Display grosscap,forate,uforate,disc,million,resmarg,AnPeakDem,pubase;
*display AvgRainfall;

*======================================================================
*Creating Other Paramters Based on input tables
*======================================================================
Parameters
 AvailableEPlant(year,EPlant,tec) 1 if Existing plant is available in year 0 otherwise
 discf(year) Discount Factor
 Mday(dtype) Number of days per day type in a year
 Mquart(quart) Proportion of year in a quarter
 mth(htype)   Number of hours by hour type
 Bij(tline) Inverse of reactance used in power flow constraints
 FuelPrice(year,thermal) Fuel Price in (2017$ per mmBtu) for use in each scenario
 RainfallDev(quart)    Deviation from average rainfall
 AdjAvailFact1(plant,tec,quart,htype) Adjusted Availability factors (first step of calculation)
 AdjAvailFact2(plant,tec,quart,htype) Adjusted Availability factors (2nd step of calculation)
;

AvailableEPlant(year,EPlant,tec) = 1$PlantType(Eplant,tec);
display availableEplant;
AvailableEPlant(year,decomplant,tec)$((ord(year)+2017) gt DecomDate(DecomPlant,tec) and PlantType(decomplant,tec))=0;

discf(year) = 1/((1+disc)**(ord(year)-1));

Mquart(quart)=sum(wk$atqwk(quart,wk),1)/card(wk);
Mth(htype) = sum(hr$atth(htype,hr),1);
Mday(dtype)= 365*sum(dow$attday(dtype,dow),1)/card(dow);

Bij(tline) = 1/Reactance(tline);

*----------------------------------------------------
*Adjusting Hydro availability factors for seasonality
*----------------------------------------------------
RainfallDev(quart) = (rainfall(quart)-Avgrainfall)/AvgRainfall;
Display RainfallDev, AvailabilityFactor;

AdjAvailFact1(plant,tec,quart,htype)$PlantType(Plant,tec) = AvailabilityFactor(plant,tec,htype);

AdjAvailFact1(plant,'hydro',quart,htype)$PlantType(Plant,'hydro') = (1+RainfallDev(quart))*AvailabilityFactor(plant,'hydro',htype);
AdjAvailFact2(plant,tec,quart,htype)$PlantType(Plant,Tec) = AdjAvailFact1(plant,tec,quart,htype) ;

AdjAvailFact2(plant,'hydro',quart,htype)$(ord(quart) LE 3 and PlantType(Plant,'hydro')) = AdjAvailFact1(plant,'hydro',quart,htype)+((AdjAvailFact1(plant,'hydro','Q4',htype)-1)/3)$(AdjAvailFact1(plant,'hydro','q4',htype) GT 1);
AdjAvailFact2(plant,'hydro','q4',htype)$(PlantType(Plant,'hydro') and AdjAvailFact2(plant,'hydro','q4',htype) GT 1) = 1;
Display AdjAvailFact1,AdjAvailFact2;

$ontext
*=================================
*Setting Investment Budget
*=================================
 InvBudget(year) = 100;
$offtext





*=================================
*Storage Parameters
*=================================
*Here I create parameters for storing bases for comparing models
Parameters
 STotCost(policy) Storage parameter for NPV over planning horizon (USD mil)
 TotCostY(year,policy) Annual Total Cost in USD Million (operations and investments)
 OpCost(year,policy) Operating Cost USD Millions (Fixed & Variable)
 SInvCostPlant(year,policy) Investment Cost of power plants (millions)
 SInvCostTline(year,policy) Investment cost of transmission infrastructure (millions)
 SBuildPlant(year,CPlant,tec,policy) Storage parameter for built plant variable
 SBuildTline(year,ctline,policy) Storage parameter for built transmission line variable
 Annual_Generation (year,policy) Annual Generation (GWh)
 LCOE(year,policy) Levelized Cost of energy (US cents per kWh)
 GenPortfolio(year,tec,policy) Annual generation (GWh) by technology
 GenPortfolioShare(year,tec,policy) Share of output by techology (in %)
 Capfactor(plant,tec,year,policy) Capacity Factor
 Emissions(year,policy) Metric Ton of CO2 emitted per year
 TotalEmission(policy) Metric Ton of CO2 produced over planning horizon
 CTAXCost(year,policy) Annual Cost of CTAX to government in thousdands of dollars
 TotalCTAXCost(policy) Total CTAX Cost to governmeng in Thousands of dollars over planning horizon
 PSCost(year,policy) Annual Cost of Production Subsidy to government in thousdands of dollars
 TotalPSCost(policy) Total Production Subsidy Cost to governmeng in Thousands of dollars over planning horizon
 NetSystemCost(year,policy) System cost net of costs associated with government policy (in USD million)
 TotalNetSystemCost(policy) Total Net System Cost (in USD millions)
;



*=========================================
*Global Variables & Definition
*=========================================
Variable TotCost Net Present Value (USD Millions) of Operation and Investment Costs (Objective);
Variables
 theta(Tline,node,year,quart,dtype,htype) Bus voltage angles (rad)
 PowerFlow(tline,node,n,year,quart,dtype,htype) Power flow across transmission line in MW;


Positive Variables
 U(year,CTline) Slack variable in application of big M method
 UE(year,quart,dtype,htype,node) Average Unserved energy in MW
 DumpEn(year,quart,dtype,htype,node) Average Dumped Enegy MW
 PGG(year,quart,dtype,htype,plant,tec) Power generation in MW
 UMR(year)  Unmet Reserves (MW) each year
 FixedCost(year) Annual Total Fixed O&M Costs (USD)
 InvCostPlant(year) NPV Total Investment Cost (USD Million)  for generation each year
 InvCostTline(year) NPV Total Investment Cost (USD Million)  for transmission each year

;

Binary Variables
 BuildPlant(year,CPlant,tec) 1 if candidate plant is build at node
 BuildTline(year,CTline)       1 if candidate transmission line is built;

*=======================================================
* Model equations and Definition
*=======================================================
*Objective Function
*-------------------

Equation objdef Objective function definition;
objdef..TotCost =E=
 (SUM(year,(
      (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal)$PlantType(plant,thermal),PGG(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for Renewable plants excluding biomass plants
          +SUM(plant$PlantType(plant,'hydro'),PGG(year,quart,dtype,htype,plant,'hydro')*VOM(plant,'hydro'))

*Incentivizing Wind and Solar
          +SUM(plant$PlantType(plant,'wind'),PGG(year,quart,dtype,htype,plant,'wind')*(VOM(plant,'wind')-psrate$((ord(year)+2016) ge 2019)))

          +SUM(plant$PlantType(plant,'solar'),PGG(year,quart,dtype,htype,plant,'solar')*(VOM(plant,'solar')-psrate$((ord(year)+2016) ge 2019)))
*Unserved energy and dump costs
          + SUM(node,UECost*UE(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost(year)
*     + UMR(year)*UMRCost
 ))*discf(year)
*Converting to millions of dollars
 ))/million
*Adding Investment Costs
 + SUM(year,InvCostPlant(year)) + SUM(year,InvCostTline(year));


*-----------------------------------
*Fixed & Investment Cost Equations
*-----------------------------------
Equations
 FCostdef     Fixed O&M Cost equation definition
 InvCostPdef  Investment cost equation definition for plants
 InvCostTLdef Investment Cost equation definition for transmission lines;

FCostdef(year)..FixedCost(year) =E= SUM((EPlant,tec),FOM(year,EPlant,tec)*AvailableEPlant(year,EPlant,tec))
                                 +SUM((Cplant,tec),FOM(year,CPlant,tec)*SUM(y$(ord(y) le ord(year)),BuildPlant(y,cplant,tec)));
*$ontext
InvCostPdef(year)..InvCostPlant(year) =E= SUM((Cplant,tec),OCCg(Cplant,tec)*SUM(y$(ord(y) le ord(year)),BuildPlant(y,cplant,tec))
                                          *crfg(Cplant,tec))*discf(year);

InvCostTLdef(year)..InvCostTline(year)=E= SUM(ctline,OCCtl(ctline)*SUM(y$(ord(y) le ord(year)),BuildTline(y,ctline))*crftl(ctline))
                                         *discf(year);


$ontext
*-----------------------------------
*Investment budget Constraint
*-----------------------------------
Equation budget Annual Investment Budget Constraint;
budget(year)..InvCostPlant(year)+ InvCostTline(year) =L= InvBudget(year);
$offtext

*--------------------------------------
*Constraints on building infrastructure
*--------------------------------------
*$ontext
Equations
 POnce  Candidate plant can only be built once
 TLOnce Candidate transmission line can only be built once
;


POnce(Cplant,tec)$PlantType(CPlant,tec)..SUM(year,BuildPlant(year,CPlant,tec)) =L=1;
TLOnce(ctline)..SUM(year,BuildTline(year,ctline)) =L=1;
*Plant that must be built
BuildPlant.fx(year,MustBuildPlant,tec)$(ord(year)+2016 eq COD(MustBuildPlant,tec)) =1;
*display BuildPlant.l;

*=============================================================
*Generation Capacity Constraints
*=============================================================
Equations
* EThermalGen Constraint on existing thermal generation
 CThermalGen Constraint on candidate thermal generation
* EREGen      Constrain on existing renewable generation
 CREGen      Constraint on candidate renewable generation
;

*---------------
*Thermal Plants
*---------------
$ontext
EThermalGen(year,quart,dtype,htype,Eplant,thermal)$PlantType(EPlant,thermal)..
         PGG(year,quart,dtype,htype,Eplant,thermal) =L=
            AvailableEPlant(year,EPlant,thermal)*GrossCap(EPlant,thermal)
           *(1-FOrate(EPlant,thermal))*(1-UFOrated(EPlant,thermal,htype));
$offtext
*Setting Upper bound on existing thermal generation
PGG.up(year,quart,dtype,htype,Eplant,thermal)$PlantType(EPlant,thermal)=
            AvailableEPlant(year,EPlant,thermal)*GrossCap(EPlant,thermal)
           *(1-FOrate(EPlant,thermal))*(1-UFOrated(EPlant,thermal,htype));


CThermalGen(year,quart,dtype,htype,Cplant,thermal)$PlantType(CPlant,thermal)..
         PGG(year,quart,dtype,htype,Cplant,thermal)=L=
         SUM(y$(ord(y) le ord(year)),BuildPlant(y,cplant,thermal))
         *GrossCap(CPlant,thermal)*(1-FOrate(CPlant,thermal))
            *(1-UFOrated(CPlant,thermal,htype));



*------------------------------
*Renewable Energy Constraints
*------------------------------
$Ontext
EREGen(year,quart,dtype,htype,Eplant,retecnb)$PlantType(EPlant,retecnb)..
         PGG(year,quart,dtype,htype,Eplant,retecnb) =L=
          AvailableEPlant(year,EPlant,retecnb)*GrossCap(EPlant,retecnb)
          *AvailabilityFactor(EPlant,retecnb,htype);

CREGen(year,quart,dtype,htype,Cplant,retecnb)$PlantType(CPlant,retecnb)..
          PGG(year,quart,dtype,htype,Cplant,retecnb) =L=
         SUM(y$(ord(y) le ord(year)),BuildPlant(y,Cplant,retecnb))*GrossCap(CPlant,retecnb)
          *AvailabilityFactor(CPlant,retecnb,htype);
$Offtext
$ontext
EREGen(year,quart,dtype,htype,Eplant,retecnb)$PlantType(EPlant,retecnb)..
         PGG(year,quart,dtype,htype,Eplant,retecnb) =L=
          AvailableEPlant(year,EPlant,retecnb)*GrossCap(EPlant,retecnb)
          *AdjAvailFact2(EPlant,retecnb,quart,htype);
$offtext

PGG.up(year,quart,dtype,htype,Eplant,retecnb)$PlantType(EPlant,retecnb)=
          AvailableEPlant(year,EPlant,retecnb)*GrossCap(EPlant,retecnb)
          *AdjAvailFact2(EPlant,retecnb,quart,htype);

CREGen(year,quart,dtype,htype,Cplant,retecnb)$PlantType(CPlant,retecnb)..
          PGG(year,quart,dtype,htype,Cplant,retecnb) =L=
         SUM(y$(ord(y) le ord(year)),BuildPlant(y,Cplant,retecnb))*GrossCap(CPlant,retecnb)
          *AdjAvailFact2(CPlant,retecnb,quart,htype);



*$Ontext
*------------------------------
*Reserve Margin Constraint
*------------------------------
*Setting Availability Factor for thermal plants to 1
AvailabilityFactor(plant,thermal,htype)$PlantType(Plant,thermal) = 1;
AdjAvailFact2(plant,thermal,quart,htype)$PlantType(Plant,thermal) = 1;
display AvailabilityFactor,AdjAvailFact2;


Equation ResMargDef Reserve Margin Constraint;
$Ontext
ResMargDef(year)..SUM((EPlant,tec)$PlantType(EPlant,tec),GrossCap(EPlant,tec)*AvailableEPlant(year,EPlant,tec)* AvailabilityFactor(Eplant,tec,'peakh'))
                         +SUM((Cplant,tec)$PlantType(CPlant,tec),
                           SUM(y$(ord(y) le ord(year)),BuildPlant(y,Cplant,tec))*GrossCap(Cplant,tec)*AvailabilityFactor(Cplant,tec,'peakh'))
                           + UMR(year) =g= AnPeakdem(year)*(1+ResMarg);
$offtext

ResMargDef(year,quart)..SUM((EPlant,tec)$PlantType(EPlant,tec),GrossCap(EPlant,tec)*AvailableEPlant(year,EPlant,tec)* AdjAvailFact2(Eplant,tec,quart,'peakh'))
                         +SUM((Cplant,tec)$PlantType(CPlant,tec),
                           SUM(y$(ord(y) le ord(year)),BuildPlant(y,Cplant,tec))*GrossCap(Cplant,tec)*AdjAvailFact2(Cplant,tec,quart,'peakh'))
                           + UMR(year) =g= AnPeakdem(year)*(1+ResMarg);


*=====================================================
*Transmission Constraints
*=====================================================
*For Existing & Candidate Transmission Lines
*--------------------------------------------
Equation
* PFLimitETLine1 Capacity constraint on power flow across existing lines
* PFLimitETLine2 Capacity constraint on power flow across existing lines
 PFLimitCTLine1 Capacity constraint on power flow across candidate lines
 PFLimitCTLine2 Capacity constraint on power flow across candidate lines

;
$ontext
PFLimitETLine1(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)..
         PowerFlow(ETline,node,n,year,quart,dtype,htype) =L=
                 PFmax(ETline)/pubase;

PFLimitETLine2(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)..
         PowerFlow(ETline,node,n,year,quart,dtype,htype) =g=
                 -PFmax(ETline)/pubase;
$offtext

PowerFlow.up(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)=
                 PFmax(ETline)/pubase;

PowerFlow.lo(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)=
                 -PFmax(ETline)/pubase;

PFLimitCTLine1(CTline,node,n,year,quart,dtype,htype)$MapTline(CTline,node,n)..
         PowerFlow(CTline,node,n,year,quart,dtype,htype) =L=
                 SUM(y$(ord(y) le ord(year)),BuildTline(y,ctline))*PFmax(CTline)/pubase;


PFLimitCTLine2(CTline,node,n,year,quart,dtype,htype)$MapTline(CTline,node,n)..
         PowerFlow(CTline,node,n,year,quart,dtype,htype) =g=
                 -SUM(y$(ord(y) le ord(year)),BuildTline(y,ctline))*PFmax(CTline)/pubase;



*---------------------------------------
*Implementing Kirchhoff's Voltage Laws
*---------------------------------------
Equations
 KVL1 Constraining power flow on existing line by susceptance and volatage angles
 KVL2 Constraining power flow on Candidate line by susceptance and volatage angles
 KVL3 Constraining power flow on Candidate line by susceptance and volatage angles
 VAdef1 Constraint on bus voltage angle
 VAdef2 Constraint on bus voltage angle;


*Using Inverse reactance
KVL1(ETline,node,n,year,quart,dtype,htype)$MapTline(ETline,node,n)..
   PowerFlow(ETline,node,n,year,quart,dtype,htype)=E=
      Bij(ETline)*(
         theta(ETline,node,year,quart,dtype,htype)-theta(ETline,n,year,quart,dtype,htype));


KVL2(CTline,node,n,year,quart,dtype,htype)$MapTline(CTline,node,n)..
   PowerFlow(CTline,node,n,year,quart,dtype,htype) =E= Bij(CTline)*(
         theta(CTline,node,year,quart,dtype,htype)-theta(CTline,n,year,quart,dtype,htype))
         + (SUM(y$(ord(y) le ord(year)),BuildTline(y,ctline))-1)*M + U(year,CTLine);


KVL3(year,ctline).. U(year,CTLine) =L=2*(1-SUM(y$(ord(y) le ord(year)),BuildTline(y,ctline)))*M;
VAdef1(TLine,node,year,quart,dtype,htype)..theta(TLine,node,year,quart,dtype,htype)=L=pi ;
VAdef2(TLine,node,year,quart,dtype,htype)..theta(TLine,node,year,quart,dtype,htype)=g=-pi ;


*===============================================
* Power Balance Equations
*===============================================
Equation PowerBalance Demand must match supply;

PowerBalance(year,quart,dtype,htype,node)..
         SUM((plant,tec)$(MapPlant(node,plant) and PlantType(Plant,tec)),PGG(year,quart,dtype,htype,plant,tec)/pubase)
         + SUM((n,tline),
                 PowerFlow(tline,n,node,year,quart,dtype,htype)$MapTline(tline,n,node)
                 -PowerFlow(tline,node,n,year,quart,dtype,htype)$MapTline(tline,node,n))
          +UE(year,quart,dtype,htype,node)/pubase=E= Demand(node,year,quart,dtype,htype)/pubase;



*==========================================
* Idiosyncratic & Other Constraints
*==========================================
theta.fx(Tline,slackbus,year,quart,dtype,htype) = 0;

* I temporarily exclude biomass
PGG.fx(year,quart,dtype,htype,plant,biomass) =0;

*Since ep13 was down in 2017 (OUR data) but will be brought back online afterwards (OUR annual report 2017-2018)
PGG.fx(byear,quart,dtype,htype,"ep13","NG")=0;

*I assume that no plants will be built before 2019
BuildPlant.fx(year,Cplant,tec)$(ord(year) lt 3)=0;


*I assume that no new transmission lines will be built before 2019
Buildtline.fx(year,ctline)$(ord(year) lt 3)=0;

*Fixing unmet energy to zero until pending imprived measure of unmet energy costs.
*Cost of generator for unmet energy cost may not be sufficient
UE.fx(year,quart,dtype,htype,node)=0;


*Setting Unmet reserve to zero
UMR.fx(year) = 0;

*Ensuring no dumped energy
DumpEn.fx(year,quart,dtype,htype,node) =0;



*=================================================================================

*==============================================
* BASELINE FUEL PRICE SCENARIO
*==============================================
************************************************************************
*In this section, I solve models under the baseline fuel price scenario
************************************************************************

FuelPrice(year,thermal) = FuelPriceBaseline(year,thermal);

*$ONTEXT
*===============================================
* SIMULTANEOUS MODEL WITH LOOP FLOW
*===============================================
*****************************************************************
*In this section, I run the simultaneous model with loop flow
*and save the output to excel files.
*****************************************************************


$ONTEXT
Model GTEPJA_PS /all/;
Option MIP = Cplex;
$onecho > cplex.opt
epint 0
nodefileind 3
$offecho
$ONTEXT
GTEPJA_PS.optfile=1 ;
GTEPJA_PS.resLim=604000;
$OFFTEXT

Model GTEPJA_PS_Transp /
objdef,
FCostdef,InvCostPdef,InvCostTLdef,
*budget,
POnce,TLOnce,
*EThermalGen,
CThermalGen,
*EREGen,
CREGen,ResMargDef,
*PFLimitETLine1, PFLimitETLine2,
PFLimitCTLine1, PFLimitCTLine2,
PowerBalance
/;
$onecho > cplex.opt
epint 0
nodefileind 3
$offecho
*$ONTEXT
GTEPJA_PS_Transp.optfile=1 ;
GTEPJA_PS_Transp.resLim=604800;


*Here, model can run over a loop
loop(policy$(ord(policy) eq 4),

*Here, I manually set Production subsidy rate
psrate = 29;
Solve GTEPJA_PS_Transp using MIP minimizing totcost;


*--------------------------------------------------------
*Storing Model outputs in storage parameters
*---------------------------------------------------------
STotCost(policy) = TotCost.l;
SBuildPlant(year,cplant,tec,policy)=BuildPlant.l(year,CPlant,tec);
SBuildTline(year,ctline,policy)=BuildTline.l(year,CTline);
TotCostY(year,policy)= (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal)$PlantType(plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for hydro plants
          +SUM(plant$PlantType(plant,'hydro'),PGG.l(year,quart,dtype,htype,plant,'hydro')*VOM(plant,'hydro'))

*Incentivizing Wind and Solar
          +SUM(plant$PlantType(plant,'solar'),PGG.l(year,quart,dtype,htype,plant,'solar')*(VOM(plant,'solar')-psrate$((ord(year)+2016) ge 2019)))
          +SUM(plant$PlantType(plant,'wind'),PGG.l(year,quart,dtype,htype,plant,'wind')*(VOM(plant,'wind')-psrate$((ord(year)+2016) ge 2019)))
*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR.l(year)*UMRCost

*Converting to millions of dollars
 )*discf(year)/million
*Adding Investment Costs
 + InvCostPlant.l(year) + InvCostTline.l(year);

OpCost(year,policy) = (SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
*Fuel & Variable Costs for thermal plants
         SUM((plant,thermal)$PlantType(plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*FuelPrice(year,thermal)+VOM(plant,thermal)))
*Variable Cost for Biomass plants should come here if data available

*Variable Cost for hydro plants
          +SUM(plant$PlantType(plant,'hydro'),PGG.l(year,quart,dtype,htype,plant,'hydro')*VOM(plant,'hydro'))

*Incentivizing Wind and Solar
          +SUM(plant$PlantType(plant,'solar'),PGG.l(year,quart,dtype,htype,plant,'solar')*(VOM(plant,'solar')-psrate$((ord(year)+2016) ge 2019)))
          +SUM(plant$PlantType(plant,'wind'),PGG.l(year,quart,dtype,htype,plant,'wind')*(VOM(plant,'wind')-psrate$((ord(year)+2016) ge 2019)))

*Unserved energy and dump costs
          + SUM(node,UECost*UE.l(year,quart,dtype,htype,node))
*           + DumpCost*DumpEn(year,quart,dtype,htype,node)
                          ))
      +FixedCost.l(year)
*     + UMR.l(year)*UMRCost

*Converting to millions of dollars
 )*discf(year)/million;

 SInvCostPlant(year,policy) = InvCostPlant.l(year);

 SInvCostTLine(year,policy) = InvCostTline.l(year);

 Annual_Generation(year,policy) = SUM((quart,dtype,htype,plant,tec),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 LCOE(year,policy)= (100*million*TotCostY(year,policy))/(million*Annual_Generation (year,policy));

 GenPortfolio(year,tec,policy) = SUM((quart,dtype,htype,plant),Mquart(quart)*Mday(dtype)*mth(htype)*
         PGG.l(year,quart,dtype,htype,plant,tec))/1000;

 GenPortfolioShare(year,tec,policy)=100* GenPortfolio(year,tec,policy)/Annual_Generation(year,policy);

*Display STotCost,TotCostY,OpCost, Annual_Generation,LCOE,GenPortfolio, GenPortfolioShare;


Capfactor(plant,tec,year,policy)$PlantType(Plant,tec)= SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                            PGG.l(year,quart,dtype,htype,plant,tec))/
                           SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*
                             GrossCap(Plant,tec));
*display CapFactor;



Emissions(year,policy) = SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
                             SUM((plant,thermal)$PlantType(plant,thermal),PGG.l(year,quart,dtype,htype,plant,thermal)*
                 (hrate(plant,thermal)/1000*CO2factorTon(thermal)))));

TotalEmission(policy) = sum(year,Emissions(year,policy));

PSCost(year,policy)$((ord(year)+2016) ge 2019) = discf(year)*(SUM((quart,dtype,htype),Mquart(quart)*Mday(dtype)*mth(htype)*(
                             SUM(plant$PlantType(plant,'solar'),PGG.l(year,quart,dtype,htype,plant,'solar')*psrate)
          +SUM(plant$PlantType(plant,'wind'),PGG.l(year,quart,dtype,htype,plant,'wind')*psrate))))/1000;

TotalPSCost(policy) = sum(year, PSCost(year,policy));

NetSystemCost(year,policy) = TotCostY(year,policy) +  PSCost(year,policy)/1000;
TotalNetSystemCost(policy) = Sum(year,NetSystemCost(year,policy));
);


********************************************************************************************************************

*-------------------------------------------
*Output for Production Subsidy Analysis
*-------------------------------------------
*$Ontext
Execute_unload "Output_ProductionSubsidy.gdx" stotcost,totcosty, LCOE,  opcost, Sinvcostplant, Sinvcosttline, Sbuildplant, SbuildTline,Annual_Generation,GenPortfolio,GenPortfolioShare,capfactor,Emissions,TotalEmission,PSCost,TotalPSCost, NetSystemCost,TotalNetSystemCost
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=stotcost rng=STotalCost!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=TotCosty rng=yrlyTotCost!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=LCOE rng=LCOE_centskWh!"
*Execute "gdxxrw.exe Output_ProductionSubsidy.gdx Par=UEGWh rng=Unserved_EnergyGWh!"
*Execute "gdxxrw.exe Output_ProductionSubsidy.gdx Par=UEshare rng=Percent_Unmet_Demand!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=opcost rng=OpCost_USDM!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=Sinvcostplant rng=InvCostPlant!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=Sinvcosttline rng=InvCostTline!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=SBuildPlant rng=BuildPlant!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=SBuildTline rng=BuildTline!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=Annual_Generation rng=Generation_GWh!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=GenPortfolio rng=GenPortfolio_GWh!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=GenPortfolioShare rng=GenPortfolioShare!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=CapFactor rng=SCapFator!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=Emissions rng=yrlyEmissions!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=TotalEmission rng=TotalEmission!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=PSCost rng=yrlyPSCost!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=TotalPSCost rng=TotalPSCost!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=NetSystemCost rng=NetSystemCost!"
Execute "gdxxrw.exe Output_ProductionSubsidy.gdx par=TotalNetSystemCost rng=TotalNetSystemCost!"
*$OFFTEXT

Display TotalEmission;
