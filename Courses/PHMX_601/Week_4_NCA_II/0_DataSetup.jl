
# Call Necessary Packages 
using CSV
using Chain
using DataFrames
using Dates
using NCA
using NCAUtilities
using NCA.Unitful
using PumasUtilities


###################################################################
#                                                                 #
#                         NCA OVERVIEW                            #
#                                                                 #
###################################################################



# 1. What is NCA
# 2. Data set up 
# 3. Pumas Functions
#      - read_nca()  
#      - run_nca()



# Load Data
df_bolus_sd = CSV.read("/home/jrun/data/code/Courses/PHMX_601/Week_3_NCA/iv_bolus_sd(1).csv", DataFrame, missingstring=["NA", ".", ""])



