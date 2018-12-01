Imaging operations are documented in the [cVEDA MRI Scanner Protocol](https://cveda.org/standard-operating-procedures/).

Basic information is available from the [project wiki](https://github.com/cveda/cveda_mri/wiki).

##### `protocols`

MRI protocols used by each acquisiton centres, when possible in the form of an EDX file for Siemens
scanners and an ExamCard for Philips scanner, and as a human-readable export in PDF or text format.

##### `qc`

QC procedure to be followed locally at each MRI acqusition centre, before pushing imaging datasets
to the c-VEDA upload server.

##### `anonymization`

[DicomEditor](http://mircwiki.rsna.org/index.php?title=DicomEditor) de-identification script applied
to DICOM files after MRI acquisition and before pushing datasets to the c-VEDA upload server.
