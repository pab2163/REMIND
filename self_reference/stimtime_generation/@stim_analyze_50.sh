#!/bin/tcsh

# try to find reasonable random event related timing given the experimental
# parameters


#"In a nutshell, the normalized standard deviation is the square root of the measurement error variance. Since this variance is unknown, we estimate it with the Mean Square Error (MSE). A smaller normalized standard deviation indicates a smaller MSE. A small MSE is desirable, because MSE relates to the unexplained portion of the variance. Unexplained variance is NOT good. Therefore, the smaller the MSE (or normalized standard deviation), the better."


# ---------------------------------------------------------------------------
# some experiment parameters (most can be inserted directly into the
# make_random_timing.py command)

#set maxconsec = 3

#set num_stim    = 2    # num stim classes (conditions)
#set num_runs    = 3
#set pre_rest    = 12   # min rest before first stim (for magnet steady state) 0.85*16
#set post_rest   = 12    # min rest after last stim (for trailing BOLD response)
#set min_rest    = 0    # minimum rest after each stimulus
set tr          = 0.9   # used in 3dDeconvolve, if not make_random_timing.py

# (options that take multiple values can also take just one if they are
# all the same, such as with this example)
#
# set stim_durs   = "2.25 2.25 2.25 2.25"
# set stim_reps   = "12 12 12 12"
# set run_lengths = "300 300 300"

#set stim_durs   = 2.0
#set run_lengths = 300
#set labels      = "Cong Incong"
#set stim_reps   = 39
# num repetitions per run
# ---------------------------------------------------------------------------
# execution parameters
set iterations  = 100        # number of iterations to compare
set seed        = $1       # initial random seed
set outdir      = stim_results/stim_results.$seed  # directory that all results are under
set LCfile      = NSD_sums      # file to store norm. std. dev. sums in

# set pattern   = LC            # search pattern for LC[0], say
set pattern     = 'norm. std.'  # search pattern for normalized stdev vals
# "In a nutshell, the normalized standard deviation is the square root of the measurement error variance. Since this variance is unknown, we estimate it with the Mean Square Error (MSE). A smaller normalized standard deviation indicates a smaller MSE. A small MSE is desirable, because MSE relates to the unexplained portion of the variance. Unexplained variance is NOT good. Therefore, the smaller the MSE (or normalized standard deviation), the better."

# ===========================================================================
# start the work
# ===========================================================================

# ------------------------------------------------------------
# recreate $outdir each time

if ( -d $outdir ) then
   echo "** removing output directory, $outdir ..."
   \rm -fr $outdir
endif

echo "++ creating output directory, $outdir ..."
mkdir $outdir
if ( $status ) then
   echo "failure, cannot create output directory, $outdir"
   exit
endif

# move into the output directory and begin work
cd $outdir

# create empty LC file
echo -n "" > $LCfile

echo -n "iteration (of $iterations): 0000"

# ------------------------------------------------------------
# run the test many times

foreach iter (`count -digits 4 1 $iterations`)

 
        # create randomly ordered stimulus timing files
        # (consider: -tr_locked -save_3dd_cmd tempfile)
        #  changed to advanced format to use rand_post_stim_rest, no extra rest at end
        #  -add_timing_class rest 0 -1 8, default decay distribution min=0, max=8s


 make_random_timing.py -num_runs 2 -run_time 600  -tr $tr       \
            -pre_stim_rest 9 -post_stim_rest 6                 \
            -rand_post_stim_rest no                              \
            -add_timing_class ISI1 0.5 -1 8		 \
            -add_timing_class ISI2 0.5 -1 4  	\
            -add_timing_class ITI   1 -1 8                      \
			-add_timing_class imgt 1.5		 \
            -add_timing_class fdbkt 2.0 	\
            -add_timing_class ratet   4.0                         \
            -add_stim_class imgAA    12  imgt  ISI1                \
            -add_stim_class fdbkAA   12  fdbkt   ISI2                \
            -add_stim_class rateAA   12   ratet     ITI                \
            -ordered_stimuli  imgAA  fdbkAA  rateAA                     \
            -add_stim_class imgAR    12  imgt  ISI1                \
            -add_stim_class fdbkAR   12  fdbkt   ISI2                \
            -add_stim_class rateAR   12   ratet     ITI                \
            -ordered_stimuli  imgAR  fdbkAR  rateAR                     \
            -add_stim_class imgRA    13  imgt  ISI1                \
            -add_stim_class fdbkRA   13  fdbkt   ISI2                \
            -add_stim_class rateRA   13  ratet     ITI                \
            -ordered_stimuli  imgRA  fdbkRA  rateRA                     \
            -add_stim_class imgRR    13  imgt  ISI1                \
            -add_stim_class fdbkRR   13  fdbkt   ISI2                \
            -add_stim_class rateRR   13  ratet     ITI                \
            -ordered_stimuli  imgRR  fdbkRR  rateRR                     \
            -max_consec 2 2 2 2 2 2 2 2 2 2 2 2                                \
            -write_event_list events.4.list                       \
            -show_timing_stats                                     					\
            -prefix stimes.$iter													\
	  		-seed $seed					\
			-save_3dd_cmd cmd.3dd.$iter												\
                        >& out.mrt.$iter
        

                                             

        # consider: sed 's/GAM/"TENT(0,15,7)"/' tempfile > cmd.3dd.$iter
        #           rm -f tempfile

        # now evaluate the stimulus timings

        tcsh cmd.3dd.$iter >& out.3dD.$iter

        # save the sum of the 3 LC values
        set nums = ( `awk -F= '/'"$pattern"'/ {print $2}' out.3dD.${iter}` )

        # make a quick ccalc command
        set sstr = $nums[1]
        foreach num ( $nums[2-] )
            set sstr = "$sstr + $num"
        end
        set num_sum = `ccalc -expr "$sstr"`

        echo -n "$num_sum = $sstr : " >> $LCfile
        echo    "iteration $iter, seed $seed"                  >> $LCfile

        echo -n "\b\b\b\b\b\b\b$iter"

       # make some other random seed
        @ seed = $seed + 1


end

echo ""
echo "done, results are in '$outdir', LC sums are in '$LCfile'"
echo consider the command: "sort -n $outdir/$LCfile | head -1"

# note that if iter 042 seems to be the best, consider these commands:
#
# cd stim_results
# set iter = 042
# timing_tool.py -multi_timing stimes.${iter}_0*                  \
#                -run_len $run_lengths -multi_stim_dur $stim_durs \
#                -multi_show_isi_stats
# tcsh cmd.3dd.$iter
# 1dplot X.xmat.1D'[6..$]'
# 1dplot sum_ideal.1D
#
# - timing_tool.py will give useful statistics regarding ISI durations
#   (should be similar to what is seen in output file out.mrt.042)
# - run cmd.3dd.$iter to regenerate that X martix (to create actual regressors)
# - the first 1dplot command will show the actual regressors
#   (note that 6 = 2*$num_runs)
# - the second will plot the sum of the regressor (an integrity check)
#   (note that sum_ideal.1D is produced by cmd.3dd.$iter, along with X.xmat.1D)

