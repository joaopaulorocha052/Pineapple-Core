import sys
total_memory_size = sys.argv[2]
word_size = sys.argv[3]
address_numerical_base = sys.argv[4]
data_numerical_base = sys.argv[5]

address_count = 0

with open(sys.argv[1], 'w') as mif_file:

    mif_file.write(f'DEPTH = {total_memory_size};\n')
    mif_file.write(f'WIDTH = {word_size};\n')
    mif_file.write(f'ADDRESS_RADIX = {address_numerical_base};\n')
    mif_file.write(f'DATA_RADIX = {data_numerical_base};\n')
    mif_file.write('CONTENT\n')
    mif_file.write('BEGIN\n')

    for file in sys.argv[6:]:
        with open(file, 'r') as bin_file:

            for line in bin_file:
                line_clean = line.rstrip('\n')
                formatted_string = f' {address_count} : {line_clean};\n'
                mif_file.write(formatted_string)
                address_count += 1


    if(address_count != total_memory_size):
        mif_file.write(f" [{int(address_count)+1}..{int(total_memory_size)-1}] : {32 * '0'};\n")
    mif_file.write("END;")
