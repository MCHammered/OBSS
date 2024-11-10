function [idx] = Pan_Tompkins(fileName)

data = load(fileName);

zacetni_signal = data.val(1,:); % signal
dolzina = length(zacetni_signal); % dolzina signala (st. semplov)
Fs = 250; % frekvenca
N = 1:dolzina; % samples
t = N./Fs; % cas (sekunda na sample)

% 1. Low-pass filter: dvojno filtriranje

a1 = [1 -1];
b1 = [1 0 0 0 0 0 -1];

Y1 = flip(filter(b1,a1,flip(filter(b1,a1,zacetni_signal))));
Y1 = Y1/max(abs(Y1));

% 2. High-pass filtriranje

a2 = [1 1];
b2 = [1 zeros(1,15) 32 zeros(1,15) -1];
Y2 = filter(b2,a2,Y1);
Y2 = Y2./max(abs(Y2));

% 3. Odvajanje: "poravnamo" signal

b3 = [1 2 0 -2 -1].*1/8;
Y3 = conv(Y2,b3);
Y3 = Y3(4+N);
Y3 = Y3/max(abs(Y3));

% 4. Kvadriranje

Y4 = Y3.^2;
Y4 = Y4/max(Y4);

% 5. in 6. Moving window: vzamemo širino 30 

b5 = (1/30).*ones(1,30);
Y5 = conv(b5,Y4);
Y5 = Y5(29+N);
Y5 = Y5/max(Y5);

% 5. in 6. Iščemo signal peake

x=zeros(1,dolzina);         % za vnašanje vrednosti vrhov glede na indeks

tresholdI1=mean(Y5);        % treshold za zaporedno preverjanje
tresholdI2=0.5*tresholdI1;  % treshold za preverjanje za nazaj

spkI=0;                     % približek signal peakov
npkI=0;                     % približek šumov

korak = 30;                 % enako št. samplov, kot za moving window

for i=korak+1:korak:dolzina
    [M,I]=max(Y5((i-korak):i));
    if M > tresholdI1
        x(I+(i-(korak + 1)))=M;
        spkI = 0.125*M + 0.875*spkI;
    elseif M > tresholdI2
        x(I+(i-(korak + 1)))=M;
        spkI = 0.25*M + 0.75*spkI;
    else
        npkI = 0.125*M + 0.875*npkI;
    end
    tresholdI1 = npkI + 0.25 * (spkI - npkI);
    tresholdI2 = 0.5 * tresholdI1;    
end


% 7. RR intervali in T-wave modifikacija
indeksi = find(x>0);

idx = indeksi(1);
if length(indeksi) ~= 1
    for i=2:length(indeksi)
        if indeksi(i) - idx(end) < Fs/2
            if x(indeksi(i)) > x(idx(end))
                x(idx(end)) = 0;
                idx(end) = indeksi(i);
            else
                x(indeksi(i)) = 0;
            end
        else
            idx(end+1) = indeksi(i);
        end
    end
end

% isNZx=(~x==0); risanje

end


