#### 0.1 Configuration, assumptions and data import ####

#### Defining parameters in model####

# Parameters
pnl.rc = 0.26655  # Price of network losses in RC
y.avg = 2011:2015 # Relevant years for calculation of average values
y.cb = 2015 # The cost base year, t-2
y.rc = y.cb + 2 # The revenue cap year, t
y.hist.pen = 2007:2013 #Transition period for smoothing of pension costs, see variable list for further explenation

#NVE interest rates - used in revenue cap calculation
# https://www.nve.no/energy-market-and-regulation/revenue-regulation/the-wacc-model/
# https://www.nve.no/elmarkedstilsynet-marked-og-monopol/okonomisk-regulering-av-nettselskap/reguleringsmodellen/referanserenten/
NVE.ir = c(0.0619, 0.0562, 0.0531, 0.0420, 0.0690, 0.0661, 0.0632, 0.0632, 0.0612, 0.0588) 
names(NVE.ir) = 2009:2018

# Decision/Notice - different prices and interests are used
decision = 1 # 1 if decision mode, 0 notice mode


# Notice
NVE.ir.t_2 = NVE.ir[as.character(y.cb)]
NVE.ir.est = NVE.ir[as.character(y.rc)]
sysp.t_2 = 0.20813 # Price used in DEA

# Decision
NVE.ir.t = NVE.ir[as.character(y.rc)]

# Economic assumptions (? - Improve)
wcp = 1.01 # working capital premium
rho = 0.6 # Norm cost share in revenue cap 
gci.p = 1 # Price of grid components in interface, regional and local distribution grids





# Estimated cost for cost base year (y.cb)
lrt_RC_dec.y.cb = 10526034
         
#### Importing data ####

# Read data set from csv-file
# Base-data with costs and assets
dat = read.csv("./Data/BaseData/BaseData_Decision_2017.csv", sep=",")
dat$ap.t_2 = as.numeric(dat$ap.t_2)/1000

# Choosing correct interest rates and prices dependent on notice or decision mode

if (decision == 1)  {
  ir.dea                  = NVE.ir.t_2
  NVE.ir.RC               = NVE.ir.t
  pnl.dea                 = sysp.t_2
  pnl.rc                  = NULL
  dat$pnl.rc              = dat$pnl.rc/1000
} else {
  ir.dea                  = NVE.ir.t_2
  NVE.ir.RC               = NVE.ir.est
  pnl.dea                 = sysp.t_2
  dat$pnl.rc              = pnl.rc
}

# IDs to simplify scripts and aid analysts
id = read.csv("./Data/BaseData/id.csv", sep = ",")
# Dedicate IDs to base data using merge
dat = merge.data.frame(dat, id, by = "orgn", all.x = TRUE)
dat$comp <- as.character(dat$comp)
dat$name <- as.character(dat$comp)

# Replace NA  values with zeros to have correct means for pensions costs
dat[is.na(dat)] = 0

# Create id.y og orgn.y variable
dat$id.y <- paste(dat$id, dat$y, sep="")
dat$orgn.y <- paste(dat$y, dat$orgn, sep="")
dat$id.y <- as.numeric(dat$id.y)
dat$orgn.y <- as.numeric(dat$orgn.y)


# Remove Statnett SFs observations from dataset (TSO)
# dat <- dat[!(dat$orgn==962986633),] 

# Check for companies without ID
missing.id <- dat[is.na(dat$id),]
missing.id[c("comp", "orgn")]
stopifnot(nrow(missing.id) == 0)
rm(missing.id, id)

### Selecting companies for different evaluation types ####


# # Based on values (Improve - insert reference) - yet to be implemented
# #  De som skal m�les:
# eval.r = dat$id[dat$r_TOTXDEA >= 7000 & dat$r_vluft > 0 & dat$y == y.cb]
# #  De som kan danne fronten:
# front.r = dat$id[dat$r_TOTXDEA >= 15000 & dat$y == y.cb]
# #  De som skal evalueres, men ikke kan v�re p� fronten:
# sep.eval.r = setdiff(eval.r,front.r)


# # Manually defining group memberships 
#
# # OOTO - Companies Out Of The Ordinary
# These companies are compared to their own historical performance, cost in y.cb vs five year historical average cost in y.avg
# Criterias in local distribution: Number of subscribers (ld_sub) < 500 or kilometers of high voltage grid (ld_hv) < 100
# Criterias in regional distribution/transmission: Sum of all cost weights (rd_vw.ol + rd_wv.uc + rd_wv.sc + rd_wv.ss) < 4000
# or 0 km high voltage grid in regional distribution (rd_vw.ol = 0)
#
## av.eff - Companies set to average efficiency
# Companies with structural breaks in data. (Improve?)
#
## sep.eval - Companies included in DEA but allowed to be their own peers
# Criterias in local distribution:
# Criterias in regional distribution: TOTEX < 15000, .... ( Improve )  

# Local Distribution Grid
ld_ooto <- (c(108, 121, 167, 222, 512, 686, 743)) #852 - Her�ya. Discuss
ld_av.eff <- (c(10, 187, 294, 652, 852)) # Companies set to average efficency
ld_sep.eval <- (c()) # Companies included in DEA, but only allowed to be peers for themselves
ld_no.rc <- (c(134, 348, 521, 612, 638, 696, 524)) # Companies exluded from revenue cap calc


# Regional distribution grid (+ some transmission)
rd_ooto <- (c(10, 18,  41, 88, 135, 147, 156, 161, 162, 
              204, 222, 274, 287, 307, 349, 447, 512, 
              659,686)) # MIP (743) var med i VIR2018, men ikke notice 2017.

rd_av.eff <- (c(35, 98, 116, 152, 542, 685, 852)) #852 moved here for deciscion 2018, only 4 years of data

rd_sep.eval <- (c(7,9, 14, 37, 103, 106, 138, 164, 173,
                  184, 206, 238, 271, 288, 343, 484, 591, 625, 669))  #


rd_no.rc  <- (c()) # 35 Drangedal har 0 i rd_TOTX 2016

# CPI
cpi = c(81.0, 82.3, 84.2, 84.8, 88.0, 89.9, 92.1, 93.3, 93.9, 95.9, 97.9, 100, 103.6, 105.5, 107.8) #SSB tabell 03014
names(cpi) = 2004:2018

cpi.l = c(64.4, 67.1, 70.3, 73.7, 77.8, 81.2, 84.7, 87.9, 90.6, 93.8, 97.1, 100, 102.8, 105.8, 108.4) #SSB tabell 11118
names(cpi.l) = 2004:2018


# Data for Hammerfest
# Special treatment of CAPEX associated with LNG facility on Melkoya (Improve - ref?)
hfmo = read.csv("./Data/BaseData/Hammerfest_Melkoya.csv", sep = ",")
dat = merge.data.frame(dat, hfmo, by="id.y", all.x = TRUE)
dat$rd_bv.gf_melk[is.na(dat$rd_bv.gf_melk)] <- 0
dat$rd_dep.gf_melk[is.na(dat$rd_dep.gf_melk)] <- 0
dat$tempbv <- dat$rd_bv.gf
dat$tempdep <- dat$rd_dep.gf
dat$rd_bv.gf = dat$tempbv - dat$rd_bv.gf_melk
dat$rd_dep.gf = dat$tempdep - dat$rd_dep.gf_melk
dat$tempbv <- NULL
dat$tempdep <- NULL
rm(hfmo)


#CPI factors are used in calibration and revenue cap-calculations (part 4)
y.cb.cpi.l.factor = cpi.l[as.character(y.rc)]/cpi.l[as.character(y.cb)]
y.cb.cpi.factor = cpi[as.character(y.rc)]/cpi[as.character(y.cb)]
