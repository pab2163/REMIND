#! /bin/bash
# Clemens Bauer
# Modified by Paul Bloom December 202


## 4 ARGS: [subid] [ses] [run] [step]

#Step 1: disable wireless internet, set MURFI_SUBJECTS_DIR, and NAMEcd
#Step 2: receive 2 volume scan
#Step 3: create masks
#Step 4: run murfi for realtime

subj=$1
step=$2
ses='ses-lo1'
run='run-01'

# Set initial paths
subj_dir=../subjects/$subj
cwd=$(pwd)
absolute_path=$(dirname $cwd)
subj_dir_absolute="${absolute_path}/subjects/$subj"
fsl_scripts=../scripts/fsl_scripts

# Set paths & check that computers are properly connected with scanner via Ethernet
if [ ${step} = setup ]
then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Wellcome to MURFI real-time Neurofeedback"
    echo "+ running " ${step}
    export MURFI_SUBJECTS_DIR="${absolute_path}/subjects/"
    export MURFI_SUBJECT_NAME=$subj
    echo "+ subject ID: "$MURFI_SUBJECT_NAME
    echo "+ working dir: $MURFI_SUBJECTS_DIR"
    #echo "disabling wireless internet"
    #ifdown wlan0
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "checking the presence of scanner and stim computer"
    ping -c 3 192.168.2.1
    ping -c 3 192.168.2.6
    echo "make sure Wi-Fi is off"
    echo "make sure you are Wired Connected to rt-fMRI"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi  

# run MURFI for 2vol scan (to be used for registering masks to native space)  
if [ ${step} = 2vol ]
then
    clear
    echo "ready to receive 2 volume scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/2vol.xml
fi

# For registering masks in MNI space to native space (based on 2vol scan)
if [ ${step} = register ]
then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "Registering masks to study_ref"
    echo "Ignore Flipping WARNINGS we need LPS/NEUROLOGICAL orientation for murfi feedback!!"
    latest_ref=$(ls -t $subj_dir/xfm/*.nii | head -n1)
    latest_ref="${latest_ref::-4}"
    echo ${latest_ref}
    bet ${latest_ref} ${latest_ref}_brain -R -f 0.4 -g 0 -m # changed from -f 0.6
    slices ${latest_ref}_brain ${latest_ref} -o $subj_dir/xfm/2vol_skullstrip_check.gif

    # CCCB version (direct flirt from subject functional to MNI structural: step 1)
    # because the images that we get from Prisma through Vsend are in LPS orientation we need to change both our MNI mean image and our mni masks accordingly: 
    #fslswapdim MNI152_T1_2mm.nii.gz x -y z MNI152_T1_2mm_LPS.nii.gz
    #fslorient -forceneurological MNI152_T1_2mm_LPS.nii.gz
    # once the images are in the same orientation we can do registration
    rm -r $subj_dir/xfm/epi2reg
    mkdir $subj_dir/xfm/epi2reg
    mkdir $subj_dir/mask/lps

    # warp MNI templates into native space
    flirt -in MNI152_T1_2mm_LPS.nii.gz -ref ${latest_ref} -out $subj_dir/xfm/epi2reg/mnilps2studyref -omat $subj_dir/xfm/epi2reg/mnilps2studyref.mat
    flirt -in MNI152_T1_2mm_LPS_brain.nii.gz -ref ${latest_ref}_brain -out $subj_dir/xfm/epi2reg/mnilps2studyref_brain -omat $subj_dir/xfm/epi2reg/mnilps2studyref.mat

    slices $subj_dir/xfm/epi2reg/mnilps2studyref_brain ${latest_ref}_brain -o $subj_dir/xfm/MNI2_warp_to_2vol_native_check.gif

    # For each MNI mask in the participant's MNI mask directory, swap dimension & register to 2vol native space
    for mni_mask in {dmn,cen};
    do 
        echo "+ REGISTERING ${mni_mask} TO study_ref" 
        fslswapdim $subj_dir/mask/mni/${mni_mask}_mni x -y z $subj_dir/mask/lps/${mni_mask}_mni_lps
        fslorient -forceneurological $subj_dir/mask/lps/${mni_mask}_mni_lps
        
        #start registration
        flirt -in $subj_dir/mask/lps/${mni_mask}_mni_lps -ref ${latest_ref} -out $subj_dir/mask/${mni_mask} -init $subj_dir/xfm/epi2reg/mnilps2studyref.mat -applyxfm -interp nearestneighbour -datatype short
        fslmaths $subj_dir/mask/${mni_mask}.nii.gz -mul ${latest_ref}_brain_mask $subj_dir/mask/${mni_mask}.nii.gz -odt short
        gunzip -f $subj_dir/mask/${mni_mask}.nii.gz
    done

    echo "+ INSPECT"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fsleyes ${latest_ref}_brain  $subj_dir/mask/cen.nii -cm red $subj_dir/mask/dmn.nii -cm blue  #$subj_dir/mask/smc.nii -cm yellow $subj_dir/mask/stg.nii -cm green
fi

if  [ ${step} = feedback ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive rtdmn feedback scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/rtdmn.xml
fi


if  [ ${step} = resting_state ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive resting state scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/rest.xml
fi



if  [ ${step} = extract_rs_networks ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ compiling resting state run into analysis folder"

    expected_volumes=250
    # get all volumes of resting data (no matter how many) merged into 1 .nii.gz file
    run_0_volumes=$(find ../subjects/${subj}/img/ -name "img-00000*" | wc -l)
    run_1_volumes=$(find ../subjects/${subj}/img/ -name "img-00001*" | wc -l)

    if [ ${run_0_volumes} -eq 250 ] && [ ${run_1_volumes} -eq 250 ];
    then
        rest_runA_num=0
        rest_runB_num=1
    else
        runstring=''
        for i in {0..10};
        do
            #echo $i
            run_volumes=$(find ../subjects/${subj}/img/ -name "img-0000${i}*" | wc -l)
            if [ ${run_volumes} -ne 0 ]
            then
                runstring="${runstring}\nRun ${i}: ${run_volumes} volumes"
            fi
        done

        # use zenity to allow user to choose which resting volume to use
        input_string=$(zenity --forms --title="Which resting state runs to use for ICA?" \
            --separator=" " --width 600 --height 600 \
            --add-entry="Run A" \
            --add-entry="Run B" --text="`printf "${runstring}"`")


        # parse zenity output using space as delimiter
        read -a input_array <<< $input_string
        rest_runA_num=${input_array[0]}
        rest_runB_num=${input_array[1]}
    fi
    
    echo "Using run ${rest_runA_num} and run ${rest_runB_num}"

    # merge individual volumes to make 1 file for each resting state run
    rest_runB_filename=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold'.nii.gz
    rest_run2_filename=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold'.nii.gz 
    fslmerge -tr $rest_runB_filename $subj_dir_absolute/img/img-0000${rest_runA_num}* 1.2
    fslmerge -tr $rest_run2_filename $subj_dir_absolute/img/img-0000${rest_runB_num}* 1.2


    # figure out how many volumes of resting state data there were to be used in ICA
    restvolumes1=$(fslnvols $rest_runB_filename)
    restvolumes2=$(fslnvols $rest_run2_filename)
    if [ ${restvolumes1} -ne ${expected_volumes} ] || [ ${restvolumes2} -ne ${expected_volumes} ]; 
    then
        echo "WARNING! ${restvolumes1} volumes of resting-state data found for run 1."
        echo "${restvolumes2} volumes of resting-state data found for run 2. ${expected_volumes} expected?"

        # calculate minimum volumes (which run has fewer, then use fslroi to cut both runs to this minimum)
        minvols=$(( run_0_volumes < run_1_volumes ? run_0_volumes : run_1_volumes ))
        fslroi $rest_runB_filename $rest_runB_filename 0 $minvols
        fslroi $rest_run2_filename $rest_run2_filename 0 $minvols
        echo "Clipping runs so that both have ${minvols} volumes"
    else
        minvols=$expected_volumes
    fi

    echo "+ computing resting state networks this will take about 25 minutes"
    echo "+ started at: $(date)"
    
    # update FEAT template with paths and # of volumes of resting state run
    cp $fsl_scripts/rest_template.fsf $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    #DATA_path=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz
    OUTPUT_dir=$subj_dir_absolute/rest/rs_network
    sed -i "s#DATA1#$rest_runB_filename#g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    sed -i "s#DATA2#$rest_run2_filename#g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    sed -i "s#OUTPUT#$OUTPUT_dir#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf

    # update fsf to match number of rest volumes
    sed -i "s/set fmri(npts) 250/set fmri(npts) ${minvols}/g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    feat $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
fi



if [ ${step} = process_roi_masks ]
then
clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Generating DMN & CEN Masks "
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    

# Set up file paths needed for mask creation

## File to contain spatial correlations between ICs & template networks
ica_directory=$subj_dir/rest/rs_network.gica/groupmelodic.ica/
correlfile=$ica_directory/template_rsn_correlations_with_ICs.txt
touch ${correlfile}

# ICs in native space
infile=$ica_directory/melodic_IC.nii.gz 

# ICs in 
#infile_2mm=$ica_directory/melodic_IC_2mm.nii.gz

# Template & transform matrices needed for registration
#examplefunc=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/example_func.nii.gz
#standard=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/standard.nii.gz
#example_func2standard_mat=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/example_func2standard.mat
#standard2example_func_mat=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/standard2example_func.mat
template_networks='template_networks.nii.gz'


# Set template files
template_dmn='DMNax_brainmaskero2.nii'
template_cen='CENa_brainmaskero2.nii'

# Merge template files to 1 image
fslmerge -tr ${template_networks} ${template_dmn} ${template_cen} 1

# Warp template to native space (based on the resting state data used for ICA)
#template2example_func=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/template_networks2example_func.nii.gz
#flirt -in ${template_networks} -ref ${examplefunc} -out ${template2example_func} -init ${standard2example_func_mat} -applyxfm

# Correlate (spatially) ICA components (not thresholded) with DMN & CEN template files
fslcc --noabs -p 3 -t 0.05 ${infile} ${template_networks} >>${correlfile}

# Split ICs to separate files
split_outfile=$ica_directory/melodic_IC_
fslsplit ${infile} ${split_outfile}

# Selection of ICs most highly correlated with template networks
python rsn_get.py ${subj}


# Set paths for files needed for the next few steps 
## Unthresholded masks in native space
#dmn_uthresh=$ica_directory/dmn_uthresh.nii.gz
#cen_uthresh=$ica_directory/cen_uthresh.nii.gz

## Unthresholded masks in mni space
dmn_mni_uthresh=$ica_directory/dmn_mni_uthresh.nii.gz
cen_mni_uthresh=$ica_directory/cen_mni_uthresh.nii.gz

## Thresholded masks in MNI space
dmn_mni_thresh=$ica_directory/dmn_mni_thresh.nii.gz
cen_mni_thresh=$ica_directory/cen_mni_thresh.nii.gz


# Hard code the number of voxels desired for each mask
num_voxels_desired=1000

# register non-thresholded masks to MNI space
#flirt -in  ${dmn_uthresh} -ref ${standard} -out ${dmn_mni_uthresh} -init ${example_func2standard_mat} -applyxfm
#flirt -in  ${cen_uthresh} -ref ${standard} -out ${cen_mni_uthresh} -init ${example_func2standard_mat} -applyxfm

# zero out voxels not included in the template masks (i.e. so we only select voxels within template DMN/CEN)
fslmaths ${dmn_mni_uthresh} -mul ${template_dmn} ${dmn_mni_uthresh}
fslmaths ${cen_mni_uthresh} -mul ${template_cen} ${cen_mni_uthresh}


# get number of non-zero voxels in masks, calculate percentile cutofff needed for the desired absolute number of voxels
voxels_in_dmn=$(fslstats ${dmn_mni_uthresh} -V | awk '{print $1}')
percentile_dmn=$(python -c "print(100*(1-${num_voxels_desired}/${voxels_in_dmn}))")
voxels_in_cen=$(fslstats ${cen_mni_uthresh} -V | awk '{print $1}')
percentile_cen=$(python -c "print(100*(1-${num_voxels_desired}/${voxels_in_cen}))")


# get threshold based on percentile
dmn_thresh_value=$(fslstats ${dmn_mni_uthresh} -P ${percentile_dmn})
cen_thresh_value=$(fslstats ${cen_mni_uthresh} -P ${percentile_cen})

# threshold masks in MNI space
fslmaths ${dmn_mni_uthresh} -thr ${dmn_thresh_value} -bin ${dmn_mni_thresh} -odt short
fslmaths ${cen_mni_uthresh} -thr ${cen_thresh_value} -bin ${cen_mni_thresh} -odt short


echo "Number of voxels in dmn mask: $(fslstats ${dmn_mni_thresh} -V)"
echo "Number of voxels in cen mask: $(fslstats ${cen_mni_thresh} -V)"

# copy masks to participant's mask directory
cp ${dmn_mni_thresh} ${subj_dir}/mask/mni/dmn_mni.nii.gz
cp ${cen_mni_thresh} ${subj_dir}/mask/mni/cen_mni.nii.gz


# Display masks with FSLEYES
fsleyes  mean_brain.nii.gz ${dmn_mni_thresh} -cm blue ${cen_mni_thresh} -cm red

fi

