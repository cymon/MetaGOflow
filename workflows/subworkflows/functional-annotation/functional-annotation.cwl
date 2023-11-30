#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2

requirements:
  ResourceRequirement:
      ramMin: 1000
      coresMin: 1
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  type: string
  CGC_predicted_proteins: File

  name_hmmer: string
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string
  HMM_database_dir: [string, Directory?]

  name_ips: string
  InterProScan_databases: [string, Directory]
  InterProScan_applications: string[]  
  InterProScan_outputFormat: string[]  

  EggNOG_db: [string?, File?]
  EggNOG_diamond_db: [string?, File?]
  EggNOG_data_dir: [string?, Directory?]
  
  threads: int
  chunk_size: int

outputs:
  hmm_result:
    type: File
    outputSource: run_hmmer/hmm_result
  ips_result:
    type: File
    outputSource: run_IPS/ips_result
  eggnog_annotations:
    outputSource: eggnog/annotations
    type: File?
  eggnog_orthologs:
    outputSource: eggnog/orthologs
    type: File?

steps:
  # Chunk faa file
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: chunk_size
    out: [ chunks ]
    run: ../../../tools/chunks/protein_chunker.cwl

  # Annotation steps
  eggnog:
    run: ../assembly/eggnog-subwf.cwl
    in:
      fasta_chunks: split_seqs/chunks
      db_diamond: EggNOG_diamond_db
      db: EggNOG_db
      data_dir: EggNOG_data_dir
      threads: threads
      file_acc:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot)
    out: [ annotations, orthologs ]

  run_IPS:
    run: ../IPS-subwf.cwl
    in:
      fasta_chunks: split_seqs/chunks
      threads: threads
      name_ips: name_ips
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      #This is just a flag to delay execution of step until eggnog finishes
      previous_step_result: eggnog/annotations
    out: [ ips_result ]

  run_hmmer:
    run: ../hmmer/hmmsearch-subwf.cwl
    in:
      fasta_chunks: split_seqs/chunks
      threads: threads
      name_hmmer: name_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_database
      HMM_database_dir: HMM_database_dir
      file_acc: 
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot)
      #This is just a flag to delay execution until IPS finishes
      previous_step_result: run_IPS/ips_result
    out: [ hmm_result ]

# Namespaces and schemas
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - https://raw.githubusercontent.com/edamontology/edamontology/main/releases/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
