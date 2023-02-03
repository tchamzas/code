
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
#                  IV BOLUS SINGLE DOSE EXAMPLE                   #
#                                                                 #
###################################################################



# Load Data
df_bolus_sd = CSV.read("data/iv_bolus_sd.csv", DataFrame, missingstring=["NA", ".", ""])



# Define Units 
timeu = u"hr"
concu = u"mg/L"
amtu  = u"mg"



# Map Dataframe to NCA Population
pop_bolus_sd = read_nca(df_bolus_sd,
                id            = :id,
                time          = :time,
                observations  = :conc,
                amt           = :amt,
                route         = :route,
                #timeu         = true, 
                #amtu          = true, 
                #concu         = true, 
                llq           = 0.001) # bioassay
#




# Preview Data 
## individual plot - linear scale 
obsvstimes = observations_vs_time(pop_bolus_sd[5])


## individual plot - semi-log scale
obsvstimes = observations_vs_time(pop_bolus_sd[1], axis = (yscale = log,))


## mean concentration-time curve of population 
summary_observations_vs_time(pop_bolus_sd,
                                axis = (xlabel = "Time (hour)", 
                                ylabel = "Drug Concentration (mg/L)"))
#


# plot means - semilog scale 
sp_log = summary_observations_vs_time(pop_bolus_sd, 
                                  axis = (xlabel = "Time (hour)", 
                                  ylabel = "Drug Concentration (mg/L)",
                                  yscale = Makie.pseudolog10, # error bars require pseudo
                                  columns = 2, rows = 3,
                                  plot_resolution = (600, 1000)))  





# Perform Simple NCA
nca_bolus_sd = run_nca(pop_bolus_sd, sigdigits=3)



# Run Annotated NCA for Final Report 
nca_bolus_sd_report = run_nca(pop_bolus_sd, sigdigits=3,
                        studyid="STUDY-001",
                        studytitle="Phase 1 Drug Trial: IV Bolus Single Dose", # required
                        author = [("Author 1", "Author 2")], # required
                        sponsor = "PumasAI",
                        date=Dates.now(),
                        conclabel="Drug Concentration (mg/L)",
                        timelabel="Time (hr)",
                        versionnumber=v"0.1",)
#



# Summarize Results of Interest for Final Report
param_summary_bolus_sd  = summarize(nca_bolus_sd_report.reportdf, 
                            parameters = [:half_life, 
                                          :tmax, 
                                          :cmax, 
                                          :auclast, 
                                          :vz_obs, 
                                          :cl_obs, 
                                          :aucinf_obs])
#


# Generate NCA Report 
report(nca_bolus_sd_report, param_summary_bolus_sd, clean=false)



