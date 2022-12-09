

cd data
files=dir('*S20*');

run1=load(files(1,1).name); %load run 1
response=run1.response; TP_Results=run1.TP_Results; ttt=run1.ttt; start_trials=run1.start_trials; end_trials=run1.end_trials;
cd ..
TP_analyze(response,ttt,TP_Results,start_trials,end_trials,5);
SD_run1=ans(:,6); MW_run1=ans(:,1); RT_run1=ans(:,5);

cd data
run2=load(files(2,1).name); %load run 1
response=run2.response; TP_Results=run2.TP_Results; ttt=run2.ttt; start_trials=run2.start_trials; end_trials=run2.end_trials;
cd ..
TP_analyze(response,ttt,TP_Results,start_trials,end_trials,5);
SD_run2=ans(:,6); MW_run2=ans(:,1); RT_run2=ans(:,5);

cd data
run3=load(files(3,1).name); %load run 1
response=run3.response; TP_Results=run3.TP_Results; ttt=run3.ttt; start_trials=run3.start_trials; end_trials=run3.end_trials;
cd ..
TP_analyze(response,ttt,TP_Results,start_trials,end_trials,5);
SD_run3=ans(:,6); MW_run3=ans(:,1); RT_run3=ans(:,5);

cd data
run4=load(files(4,1).name); %load run 1
response=run4.response; TP_Results=run4.TP_Results; ttt=run4.ttt; start_trials=run4.start_trials; end_trials=run4.end_trials;
cd ..
TP_analyze(response,ttt,TP_Results,start_trials,end_trials,5);
SD_run4=ans(:,6); MW_run4=ans(:,1); RT_run4=ans(:,5);

citytest=dir('*S20-R1-F*'); cityfirst=isempty(citytest); % find whether first run was city or face

if cityfirst==0
    SD_city_runs=[SD_run1;SD_run3];
    SD_face_runs=[SD_run2;SD_run4];
    RT_city_runs=[RT_run1;RT_run3];
    RT_face_runs=[RT_run2;RT_run4];
    MW_city_runs=[MW_run1;MW_run3];
    MW_face_runs=[MW_run2;MW_run4];
 
    
else
    SD_face_runs=[SD_run1;SD_run3];
    SD_city_runs=[SD_run2;SD_run4];
    RT_face_runs=[RT_run1;RT_run3];
    RT_city_runs=[RT_run2;RT_run4];
    MW_face_runs=[MW_run1;MW_run3];
    MW_city_runs=[MW_run2;MW_run4];
    
end

all=[MW_city_runs,SD_city_runs,RT_city_runs,MW_face_runs,SD_face_runs,RT_face_runs];




