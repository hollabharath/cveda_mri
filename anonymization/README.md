Acquisition centres run [DicomEditor][1] de-identification scripts to anonymize DICOM files
before uploading them to the c-VEDA server.

The syntax of these scripts is described in the [MIRC DICOM Anonymizer][2] page.

History
=======

Since initial versions of the anoymization script were distributed by mail instead of being versioned,
here is a brief history of all successive versions of the script. Dates and times refer to the moment
anonymization scripts were distributed via mail (or otherwise committed to GitHub for newer versions).

__________

### 2017-01-24 — 15:37:39 UTC

#### `MYSURU_NIMHANS_00104000_PatientComments`

Script for NIMHANS and MYSURU.
* In the latest DICOM dataset from NIMHANS acquired on 2017-01-19, the PSC1
  code is in DICOM tag (0010,4000) _PatientComments_. Do not empty anymore.

__________

### 2017-01-04 — 15:58:57 UTC

* Date and time are not erased anymore:
  * Time of acqusition might be [needed for processing resting state fMRI][3].
  * Date of DICOM files can be cross-checked against date of acquisition when uploading to databank.

#### `2017-01-04_MYSURU_NIMHANS`

Script for NIMHANS and MYSURU.
* I don't know where to look for PSC1. Strangely enough, all the following DICOM tags are emptied!
  * (0010,0020) _PatientID_,
  * (0010,4000) _PatientComments_,
  * (0020,4000) _ImageComments_,
  * (0040,0280) _CommentsOnPerformedProcedureStep_,

#### `CHANDIGARH_00100020_PatientID`

Specific script for CHANDIGARH.
* Eventually DICOM tag (0010,0020) _PatientID_ appears to contain PSC1. Do not empty it anymore.

__________

### 2017-01-04 — 14:19:28 UTC

#### `2017-01-04`

* Empty DICOM tag (0010,0020) _PatientID_.
* The PSC1 code is supposed to be found in DICOM tag:
  * (0020,4000) _ImageComments_ at NIMHANS,
  * perhaps (0010,21B0) _AdditionalPatientHistory_ at CHANDIGARH,
  * perhaps (0040,0280) _CommentsOnPerformedProcedureStep_ at MYSURU.

__________

### 2016-10-04 — 17:38:59 UTC

#### `2016-10-04`

Initial script for all acquistion centres.
* Mostly changes all occurrences of function `@empty()` into `@remove()`.
  Now original DICOM tags are not totally removed. Rather their contents are emptied.

__________

### 2016-06-29 — 20:07:30 UTC

#### `2016-06-29`

Initial script for all acquisition centres.
* At this point DICOM tag (0010,0020) _PatientID_ is not removed. It is suposed to contain PSC1.
* DICOM tags (0010,4000) _PatientComments_ and (0020,4000) _ImageComments_ are removed.

[1]: http://mircwiki.rsna.org/index.php?title=DicomEditor
[2]: http://mircwiki.rsna.org/index.php?title=The_MIRC_DICOM_Anonymizer
[3]: http://jpn.ca/vol38-issue2/38-2-84/
