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
        echo ""
        echo "Usage:tcsh ./`basename $0` <Path/to/DICOM>"
        echo ""
        echo ""
        echo ""
        echo "NB:         Multiple subject DICOM folders can be sorted by providing their Path/to/DICOM/PSC_ID separated by space "
        echo ""
        echo ""
        echo ""
        echo "The script automates the DICOM sorting and changes the folder names as per cVEDA naming conventions"
        echo ""
        echo ""
        echo ""
        echo "Depends: AFNI (>= AFNI_18.2.14)"
        echo ""
        echo ""
        echo ""
        echo "v.1 15-Dec-2018 Bharath Holla, NIMHANS, Bengaluru (hollabharath@gmail.com)" 
        echo ""
        echo ""
        exit 1
endif
set start_time = `date +%s`
set here = $PWD
set alldir = $1
set sortdir = $here/DICOM
foreach dd ($argv)
        set bb = `basename ${dd}`
        cd ${dd}
        echo "Directory for the sorted DICOMS of ${bb} : "
        echo "                                         ${sortdir}/${bb}"
        echo "Please wait while I look though the DICOM tags"
        find ${dd} -type f | xargs dicom_hinfo -full_entry -tag 0008,103e >> atext.txt
        foreach line ("`cat ${dd}/atext.txt`")
                set idir = `echo ${line}| awk '{print $1}'`
                set ifile = `basename ${idir}`
                set odir = `echo ${line}| awk '{$1=""; print $0}' | sed 's/[[:space:]]//g'`
                if ( ! -e ${sortdir}/${bb}/${odir} ) then
                        mkdir -p ${sortdir}/${bb}/${odir}
                        echo "Now sorting to ${odir}"
                endif
                if ( -e ${sortdir}/${bb}/${odir}/${ifile} ) then
                touch ${sortdir}/${bb}/${odir}/${ifile}
                set ts = `date "+%s"`
                cp -a ${idir} ${sortdir}/${bb}/${odir}/${ifile}-${ts}
                else
                cp -a ${idir} ${sortdir}/${bb}/${odir}/${ifile}
                endif
        end
        rm ./atext.txt
        echo ""
        echo ""
        echo "Now changing the folder names to cVEDA naming conventions"
        echo ""
        echo ""
        set FLAIR = `ls -d ${sortdir}/${bb}/*FLAIR*`
        set T1w = `ls -d ${sortdir}/${bb}/*T1*`
        set T2w = `ls -d ${sortdir}/${bb}/*T2*`
        set rest = `ls -d ${sortdir}/${bb}/*REST*`
        set B0_map = `ls -d ${sortdir}/${bb}/*B0*`
        set dwi = `ls -d ${sortdir}/${bb}/*DTI*`
        mv $FLAIR ${sortdir}/${bb}/FLAIR
        mv $T1w ${sortdir}/${bb}/T1w
        mv $T2w ${sortdir}/${bb}/T2w
        mv $rest ${sortdir}/${bb}/rest
        mv $B0_map ${sortdir}/${bb}/B0_map
        mv $dwi[1] ${sortdir}/${bb}/dwi
        mv $dwi[2] ${sortdir}/${bb}/dwi_rev
        echo ""
        echo ""
        echo "Folder Names successfully changed"
        echo ""
        echo ""
        echo "Verify the number of files and the folder size for each sequence"
        echo ""
        echo "B0_map  : `ls ${sortdir}/${bb}/B0_map/* | wc -l` `du -h ${sortdir}/${bb}/B0_map` "
        echo "FLAIR   : `ls ${sortdir}/${bb}/FLAIR/* | wc -l` `du -h ${sortdir}/${bb}/FLAIR` "
        echo "T2w     : `ls ${sortdir}/${bb}/T2w/* | wc -l` `du -h ${sortdir}/${bb}/T2w` "
        echo "T1w     : `ls ${sortdir}/${bb}/T1w/* | wc -l` `du -h ${sortdir}/${bb}/T1w` "
        echo "rest    : `ls ${sortdir}/${bb}/rest/* | wc -l` `du -h ${sortdir}/${bb}/rest` "
        echo "dwi     : `ls ${sortdir}/${bb}/dwi/* | wc -l` `du -h ${sortdir}/${bb}/dwi` "
        echo "dwi_rev : `ls ${sortdir}/${bb}/dwi_rev/* | wc -l` `du -h ${sortdir}/${bb}/dwi_rev` "
        set end_time = `date +%s`
        echo ""
        echo "DICOM sorting completed in `expr $end_time - $start_time`s."
end
