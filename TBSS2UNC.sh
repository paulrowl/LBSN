#/bin/bash
RootDir=/Users/paulrowley/Documents/DTI/3-TBSS
StarterPack=/Users/par258/Documents/DTI/UNC-ROI/UNC-ROI-p72-starterpack

#for stats maps, just reorient and resample

DataDir=$RootDir/$Experiment/$Group
printf "%s\n" "Welcome. " "Lets prepare your TBSS results for ROI Segmentation in UNC Space" "This script created by Paul Rowley & Jose Gonzalez. " "Last modified: "
date -r TBSS2UNC.sh
printf "%s\n" "Please select an experiment." "Type the number corresponding the experiment and press enter"

select Experiment in $RootDir/*; do test -n "$Experiment" && break; echo ">>> Invalid Selection"; done
# cd into the selected folder and list path
cd "$Experiment" && pwd

printf "Please select a group:\n"
select Group in $Experiment/*; do test -n "$Group" && break; echo ">>> Invalid Selection"; done
  cd "$Group" && pwd

read -p 'Please enter a label to attach to the output files corresponding to the group: ' label

cd $Group
mkdir $label
cp $Group/stats/tbss*.nii.gz $Group/$label
#reorient high resolution mean
root=$Group
input=$root/FA/mean_final_high_res.nii.gz
output=$root/$label/mean_final_high_res_reoriented.nii.gz
affineSymTensor3DVolume -in ${input} -out ${output}  -euler 90 -180 0

#compute maps
cd $Group/$label
#root=$Group/$label
if [ -e "mean_final_high_res_reoriented.nii.gz" ]; then
  TVtool -in mean_final_high_res_reoriented.nii.gz -out fa_$label.nii.gz -fa
  TVtool -in mean_final_high_res_reoriented.nii.gz -out tr_$label.nii.gz -tr
  SVtool -in tr_$label.nii.gz -out tr_$label.nii.gz -scale 0.3333333
  TVtool -in mean_final_high_res_reoriented.nii.gz -out rd_$label.nii.gz -rd
  TVtool -in mean_final_high_res_reoriented.nii.gz -out ad_$label.nii.gz -ad
else
  echo "mean_final_high_res_reoriented does not exist"
fi

#resample template to higher resolution

root=$Group/$label
fixed_img_1=$root/tr_$label.nii.gz
fixed_img_2=$root/fa_$label.nii.gz
fixed_img_3=$root/rd_$label.nii.gz
fixed_img_4=$root/ad_$label.nii.gz

#run the command below for each of the fixed_img's
if [ -e "ad_$label.nii.gz" ]; then
  SVResample -in $fixed_img_1 -size 171 171 171 -vsize .15 .15 .15
  SVResample -in $fixed_img_2 -size 171 171 171 -vsize .15 .15 .15
  SVResample -in $fixed_img_3 -size 171 171 171 -vsize .15 .15 .15
  SVResample -in $fixed_img_4 -size 171 171 171 -vsize .15 .15 .15
else
  echo "you have not properly computed your DTI maps! Aborting ship"
fi

#run multicontrast warping (md, fa, md, rd) with higher resolution of group A template
root=$Group/$label
prefix=$Group/$label
segmentation=$StarterPack/atlas_segmentation_masked.nii.gz

fixed_img_1=$root/tr_$label.nii.gz
moving_img_1=$StarterPack/md_atlas_masked_scale.nii.gz

fixed_img_2=$root/fa_$label.nii.gz
moving_img_2=$StarterPack/fa_atlas_masked.nii.gz

fixed_img_3=$root/rd_$label.nii.gz
moving_img_3=$StarterPack/dti_atlas_scale_masked_rd.nii.gz

fixed_img_4=$root/ad_$label.nii.gz
moving_img_4=$StarterPack/dti_atlas_scale_masked_ad.nii.gz

echo "registering UNC atlas to Template for $label"
#RegisterAtlasToTemplate
nohup ANTS 3 -m PR[$fixed_img_1,$moving_img_1,1,4] -m PR[$fixed_img_2,$moving_img_2,1,4] -m PR[$fixed_img_3,$moving_img_3,1,4] -m PR[$fixed_img_4,$moving_img_4,1,4] -o ${prefix}_template_ANTS_PR.nii -i 10x20x5  -r Gauss[3,0] -t SyN[0.25] --affine-metric-type CC --number-of-affine-iterations 1000x1000x1000
echo "successfully registered UNC to Template"

#ComposeAffNonLinWarp
if [ -e "${prefix}_template_ANTS_PRWarp.nii" ]; then
antsApplyTransforms -d 3 -r $fixed_img_1 -r $fixed_img_2 -r $fixed_img_3 -r $fixed_img_4 -o [${prefix}_composed_transform.nii.gz,1] -t ${prefix}_template_ANTS_PRWarp.nii -t ${prefix}_template_ANTS_PRAffine.txt
#WarpAtlasToTemplate
antsApplyTransforms -d 3 -r $fixed_img_1 -r $fixed_img_2 -r $fixed_img_3 -r $fixed_img_4 -i $segmentation -o ${prefix}_segmentation.nii.gz -t ${prefix}_composed_transform.nii.gz -n NearestNeighbor
#WarpAtlasBrainToTemplate md
antsApplyTransforms -d 3 -r $fixed_img_1 -i $moving_img_1 -o ${prefix}md_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#WarpAtlasBrainToTemplate fa
antsApplyTransforms -d 3 -r $fixed_img_2 -i $moving_img_2 -o ${prefix}fa_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#WarpAtlasBrainToTemplate rd
antsApplyTransforms -d 3 -r $fixed_img_3 -i $moving_img_3 -o ${prefix}rd_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#WarpAtlasBrainToTemplate ad
antsApplyTransforms -d 3 -r $fixed_img_4 -i $moving_img_4 -o ${prefix}ad_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
else
  echo "You need to register the UNC atlas to population template."
fi

#### For stats files  ####

affineSymTensor3DVolume -in tbss_AD_tfce_corrp_tstat1.nii.gz -out $label.AD_tfce_corrp_tstat1.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_AD_tfce_corrp_tstat2.nii.gz -out $label.AD_tfce_corrp_tstat2.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_FA_tfce_corrp_tstat1.nii.gz -out $label.FA_tfce_corrp_tstat1.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_FA_tfce_corrp_tstat2.nii.gz -out $label.FA_tfce_corrp_tstat2.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_RD_tfce_corrp_tstat1.nii.gz -out $label.RD_tfce_corrp_tstat1.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_RD_tfce_corrp_tstat2.nii.gz -out $label.RD_tfce_corrp_tstat2.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_TR_tfce_corrp_tstat1.nii.gz -out $label.TR_tfce_corrp_tstat1.nii.gz -euler 90 -180 0
affineSymTensor3DVolume -in tbss_TR_tfce_corrp_tstat2.nii.gz -out $label.TR_tfce_corrp_tstat2.nii.gz -euler 90 -180 0


#resample template to higher resolution
#run the command below for each of the fixed_img's
SVResample -in $label.AD_tfce_corrp_tstat1.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.AD_tfce_corrp_tstat2.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.FA_tfce_corrp_tstat1.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.FA_tfce_corrp_tstat2.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.RD_tfce_corrp_tstat1.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.RD_tfce_corrp_tstat2.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.TR_tfce_corrp_tstat1.nii.gz -size 171 171 171 -vsize .15 .15 .15
SVResample -in $label.TR_tfce_corrp_tstat2.nii.gz -size 171 171 171 -vsize .15 .15 .15

cd $Group
mv ${label}_composed_transform.nii.gz $Group/$label/${label}_composed_transform.nii.gz
mv ${label}_template_ANTS_PRAffine.txt $Group/$label/${label}_template_ANTS_PRAffine.txt
mv ${label}_template_ANTS_PRInverseWarp.nii $Group/$label/${label}_template_ANTS_PRInverseWarp.nii
mv ${label}_template_ANTS_PRWarp.nii $Group/$label/${label}__template_ANTS_PRWarp.nii

cd $Group/$label
mv ${prefix}md_atlas.nii.gz $Group/$label/${label}_md_atlas.nii.gz
mv ${prefix}fa_atlas.nii.gz $Group/$label/${label}_fa_atlas.nii.gz
mv ${prefix}rd_atlas.nii.gz $Group/$label/${label}_rd_atlas.nii.gz
mv ${prefix}ad_atlas.nii.gz $Group/$label/${label}_ad_atlas.nii.gz
mv ${prefix}_segmentation.nii.gz $Group/$label/${label}_segmentation.nii.gz

/Applications/ITK-SNAP.app/Contents/MacOS/ITK-SNAP -g fa_$label.nii.gz -s ${label}_segmentation.nii.gz

printf "%s\n" "CONGRATS " "Your data, $Group/$label , has been successfully warped to UNC space. " "Now open ITK-Snap, import the segmentation labels, and add the warped statistical output images to identify the regions of significance from your TBSS analysis. " "Good bye for now... "
exit
