
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
#      ORAL MULTIPLE DOSE EXAMPLE: STEADY STATE DATA ONLY         #
#                                                                 #
###################################################################




# Load Data
df_oral_ss = CSV.read("/home/jrun/data/code/Courses/PHMX_601/Week_4_NCA_II/Data_Week4/oral_md_ss_only.csv", DataFrame, missingstring=["NA", ".", ""])



# Map Dataframe to NCA Population
pop_oral_ss = read_nca(df_oral_ss,
                id            = :id,
                time          = :tad,
                observations  = :conc,
                amt           = :amt,
                route         = :route,
                ii            = :ii,
                ss            = :ss, 
                llq           = 0.001)
#



# Preview Data 
## mean concentration-time curve of population 
summary_observations_vs_time(pop_oral_ss,
                                axis = (xlabel = "Time (hour)", 
                                ylabel = "Drug Concentration (mg/L)"))
#

## grid of individual plots for the first 9 subjects - linear scale 
ctplots = observations_vs_time(pop_oral_ss[1:9], 
                                axis = (xlabel = "Time (hour)", 
                                        ylabel = "Drug Concentration (mg/L)"),
                                paginate = true, #creates multiple pages  
                                columns = 3, rows = 3, #number of col/rows per page 
                                facet = (combinelabels = true,)) #creates 1 label for each page
ctplots[1]


# grid individual observation vs time plots - semilog scale 
ot_log = observations_vs_time(pop_oral_ss, 
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
nca_oral_ss = run_nca(pop_oral_ss, sigdigits=3)



# Generate Individual NCA Parameters 
vz        = NCA.vz(pop_oral_ss, sigdigit=3)  # Volume of Distribution/F, in this case since the drug is given orally
cl        = NCA.cl(pop_oral_ss, sigdigits=3)  # Clearance/F, in this case since the drug is given orally
lambdaz   = NCA.lambdaz(pop_oral_ss, threshold=3, sigdigits=3)  # Terminal Elimination Rate Constant, threshold=3 specifies the max no. of time point used for calculation
thalf     = NCA.thalf(pop_oral_ss, sigdigits=3) # Half-life calculation 
cmax_d    = NCA.cmax(pop_oral_ss, normalize=true, sigdigits=3) # Dose Normalized Cmax
mrt       = NCA.mrt(pop_oral_ss, sigdigits=3) # Mean residence time
individual_params      = innerjoin(vz,cl,lambdaz,thalf,cmax_d,mrt, on=[:id], makeunique=true)


auc0_12   = NCA.auc(pop_oral_ss, interval=(0,12), method=:linuplogdown, sigdigits=3) #various other methods are :linear, :linlog
auc12_24  = NCA.auc(pop_oral_ss, interval=(12,24), method=:linuplogdown, sigdigits=3) #looking at auc 12 to 24 hours (can make this interval anything!)
partial_aucs = NCA.auc(pop_oral_ss, interval = [(0,12), (12,24)], method=:linuplogdown, sigdigits=3)





# Run Annotated NCA for Final Report 
nca_oral_ss_report = run_nca(pop_oral_ss, sigdigits=3,
                        studyid="STUDY-004",
                        studytitle="Phase 1 Drug Trial: Oral Multiple Dosing (SS Only)", # required
                        author = [("Author 1", "Author 2")], # required
                        sponsor = "PumasAI",
                        date=Dates.now(),
                        conclabel="Drug Concentration (mg/L)",
                        timelabel="Time (hr)",
                        versionnumber=v"0.1",)
#


# Summarize Results of Interest for Final Report
param_summary_oral_ss  = summarize(nca_oral_ss_report.reportdf, 
                                        parameters = [:half_life, 
                                                        :tmax, 
                                                        :cmax, 
                                                        :auclast, 
                                                        :vz_f_obs, 
                                                        :cl_f_obs])
#


# Generate NCA Report 
report(nca_oral_ss_report, param_summary_oral_ss)

