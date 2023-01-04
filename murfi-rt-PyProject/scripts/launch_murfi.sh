#!/bin/sh

input_string=$(zenity --forms --title="Launch Murfi" \
	--separator=" " \
	--add-entry="Participant ID" \
	--add-combo="Step" --combo-values "create|setup|resting_state|2vol|register|extract_rs_networks|process_roi_masks|feedback")


# parse zenity output using space as delimiter
read -a input_array <<< $input_string
partcipant_id=remind${input_array[0]}
step=${input_array[1]}


if [ ${step} == 'create' ]
then
	source createxml.sh ${partcipant_id} setup
else
	source feedback.sh ${partcipant_id} ${step}
fi



