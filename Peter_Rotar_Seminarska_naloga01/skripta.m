% --- THE FOLLOWING SCRIPT RUNS THE EVALUATION AND PRINTS THE AGGREGATED RESULTS ---
% (see instructions on the web classroom regarding how to calculate the Se and +P)


% Records

RECORDS = ...
    ["s20011" "s20021" "s20031" "s20041" "s20051" "s20061" "s20071" "s20081" "s20091" "s20101" ...
     "s20111" "s20121" "s20131" "s20141" "s20151" "s20161" "s20171" "s20181" "s20191" "s20201" ...
     "s20211" "s20221" "s20231" "s20241" "s20251" "s20261" "s20271" "s20272" "s20273" "s20274" ...
     "s20281" "s20291" "s20301" "s20311" "s20321" "s20331" "s20341" "s20351" "s20361" "s20371" ...
     "s20381" "s20391" "s20401" "s20411" "s20421" "s20431" "s20441" "s20451" "s20461" "s20471" ...
     "s20481" "s20491" "s20501" "s20511" "s20521" "s20531" "s20541" "s20551" "s20561" "s20571" ...
     "s20581" "s20591" "s20601" "s20611" "s20621" "s20631" "s20641" "s20651" "s30661" "s30671" ...
     "s30681" "s30691" "s30701" "s30711" "s30721" "s30731" "s30732" "s30741" "s30742" "s30751" ...
     "s30752" "s30761" "s30771" "s30781" "s30791" "s30801"];

% First remove the eval1.txt, eval2.txt, and results.txt files from the previous run.
if (isfile('eval1.txt')) delete('eval1.txt'); end
if (isfile('eval2.txt')) delete('eval2.txt'); end
if (isfile('results.txt')) delete('results.txt'); end

% For all records
for record = RECORDS
    % If the Matlab file for this record does not exist
    if (~isfile(sprintf('%sm.mat', record)))
        % Convert the record into Matlab using wfdb2mat (creates recordm.mat)
        cmd=sprintf('wfdb2mat -r %s', record);
        system(cmd);
    end

    % Delete the .asc and .qrs files from the previous run, just in case the detector
    % fails to overwrite the .asc file or if wrann fails to convert it for some reason.
    df = sprintf('%s.asc', record);
    if (isfile(df)) delete(df); end;
    df = sprintf('%s.qrs', record);
    if (isfile(df)) delete(df); end;

    % Run and evaluate the detector the this record
    Detector(record);

    % Convert the created .asc file to WFDB format using wrann
    cmd = sprintf('wrann -r %s -a qrs <%s.asc', record, record);
    system(cmd);

    % Evaluate the detector .qrs annotation against reference .atr annotations
    % and add the resulting statistics to eval1.txt and eval2.txt files.
    % Optionally, the -f 0 option forces bxb not to skip the first 5 minutes of the
    % record, although this will report a warning that can be disregarded.
    cmd = sprintf('bxb -r %s -a atr qrs -l eval1.txt eval2.txt -f 0', record);
    [status, cmdout] = system(cmd);
end

% After the run, calculate the aggregated statistics, save the results into results.txt
system('sumstats eval1.txt eval2.txt >results.txt');

% Print the results from results.txt. Note: do not use the Gross or Average
% results in the bottom two lines, you have to manually calculate Se and +P
% according to the instructions given in General notes (regarding assignments)
% available on the web classroom).
% type results.txt