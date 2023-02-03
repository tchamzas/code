
# The first step of modeling consists of an exploratory analysis 
#    - Plots
#    - Summary statistics*
#    - NCA

# Call packages 
using Pumas, CSV, Chain
using Pumas 
using PumasUtilities
using CSV
using Random
using Chain 
using DataFramesMeta 
using StatsBase 
using Dates 
using DataFramesMeta
using Distributions
using CairoMakie
using AlgebraOfGraphics
using CategoricalArrays
using PlotUtils



# Read in Data 
covs = CSV.read("/home/jrun/data/code/Courses/PHMX_601/Week_3_NCA/dapa_Covariate_Dataset_IV.csv", DataFrame, header=1, skipto=3)


# Age -- years 
# Weight -- kg 
# Gender -- 0=male, 1=female
# Race -- 0=white, 1=black, 2=asian 
# isPM -- is poor metabolizer? (0=no, 1=yes)
# CrCl -- mL/min 






#################################################
#                                               #
#          COVARIATE DATA SUMMARIES             #
#                                               #
#################################################


#### CONTINUOUS COVARIATES ####
# summarystats() 
# describe() 
# summarize() 



## continuous covariate summary statistics - REPL output 
age_stats = summarystats(covs[!,:Age])
wt_stats = summarystats(covs[!,:Weight])
crcl_stats = summarystats(covs[!,:CrCl])



## continuous covariate summary statistics - simple 
cont_covs = select(covs, [:Age, :Weight, :CrCl])
cont_cov_describe = describe(cont_covs)


## continuous covariate summary statistics - specified 
cont_cov_summary = summarize(cont_covs, 
                    parameters = [:Age, :Weight, :CrCl], 
                    stats=[extrema, mean, std])
#          

## continuous covariate summary statistics - stratified 
cont_cov_summary_byrace = summarize(covs, 
                    stratify_by = [:Race],
                    parameters = [:Age, :Weight, :CrCl], 
                    stats=[extrema, mean, std])
#
cont_cov_summary_bygender = summarize(covs, 
                    stratify_by = [:Gender],
                    parameters = [:Age, :Weight, :CrCl], 
                    stats=[extrema, mean, std])
#
cont_cov_summary_byispm = summarize(covs, 
                    stratify_by = [:isPM],
                    parameters = [:Age, :Weight, :CrCl], 
                    stats=[extrema, mean, std])
#









#### CATEGORICAL COVARIATES ####

## categorical covariate summary - full population 
cat_cov_summary = @chain covs begin
    stack(_, [:Gender,:Race,:isPM]) # columns to rows of 3 variables
    groupby(_, [:variable, :value])
    combine(_, nrow => :count)
    groupby(_, [:variable])
    transform(_, :count => (x -> x / sum(x)) => :prop) 
end

check1 = stack(covs, [:Gender,:Race,:isPM])
check2 = groupby(check1, [:variable, :value])
check3 = combine(check2, nrow => :count)
check4 = groupby(check3, [:variable])
check5 = transform(check4, :count => (x -> x / sum(x)) => :prop)


## categorical covariate summary - by Gender 
cat_cov_summary_bygender = @chain covs begin
    stack([:Race, :isPM])
    groupby(_, [:Gender, :variable, :value])
    combine(nrow => :count)
    groupby(_, [:Gender, :variable])
    transform(_, :count => (x -> x / sum(x)) => :prop) 
    sort([:Gender])
end


## categorical covariate summary - by Race 
cat_cov_summary_byrace = @chain covs begin
    stack([:Gender, :isPM])
    groupby(_, [:Race, :variable, :value])
    combine(nrow => :count)
    groupby(_, [:Race, :variable])
    transform(_, :count => (x -> x / sum(x)) => :prop) 
    sort([:Race])
end


## categorical covariate summary - by isPM 
cat_cov_summary_byispm = @chain covs begin
    stack([:Gender, :Race])
    groupby(_, [:isPM, :variable, :value])
    combine(nrow => :count)
    groupby(_, [:isPM, :variable])
    transform(_, :count => (x -> x / sum(x)) => :prop) 
    sort([:isPM])
end






#################################################
#                                               #
#         COVARIATE DATA VISUALIZATION          #
#                                               #
#################################################

# https://tutorials.pumas.ai/
# Section 5


# Collinearity assessment - box plots 
## internal box plot function 
boxplot(covs[!,:Gender], covs[!,:Weight], 
                show_outliers=true,
                axis = (xlabel = "Gender", 
                        ylabel = "Weight (kg)",
                        xticks = ([0,1],["Male", "Female"])))
#
## algebra of graphics - simple 
data(covs) * mapping(:Race, :Weight) * visual(BoxPlot) |> draw
#
## algebra of graphics - advanced 
race_wt = data(covs) * mapping(:Race, :Weight) * visual(BoxPlot, color=:lightblue)
d_race_wt = draw(race_wt; axis = (
            title = "Weight Distribution by Race",
            xlabel = "Race", 
            ylabel = "Weight (kg)",
            xticks = ([0,1,2],["Caucasian", "Black", "Asian"]),
            titlesize=30,
            xlabelsize=25,
            ylabelsize=25,
            xticksize=5,
            titlecolor=:white,
            xlabelcolor=:white,
            ylabelcolor=:white),
            figure = (; backgroundcolor=:grey50))
#





# Distribution assessment - histogram, density & violin plot 
hist(covs[!,:CrCl],
    bins = 9,
   axis = (xlabel = "CrCl (mL/min)",
           ylabel = "Count"))
#

# Violin Plot
violin(covs[!,:Gender], covs[!,:Age],
   axis = (xlabel = "Gender",
           ylabel = "Age",
           xticks = ([0,1],["Male", "Female"])))
#




## algebra of graphics 
data(covs) * mapping(:CrCl => "CrCl (mL/min)") * histogram(bins=10) |> draw
#


data(covs) * mapping(:CrCl; layout=:isPM => nonnumeric) * histogram() |> draw
#


covs = @rtransform covs :GENDER_CAT = :Gender == 1 ? "Female" : "Male"


data(covs) * mapping(:Age; layout=:GENDER_CAT => "Gender") * histogram(bins=9) |> draw
#


