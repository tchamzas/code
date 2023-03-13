# Call Necessary Packages 
using CSV
using Chain
using DataFramesMeta 
using DataFrames 
using Dates
using NCA
using NCAUtilities
using NCA.Unitful
using Pumas 
using PumasUtilities
using CairoMakie
using StatsBase
using CategoricalArrays
using AlgebraOfGraphics

# Read in the provided data (nca_pp3.csv)
# amt -- mcg 
# conc -- mcg/L 
# time -- hour 
df = CSV.read("/home/jrun/data/code/Courses/PHMX_601/Practice_Problems/PP3/nca_pp3.csv",DataFrame,missingstring=["NA", ".", ""])

# convert categorical covariates to categorical type 
@chain df begin
    transform!(_, [:group, :Gender, :isFed] .=> categorical, renamecols = false)
end


# create a dataframe that only contains covariates by ID. name that dataframe "covs"
# covariates: group, Gender, WT, Age, isFed, SCr 
# hint: the vertical length of your dataframe should be 20 

covs = @rsubset(df,:time==0)
covs = @select(df,:group,:Gender,:WT,:Age,:isFed,:SCr)




#################################################
#                                               #
#          COVARIATE DATA SUMMARIES             #
#                                               #
#################################################

# Use the new "covs" dataframe you made for all tasks under "Covariate Data Summaries" and "Covariate Data Visualization" 


# Change the "isFed" column so that instead of numbers 1 and 0 it contains the following:
# 1 --> "Fed"
# 0 --> "Fasted"
covs = @rtransform covs :isFed = :isFed==1 ? "Fed" : "Fasted"


# use the summarize() function to get summary statistics for our 3 continuous covariates for the entire population 
# continuous covs: WT, Age, SCr 
# summary statistics: extrema, mean, std 
summarize(covs,parameters=[:WT,:Age,:SCr],stats=[extrema,mean,std])


# use the summarize() function to get summary stats of continuous covariates stratified by dose group 
# continuous covs: WT, Age, SCr 
# summary statistics: extrema, mean, std 
summarize(covs,stratify_by=[:group],parameters=[:WT,:Age,:SCr],stats=[extrema,mean,std])


# summarize categorical covariates by count & proportion for the whole population 
# categorical covariates: Gender, isFed 
cat_cov_summary = @chain covs begin
    stack(_, [:Gender,:isFed]) # columns to rows of 3 variables
    groupby(_, [:variable, :value])
    combine(_, nrow => :count)
    groupby(_, [:variable])
    transform(_, :count => (x -> x / sum(x)) => :prop) 
end



# summarize categorical covariates by count & proportion stratified by dose group 
# categorical covariates: Gender, isFed 
cat_cov_summary = @chain covs begin
    stack(_, [:Gender,:isFed]) # columns to rows of 3 variables
    groupby(_, [:group,:variable, :value])
    combine(_, nrow => :count)
    groupby(_, [:group,:variable])
    transform(_, :count => (x -> x / sum(x)) => :prop) 
    sort([:group])
end









#################################################
#                                               #
#         COVARIATE DATA VISUALIZATION          #
#                                               #
#################################################


# Using algebra of graphics, create a figure grid of 9 boxplots to test collinearity of the following covariates: 

# 1. WT and Gender
# 2. WT and dose group 
# 3. WT and isFed 
# 4. Age and Gender 
# 5. Age and dose group 
# 6. Age and isFed 
# 7. SCr and Gender 
# 8. SCr and dose group 
# 9. SCr and isFed 


## WT by categorical covariates 
gender_wt = data(covs) * mapping(:Gender, :WT) * visual(BoxPlot, color=:lightblue)
dose_wt = data(covs) * mapping(:group, :WT) * visual(BoxPlot, color=:lightblue)
isfed_wt = data(covs) * mapping(:isFed, :WT) * visual(BoxPlot, color=:lightblue)

# Age by categorical covariates 
gender_Age = data(covs) * mapping(:Gender, :Age) * visual(BoxPlot, color=:lightblue)
dose_Age = data(covs) * mapping(:group, :Age) * visual(BoxPlot, color=:lightblue)
isfed_Age = data(covs) * mapping(:isFed, :Age) * visual(BoxPlot, color=:lightblue)

# SCr by categorical covariates 
gender_wt = data(covs) * mapping(:Gender, :WT) * visual(BoxPlot, color=:lightblue)
dose_wt = data(covs) * mapping(:group, :WT) * visual(BoxPlot, color=:lightblue)
isfed_wt = data(covs) * mapping(:isFed, :WT) * visual(BoxPlot, color=:lightblue)


# Generate a 3x3 figure using the Figure() function 
fig = Figure(resolution = (2800, 2500); fontsize = 40)
draw!(fig[1,1], gender_wt; axis = (
                title = "Weight Distribution by Gender",
                xlabel = " ", 
                ylabel = "Weight (kg)",
                titlesize=50,
                ylabelsize=45,
                xticksize=5))
#draw!(fig[1,2], ...)
#draw!(fig[1,3], ...)
#draw!(fig[2,1], ...)
#draw!(fig[2,2], ...)
#draw!(fig[2,3], ...)
#draw!(fig[3,1], ...)
#draw!(fig[3,2], ...)
#draw!(fig[3,3], ...)

# Preview figure 
fig 

# Save figure
save("cov_col.png", fig)






#################################################
#                                               #
#           PK Visualization & NCA              #
#                                               #
#################################################




# Map you dataframe using the read_nca() function to create a type Population
# remember to group by our dose group column  
pop = read_nca(df,
                id            = :id,
                time          = :time,
                observations  = :conc,
                amt           = :amt,
                route         = :route,
                group         = [:group])


# Using the Pumas NCA function below, plot an average concentration-time curve of population 
# Function: summary_observations_vs_time() 
summary_observations_vs_time(pop)



# Using the Pumas NCA function below, create a grid of individual plots for all subjects on a linear scale 
# Function: observation_vs_time() 
ctplots = observations_vs_time(pop, 
                                axis = (xlabel = "Time (hour)", 
                                        ylabel = "Drug Concentration (mcg/L)"),
                                separate = true, 
                                paginate = true, #creates multiple pages  
                                limit=10,
                                facet = (combinelabels = true,)) #creates 1 label for each page
ctplots[1]
ctplots[2]

# Using the Pumas NCA function below, create a grid of individual plots for all subjects on a semilog scale 
# Function: observation_vs_time() 

ot_log = observations_vs_time(pop, 
                                axis = (xlabel = "Time (hour)", 
                                ylabel = "Drug Concentration (mcg/L)",
                                yscale = log10,),
                                separate = true,
                                paginate = true, 
                                limit = 10,
                                facet = (combinelabels=true,),)

ot_log[1]
ot_log[2]

# Generate a report using the following information as your annotations: 
# Study ID: STUDY-PP3 
# Study Title: Phase 1 Drug Trial: EV Single Dose
# Author: Your Name 
# Sponsor: UMB CTM 
# Date: The date of report generation (today's date)
# Concentration label: Drug Concentration (mcg/L)
# Time label: Time (hr) 

nca_report = run_nca(pop, sigdigits=3,
                        studyid="STUDY-PP3",
                        studytitle="Phase 1 Drug Trial: EV Single Dose",
                        author = [("Athanasios Chamzas")], # required
                        sponsor = "UMB CTM",
                        date=Dates.now(),
                        conclabel="Drug Concentration (mcg/L)",
                        timelabel="Time (hr)",
                        versionnumber=v"0.1",)


# Generate summary statistics of key PK parameters from your NCA report using the summarize() function
# remember to stratify by dose group
# key parameters: half life, terminal volume, clearnace, time of maximum concentraiton, 
# maximum concentration, AUC from 0 to the last observation, AUC from 0 extrapolated to infinity using observed data

param_summary  = summarize(nca_report.reportdf, 
                            stratify_by=[:group,], 
                            parameters = [:half_life, 
                                            :vz_f_obs, 
                                            :cl_f_obs,
                                            :tmax, 
                                            :cmax, 
                                            :auclast,  
                                            :aucinf_obs])


# Generate the NCA report and save the report PDF locally to be submitted to blackboard 
report(nca_report, param_summary, clean=true)
