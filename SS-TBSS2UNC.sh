#/bin/bash
#This script takes individual sample tensor volumes as the input. The output is a folder named based on the tensor file basename. Briefly, the script itself warps a segmentation map to the sample data, computes region-based diffusion measures, and exports the data in text files.

#To use this script, you must set paths to your RootDir and StarterPack. As well, you must arrange your data in the following manner:
#StarterPack= this is a directory containing the UNC atlas data (atlas_segmentation_mask.nii.gz, mask_p72.nii.gz, dti_atlas_scaled_masked_ad.nii.gz, dti_atlas_scaled_masked_rd.nii.gz, fat_atlas_masked.nii.gz, md_atlas_masked_scale.nii.gz). For more information on this data please see: Rumple A, McMurray M, Johns J, Lauder J, Makam P, Radcliffe M, et al. (2013) 3-Dimensional Diffusion Tensor Imaging (DTI) Atlas of the Rat Brain. PLoS ONE 8(7): e67334. https://doi.org/10.1371/journal.pone.0067334

#RootDir = directory containing folders corresponding to each experiment
#Experiment = name of directory corresponding to each experiment
#Group = experimental group folder name.
  #each $Group directory should contain only the tensor files (ending in composed_iso.nii.gz). 

Home=/Users/<user-name>
RootDir=$Home/Documents/DTI/5-SS-ROI
StarterPack=$Home/Documents/DTI/UNC-ROI/UNC-ROI-p72-starterpack
#set -e
#set -v

DataDir=$RootDir/$Experiment/$Group
printf "%s\n" "Welcome. " "Time to do some single subject ROI analysis! " "This script created by Paul Rowley & Jose Gonzalez. " #"Last modified: "
#date -r SS-TBSS2UNC.sh
printf "%s\n" "Please select an experiment." "Type the number corresponding the experiment and press enter. "

select Experiment in $RootDir/*; do test -n "$Experiment" && break; echo ">>> Invalid Selection"; done
# cd into the selected folder and list path
cd "$Experiment" && pwd

printf "Please select a group:\n"
select Group in $Experiment/*; do test -n "$Group" && break; echo ">>> Invalid Selection"; done
  cd "$Group" && pwd

# ${x%.*.*}=$prefix=/path/to/sample_directory
# ${x}=/path/to/sample-in-group-dir.nii.gz

#create sample data directory
for x in $Group/*.nii.gz; do
    mkdir "${x%.*.*}" && mv "$x" "${x%.*.*}"

# transform data into atlas orientation
input=${x%.*.*}/*.nii.gz
output=${x%.*.*}/*.nii.gz
affineSymTensor3DVolume -in ${input} -out ${output}  -euler 90 -180 0

# compute maps
  TVtool -in ${x%.*.*}/*.nii.gz -out ${x%.*.*}_fa.nii.gz -fa
  TVtool -in ${x%.*.*}/*.nii.gz -out ${x%.*.*}_tr.nii.gz -tr
  SVtool -in ${x%.*.*}_tr.nii.gz -out ${x%.*.*}_tr.nii.gz -scale 0.3333333
  TVtool -in ${x%.*.*}/*.nii.gz -out ${x%.*.*}_rd.nii.gz -rd
  TVtool -in ${x%.*.*}/*.nii.gz -out ${x%.*.*}_ad.nii.gz -ad



#resample template to higher resolution
  root=$Group
  fixed_img_1=${root}/*_tr.nii.gz
  fixed_img_2=${root}/*_fa.nii.gz
  fixed_img_3=${root}/*_rd.nii.gz
  fixed_img_4=${root}/*_ad.nii.gz

  SVResample -in $fixed_img_1 -size 171 171 171 -vsize .15 .15 .15
  SVResample -in $fixed_img_2 -size 171 171 171 -vsize .15 .15 .15
  SVResample -in $fixed_img_3 -size 171 171 171 -vsize .15 .15 .15
  SVResample -in $fixed_img_4 -size 171 171 171 -vsize .15 .15 .15


# run multicontrast warping (md, fa, md, rd) with higher resolution of UNC template
prefix=${x%.*.*}
segmentation=$StarterPack/atlas_segmentation_masked.nii.gz

fixed_img_1=${prefix}_tr.nii.gz
moving_img_1=$StarterPack/md_atlas_masked_scale.nii.gz

fixed_img_2=${prefix}_fa.nii.gz
moving_img_2=$StarterPack/fa_atlas_masked.nii.gz

fixed_img_3=${prefix}_rd.nii.gz
moving_img_3=$StarterPack/dti_atlas_scale_masked_rd.nii.gz

fixed_img_4=${prefix}_ad.nii.gz
moving_img_4=$StarterPack/dti_atlas_scale_masked_ad.nii.gz

#echo "registering UNC atlas to $Group"
# #RegisterAtlasToTemplate
#if [ -e "${prefix}_ad.nii.gz" ]; then
nohup ANTS 3 -m PR[$fixed_img_1,$moving_img_1,1,4] -m PR[$fixed_img_2,$moving_img_2,1,4] -m PR[$fixed_img_3,$moving_img_3,1,4] -m PR[$fixed_img_4,$moving_img_4,1,4] -o ${prefix}_template_ANTS_PR.nii -i 10x20x5  -r Gauss[3,0] -t SyN[0.25] --affine-metric-type CC --number-of-affine-iterations 1000x1000x1000
#else
#  echo "Registration of UNC atlas to sample failed - SAD!"
#fi
#echo "successfully registered UNC to Template"

# #ComposeAffNonLinWarp
#if [ -e "${prefix}_template_ANTS_PRWarp.nii" ]; then
antsApplyTransforms -d 3 -r $fixed_img_1 -r $fixed_img_2 -r $fixed_img_3 -r $fixed_img_4 -o [${prefix}_composed_transform.nii.gz,1] -t ${prefix}_template_ANTS_PRWarp.nii -t ${prefix}_template_ANTS_PRAffine.txt
#WarpAtlasToTemplate
antsApplyTransforms -d 3 -r $fixed_img_1 -r $fixed_img_2 -r $fixed_img_3 -r $fixed_img_4 -i $segmentation -o ${prefix}_segmentation.nii.gz -t ${prefix}_composed_transform.nii.gz -n NearestNeighbor
#WarpAtlasBrainToTemplate md
antsApplyTransforms -d 3 -r $fixed_img_1 -i $moving_img_1 -o ${prefix}_md_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#WarpAtlasBrainToTemplate fa
antsApplyTransforms -d 3 -r $fixed_img_2 -i $moving_img_2 -o ${prefix}_fa_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#WarpAtlasBrainToTemplate rd
antsApplyTransforms -d 3 -r $fixed_img_3 -i $moving_img_3 -o ${prefix}_rd_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#WarpAtlasBrainToTemplate ad
antsApplyTransforms -d 3 -r $fixed_img_4 -i $moving_img_4 -o ${prefix}_ad_atlas.nii.gz -t ${prefix}_composed_transform.nii.gz
#else
#  echo "You need to register the UNC atlas to population template."
#fi

3dROIstats -mask ${prefix}_segmentation.nii.gz ${prefix}_fa.nii.gz > ${prefix}.FA.1D
3dROIstats -mask ${prefix}_segmentation.nii.gz ${prefix}_ad.nii.gz > ${prefix}.AD.1D
3dROIstats -mask ${prefix}_segmentation.nii.gz ${prefix}_rd.nii.gz > ${prefix}.RD.1D
3dROIstats -mask ${prefix}_segmentation.nii.gz ${prefix}_tr.nii.gz > ${prefix}.TR.1D
cat ${prefix}.*.1D  > ${prefix}.ROIstats.csv

cd ${x%.*.*}
mv ${x%.*.*}*.*.* "${x%.*.*}"
mv ${x%.*.*}*.* "${x%.*.*}"

done

printf "%s\n" "CONGRATS " "Your data, $Group, has been successfully warped to UNC space. " "Good bye for now... "
#exit
