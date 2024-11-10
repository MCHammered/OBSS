function Detector(record)
  % Summary of this function and detailed explanation goes here

  % First convert the record into matlab (creates recordm.mat):
  % wfdb2mat -r record
  % .hea, .atr in .dat

  % wrann -r s20641 -a qrs <s20641.asc
  % bxb -r s30801 -a atr qrs -l eval1.txt eval2.txt -f 0
  % sumstats eval1.txt eval2.txt >results.txt


  fileName = sprintf('%sm.mat', record);
  idx = Pan_Tompkins(fileName);
  asciName = sprintf('%s.asc',record);
  fid = fopen(asciName, 'wt');
  for i=1:size(idx,2)
      fprintf(fid,'0:00:00.00 %d N 0 0 0\n', idx(1,i) );
  end
  fclose(fid);

  % Now convert the .asc text output to binary WFDB format:
  % wrann -r record -a qrs <record.asc
  % And evaluate against reference annotations (atr) using bxb:
  % bxb -r record -a atr qrs
end
