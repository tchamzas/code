

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
#                 NCA FUNCTIONS FOR VISUALIZATION                 #
#                                                                 #
###################################################################



# Load Data
df = CSV.read("/home/jrun/data/code/Courses/PHMX_601/Week_3_NCA/iv_bolus_sd(1).csv", DataFrame, missingstring=["NA", ".", ""])



# Map Dataframe to NCA Population
pop = read_nca(df)





# simple plots 
## average concentration-time of populaiton 
summary_observations_vs_time(pop)



## concentration-time of first subject 
observations_vs_time(pop[1])


## concentration-time of first 4 subject 
observations_vs_time(pop[1:4])










# Detailed plots 
## mean concentration-time curve of population 
summary_observations_vs_time(pop,
                            axis = (xlabel = "Time (hour)", 
                            ylabel = "Drug Concentration (mg/L)"))
#


## grid of individual plots - linear scale 
ctplots = observations_vs_time(pop, 
                                axis = (xlabel = "Time (hour)", 
                                        ylabel = "Drug Concentration (mg/L)"),
                                paginate = true, #creates multiple pages  
                                columns = 3, rows = 3, #number of col/rows per page 
                                facet = (combinelabels = true,)) #creates 1 label for each page
#
ctplots[1]





## specify the x axis ticks 
ctplots_t = observations_vs_time(pop, 
                                axis = (xlabel = "Time (hour)", 
                                        ylabel = "Drug Concentration (mg/L)",
                                        xticks = [0,24,48,72],),
                                paginate = true, #creates multiple pages  
                                columns = 3, rows = 3, #number of col/rows per page 
                                facet = (combinelabels = true,)) #creates 1 label for each page
#
ctplots_t[1]




## plot on a semi-log scale 
ot_log = observations_vs_time(pop, 
                                axis = (xlabel = "Time (hour)", 
                                ylabel = "Drug Concentration (mg/L)",
                                #yscale = log10,), ## log base 10
                                yscale = log,), ## natural log 
                                separate = true,
                                paginate = true, 
                                limit = 9,
                                facet = (combinelabels=true,),)
#
ot_log[1]






# To get an introduction to NCA (next lecture series) - review the following tutorial: 
# https://tutorials.pumas.ai/html/nca/nca_introduction.html 