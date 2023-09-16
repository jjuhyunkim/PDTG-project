from Bio import SeqIO
import sys

from Bio import SeqIO

def extract_circular_sequence(fasta_file):
    # Read the FASTA file and assume only one sequence is present
    record = SeqIO.read(fasta_file, "fasta")
    return record.seq, record.id

def convert_coordinates(start, end, sequence_length):
    if start <= end:
        return start, end
    else:
        return start, sequence_length, 0, end

def process_feature(feature, sequence_length):
    start, end = convert_coordinates(feature.start, feature.end, sequence_length)
    return (start, end, feature.strand)

def main(circular_gtf, fasta_file, output_gtf, output_fasta):
    # Step 1: Extract circular genome sequence
    circular_sequence, record_id = extract_circular_sequence(fasta_file)
    sequence_length = len(circular_sequence)

    # Step 2: Process GTF file
    with open(circular_gtf, "r") as in_file, open(output_gtf, "w") as out_file:
        for line in in_file:
            if line.startswith("#"):
                out_file.write(line)
                continue

            fields = line.strip().split("\t")
            feature_start, feature_end, feature_strand = int(fields[3]), int(fields[4]), fields[6]

            # Adjust coordinates for features spanning the origin
            new_start, new_end = convert_coordinates(feature_start, feature_end, sequence_length)

            # Update the line and write to output GTF
            fields[3], fields[4], fields[6] = str(new_start), str(new_end), feature_strand
            out_file.write("\t".join(fields) + "\n")

    # Step 3: Write modified circular genome sequence to new FASTA file
    with open(output_fasta, "w") as out_fasta:
        out_fasta.write(f">{record_id}\n{circular_sequence}\n")

if __name__ == "__main__":
    circular_gtf = sys.argv[1]
    fasta_file = sys.argv[2]
    output_gtf = sys.argv[3]
    output_fasta = sys.argv[4]
    main(circular_gtf, fasta_file, output_gtf, output_fasta)

