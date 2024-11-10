function Canny_algoritem(I)
    slika = im2double(imread(I));
    [n,m] = size(slika);
    
    % originalna slika
    figure; imshow(slika, []); title('Originalna slika');

    % Roberts
    kernel_x = [-1 1];
    kernel_y = [-1; 1];
    
    % Gauss
    sigma = min(size(slika))*0.005;
    slika = imgaussfilt(slika, sigma);
    
    gx = conv2(slika,kernel_x,'same');
    gy = conv2(slika,kernel_y,'same');
    
    % magnituda in kot posameznih tock
    mag = sqrt(gx.^2 + gy.^2);
    ang = atan2d(gy, gx);
    
    %% Nonmaxima supression
    
    % robne tocke
    mag(1,:) = 0;
    mag(end,:) = 0;
    mag(:,1) = 0;
    mag(:,end) = 0;
    
    mag2 = mag;
    for i=2:n-1
        for j=2:m-1
            kot = ang(i,j);
            if (-22.5 <= kot && kot <= 22.5) || (157.5 < kot || kot < -157.5)
                if mag2(i,j) < mag(i,j-1) || mag2(i,j) < mag(i,j+1)
                    mag2(i,j) = 0;
                end
            end
             if (22.5 <= kot && kot < 67.5) || (-157.5 <= kot && kot < -112.5)
                if mag2(i,j) < mag(i-1,j-1) || mag2(i,j) < mag(i+1,j+1)
                    mag2(i,j) = 0;
                end
             end
             if (67.5 <= kot && kot < 112.5) || (-112.5 <= kot && kot < -67.5)
                if mag2(i,j) < mag(i-1,j) || mag2(i,j) < mag(i+1,j)
                    mag2(i,j) = 0;
                end
             end
             if (112.5 <= kot && kot < 157.5) || (-67.5 <= kot && kot <= -22.5)
                if mag2(i,j) < mag(i+1,j-1) || mag2(i,j) < mag(i-1,j+1)
                    mag2(i,j) = 0;
                end
             end
        end
    end
    
    mag = mag2;

    % Slika poiskanih robov
    figure; imshow(mag, []); title('Slika po detekciji robov');
    
    %% Hysteresis thresholding
    maksimum = max(max(mag));
    value = sort(mag(:), 'descend');
    tresholdH = min(value(1:5000));
    tresholdL = tresholdH/2;
    
    mag(mag<=tresholdL) = 0;
    mag(mag>=tresholdH) = maksimum;
    % Vzamemo tocke, ki so nad high tresholdom
    indeksna_matrika = (mag>=tresholdH);
    while (sum(sum(indeksna_matrika)) > 0)
        [k,l] = find(indeksna_matrika==1);
        for i=1:length(k)
            A = mag(k(i)-1:k(i)+1,l(i)-1:l(i)+1);
            indeksnaA = indeksna_matrika(k(i)-1:k(i)+1,l(i)-1:l(i)+1);
            for r=1:3
                for s=1:3
                    if A(r,s) > tresholdL && A(r,s) < tresholdH
                        A(r,s) = maksimum;
                        indeksnaA(r,s) = 1;
                    end
                end
            end
        mag(k(i)-1:k(i)+1,l(i)-1:l(i)+1) = A;
        indeksna_matrika(k(i)-1:k(i)+1,l(i)-1:l(i)+1) = indeksnaA;
        indeksna_matrika(k(i),l(i)) = 0;
        end
    end
    
    mag(mag<tresholdH) = 0;

    % slika po edge linkingu
    figure; imshow(mag,[]); title('Slika po edge linkingu');

    % shranimo sliko
    ime_slike = erase(I,'.png');
    imwrite(imbinarize(mag),append(ime_slike,'_binarized.png'));
end