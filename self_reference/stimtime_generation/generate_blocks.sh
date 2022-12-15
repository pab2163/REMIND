iter=$1
make_random_timing.py -num_runs 10 -run_time 32  \
    -pre_stim_rest 0 -post_stim_rest 8 \
    -rand_post_stim_rest no                 \
    -prefix sret_blocks/stimes                \
    -max_consec 2 2                         \
    -add_timing_class ISI1 0.5 -1 8		 \
    -add_timing_class word 2.5 \
    -add_stim_class pos_${iter}  3  word  ISI1               \
    -add_stim_class neg_${iter}  3  word  ISI1               \
    -show_timing_stats \
    -save_3dd_cmd sret_blocks/cmd.3dd.$iter												\
                        >& sret_blocks/out.mrt.$iter