#/bin/bash

##### FULLY AUTOMATED TBSS SCRIPT #####
##### To execute:
#1. Fill in full pathname for RootDir. This corresponds to the parent folder containing a folder for each experiment ($Experiment) which contain the TBSS comparison groups ($Group). Thus your data should be organized: DataDir=$RootDir/$Experiment/$Group
#2. Fill in the full pathname to your templates directory (just for viewing purposes)
#3. Go to directory containing TBSS.sh in Terminal and type sh TBSS.sh

Home=/Users/<username>
RootDir=$Home/Documents/DTI/3-TBSS
Templates=$Home/Documents/DTI/templates

DataDir=$RootDir/$Experiment/$Group
printf "%s\n" "Welcome. Lets do some TBSS " "This script created by Paul Rowley & Jose Gonzalez. " "Last modified: "
date -r TBSS.sh
printf "%s\n" "Please select an experiment." "Type the number corresponding the experiment and press enter"
#printf "Please select an Experiment by typing the number corresponding the experiment and pressing enter :\n"
select Experiment in $RootDir/*; do test -n "$Experiment" && break; echo ">>> Invalid Selection"; done
# cd into the selected folder and list path
cd "$Experiment" && pwd

printf "Please select a group:\n"
select Group in $Experiment/*; do test -n "$Group" && break; echo ">>> Invalid Selection"; done
  cd "$Group" && pwd

read -p 'How many control samples are in this group? ' GroupA_SampleSize
read -p 'How many experimental samples are in this group? ' GroupB_SampleSize

printf "Please select a template to display your results:\n"
select Temp in $Templates/*; do test -n "$Temp" && break; echo ">>> Invalid Selection"; done

#fill in group name as it appears in TBSS folder and number of samples per group.
DataDir=$RootDir/$Experiment/$Group
cd $Group
  #statements
#start in main group directory (ex: Protein)
#put all *_composed_iso.nii.gz volumes in the main group directory, then execute commands.
mkdir FA TR RD AD orig stats design
cp -r ./*.nii.gz ./FA/
cp -r ./*.nii.gz ./TR/
cp -r ./*.nii.gz ./AD/
cp -r ./*.nii.gz ./RD/
mv ./*.nii.gz ./orig/
cd FA
#to compute TBSS for FA
ls *.nii.gz > subjs.txt
cp ./subjs.txt ../TR/
cp ./subjs.txt ../AD/
cp ./subjs.txt ../RD/
#to compute TBSS for FA
TVMean -in subjs.txt -out mean_final_high_res.nii.gz
if [ -e "mean_final_high_res.nii.gz" ]; then
TVtool -in mean_final_high_res.nii.gz -fa
else
  echo "mean_final_high_res does not exist"
fi
mv mean_final_high_res_fa.nii.gz mean_FA.nii.gz
tbss_skeleton -i mean_FA -o mean_FA_skeleton

for sub in `cat subjs.txt`
do
  TVtool -in ${sub} -fa
done

mkdir FA
mv ./*_fa.nii.gz ./FA
cd FA
fslmerge -t all_FA.nii.gz *.nii.gz
mv ./all_FA.nii.gz ../all_FA.nii.gz
cd ..


#fslmerge -t all_FA.nii.gz <fa_file1 fa_file2 .......> # make sure that the files inside the < > are listed in such a way that they remain in their respective group. For example if each group has 5 samples make sure that the first 5 fa_files are from group 1 and the other five from group 2 and keep record of which group goes first. This is extremely important for carrying out the statistical testing correctly.
fslmaths all_FA -max 0 -Tmin -bin mean_FA_mask -odt char
if [ -e "mean_FA_mask.nii.gz" ]; then
  tbss_4_prestats 0.2
else
    echo "mean_FA_mask does not exist"
  fi
echo "computing FA"
design_ttest2 design $GroupA_SampleSize $GroupB_SampleSize
if [ -e "all_FA_skeletonised.nii.gz" ]; then
  randomise -i all_FA_skeletonised -o tbss_FA -m mean_FA_skeleton_mask -d design.mat -t design.con -n 20000 --T2
else
    echo "all_FA_skeletonised does not exist"
fi
#Glm_gui
echo "FA computation completed, computing TR"
cp ./tbss_FA_tfce_corrp_tstat1.nii.gz ../stats/
cp ./tbss_FA_tfce_corrp_tstat2.nii.gz ../stats/
cp ./design.con ../TR/design.con
cp ./design.con ../AD/design.con
cp ./design.con ../RD/design.con
cp ./design.mat ../TR/design.mat
cp ./design.mat ../AD/design.mat
cp ./design.mat ../RD/design.mat
mv ./design* ../design/
cp ./all_FA.nii.gz ../TR/all_FA.nii.gz
cp ./all_FA.nii.gz ../AD/all_FA.nii.gz
cp ./all_FA.nii.gz ../RD/all_FA.nii.gz
cp ./mean_FA.nii.gz ../TR/mean_FA.nii.gz
cp ./mean_FA.nii.gz ../AD/mean_FA.nii.gz
cp ./mean_FA.nii.gz ../RD/mean_FA.nii.gz
cp ./mean_FA_skeleton.nii.gz ../TR/mean_FA_skeleton.nii.gz
cp ./mean_FA_skeleton.nii.gz ../AD/mean_FA_skeleton.nii.gz
cp ./mean_FA_skeleton.nii.gz ../RD/mean_FA_skeleton.nii.gz
cp ./mean_FA_skeleton_mask.nii.gz ../TR/mean_FA_skeleton_mask.nii.gz
cp ./mean_FA_skeleton_mask.nii.gz ../AD/mean_FA_skeleton_mask.nii.gz
cp ./mean_FA_skeleton_mask.nii.gz ../RD/mean_FA_skeleton_mask.nii.gz
cp ./mean_FA_skeleton_mask_dst.nii.gz ../TR/mean_FA_skeleton_mask_dst.nii.gz
cp ./mean_FA_skeleton_mask_dst.nii.gz ../AD/mean_FA_skeleton_mask_dst.nii.gz
cp ./mean_FA_skeleton_mask_dst.nii.gz ../RD/mean_FA_skeleton_mask_dst.nii.gz
#done
###### FOR NON-FA METRICS: ######
#make directories for non-FA (TR, AD, RD)
#copy 1) isotropic normalised volumes, 2) all_FA, 3) mean_FA_skeleton_mask, 4) mean_FA_skeleton_mask_dst, 5) mean_FA_skeleton, 6) mean_FA, 7) design.con, 8) design.mat and 9) subjs.txt into non-FA directories
cd ../TR
###### TO COMPUTE TR #######
for sub in `cat subjs.txt`
do
  TVtool -in ${sub} -tr
done

mkdir TR
mv ./*_tr.nii.gz ./TR
cd TR
fslmerge -t all_TR.nii.gz *.nii.gz
mv ./all_TR.nii.gz ../all_TR.nii.gz
cd ..

if [ -e "all_TR.nii.gz" ]; then
tbss_skeleton -i mean_FA -p 0.2 mean_FA_skeleton_mask_dst mean_FA_skeleton_mask all_FA all_TR_skeletonised -a all_TR
else
    echo "all_TR does not exist"
fi

if [ -e "all_TR_skeletonised.nii.gz" ]; then
randomise -i all_TR_skeletonised -o tbss_TR -m mean_FA_skeleton_mask -d design.mat -t design.con -n 20000 --T2
else
  echo "all_TR_skeletonised does not exist"
fi
cp ./tbss_TR_tfce_corrp_tstat1.nii.gz ../stats/tbss_TR_tfce_corrp_tstat1.nii.gz
cp ./tbss_TR_tfce_corrp_tstat2.nii.gz ../stats/tbss_TR_tfce_corrp_tstat2.nii.gz

cd ../AD
#######to compute AD######
for sub in `cat subjs.txt`
do
  TVtool -in ${sub} -ad
done

mkdir AD
mv ./*_ad.nii.gz ./AD
cd AD
fslmerge -t all_AD.nii.gz *.nii.gz
mv ./all_AD.nii.gz ../all_AD.nii.gz
cd ..

if [ -e "all_AD.nii.gz" ]; then
tbss_skeleton -i mean_FA -p 0.2 mean_FA_skeleton_mask_dst mean_FA_skeleton_mask all_FA all_AD_skeletonised -a all_AD
else
    echo "all_AD does not exist"
fi

if [ -e "all_AD_skeletonised.nii.gz" ]; then
randomise -i all_AD_skeletonised -o tbss_AD -m mean_FA_skeleton_mask -d design.mat -t design.con -n 20000 --T2
else
  echo "all_AD_skeletonised does not exist"
fi

cp ./tbss_AD_tfce_corrp_tstat1.nii.gz ../stats/tbss_AD_tfce_corrp_tstat1.nii.gz
cp ./tbss_AD_tfce_corrp_tstat2.nii.gz ../stats/tbss_AD_tfce_corrp_tstat2.nii.gz

cd ../RD
#######to compute RD######
for sub in `cat subjs.txt`
do
  TVtool -in ${sub} -rd
done

mkdir RD
mv ./*_rd.nii.gz ./RD
cd RD
fslmerge -t all_RD.nii.gz *.nii.gz
mv ./all_RD.nii.gz ../all_RD.nii.gz
cd ..

if [ -e "all_RD.nii.gz" ]; then
tbss_skeleton -i mean_FA -p 0.2 mean_FA_skeleton_mask_dst mean_FA_skeleton_mask all_FA all_RD_skeletonised -a all_RD
else
    echo "all_RD does not exist"
fi

if [ -e "all_RD_skeletonised.nii.gz" ]; then
randomise -i all_RD_skeletonised -o tbss_RD -m mean_FA_skeleton_mask -d design.mat -t design.con -n 20000 --T2
else
  echo "all_RD_skeletonised does not exist"
fi

cp ./tbss_RD_tfce_corrp_tstat1.nii.gz ../stats/tbss_RD_tfce_corrp_tstat1.nii.gz
cp ./tbss_RD_tfce_corrp_tstat2.nii.gz ../stats/tbss_RD_tfce_corrp_tstat2.nii.gz

cd ../stats

cd $Group/stats

ls tbss*.nii.gz > voxel.inputs.txt
for input in `cat voxel.inputs.txt`
do
  fslstats ${input} -l 0.95 -V > voxels.${input}.txt
done

cat voxel* > $Group.voxels.csv
rm voxel*

fslview_deprecated $Temp -b 0,1.0 -l Greyscale tbss_AD_tfce_corrp_tstat1.nii.gz -b 0.95,1.0 tbss_RD_tfce_corrp_tstat1.nii.gz -b 0.95,1.0 tbss_AD_tfce_corrp_tstat2.nii.gz -b 0.95,1.0	tbss_RD_tfce_corrp_tstat2.nii.gz -b 0.95,1.0 tbss_FA_tfce_corrp_tstat1.nii.gz	-b 0.95,1.0 tbss_TR_tfce_corrp_tstat1.nii.gz -b 0.95,1.0 tbss_FA_tfce_corrp_tstat2.nii.gz	-b 0.95,1.0 tbss_TR_tfce_corrp_tstat2.nii.gz -b 0.95,1.0
echo "all done with TBSS for $Group"
echo "see $Group to inspect results"
exit
