import { BooleanLike } from 'common/react';

export type MedicalRecordData = {
  assigned_view: string;
  authenticated: BooleanLike;
<<<<<<< HEAD
=======
  station_z: BooleanLike;
  physical_statuses: string[];
  mental_statuses: string[];
>>>>>>> 73172f8836525 (Re-implements Physical and Mental statuses in crewmember Medical Records (#73882))
  records: MedicalRecord[];
  min_age: number;
  max_age: number;
};

export type MedicalRecord = {
  age: number;
  blood_type: string;
  crew_ref: string;
  dna: string;
  gender: string;
  major_disabilities: string;
  minor_disabilities: string;
  physical_status: string;
  mental_status: string;
  name: string;
  notes: MedicalNote[];
  quirk_notes: string;
  rank: string;
  species: string;
  // NON-MODULAR CHANGES: Adds med records to TGUI
  old_general_records: string;
  old_medical_records: string;
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
