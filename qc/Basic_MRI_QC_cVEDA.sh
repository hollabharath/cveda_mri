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

if ( $#argv < 1 ) then 
	echo "" ;	
	echo "Usage:tcsh ./`basename $0` <SubjectID>" ;
	echo "" ;
	echo "" ;
	echo "" ;
	echo "NB: 	Multiple subjects can be QC'd by providing their PSC_ID separated by space "
	echo " 	The terminal working directory should contain DICOM/PSC_ID/SUB_FOLDERS" ;
	echo "	(for DICOM directory structure refer https://github.com/cveda/cveda_mri/wiki)" ;
	echo "" ;
	echo "" ;
	# echo "v.1 29-Nov-2018;
	echo "cVEDA Basic QC for dti/rest/t1w data - to be implemented at the acquisition centres" ;
	echo "The script automates the DICOM to NIFTI Conversions & generates QC images/reports" 
	echo "" ;
	echo "" ;
	# echo "v.2 01-Dec-2018 Bharath Holla, NIMHANS, Bengaluru (hollabharath@gmail.com)" ;
	# can now handle the new 32 dwi_ap acquisition for follow up scans
	# can now extract DWI PhaseEncodingAxis/PhaseEncodingDirection information from JSON sidecar
	echo "v.3 04-Dec-2018 Bharath Holla, NIMHANS, Bengaluru (hollabharath@gmail.com)" ;
	# Calculates Framewise Displacement, DVARS and AFNI style Quality/Outlier indices for rsfMRI
	echo "" ;
	echo "" ;
	echo "" ;
	echo "" ;
	echo "" ;
	echo "Depends: AFNI (>= AFNI_18.2.14)" ;
	echo "" ;
	echo "" ;
	echo "" ;
	exit 1 ; 
else
set here = $PWD
set proc_path = $here/Proc
set dicom_path = $here/DICOM
setenv AFNI_NIFTI_TYPE_WARN NO
setenv OMP_NUM_THREADS 4
foreach sub ($argv)
	set t1w		= $proc_path/${sub}/t1w
	set dwi		= $proc_path/${sub}/dwi
	set rest	= $proc_path/${sub}/rest
	set QC		= $proc_path/${sub}/QC
	echo "##############     Begin DICOM to NIfTI Conversions for $sub	##############"
	\mkdir -p $dwi
	dcm2niix_afni                        \
		-z y                         \
		-p y                         \
		-x n                         \
		-v 0                         \
		-o $dwi                      \
		-f dwi_${sub}                \
		${dicom_path}/${sub}/dwi/
	dcm2niix_afni                        \
		-z y                         \
		-p y                         \
		-x n                         \
		-v 0                         \
		-o $dwi                      \
		-f dwir_${sub}               \
		${dicom_path}/${sub}/dwi_rev/
	if ( -e ${dicom_path}/${sub}/dwi_ap ) then
	dcm2niix_afni                        \
		-z y                         \
		-p y                         \
		-x n                         \
		-v 0                         \
		-o $dwi                      \
		-f dwiap_${sub}              \
		${dicom_path}/${sub}/dwi_ap/
	endif
	\mkdir -p $t1w
	dcm2niix_afni                        \
		-z y                         \
		-p y                         \
		-x n                         \
		-o $t1w                      \
		-f t1w_${sub}                \
		${dicom_path}/${sub}/T1w/
	\mkdir -p $rest
	dcm2niix_afni                        \
		-z y                         \
		-p y                         \
		-v 0                         \
		-x n                         \
		-o $rest                     \
		-f rest_${sub}               \
		${dicom_path}/${sub}/rest/
	echo "#############     Begin QC Images	##############"
	\mkdir -p $QC
	set t1 = `ls $t1w/t1w*${sub}*.nii.gz` 
	@chauffeur_afni                        \
		-ulay "${t1[1]}"               \
		-montx 8 -monty 1              \
		-set_dicom_xyz   5 18 18       \
		-delta_slices   10 20 10       \
		-olay_off                      \
		-prefix "$QC/t1w_${sub}"       \
		-set_xhairs OFF                \
		-do_clean
	imcat                                          \
		-nx 1 -ny 3 -prefix $QC/t1w_${sub}.jpg \
		$QC/t1w*axi* $QC/t1w*cor* $QC/t1w*sag*
	rm $QC/t1w*sag*
	rm $QC/t1w*axi*
	rm $QC/t1w*cor*
	3dinfo -n4 -ad3 -tr -orient -prefix $t1 > $QC/t1w_${sub}_info.txt
	foreach dd ( `ls $dwi/dwi*${sub}*.nii.gz` )
		set ff = `basename $dd .nii.gz`
		3dAutomask                       	\
			-overwrite                     	\
			-prefix $dwi/${ff}_mask.nii.gz 	\
			$dwi/${ff}.nii.gz'[0]'
		3dZipperZapper                          \
			-overwrite                      \
			-do_out_slice_param             \
			-prefix  $dwi/${ff}_zz.nii.gz   \
			-mask    $dwi/${ff}_mask.nii.gz \
			-input   $dwi/${ff}.nii.gz
		#@djunct_4d_imager             		\
		#	-inset  $dwi/${ff}.nii.gz       \
		#	-prefix $QC/${ff}
		3dinfo -n4 -ad3 -tr -orient -prefix $dwi/${ff}.nii.gz > $QC/${ff}_info.txt
	end
	set rest4d = `ls $rest/rest*${sub}*.nii.gz` 
	3dinfo -n4 -ad3 -tr -orient -prefix ${rest4d[1]} > $QC/rest_${sub}_info.txt
	3dTstat																				\
		-tsnr -prefix $QC/rest_tsnr_${sub}.nii.gz   \
		$rest4d[1]
	@chauffeur_afni                                     \
		-ulay "$QC/rest_tsnr_${sub}.nii.gz"         \
	  	-montx 20 -monty 1                          \
		-olay_off                                   \
		-prefix "$QC/tsnr_rest_${sub}"              \
		-set_xhairs OFF                             \
		-do_clean
	imcat                                               \
		-ny 3                                       \
	  	-prefix $QC/rest_tsnr_${sub}.jpg            \
		$QC/tsnr*axi* $QC/tsnr*cor* $QC/tsnr*sag*
			rm $QC/tsnr*sag* 
			rm $QC/tsnr*cor* 
			rm $QC/tsnr*axi* 
	3dTstat                                             \
		-stdev -prefix $QC/rest_tstd_${sub}.nii.gz  \
		$rest4d[1]
	@chauffeur_afni                                     \
		-ulay "$QC/rest_tstd_${sub}.nii.gz"         \
	  	-montx 20 -monty 1                          \
		-olay_off                                   \
		-prefix "$QC/tstd_rest_${sub}"              \
		-set_xhairs OFF                             \
		-do_clean
	imcat                                               \
		-ny 3                                       \
	  	-prefix $QC/rest_tstd_${sub}.jpg            \
		$QC/tstd*axi* $QC/tstd*cor* $QC/tstd*sag*  
			rm $QC/tstd*sag* 
			rm $QC/tstd*cor*
			rm $QC/tstd*axi* 
	3dTstat																				\
		-MASDx -prefix $QC/rest_masd_${sub}.nii.gz  \
		$rest4d[1]
	@chauffeur_afni                                     \
		-ulay "$QC/rest_masd_${sub}.nii.gz"         \
	 	-montx 20 -monty 1                          \
		-olay_off                                   \
		-prefix "$QC/masd_rest_${sub}"              \
		-set_xhairs OFF                             \
		-do_clean
	imcat                                               \
		-ny 3                                       \
	  	-prefix $QC/rest_masd_${sub}.jpg            \
		$QC/masd*axi* $QC/masd*cor* $QC/masd*sag* 
			rm $QC/masd*sag* 
			rm $QC/masd*cor* 
			rm $QC/masd*axi*  
	3dToutcount                                                \
		-automask -fraction -legendre                      \
		-save $QC/rest_aor_${sub}_outlier.nii.gz           \
		$rest4d[1] > $QC/3dToutcount_fraction.1D  
	1dplot                                                     \
		-plabel 'Fraction of Outlier Voxels [3dToutcount]' \
		-jpg $QC/rest_aor_${sub}.jpg                       \
		$QC/3dToutcount_fraction.1D
	set aor = `3dTstat -prefix - $QC/3dToutcount_fraction.1D\'`
	3dTqual                                                    \
		-automask -range -spearman                         \
		$rest4d[1] > $QC/3dTqual_range.1D  
	1dplot                                                     \
		-plabel 'Mean Distance to Median Volume [3dTqual]' \
		-jpg $QC/rest_aqi_${sub}.jpg                       \
		-one $QC/3dTqual_range.1D
	set aqi = `3dTstat -prefix - $QC/3dTqual_range.1D\'`
	3dvolreg                                                   \
		-verbose -zpad 1 -1Dfile $QC/rest_motion.1D        \
		-cubic -prefix NULL                                \
		$rest4d[1]
	1d_tool.py -infile $QC/rest_motion.1D -derivative          \
		-collapse_cols weighted_enorm                      \
		-weight_vec .9 .9 .9 1 1 1                         \
		-write $QC/rest_fwd.1D
	3dTstat -abssum -prefix - $QC/rest_fwd.1D > $QC/rest_fwd_abssum.1D
	set FD = `3dTstat -prefix - $QC/rest_fwd_abssum.1D\'` 
	echo $FD
	3dTto1D                                                    \
		-automask  -method srms                            \
		-prefix $QC/rest_dvars.1D -input $rest4d[1]
	set DVARS = `3dTstat -prefix - $QC/rest_dvars.1D\'` 
	1dplot.py -sepscl -boxplot_on -reverse_order               \
		-infiles $QC/rest_motion.1D                        \
			 $QC/rest_fwd_abssum.1D                    \
			 $QC/rest_dvars.1D                         \
		-ylabels VOLREG FD DVARS -xlabel "Volumes"         \
		-title "Motion and outlier plots"                  \
		-prefix $QC/rest_fd_dvars_mot_plot.png
	
	set out_echo = $proc_path/${sub}/QC_Report_${sub}.txt
	printf "" > $out_echo	
	echo "###########################################" >> $out_echo
	echo "# Basic MRI QC Report for ${sub} #" >> $out_echo
	echo "###########################################" >> $out_echo
	foreach json ( `ls $dwi/dwi*${sub}*.json` )
	set Make = `grep '"Manufacturer":' $json | sed 's/^.*: "//;s/..$//'`
	set Model = `grep '"ManufacturersModelName":' $json | sed 's/^.*: "//;s/..$//'`
	end
	echo "Scanner : $Make $Model " >> $out_echo
	echo "" >> $out_echo
	foreach json ( `ls $dwi/dwi*${sub}*.json` )
	set PEdir = `grep '"PhaseEncodingDirection":' $json | sed 's/^.*: "//;s/..$//'`
	if ( $PEdir == j ) then
	echo "Phase encoding direction for `basename $json .json` is : P>>A" >> $out_echo
	endif
	if ( $PEdir == j- ) then
	echo "Phase encoding direction for `basename $json .json` is : A>>P" >> $out_echo
	endif
	if ( $PEdir == i ) then
	echo "Phase encoding direction for `basename $json .json` is : R>>L" >> $out_echo
	endif
	if ( $PEdir == i- ) then
	echo "Phase encoding direction for `basename $json .json` is : L>>R" >> $out_echo
	endif
	set PEAx = `grep '"PhaseEncodingAxis":' $json | sed 's/^.*: "//;s/..$//'`
	if ( $PEAx == j ) then
	echo "Phase encoding Axis for `basename $json .json` is : COL" >> $out_echo
	endif
	if ( $PEAx == j- ) then
	echo "Phase encoding Axis for `basename $json .json` is : COL" >> $out_echo
	endif
	if ( $PEAx == i ) then
	echo "Phase encoding Axis for `basename $json .json` is : ROW" >> $out_echo
	endif
	if ( $PEAx == i- ) then
	echo "Phase encoding Axis for `basename $json .json` is : ROW" >> $out_echo
	endif
	end
	if ( $PEdir ==  ) then
	echo "NB --> Phase encoding polarity cannot be reliably obtained if only the PE Axis info is stored in the DICOM header" >> $out_echo
	endif
	foreach zzbad ( `ls $dwi/dwi*${sub}*zz_badlist.txt` )
	set dwi_list  = `basename $zzbad _zz_badlist.txt`
	set ofile = $QC/${dwi_list}_bad_dir_list.txt
	printf "" > $ofile
	set dwi_bad = `cat $zzbad | wc -l`
	set dwi_bad_list = `cat $zzbad`
	echo $sub $dwi_bad $dwi_bad_list  >> $ofile
	set nv = `3dinfo -nv 	$dwi/$dwi_list.nii.gz`
	@ xv = $nv / 5
	if ( $dwi_bad < $xv ) then    
	echo "Number of volumes in $dwi_list corrupted by motion/slice-drop : $dwi_bad ---> Pass"  >> $out_echo
	else
	echo "Number of volumes in $dwi_list corrupted by motion/slice-drop : $dwi_bad ---> Fail"  >> $out_echo
	endif
	if ( $dwi_bad > 1 ) then
	echo "Visual inspection warranted for the following $dwi_list volumes :  $dwi_bad_list" >> $out_echo
	endif
	end
	echo "" >> $out_echo
	echo "" >> $out_echo
	echo "Resting-state fMRI:" >> $out_echo
	echo "Mean Framewise Displacement (FD) in `basename $rest4d`  [Motion Index] : $FD"    >> $out_echo
	echo "Mean DVARS (scaled by glob mean) in `basename $rest4d`   [DVARS Index] : $DVARS" >> $out_echo
	echo "Mean Outlier Vox-to-Vol Fraction in `basename $rest4d` [Outlier Index] : $aor"   >> $out_echo
	echo "Mean Distance to Median Volume in `basename $rest4d`   [Quality Index] : $aqi[1]"   >> $out_echo
	echo $FD "0.25" | awk '{ if ($1 > $2) print "Result --> Mean FD Motion exceeds acceptable thresholds"; else print "Result --> Mean FD Motion is within acceptable thresholds"}'>> $out_echo
	echo "" >> $out_echo
	echo "Visually inspect the TSNR, TSTD & MASD QC snapshots:" >> $out_echo
	echo "" >> $out_echo
	echo "Does the TSNR snapshot (rest_tsnr_${sub}.jpg) reveal any unusual artefact (y/n) : " >> $out_echo
	echo "Does the TSTD snapshot (rest_tstd_${sub}.jpg) reveal any unusual artefact (y/n) : " >> $out_echo
	echo "Does the MASD snapshot (rest_masd_${sub}.jpg) reveal any unusual artefact (y/n) : " >> $out_echo
	echo "" >> $out_echo
	echo "" >> $out_echo
	echo "T1w Visual QC :" >> $out_echo
	echo "Does the T1w snapshot (t1w_${sub}.jpg)  reveal any unusual artefact (y/n) : " >> $out_echo
	echo "" >> $out_echo
	echo "" >> $out_echo
	echo "3d Volume info :" >> $out_echo
	echo "Mat_x	Mat_y	Sli	Vol	Di		Dj		Dk		TR		Orient	Filename " >> $out_echo
	foreach volinfo (`ls $QC/*info.txt`)
	echo "`cat $volinfo`" >> $out_echo
	end
	echo "" >> $out_echo
	echo "" >> $out_echo
	echo "#######################################   QC Notes  ################################" >> $out_echo
	echo "" >> $out_echo
	echo "DWI QC :" >> $out_echo
	echo "	[1] Blip Up data should be acquired in P>>A phase encode and Blip down data in A>>P" >> $out_echo
	echo "	[2] Atleast 1 b0 & >80% of high b should be of good quality" >> $out_echo
	echo "" >> $out_echo
	echo "rsfMRI QC:" >> $out_echo
	echo "TSNR:	Gray matter and ventricles have lower temporal signal to noise ratio (TSNR) than white matter" >> $out_echo
	echo "	[Gray matter is more active metabolically than white matter, whereas CSF has greater pulsatility than tissue]" >> $out_echo
	echo "TSTD:	Brain edges will have higher temporal std deviation (TSTD) than central brain regions with subtle enhancement of the A-P edges > chin-to-chest micro head movements" >> $out_echo
	echo "	Gray matter will have higher std dev than white matter, because it's more active metabolically > physiological noise" >> $out_echo
	echo "	Also useful to spot any N/2 ghosting artefacts" >> $out_echo
	echo "MASD:	Median of absolute values of Successive Squared Differences times 1.4826 (to scale it like standard deviation)" >> $out_echo
	echo "	Similar to TSNR with additional advantage of identyfying subtle slice reconstruction artefacts" >> $out_echo
	echo "" >> $out_echo
	echo "T1w QC :" >> $out_echo
	echo "	Look for artefacts such as ringing, blurring, ghosting, and striping/ or incomplete head coverage" >> $out_echo
	echo "####################################################################################" >> $out_echo
	cat $out_echo
end
endif
