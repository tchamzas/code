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





#################################################
#                                               #
#            DATA WRANGLING PRACTICE            #
#                                               #
#################################################


# read in the file "dapa_IV_ORAL.csv" and save as "pkdata"
# specify that the header is the first row and skip to the 3rd row to exclude the units row 
pkdata = CSV.read("/home/jrun/data/code/Courses/PHMX_601/Practice_Problems/PP2/dapa_IV_ORAL.csv",DataFrame,missingstring=["NA", ".", ""],skipto=3,header=1)

# create a new dataframe called "dose_event" by subseting "pkdata" at TAD==0.0
dose_event = @rsubset(pkdata, :TAD==0)

# make a copy of the new data frame "dose_event" and name it "conc_updates" 
conc_updates = copy(dose_event)

# replace the enire CObs column of "dose_event" with missing values 
@rtransform!(dose_event,:CObs = missing)

# add 0.001 to all elements in the TIME column of "conc_updates" 
conc_updates[!,:TIME].=conc_updates[!,:TIME].+0.001

# add 0.001 to all elements in the TAD column of "conc_updates"
conc_updates[!,:TAD].=conc_updates[!,:TAD].+0.001


# add a new column called "AMT" to "dose_event" 
# what goes in this column is the addition of column "AMT_IV" + "AMT_ORAL" of "dose_event"
dose_event[!,:AMT].=dose_event[!,:AMT_IV].+dose_event[!,:AMT_ORAL]


# create a new dataframe called "pkdata_nodose" by subseting "pkdata" when TAD does NOT equal 0.0 (TAD!=0.0)
pkdata_nodose = @rsubset(pkdata,:TAD!=0)

# set all elements in the "AMT" column of "pkdata_nodose" dataframe equal to missing 
pkdata_nodose[!,:AMT] .= missing

# set all elements in the "AMT" column of "conc_updates" dataframe equal to missing 
@rtransform!(conc_updates,:AMT=missing)

# vertically concatenate all 3 dataframes to create a new dataframe called "pkdata_fin"
# the 3 dataframes to concatenate include "pkdata_nodose", "dose_event", and "conc_updates"
pkdata_fin = vcat(pkdata_nodose,dose_event,conc_updates)


# order pkdata_fin by both ID and TIME so that ID is from smallest and largest & TIME is monotonically increasing
pkdata_fin = @orderby(pkdata_fin,:ID,:TIME)

# create a new dataframe called "pkdata_fin" that is just the following columns selected from "pkdata_fin":
# columns to select (in this order) include: ID, TIME, TAD, AMT, CObs, Formulation, OCC 
pkdata_fin = @select(pkdata_fin,:ID,:TIME,:TAD,:AMT,:CObs,Formulation,:OCC)


# create a new column labeled "DOSE" to the "pkdata_fin" dataframe that is equal to column "AMT" 


# conditionally fill "DOSE" where if AMT is missing, then DOSE is equal to zero, if AMT is not-missing, DOSE remains unchanged 
pkdata_fin = @rtransform pkdata_fin :DOSE = ismissing(:AMT) == true ? 0 : :DOSE

# appropriately fill "DOSE" so that every row indicates the dose given to each subject ("ID") at each occassion ("OCC")
pkdata_fin = @chain pkdata_fin begin
    groupby(_, [:ID, :OCC]) 
    transform(_, :DOSE => (x -> cumsum(x)) => :DOSE)
end

# add a column "EVID" to "pkdata_fin" and fill that column based on the following conditional
# if AMT is missing, then EVID is equal to 0 
# if AMT is not missing, then EVID is equal to 1 



# Save the dataframe "pkdata_fin" as a csv file called "pkdata_dapa.csv" 













#################################################
#                                               #
#          DATA VISUALIZATION PRACTICE          #
#                                               #
#################################################


# create a new dataframe called "iv_5" which contains all PK data for subjects
# who received 5 mg of IV drug using dataframe "pkdata_fin" 


# remove all IDs that are greater than the number 10 from "iv_5"
# i.e. you will be left with only ID # 1 through 10 


# remove all rows with missing concentration cells from dataframe "iv_5" 


# change columns "DOSE" and "ID" to type categorical 
@chain iv_5 begin
    transform!(_, [:ID, :DOSE] .=> categorical, renamecols = false)
end


# using Algebra of Graphics, plot concentration vs time for all subjects who received 5 mg IV drug ("iv_5")
# the plot should contain the following elements: 
# 1. each of our 10 subjects (ID) should be represented by a unique color 
# 2. the y-axis should have the following tick marks: 0, 50, 100, 150, 200, 250, 300
# 3. the x-axis should have the following tick marks: 0, 2, 4, 6, 8, 12, 24 
# 4. the y-axis should be a linear scale 
# 5. label the x-axis "Time (hours)"
# 6. label the y-axis "Concentration (mcg/L)"
# 7. title the graph "PP2 Concentration vs Time - 5 mg IV"
# 8. the aspect ratio should be set equal to 1 (so that the plot is square!)

