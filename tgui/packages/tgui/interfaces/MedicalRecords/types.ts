import { BooleanLike } from 'common/react';

export type MedicalRecordData = {
  assigned_view: string;
  authenticated: BooleanLike;
  records: MedicalRecord[];
};

export type MedicalRecord = {
  age: number;
  blood_type: string;
  crew_ref: string;
  dna: string;
  gender: string;
  major_disabilities: string;
  minor_disabilities: string;
  name: string;
  notes: MedicalNote[];
  quirk_notes: string;
  rank: string;
  species: string;
  // NON-MODULAR CHANGES: Adds records to med console tgui
  old_general_records: string;
  old_medical_records: string;
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
