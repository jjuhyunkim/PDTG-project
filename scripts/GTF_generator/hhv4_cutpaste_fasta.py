import sys

inputFasta=sys.argv[1]
outputFasta=sys.argv[2]
splitPoint=sys.argv[3]


def cut_and_paste_fasta(input_file, output_file, cut_length):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    header = lines[0].strip()
    sequence = ''.join([line.strip() for line in lines[1:]])

    cut_sequence = sequence[:cut_length]
    remaining_sequence = sequence[cut_length:]

    new_sequence = remaining_sequence + cut_sequence

    with open(output_file, 'w') as f:
        f.write(f'{header}\n')
        f.write('\n'.join([new_sequence[i:i+80] for i in range(0, len(new_sequence), 80)]))

# Example usage
cut_and_paste_fasta(inputFasta, outputFasta, int(splitPoint))
