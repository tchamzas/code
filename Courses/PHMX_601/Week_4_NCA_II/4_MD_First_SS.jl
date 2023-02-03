
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
using DataFramesMeta


###################################################################
#                                                                 #
#   ORAL MULTIPLE DOSE EXAMPLE: FIRST DOSE & STEADY STATE DATA    #
#                                                                 #
###################################################################





#################### OPTION #1 ####################

# Load Data
df_oral_first_ss = CSV.read("data/oral_md_first_ss.csv", DataFrame, missingstring=["NA", ".", ""])



# Map Dataframe to NCA Population
pop_oral_first_ss = read_nca(df_oral_first_ss,
                id            = :id,
                time          = :time,
                observations  = :conc,
                amt           = :amt,
                route         = :route,
                ii            = :ii,
                ss            = :ss, 
                llq           = 0.001)
#


# Preview Data 
## individual plot - linear scale 
obsvstimes = observations_vs_time(pop_oral_first_ss[1])





# Perform Simple NCA
nca_oral_first_ss = run_nca(pop_oral_first_ss, sigdigits=3)


# Run Annotated NCA for Final Report 
nca_oral_first_ss_report = run_nca(pop_oral_first_ss, sigdigits=3,
                        studyid="STUDY-003",
                        studytitle="Phase 1 Drug Trial: Oral Multiple Dosing (First & SS)", # required
                        author = [("Author 1", "Author 2")], # required
                        sponsor = "PumasAI",
                        date=Dates.now(),
                        conclabel="Drug Concentration (mg/L)",
                        timelabel="Time (hr)",
                        versionnumber=v"0.1",)
#


# Summarize Results of Interest for Final Report
param_summary_oral_first_ss  = summarize(nca_oral_first_ss_report.reportdf, 
                                        parameters = [:half_life, 
                                                        :tmax, 
                                                        :cmax, 
                                                        :auclast, 
                                                        :vz_f_obs, 
                                                        :cl_f_obs])
#


# Generate NCA Report 
report(nca_oral_first_ss_report, param_summary_oral_first_ss)















######################## option #2 ##############################

# Load Data
df_oral_first_ss = CSV.read("data/oral_md_first_ss.csv", DataFrame, missingstring=["NA", ".", ""])


# Data wrangle 
df_oral_first_ss = @rtransform df_oral_first_ss :evid = ismissing(:amt) == false ? 1 : 0 
df_oral_first_ss = @chain df_oral_first_ss begin
    groupby(_, [:id]) 
    transform(_, :evid => (x -> cumsum(x)) => :occ)
  end
  

# Map Dataframe to NCA Population
pop_oral_first_ss = read_nca(df_oral_first_ss,
                id            = :id,
                time          = :time,
                observations  = :conc,
                amt           = :amt,
                route         = :route,
                ii            = :ii,
                ss            = :ss, 
                group         = [:occ,],
                llq           = 0.001)
#


# Preview Data 
## individual plot - linear scale 
obsvstimes = observations_vs_time(pop_oral_first_ss[1])
obsvstimes = observations_vs_time(pop_oral_first_ss[2])
obsvstimes = observations_vs_time(pop_oral_first_ss[3])
obsvstimes = observations_vs_time(pop_oral_first_ss[11])




# Perform Simple NCA
nca_oral_first_ss = run_nca(pop_oral_first_ss, sigdigits=3)

df_nca = DataFrame(nca_oral_first_ss.reportdf)
df_nca[!,:id] = parse.(Int,df_nca[!,:id])
df_nca[!,:occ] = parse.(Int,df_nca[!,:occ])
df_nca = @orderby df_nca :id :occ







# Run Annotated NCA for Final Report 
nca_oral_first_ss_report = run_nca(pop_oral_first_ss, sigdigits=3,
                        studyid="STUDY-003",
                        studytitle="Second - Phase 1 Drug Trial: Oral Multiple Dosing (First & SS)", # required
                        author = [("Author 1", "Author 2")], # required
                        sponsor = "PumasAI",
                        date=Dates.now(),
                        conclabel="Drug Concentration (mg/L)",
                        timelabel="Time (hr)",
                        versionnumber=v"0.1",)
#


# Summarize Results of Interest for Final Report
param_summary_oral_first_ss  = summarize(nca_oral_first_ss_report.reportdf, 
                                        stratify_by = [:occ,],
                                        parameters = [:half_life, 
                                                        :tmax, 
                                                        :cmax, 
                                                        :auclast, 
                                                        :vz_f_obs, 
                                                        :cl_f_obs])
#


# Generate NCA Report 
report(nca_oral_first_ss_report, param_summary_oral_first_ss)