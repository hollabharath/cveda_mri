Acquisition centres run these [DicomEditor](http://mircwiki.rsna.org/index.php?title=DicomEditor)
de-identification scripts to anonymize DICOM files before uploading them to the c-VEDA server.

### History

### 2017-01-04 15:58:57 UTC

* Date and time are not erased anymore:
  * Time of acqusition might be [needed for processing resting state fMRI](http://jpn.ca/vol38-issue2/38-2-84/).
  * Date of DICOM files can be cross-checked against date of acquisition when uploading to databank.

#### `MYSURU_NIMHANS`

Script for NIMHANS and MYSURU.
* Strangely anough, all the following DICOM tags are emptied. I don't know where we are supposed to find PSC1!
  * (0010,0020) _PatientID_,
  * (0010,4000) _PatientComments_,
  * (0020,4000) _ImageComments_,
  * (0040,0280) _CommentsOnPerformedProcedureStep_,

#### `CHANDIGARH_00100020_PatientID`

Specific script for CHANDIGARH.
* Eventually DICOM tag (0010,0020) _PatientID_ appears to contain PSC1. Do not empty it anymore.

### 2017-01-04 14:19:28 UTC

#### `2017-01-04`

* Empty DICOM tag (0010,0020) _PatientID_.
* The PSC1 code is supposed to be found in DICOM tag:
  * (0020,4000) _ImageComments_ at NIMHANS,
  * perhaps (0010,21B0) _AdditionalPatientHistory_ at CHANDIGARH,
  * perhaps (0040,0280) _CommentsOnPerformedProcedureStep_ at MYSURU.

### 2016-10-04 17:38:59 UTC

#### `2016-10-04`

Initial script for all acquistion centres.
* Mostly changes all occurrences of function `@empty()` into `@remove()`.
  Now original DICOM tags are not totally removed. Rather their contents are emptied.

### 2016-06-29 20:07:30 UTC

#### `2016-06-29`

Initial script for all acquisition centres.
* At this point DICOM tag (0010,0020) _PatientID_ is not removed. It is suposed to contain PSC1.
* DICOM tags (0010,4000) _PatientComments_ and (0020,4000) _ImageComments_ are removed.
