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
  fasta_chunks: File[]
  threads: int?
  name_ips: string
  InterProScan_databases: [string, Directory]
  InterProScan_applications: string[]
  InterProScan_outputFormat: string[]
  file_acc: string
  previous_step_result: File?

outputs:
  ips_result:
    type: File
    outputSource: combine_ips/result

steps:
  # << InterProScan >>
  interproscan:
    scatter: inputFile
    in:
      inputFile: fasta_chunks
      applications: InterProScan_applications
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
      threads:
        source: fasta_chunks
        valueFrom: $(Math.floor(inputs.threads/self.length))
    out: [ i5Annotations ]
    run: ../../tools/InterProScan/InterProScan-v5.cwl
    label: "InterProScan: protein sequence classifier"

  combine_ips:
    in:
      files: interproscan/i5Annotations
      outputFileName:
        source: file_acc
        valueFrom: $(self.split('_CDS')[0])
      postfix: name_ips
    out: [ result ]
    run: ../../utils/concatenate.cwl

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
