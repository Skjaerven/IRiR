#### Spec Average efficiency - "model" ####
#
# Conditon: Incomplete or structural brakes in data
#
# The companies in this model er set to averege efficiency which
# in essence give them NVE interest in return and cost recovery

## Local distribution grid ------------------------------------
#Create dummy variable
dat$ld_AV.EFF = 0

#Set dummy variable value for companies in vector ld_av.eff
for (i in which(dat$id %in% ld_av.eff & dat$y==y.cb)){  
        dat[i,"ld_AV.EFF"]  = 1   
} 

#Create data frame of companies with ld_AV.EFF = 1
for (i in which(dat$y %in% y.cb)){
        ld_AV.EFF <-dat[dat$ld_AV.EFF==1,]
}


ld_AV.EFF$fha_ld_cb <- ((ld_AV.EFF$fha_fp_ld_OPEX*y.cb.cpi.l.factor) + ((ld_AV.EFF$fha_fp_ld_rab.sf*y.cb.cpi.factor)*NVE.ir.RC) + 
                                (ld_AV.EFF$fha_fp_ld_dep.sf*y.cb.cpi.factor) + (ld_AV.EFF$fha_fp_ld_cens*y.cb.cpi.factor) + 
                                (ld_AV.EFF$fha_ld_nl*pnl.rc) - (ld_AV.EFF$fha_fp_ld_gci.cost*y.cb.cpi.factor))

# Cost recovery, cost norm = cost base.
# As with companies in the OOTO model (.._cn.cal.RAB) indicates that these values are included
# in calibration. Contradictory to this, these companies are not included in the
# calibration and this is done to "gather the pieces" in the RC calculation

ld_AV.EFF$ld_cn.cal.RAB = ld_AV.EFF$fha_ld_cb


## Regional distribution grid ----------------------------------------------

dat$rd_AV.EFF = 0


for (i in which(dat$id %in% rd_av.eff & dat$y==y.cb)){  
        dat[i,"rd_AV.EFF"]  = 1   
} 


for (i in which(dat$y %in% y.cb)){
        rd_AV.EFF <-dat[dat$rd_AV.EFF==1,]
}

rd_AV.EFF[rd_OOTO$id == 167] = NULL
#Calculate cost base (cb) as input in calibration - regional distribution
rd_AV.EFF$fha_rd_cb <- ((rd_AV.EFF$fha_fp_rd_OPEX*y.cb.cpi.l.factor) + ((rd_AV.EFF$fha_fp_rd_rab.sf*y.cb.cpi.factor)*NVE.ir.RC) + 
                                (rd_AV.EFF$fha_fp_rd_dep.sf*y.cb.cpi.factor) + (rd_AV.EFF$fha_fp_rd_cens*y.cb.cpi.factor))

rd_AV.EFF$rd_cn.cal.RAB = rd_AV.EFF$fha_rd_cb
