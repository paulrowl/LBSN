#bin/bash

### enter the following variables.
#fill in prefix appended to each volumetric parameter map
prefix=oneweek

#fill in name of each file (including .nii) corresponding to each ROI mask. Names should follow the convention "3_Cord_ROI_001.nii"
top_mask=3_Cord_ROI_003.nii
right_mask=3_Cord_ROI_002.nii
left_mask=3_Cord_ROI_004.nii

#fill in the name of the sample IDs corresponding to their label and position during scanning. (ex: left_brain=CON_A1)
left_brain=CON_A1
right_brain=CON_A2
top_brain=CON_A3

fslmaths ${prefix}_fibredirs_xvec.nii -sub $top_mask -thr 0 ${prefix}_LR_fibredirs_xvec
fslmaths ${prefix}_LR_fibredirs_xvec.nii -sub $right_mask -thr 0 ${left_brain}_fibredirs_xvec
fslmaths ${prefix}_LR_fibredirs_xvec.nii -sub $left_mask -thr 0 ${right_brain}_fibredirs_xvec
fslmaths ${prefix}_fibredirs_xvec.nii -sub $left_mask -thr 0 ${prefix}_TR_fibredirs_xvec
fslmaths ${prefix}_TR_fibredirs_xvec.nii -sub $right_mask -thr 0 ${top_brain}_fibredirs_xvec

fslmaths ${prefix}_fibredirs_yvec.nii -sub $top_mask -thr 0 ${prefix}_LR_fibredirs_yvec
fslmaths ${prefix}_LR_fibredirs_yvec.nii -sub $right_mask -thr 0 ${left_brain}_fibredirs_yvec
fslmaths ${prefix}_LR_fibredirs_yvec.nii -sub $left_mask -thr 0 ${right_brain}_fibredirs_yvec
fslmaths ${prefix}_fibredirs_yvec.nii -sub $left_mask -thr 0 ${prefix}_TR_fibredirs_yvec
fslmaths ${prefix}_TR_fibredirs_yvec.nii -sub $right_mask -thr 0 ${top_brain}_fibredirs_yvec

fslmaths ${prefix}_fibredirs_zvec.nii -sub $top_mask -thr 0 ${prefix}_LR_fibredirs_zvec
fslmaths ${prefix}_LR_fibredirs_zvec.nii -sub $right_mask -thr 0 ${left_brain}_fibredirs_zvec
fslmaths ${prefix}_LR_fibredirs_zvec.nii -sub $left_mask -thr 0 ${right_brain}_fibredirs_zvec
fslmaths ${prefix}_fibredirs_zvec.nii -sub $left_mask -thr 0 ${prefix}_TR_fibredirs_zvec
fslmaths ${prefix}_TR_fibredirs_zvec.nii -sub $right_mask -thr 0 ${top_brain}_fibredirs_zvec

fslmaths ${prefix}_ficvf.nii -sub $top_mask -thr 0 ${prefix}_LR_ficvf
fslmaths ${prefix}_LR_ficvf.nii -sub $right_mask -thr 0 ${left_brain}_ficvf
fslmaths ${prefix}_LR_ficvf.nii -sub $left_mask -thr 0 ${right_brain}_ficvf
fslmaths ${prefix}_ficvf.nii -sub $left_mask -thr 0 ${prefix}_TR_ficvf
fslmaths ${prefix}_TR_ficvf.nii -sub $right_mask -thr 0 ${top_brain}_ficvf

fslmaths ${prefix}_fiso.nii -sub $top_mask -thr 0 ${prefix}_LR_fiso
fslmaths ${prefix}_LR_fiso.nii -sub $right_mask -thr 0 ${left_brain}_fiso
fslmaths ${prefix}_LR_fiso.nii -sub $left_mask -thr 0 ${right_brain}_fiso
fslmaths ${prefix}_fiso.nii -sub $left_mask -thr 0 ${prefix}_TR_fiso
fslmaths ${prefix}_TR_fiso.nii -sub $right_mask -thr 0 ${top_brain}_fiso

fslmaths ${prefix}_fmin.nii -sub $top_mask -thr 0 ${prefix}_LR_fmin
fslmaths ${prefix}_LR_fmin.nii -sub $right_mask -thr 0 ${left_brain}_fmin
fslmaths ${prefix}_LR_fmin.nii -sub $left_mask -thr 0 ${right_brain}_fmin
fslmaths ${prefix}_fmin.nii -sub $left_mask -thr 0 ${prefix}_TR_fmin
fslmaths ${prefix}_TR_fmin.nii -sub $right_mask -thr 0 ${top_brain}_fmin

fslmaths ${prefix}_kappa.nii -sub $top_mask -thr 0 ${prefix}_LR_kappa
fslmaths ${prefix}_LR_kappa.nii -sub $right_mask -thr 0 ${left_brain}_kappa
fslmaths ${prefix}_LR_kappa.nii -sub $left_mask -thr 0 ${right_brain}_kappa
fslmaths ${prefix}_kappa.nii -sub $left_mask -thr 0 ${prefix}_TR_kappa
fslmaths ${prefix}_TR_kappa.nii -sub $right_mask -thr 0 ${top_brain}_kappa

fslmaths ${prefix}_odi.nii -sub $top_mask -thr 0 ${prefix}_LR_odi
fslmaths ${prefix}_LR_odi.nii -sub $right_mask -thr 0 ${left_brain}_odi
fslmaths ${prefix}_LR_odi.nii -sub $left_mask -thr 0 ${right_brain}_odi
fslmaths ${prefix}_odi.nii -sub $left_mask -thr 0 ${prefix}_TR_odi
fslmaths ${prefix}_TR_odi.nii -sub $right_mask -thr 0 ${top_brain}_odi

#### After ascertaining the translation and euler transformations from manually performing transformations on one output NODDI volumetric paramter, enter the transformation parameters into the variables below. ####
###usage -translation trans_X trans_Y trans_Z -euler theta phi psi
trans_X=
trans_Y=
trans_Z=
theta=
phi=
psi=

affineScalarVolume -in ${left_brain}_fibredirs_xvec.nii.gz -out ${left_brain}_fibredirs_xvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_fibredirs_yvec.nii.gz -out ${left_brain}_fibredirs_yvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_fibredirs_zvec.nii.gz -out ${left_brain}_fibredirs_zvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_ficvf.nii.gz -out ${left_brain}_ficvf.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_fiso.nii.gz -out ${left_brain}_fiso.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_fmin.nii.gz -out ${left_brain}_fmin.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_kappa.nii.gz -out ${left_brain}_kappa.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${left_brain}_odi.nii.gz -out ${left_brain}_odi.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi

affineScalarVolume -in ${right_brain}_fibredirs_xvec.nii.gz -out ${right_brain}_fibredirs_xvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_fibredirs_yvec.nii.gz -out ${right_brain}_fibredirs_yvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_fibredirs_zvec.nii.gz -out ${right_brain}_fibredirs_zvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_ficvf.nii.gz -out ${right_brain}_ficvf.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_fiso.nii.gz -out ${right_brain}_fiso.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_fmin.nii.gz -out ${right_brain}_fmin.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_kappa.nii.gz -out ${right_brain}_kappa.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${right_brain}_odi.nii.gz -out ${right_brain}_odi.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi

affineScalarVolume -in ${top_brain}_fibredirs_xvec.nii.gz -out ${top_brain}_fibredirs_xvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_fibredirs_yvec.nii.gz -out ${top_brain}_fibredirs_yvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_fibredirs_zvec.nii.gz -out ${top_brain}_fibredirs_zvec.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_ficvf.nii.gz -out ${top_brain}_ficvf.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_fiso.nii.gz -out ${top_brain}_fiso.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_fmin.nii.gz -out ${top_brain}_fmin.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_kappa.nii.gz -out ${top_brain}_kappa.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi
affineScalarVolume -in ${top_brain}_odi.nii.gz -out ${top_brain}_odi.nii.gz -translation $trans_X $trans_Y $trans_Z -euler $theta $phi $psi

echo "that's all folks!"
