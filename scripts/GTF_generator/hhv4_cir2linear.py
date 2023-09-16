from Bio import SeqIO
import sys

cir_fasta=sys.argv[1]
cir_gtf=sys.argv[2]
split_point=sys.argv[3]
prefix=sys.argv[4]

split_point=int(split_point)

def split_circular_genome(fasta_path, gtf_path, split_position, output_prefix):
    # Edit the FASTA file
    with open(fasta_path, 'r') as f:
        lines = f.readlines()
        seq = ''.join([line.strip() for line in lines[1:]])
        print("seq len : " + str(len(seq)))
        

    # Adjust Annotations in GTF File
    with open(gtf_path, 'r') as f:
        lines = f.readlines()

        new_gtf_lines = []
        for line in lines:
            if line.startswith('#'):
                new_gtf_lines.append(line)
                continue

            parts = line.strip().split('\t')
            chrom, feature, start, end = parts[0], parts[2], int(parts[3]), int(parts[4])

            # Adjust coordinates if necessary
            
            if end < split_point:
                start = start + len(seq)
                end = end + len(seq)
            
            start = start - split_position
            end = end - split_position


            new_gtf_lines.append(f'{chrom}\t{parts[1]}\t{feature}\t{start}\t{end}\t{parts[5]}\t{parts[6]}\t{parts[7]}\t{parts[8]}')

    with open(f'{output_prefix}_adjusted.gtf', 'w') as f:
        f.write('\n'.join(new_gtf_lines))

split_circular_genome(cir_fasta , cir_gtf, split_point, prefix)


