Acquisition centres run [DicomEditor][1] de-identification scripts to anonymize DICOM files
before uploading them to the c-VEDA server.
The syntax of these scripts is described in the [MIRC DICOM Anonymizer][2] page.
Our strategy is to:
* start with the default `dicom-anonymizer.script` bundled with [DicomEditor][1],
  which is supposed to implement the `Basic Profile` described in [DICOM PS3.15][4],
  [Table E.1-1 Application Level Confidentiality Profile Attributes][5]
* keep dates and time as described in column `Rtn. Long. Full Dates Opt.`,
* keep the attribute that holds the PSC1 code.

History
=======

Since initial versions of the anoymization script were distributed by mail instead of being versioned,
here is a brief history of all successive versions of the script. Dates and times refer to the moment
anonymization scripts were distributed via mail (or otherwise committed to GitHub for newer versions).

### 2018-03-23 — 18:00:00 UTC

#### `NIMHANS`

Empty:
* `(0008,1030)` *Study Description*

__________

### 2018-03-22 — 22:00:00 UTC

#### `PGIMER`

Empty instead of hashing:
* `(0010,0010)` *Patient Name*
* `(0010,0030)` *Patient Birth Date*

#### `MYSORE`

Empty instead of hashing:
* `(0010,0010)` *Patient Name*
* `(0010,0020)` *Patient ID*
* `(0010,0030)` *Patient Birth Date*

#### `archives/2018-03-22_NIMHANS`

Empty instead of hashing:
* `(0010,0010)` *Patient Name*
* `(0010,0020)` *Patient ID*
* `(0010,0030)` *Patient Birth Date*

__________

### 2018-03-12 — 14:00:00 UTC

#### `archives/2018-03-12_CHANDIGARH`

In an attempt to standardize, merge vanilla `DICOM-PS3.15E-FullDates` and
previous `CHANDIGARH` file. Make sure a few additional attributes are
removed or kept and the PSC1 code is kept:
* `(0010,0020)` *Patient ID*

#### `archives/2018-03-12_MYSORE`

In an attempt to standardize, merge vanilla `DICOM-PS3.15E-FullDates` and
previous `CHANDIGARH` file. Make sure a few additional attributes are
removed or kept and the PSC1 code is kept:
* `(0040,0280)` *Comments on the Performed Procedure Step*

#### `archives/2018-03-12_NIMHANS`

In an attempt to standardize, merge vanilla `DICOM-PS3.15E-FullDates` and
previous `CHANDIGARH` file. Make sure a few additional attributes are
removed or kept and the PSC1 code is kept:
* `(0010,4000)` *Patient Comments*
* `(0032,4000)` *Study Comments*

__________

### 2018-03-12 — 12:00:00 UTC

#### `DICOM-PS3.15E-Basic`

The default `dicom-anonymizer.script` bundled with [DicomEditor][1] that is
supposed to implement the `Basic Profile` described in [DICOM PS3.15][4],
[Table E.1-1 Application Level Confidentiality Profile Attributes][5].

#### `DICOM-PS3.15E-FullDates`

The default `dicom-anonymizer.script` modified as suggested in column
`Rtn. Long. Full Dates Opt.` of [DICOM PS3.15][4],
[Table E.1-1 Application Level Confidentiality Profile Attributes][5].

__________

### 2018-02-21 — 06:05:46 UTC

#### `archives/2018-02-21_CHANDIGARH`

Thamodaran provided the script currently in use in PGIMER. It had
diverged from the reference script on GitHub.

#### `archives/2018-02-21_MYSORE`

Thamodaran provided the script currently in use in MYSORE. It had
diverged from the reference script on GitHub.

#### `archives/2018-02-21_NIMHANS`

Thamodaran provided the script currently in use in NIMHANS with both the
Philips and Siemens scanners. It had diverged from the reference script
on GitHub.

__________

### 2017-11-07 — 05:55:55 UTC

#### `archives/2017-11-07_NIMHANS_00081500_AttendingPhysiciansName`

Script for the Philips scanner at NIMHANS.

__________

### 2017-01-24 — 15:37:39 UTC

#### `archives/2017-01-24_MYSORE_NIMHANS_00104000_PatientComments`

Script for NIMHANS and MYSORE.
* In the latest DICOM dataset from NIMHANS acquired on 2017-01-19, the PSC1
  code is in DICOM tag (0010,4000) _PatientComments_. Do not empty anymore.

__________

### 2017-01-04 — 15:58:57 UTC

* Date and time are not erased anymore:
  * Time of acqusition might be [needed for processing resting state fMRI][3].
  * Date of DICOM files can be cross-checked against date of acquisition when uploading to databank.

#### `archives/2017-01-04_MYSORE_NIMHANS`

Script for NIMHANS and MYSORE.
* I don't know where to look for PSC1. Strangely enough, all the following DICOM tags are emptied!
  * (0010,0020) _PatientID_,
  * (0010,4000) _PatientComments_,
  * (0020,4000) _ImageComments_,
  * (0040,0280) _CommentsOnPerformedProcedureStep_,

#### `archives/2017-01-14_CHANDIGARH_00100020_PatientID`

Specific script for PGIMER.
* Eventually DICOM tag (0010,0020) _PatientID_ appears to contain PSC1. Do not empty it anymore.

__________

### 2017-01-04 — 14:19:28 UTC

#### `archives/2017-01-04`

* Empty DICOM tag (0010,0020) _PatientID_.
* The PSC1 code is supposed to be found in DICOM tag:
  * (0020,4000) _ImageComments_ at NIMHANS,
  * perhaps (0010,21B0) _AdditionalPatientHistory_ at PGIMER,
  * perhaps (0040,0280) _CommentsOnPerformedProcedureStep_ at MYSORE.

__________

### 2016-10-04 — 17:38:59 UTC

#### `archives/2016-10-04`

Initial script for all acquistion centres.
* Mostly changes all occurrences of function `@empty()` into `@remove()`.
  Now original DICOM tags are not totally removed. Rather their contents are emptied.

__________

### 2016-06-29 — 20:07:30 UTC

#### `archives/2016-06-29`

Initial script for all acquisition centres.
* At this point DICOM tag (0010,0020) _PatientID_ is not removed. It is suposed to contain PSC1.
* DICOM tags (0010,4000) _PatientComments_ and (0020,4000) _ImageComments_ are removed.

[1]: http://mircwiki.rsna.org/index.php?title=DicomEditor
[2]: http://mircwiki.rsna.org/index.php?title=The_MIRC_DICOM_Anonymizer
[3]: http://jpn.ca/vol38-issue2/38-2-84/
[4]: http://dicom.nema.org/medical/dicom/current/output/html/part15.html
[5]: http://dicom.nema.org/medical/dicom/current/output/html/part15.html#table_E.1-1
