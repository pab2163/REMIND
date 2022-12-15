
foreach iter ( `count -digits 1 0 99` )
   @ sbase = 0 + 10000 * $iter
   echo tcsh @stim_analyze_50.sh $sbase >> run.all.stimanalyze.swarm 
end




#echo "" > run.all.stimanalyze_5run.swarm
#foreach iter ( `count -digits 1 0 99` )
#   @ sbase = 0 + 10000 * $iter
#   echo tcsh @stim_analyze_50_5run.sh $sbase >> run.all.stimanalyze_5run.swarm 
#end