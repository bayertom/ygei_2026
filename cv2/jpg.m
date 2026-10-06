
clc
clear

%Read file
%raster = imread('s:/K155/Public/155YGEI/2026/cv2/Image1.bmp')


%Show image
imshow(raster)

%Get components
R = double(raster(:, :, 1));
G = double(raster(:, :, 2));
B = double(raster(:, :, 3));

%Conversion RGB to YCbCr
Y = 0.299 * R + 0.587 * G + 0.114 * B;
Cb = -0.1687 * R -0.3313 * G + 0.5 * B + 128;
Cr = 0.5 * R -0.4187 * G - 0.0813 * B + 128;

%Quantisation matrix: Y
QY = [16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 87 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 26 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99];

%Quantisation matrix: Cb, Cr
QC = [17 18 24 47 66 99 99 99
    18 21 26 66 99 99 99 99
    24 26 56 99 99 99 99 99
    47 69 99 99 99 99 99 99
    99 99 99 99 99 99 99 99
    99 99 99 99 99 99 99 99
    99 99 99 99 99 99 99 99
    99 99 99 99 99 99 99 99];

%Compression factor
q = 50;
QY = (50 * QY) / q;
QC = (50 * QC) / q;

%DCT
Yt_t = mydct(Y, QY);
Cb_t = mydct(Cb, QC);
Cr_t = mydct(Cr, QC);

%IDCT




function [Rt] = mydct(R, Q)
    %DCT of entire raster
    [m, n] = size(R);
    Rt  = R;
    
    %Divide raster to submatrices
    for i = 1:8:m -7
        for j = 1:8:n -7
            %Get submatrix
            R_sub = R(i:i+7, j:j+7);
    
            %Compute DCT
            R_sub_dct = mydctsub(R_sub);
    
            %Quantization
            R_sub_quant = R_sub_dct ./ Q;
            R_sub_quant = round(R_sub_quant);
    
            %Replace submatrix
            Rt(i:i+7, j:j+7) = R_sub_quant;
    
        end
    end

end


function [Rt] = mydctsub(R)
    % Discrete cosine transformation for a 8 x 8 matrix
    Rt = R;
    
    %Output raster: rows
    for u = 0:7
    
        % Set cu
        if u == 0
            cu = sqrt(2)/2;
        else
            cu = 1;
        end
    
        %Output raster: columns
        for v = 0:7
    
            % Set cv
            if v == 0
                cv = sqrt(2)/2;
            else
                cv = 1;
            end
    
            % Reset sum for this (u,v)
            F = 0;
    
            %Input raster: rows
            for x = 0:7
                %Input raster: columns
                for y = 0:7
                    F = F + 1/4 * cu * cv * R(x+1, y+1) * cos((2*x+1)*u*pi/16) * cos((2*y+1)*v*pi/16);
                end
            end
    
            % Store DCT coefficient
            Rt(u+1,v+1) = F;
    
        end
    end
end


