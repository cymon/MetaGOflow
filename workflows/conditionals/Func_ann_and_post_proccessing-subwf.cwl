#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

  filtered_fasta: File
  rna_prediction_ncRNA: File

  cgc_results_faa: File
  protein_chunk_size_hmm: int
  protein_chunk_size_IPS: int

  func_ann_names_ips: string
  InterProScan_databases: [string, Directory]
  InterProScan_applications: string[]
  InterProScan_outputFormat: string[]
  ips_header: string

  func_ann_names_hmmer: string
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string
  HMM_database_dir: [string, Directory?]
  hmmsearch_header: string

  EggNOG_db: [string?, File?]
  EggNOG_diamond_db: [string?, File?]
  EggNOG_data_dir: [string?, Directory?]  

  go_config: [string, File]
  ko_file: [string, File]

  protein_chunk_size_eggnog: int

  threads: int
  interproscan_threads: int

outputs:
  functional_annotation_folder:
    type: Directory
    outputSource: move_to_functional_annotation_folder/out
  stats:
    outputSource: post_processing/stats
    type: Directory

steps:

  # Performs: 1. eggNOG, 2. hmmscan, 3. IPS 
  functional_annotation:
    run: ../subworkflows/functional-annotation/functional-annotation.cwl
    in:
      type: { default: "raw-reads"}
      CGC_predicted_proteins: cgc_results_faa
      chunk_size_hmm: protein_chunk_size_hmm
      chunk_size_IPS: protein_chunk_size_IPS
      name_ips: func_ann_names_ips
      name_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_database
      HMM_database_dir: HMM_database_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      chunk_size_eggnog: protein_chunk_size_eggnog
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      EggNOG_db: EggNOG_db
      threads: threads
      interproscan_threads: interproscan_threads
    out: [ hmm_result, ips_result, eggnog_annotations ]  

  # GO SUMMARY; PFAM; summaries and stats IPS, HMMScan, Pfam; add header; chunking TSV
  post_processing:
    run: ../subworkflows/functional-annotation/post-proccessing-go-pfam-stats-subwf.cwl
    in:
      fasta: filtered_fasta
      IPS_table: functional_annotation/ips_result
      go_config: go_config
      hmmscan_table: functional_annotation/hmm_result
      rna: rna_prediction_ncRNA
      cds: cgc_results_faa
      ko_file: ko_file
      hmmsearch_header: hmmsearch_header
      ips_header: ips_header
    out:
      - stats
      - summary_pfam
      - summary_ko
      - summary_ips
      - go_summary
      - go_summary_slim
      - chunked_tsvs

  # Summary for EggNOG
  eggnog_summary:
    run: ../../tools/EggNOG-Parse/eggnog_annotations.cwl
    in:
      eggnog_annotations: functional_annotation/eggnog_annotations
    out:
      [summary_eggnog]

  # Move to functional annotation
  move_to_functional_annotation_folder:
    run: ../../utils/return_directory/return_directory.cwl
    in:
      file_list:
        source:
          - post_processing/summary_ips
          - post_processing/summary_ko
          - post_processing/summary_pfam
          - post_processing/go_summary
          - post_processing/go_summary_slim
          - post_processing/chunked_tsvs
          - eggnog_summary/summary_eggnog
        linkMerge: merge_flattened
      dir_name: { default: functional-annotation }
    out: [ out ]

# Schenas
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - https://raw.githubusercontent.com/edamontology/edamontology/main/releases/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
