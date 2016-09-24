
load coordenadas.txt

M = coordenadas';

M2 =  = M * 2^(N-2) * (1 - 2^(-N_bits_row+1));

fid = fopen(file_name, "w");
fwrite(fid, M2, "int16", "ieee-le");
fclose(fid);
