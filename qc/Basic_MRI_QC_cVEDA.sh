#!/bin/tcsh
#
# Copyright (c) 2018, NIMHANS
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of NIMHANS nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL NIMHANS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

if ( $#argv != 1 ) then
	echo "Usage: `basename $0` <SubjectID>"
	echo ""
	echo "NB: 	Multiple subjects can be QC'd by providing their PSC_ID separated by space "
	echo "	The terminal working directory should contain DICOM/PSC_ID/SUB_FOLDERS"
	echo "	(for DICOM directory structure refer https://github.com/cveda/cveda_mri/wiki)"
	echo ""
	echo ""
	echo "v.1 29-Nov-2018 Bharath Holla, NIMHANS, Bengaluru (hollabharath@gmail.com)"
	echo ""
	echo ""
	echo "cVEDA Basic QC for dti/rest/t1w data - to be implemented at the acquisition centres"
	echo "The script automates the DICOM to NIFTI Conversions & generates QC images/reports"
	echo ""
	echo ""
	echo "Depends: AFNI (>= AFNI_18.2.14)"
	exit 1
endif
set here = $PWD
set proc_path = $here/Proc
set dicom_path = $here/DICOM
setenv AFNI_NIFTI_TYPE_WARN NO
setenv OMP_NUM_THREADS 4
foreach sub ($1)
	set t1w		= $proc_path/${sub}/t1w
	set dwi		= $proc_path/${sub}/dwi
	set rest	= $proc_path/${sub}/rest
	set QC		= $proc_path/${sub}/QC
	echo "##############     Begin DICOM to NIfTI Conversions for $sub	##############"
	\mkdir -p $dwi
	dcm2niix_afni                    \
		-z y                         \
		-p y                         \
		-x n                         \
		-v 0                         \
		-o $dwi                      \
		-f dwi_${sub}                \
		${dicom_path}/${sub}/dwi/
	dcm2niix_afni                    \
		-z y                         \
		-p y                         \
		-x n                         \
		-v 0                         \
		-o $dwi                      \
		-f dwir_${sub}               \
		${dicom_path}/${sub}/dwi_rev/
	\mkdir -p $t1w
	dcm2niix_afni                    \
		-z y                         \
		-p y                         \
		-x n                         \
		-o $t1w                      \
		-f t1w_${sub}                \
		${dicom_path}/${sub}/T1w/
	\mkdir -p $rest
	dcm2niix_afni                    \
		-z y                         \
		-p y                         \
		-v 0                         \
		-x n                         \
		-o $rest                     \
		-f rest_${sub}               \
		${dicom_path}/${sub}/rest/
	echo "##############     Begin QC Images	##############"
	\mkdir -p $QC
	@chauffeur_afni                    \
		-ulay "$t1w/t1w_${sub}.nii.gz" \
		-montx 8 -monty 1              \
		-set_dicom_xyz   5 18 18       \
		-delta_slices   10 20 10       \
		-olay_off                      \
		-prefix "$QC/t1w_${sub}"       \
		-set_xhairs OFF                \
		-do_clean
	imcat                                      \
		-nx 1 -ny 3 -prefix $QC/t1w_${sub}.jpg \
		$QC/t1w*axi* $QC/t1w*cor* $QC/t1w*sag*
	rm $QC/t1w*sag*
	rm $QC/t1w*axi*
	rm $QC/t1w*cor*
	3dinfo -n4 -d3 -tr -orient -prefix $t1w/t1w_${sub}.nii.gz > $QC/t1w_${sub}_info.txt
	foreach dd ( `ls $dwi/dwi*${sub}*.nii.gz` )
		set ff = `basename $dd .nii.gz`
		3dAutomask                         \
			-overwrite                     \
			-prefix $dwi/${ff}_mask.nii.gz \
			$dwi/${ff}.nii.gz'[0]'
		3dZipperZapper                      \
			-overwrite                      \
			-do_out_slice_param             \
			-prefix  $dwi/${ff}_zz.nii.gz   \
			-mask    $dwi/${ff}_mask.nii.gz \
			-input   $dwi/${ff}.nii.gz
		@djunct_4d_imager             \
			-inset  $dwi/${ff}.nii.gz \
			-prefix $QC/${ff}
		3dinfo -n4 -d3 -tr -orient -prefix $dwi/${ff}.nii.gz > $QC/${ff}_info.txt
	end
	set rest4d = `ls $rest/rest*${sub}*.nii.gz`
	3dinfo -n4 -d3 -tr -orient -prefix ${rest4d} > $QC/rest_${sub}_info.txt
	3dTstat                                       \
		-tsnr -prefix $QC/tsnr_rest_${sub}.nii.gz \
		$rest4d
	@chauffeur_afni                         \
		-ulay "$QC/tsnr_rest_${sub}.nii.gz" \
		-montx 4 -monty 1                   \
		-ulay_range "20%" "98%"             \
		-olay_off                           \
		-prefix "$QC/tsnr_rest_${sub}"      \
		-blowup 4                           \
		-set_xhairs OFF                     \
		-do_clean
	imcat                                \
		-ny 2                            \
		-prefix $QC/rest_tsnr_${sub}.jpg \
		$QC/tsnr*sag* $QC/tsnr*axi*
	rm $QC/tsnr*sag*
	rm $QC/tsnr*cor*
	rm $QC/tsnr*axi*
	3dTstat                                        \
		-stdev -prefix $QC/tstd_rest_${sub}.nii.gz \
		$rest4d
	@chauffeur_afni                         \
		-ulay "$QC/tstd_rest_${sub}.nii.gz" \
		-montx 4 -monty 1                   \
		-ulay_range "20%" "98%"				\
		-olay_off                           \
		-prefix "$QC/tstd_rest_${sub}"      \
		-blowup 4                           \
		-set_xhairs OFF                     \
		-do_clean
	imcat                                \
		-ny 2                            \
		-prefix $QC/rest_tstd_${sub}.jpg \
		$QC/tstd*sag* $QC/tstd*axi*
	rm $QC/tstd*sag*
	rm $QC/tstd*cor*
	rm $QC/tstd*axi*
	3dTstat                                        \
		-MASDx -prefix $QC/masd_rest_${sub}.nii.gz \
		$rest4d
	@chauffeur_afni                         \
		-ulay "$QC/masd_rest_${sub}.nii.gz" \
		-montx 4 -monty 1                   \
		-ulay_range "20%" "98%"             \
		-olay_off                           \
		-prefix "$QC/masd_rest_${sub}"      \
		-blowup 4                           \
		-set_xhairs OFF                     \
		-do_clean
	imcat                                \
		-ny 2                            \
		-prefix $QC/rest_masd_${sub}.jpg \
		$QC/masd*sag* $QC/masd*axi*
	rm $QC/masd*sag*
	rm $QC/masd*cor*
	rm $QC/masd*axi*
	echo "##############     Begin QC Report	##############"
	set ofile  = $QC/dwi_${sub}_bad_dir_list.txt
	printf "" > $ofile
	set bu = `ls $dwi/dwi_*${sub}*zz_badlist.txt`
	set bu_bad = `cat $bu | wc -l`
	set bu_bad_list = `cat $bu`
	echo $sub $bu_bad $bu_bad_list >> $ofile
	set ofile  = $QC/dwir_{$sub}_bad_dir_list.txt
	printf "" > $ofile
	set bd = `ls $dwi/dwir_*${sub}*zz_badlist.txt`
	set bd_bad = `cat $bd | wc -l`
	set bd_bad_list = `cat $bd`
	echo $sub $bd_bad $bd_bad_list >> $ofile
	echo ""
	echo "Please review the below outputs to ensure atleast 1 b0 volume is good &"
	echo "not more than 6 (20%) high b (b1000) are corrupted"
	echo ""
	echo "Number of volumes in dwi_${sub} corrupted by motion/slice-drop : $bu_bad "
	echo ""
	echo "Please inspect following dwi_${sub} volumes visually  :  $bu_bad_list"
	echo ""
	echo "Number of volumes in dwir_${sub} corrupted by motion/slice-drop : $bd_bad "
	echo ""
	echo "Please inspect following dwir_${sub} volumes visually  :  $bd_bad_list"
	echo ""
	echo "3d Volume info"
	echo "Ni	Nj	Nk	Nv	Di		Dj		Dk		TR		orient	                    prefix "
	foreach volinfo (`ls $QC/*info.txt`)
		echo "`cat $volinfo`"
	end
end
