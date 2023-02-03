

# Call Necessary Packages 
using CSV
using Chain
using DataFrames
using Dates
using NCA
using NCAUtilities
using NCA.Unitful
using PumasUtilities
using CairoMakie


###################################################################
#                                                                 #
#               IV INFUSION SINGLE DOSE EXAMPLE                   #
#                                                                 #
###################################################################



# Load Data
df_inf_sd = CSV.read("data/iv_infusion_sd.csv", DataFrame, missingstring=["NA", ".", ""])



# Map Dataframe to NCA Population
pop_inf_sd = read_nca(df_inf_sd,
                id            = :id,
                time          = :time,
                observations  = :conc,
                amt           = :amt,
                route         = :route,
                group         = [:group],
                llq           = 0.001)
#



# Preview Data 
## mean concentration-time curve of population 
summary_observations_vs_time(pop_inf_sd,
                                axis = (xlabel = "Time (hour)", 
                                ylabel = "Drug Concentration (mg/L)"))
#

## grid of individual plots for the first 9 subjects - linear scale 
ctplots = observations_vs_time(pop_inf_sd[1:9], 
                                axis = (xlabel = "Time (hour)", 
                                        ylabel = "Drug Concentration (mg/L)"),
                                paginate = true, #creates multiple pages  
                                columns = 3, rows = 3, #number of col/rows per page 
                                facet = (combinelabels = true,)) #creates 1 label for each page
ctplots[1]

ctplots = observations_vs_time(pop_inf_sd, 
                                axis = (xlabel = "Time (hour)", 
                                        ylabel = "Drug Concentration (mg/L)"),
                                paginate = true, #creates multiple pages  
                                columns = 3, rows = 3, #number of col/rows per page 
                                facet = (combinelabels = true,)) #creates 1 label for each page
#
ctplots[1]


# grid individual observation vs time plots - semilog scale 
ot_log = observations_vs_time(pop_inf_sd, 
                                axis = (xlabel = "Time (hour)", 
                                ylabel = "Drug Concentration (mg/L)",
                                yscale = log,),
                                #xticks = [0,12,24,36,48,60,72],),
                                separate = true,
                                paginate = true, 
                                limit = 9,
                                facet = (combinelabels=true,),)
#
ot_log[1]






# Perform Simple NCA
nca_inf_sd = run_nca(pop_inf_sd, sigdigits=3)






###### Generate Individual NCA Parameters #######
# https://docs.pumas.ai/stable/nca/ncafunctions/

# Clearance (CL=dose/AUC)
## L/hr 
cl        = NCA.cl(pop_inf_sd, sigdigits=3)  


# Volume of distribution during the elimination phase (Vz=Dose/(λz*AUC))
## L 
vz        = NCA.vz(pop_inf_sd, sigdigits=3)  


# Terminal elimination rate constant (λz or kel --> estimated using linear regression of conc vs time on log scale)
## 1/hr or hr-1
## kel = CL/V 
lambdaz   = NCA.lambdaz(pop_inf_sd, threshold=3, sigdigits=3)  #threshold=3 specifies the max no. of time point used for calculation


# Terminal half life (t1/2 = ln(2)/λz) --> terminal slope of the natural log of concentration vs time data 
## the time required for 50% of the drug to be eliminated 
## hr 
thalf     = NCA.thalf(pop_inf_sd, sigdigits=3) 


# AUC - area under the curve --> calculated using trapezoidal method 
## hr*mg/L (time x concentration)
auc_inf = NCA.auc(pop_inf_sd, auctype=:inf, method=:linuplogdown, sigdigits=3)
auc_last = NCA.auc(pop_inf_sd, auctype=:last, method=:linuplogdown, sigdigits=3)


# AUMC - area under the first momement of concentration (units=time^2 × concentration)
## The first moment is calculated as concentration x time (mg/L * hr)
## The AUMC is the area under the (concentration x time) versus time curve (mg/L * hr^2)
## hr^2*mg/L 
aumc_inf       = NCA.aumc(pop_inf_sd, auctype=:inf, sigdigits=3)
aumc_last      = NCA.aumc(pop_inf_sd, auctype=:last, sigdigits=3)


# Mean residence time (MRT = AUMC_inf/AUC_inf) (MRT = AUMC_last/AUC_last)
## average time the drug remains in the body 
mrt_inf       = NCA.mrt(pop_inf_sd, auctype=:inf, sigdigits=3) 
mrt_last      = NCA.mrt(pop_inf_sd, auctype=:last, sigdigits=3) 


# Dose normalized Cmax 
cmax_d    = NCA.cmax(pop_inf_sd, normalize=true, sigdigits=3) 
auc_d     = NCA.auc(pop_inf_sd, normalize=true, sigdigits=3) 



# create a dataframe from all individual parameters 
individual_params    = innerjoin(vz,cl,lambdaz,thalf,cmax_d,mrt, on=[:id,:group], makeunique=true) # include group to innerjoin**




# Other AUC calculation options 
auc0_12   = NCA.auc(pop_inf_sd, interval=(0,12), method=:linuplogdown, sigdigits=3) #various other methods are :linear, :linlog
auc12_24  = NCA.auc(pop_inf_sd, interval=(12,24), method=:linuplogdown, sigdigits=3) #looking at auc 12 to 24 hours (can make this interval anything!)
partial_aucs = NCA.auc(pop_inf_sd, interval = [(0,12), (12,24)], method=:linuplogdown, sigdigits=3)


auc_inf = NCA.auc(pop_inf_sd, auctype=:inf, method=:linuplogdown, sigdigits=3)
auc_last = NCA.auc(pop_inf_sd, auctype=:last, method=:linuplogdown, sigdigits=3)


# If we want to look at a parameter for 1 individual 
thalf_4     = NCA.thalf(pop_inf_sd[4], sigdigits=3) # Half-life calculation for 4th individual



# Run Annotated NCA for Final Report 
nca_inf_sd_report = run_nca(pop_inf_sd, sigdigits=3,
                        studyid="STUDY-002",
                        studytitle="Phase 1 Drug Trial: IV Infusion Single Dose", # required
                        author = [("Author 1", "Author 2")], # required
                        sponsor = "PumasAI",
                        date=Dates.now(),
                        conclabel="Drug Concentration (mg/L)",
                        timelabel="Time (hr)",
                        versionnumber=v"0.1",)
#


# Summarize Results of Interest for Final Report
param_summary_inf_sd  = summarize(nca_inf_sd_report.reportdf, 
                                stratify_by=[:group,], # stratifying by group so we can compare each dose 
                                parameters = [:half_life, 
                                          :tmax, 
                                          :cmax, 
                                          :auclast, 
                                          :vz_obs, 
                                          :cl_obs, 
                                          :aucinf_obs])


# Generate NCA Report 
report(nca_inf_sd_report, param_summary_inf_sd)





# Look at Individual Fits 
individual_fits = subject_fits(nca_inf_sd,
             axis = (xlabel = "Time (hr)", 
                     ylabel = "Drug Concentration (mg/L)",
                     yscale = log10),
             separate = true, paginate = true,
             limit = 16, columns = 4, rows = 4, 
             facet = (combinelabels = true,))
#
individual_fits[1]






